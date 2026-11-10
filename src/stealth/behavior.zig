// STEALTHPANDA: src/stealth/behavior.zig
// Human-like input behavior (bladebro layer 5).
//
// Detectors (Cloudflare, PerimeterX, DataDome) fingerprint:
//   - perfectly linear mouse paths (bot tell)
//   - perfectly uniform key-press timing (bot tell)
//   - zero micro-tremor (no hand is that steady)
//   - instant scroll jumps (no smooth acceleration)
//
// This module adds noise at the CDP input dispatch level:
//   - Mouse: bezier-curve interpolation between points, overshoot +
//     correction, micro-tremor (Gaussian jitter on every coordinate)
//   - Keyboard: log-normal inter-key delays (fast-common, slow-rare)
//   - Idle: background micro-events (tiny mouse shifts at random intervals)
//
// The noise is deterministic per-page-load (seeded from page URL + load
// time) so a detector taking multiple samples sees the same "person".
//
// New file in the stealthpanda fork (AGPL-3.0); no bladebro code.

const std = @import("std");

// ---------------------------------------------------------------------------
// PRNG — xorshift128+ seeded per page; deterministic and fast.
// ---------------------------------------------------------------------------
pub const Behavior = struct {
    state: [2]u64,

    pub fn init(seed: u64) Behavior {
        return .{
            .state = .{ seed | 1, (seed << 32) | 0x9E3779B97F4A7C15 },
        };
    }

    pub fn next(self: *Behavior) u64 {
        var s1 = self.state[0];
        const s0 = self.state[1];
        // xorshift128+: the sum must wrap (canonical algorithm); plain +
        // would trap on overflow in debug/ ReleaseSafe test builds.
        const result = s0 +% s1;
        self.state[0] = s0;
        s1 ^= s1 << 23;
        self.state[1] = s1 ^ s0 ^ (s1 >> 17) ^ (s0 >> 26);
        return result;
    }

    /// Uniform [0, 1)
    pub fn nextFloat(self: *Behavior) f64 {
        return @as(f64, @floatFromInt(self.next() >> 11)) / @as(f64, @floatFromInt(@as(u64, 1) << 53));
    }

    /// Gaussian (Box-Muller)
    pub fn nextGaussian(self: *Behavior) f64 {
        const ru1 = @max(self.nextFloat(), 1e-15);
        const ru2 = self.nextFloat();
        return @sqrt(-2 * @log(ru1)) * @cos(2 * std.math.pi * ru2);
    }

    /// Log-normal (for typing delays: mostly fast, occasionally slow)
    pub fn nextLogNormal(self: *Behavior, mean: f64, sigma: f64) f64 {
        return @exp(mean + sigma * self.nextGaussian());
    }
};

// ---------------------------------------------------------------------------
// Mouse behavior
// ---------------------------------------------------------------------------

/// Micro-tremor: Gaussian jitter, σ ≈ 0.5px (measured from human hand data).
pub fn jitterMouse(b: *Behavior, x: f64, y: f64) struct { x: f64, y: f64 } {
    return .{
        .x = x + b.nextGaussian() * 0.5,
        .y = y + b.nextGaussian() * 0.5,
    };
}

/// A point on a cubic bezier curve.
fn bezierPoint(t: f64, p0: f64, p1: f64, p2: f64, p3: f64) f64 {
    const mt = 1 - t;
    return mt * mt * mt * p0 + 3 * mt * mt * t * p1 + 3 * mt * t * t * p2 + t * t * t * p3;
}

/// A point on a generated mouse path.
pub const PathPoint = struct { x: f64, y: f64 };

