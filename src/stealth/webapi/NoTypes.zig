// STEALTHPANDA: registry placeholder that registers no types. Used by the
// bridge type registry when build_config.stealth_surface is on and a list
// slot must contribute nothing (the stealth Plugins module already covers
// those types in a single entry). See bridge.zig PageJsApis.
// New file in the stealthpanda fork (AGPL-3.0).

pub fn registerTypes() []const type {
    return &.{};
}