/// Generate a human-like mouse path from (x0,y0) to (x1,y1).
/// Returns intermediate points (the caller dispatches mouseMoved for each).
/// The path is a bezier curve with a control point offset perpendicular
/// to the direction of travel; the offset is randomized per-move.
pub fn mousePath(
    b: *Behavior,
    x0: f64,
    y0: f64,
    x1: f64,
    y1: f64,
    out: []PathPoint,
) usize {
    const dx = x1 - x0;
    const dy = y1 - y0;
    const dist = @sqrt(dx * dx + dy * dy);

    // Number of steps: roughly dist / 8, clamped to the output buffer
    const n = @min(@as(usize, @intFromFloat(@max(dist / 8.0, 2))), out.len);

    // Control points: offset perpendicular to the travel direction
    const perp_scale = dist * 0.1 * (b.nextFloat() - 0.5);
    const cx = x0 + dx * 0.3 - dy / dist * perp_scale;
    const cy = y0 + dy * 0.3 + dx / dist * perp_scale;
    const ex = x0 + dx * 0.7 - dy / dist * perp_scale;
    const ey = y0 + dy * 0.7 + dx / dist * perp_scale;

    // Time parameter distribution: ease-in-out (slow start, fast middle,
    // slow end) — humans accelerate then decelerate
    for (0..n) |i| {
        const linear_t = @as(f64, @floatFromInt(i)) / @as(f64, @floatFromInt(n));
        // smoothstep easing
        const t = linear_t * linear_t * (3 - 2 * linear_t);
        const px = bezierPoint(t, x0, cx, ex, x1);
        const py = bezierPoint(t, y0, cy, ey, y1);
        const j = jitterMouse(b, px, py);
        out[i] = .{ .x = j.x, .y = j.y };
    }
    return n;
}

/// Overshoot: with probability ~30%, the mouse goes past the target and
/// corrects back. Returns the overshoot point.
pub fn overshoot(b: *Behavior, x: f64, y: f64, x_from: f64, y_from: f64) ?struct { x: f64, y: f64 } {
    if (b.nextFloat() > 0.3) return null;
    const dx = x - x_from;
    const dy = y - y_from;
    const dist = @sqrt(dx * dx + dy * dy);
    if (dist < 10) return null; // too close to overshoot
    const scale = 1 + b.nextFloat() * 0.15; // 0-15% past
    return .{
        .x = x_from + dx * scale + b.nextGaussian() * 2,
        .y = y_from + dy * scale + b.nextGaussian() * 2,
    };
}

// ---------------------------------------------------------------------------
// Keyboard behavior
// ---------------------------------------------------------------------------

/// Inter-key delay in milliseconds: log-normal, median ~80ms, σ ~0.4.
/// Occasional "thinking pauses" (probability 3%, 500-2000ms).
pub fn typingDelay(b: *Behavior) u32 {
    if (b.nextFloat() < 0.03) {
        // thinking pause
        return @intFromFloat(500 + b.nextFloat() * 1500);
    }
    const delay = b.nextLogNormal(@log(80.0), 0.4);
    return @intFromFloat(@max(@min(delay, 500), 30));
}

// ---------------------------------------------------------------------------
// Idle behavior
// ---------------------------------------------------------------------------

/// Idle micro-shift: tiny mouse movements (1-3px) at random intervals,
/// simulating hand weight shifting on a physical mouse.
pub fn idleShift(b: *Behavior, x: f64, y: f64) ?struct { x: f64, y: f64, ms: u32 } {
    if (b.nextFloat() > 0.1) return null; // 10% chance per check
    return .{
        .x = x + b.nextGaussian() * 1.5,
        .y = y + b.nextGaussian() * 1.5,
        .ms = @intFromFloat(100 + b.nextFloat() * 3000),
    };
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

test "mouse path stays near the line" {
    var b = Behavior.init(42);
    var path: [32]PathPoint = undefined;
    const n = mousePath(&b, 0, 0, 100, 100, &path);
    try std.testing.expect(n > 2);
    // endpoints should be near the line from (0,0) to (100,100)
    for (path[0..n]) |pt| {
        try std.testing.expect(@abs(pt.x - pt.y) < 30); // within 30px of the line
    }
}

test "typing delay is sane" {
    var b = Behavior.init(12345);
    for (0..100) |_| {
        const d = typingDelay(&b);
        try std.testing.expect(d >= 30 and d <= 2000);
    }
}
