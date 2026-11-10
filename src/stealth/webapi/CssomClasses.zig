// STEALTHPANDA: src/stealth/webapi/CssomClasses.zig
// The CSSOM interface classes Chrome exposes that stock lightpanda lacks.
//
// Reference behavior (Chrome 157): every one of these is a function on
// window — StyleSheet, MediaList, CSSMediaRule, CSSImportRule,
// CSSGroupingRule, CSSKeyframesRule, CSSSupportsRule (plus the existing
// CSSRule/CSSStyleRule/CSSStyleSheet). Scripts feature-probe them
// (typeof X === 'function') and use them as instanceof targets
// (`sheet.cssRules[i] instanceof CSSMediaRule`). Absent globals made
// `x instanceof X` throw "Right-hand side of 'instanceof' is not an
// object" on williams-sonoma AND macys (Akamai boot script da()).
//
// Presence-grade: correct class shape (name, toString, prototype);
// Chrome never constructs these from script.
//
// New file in the stealthpanda fork (AGPL-3.0); no bladebro code.

const js = @import("../../browser/js/js.zig");

pub fn registerTypes() []const type {
    return &.{
        StyleSheet,
        MediaList,
        CSSMediaRule,
        CSSImportRule,
        CSSGroupingRule,
        CSSKeyframesRule,
        CSSSupportsRule,
    };
}

/// Abstract base of CSSStyleSheet — present as a global in Chrome.
pub const StyleSheet = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(StyleSheet);

        pub const Meta = struct {
            pub const name = "StyleSheet";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// MediaList (media query lists on stylesheets/media rules).
pub const MediaList = struct {
    _pad: bool = false,

    fn item(_: *const MediaList, _: u32) ?[]const u8 {
        return null;
    }

    fn getLength(_: *const MediaList) u32 {
        return 0;
    }

    fn getMediaText(_: *const MediaList) []const u8 {
        return "";
    }

    pub const JsApi = struct {
        pub const bridge = js.Bridge(MediaList);

        pub const Meta = struct {
            pub const name = "MediaList";
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const item = bridge.function(MediaList.item, .{});
        pub const length = bridge.accessor(MediaList.getLength, null, .{});
        pub const mediaText = bridge.accessor(MediaList.getMediaText, null, .{});
    };
};

/// @media rule. Extends CSSGroupingRule in Chrome.
pub const CSSMediaRule = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSMediaRule);

        pub const Meta = struct {
            pub const name = "CSSMediaRule";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// @import rule.
pub const CSSImportRule = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSImportRule);

        pub const Meta = struct {
            pub const name = "CSSImportRule";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// Base of CSSMediaRule/CSSSupportsRule (grouping rules have cssRules).
pub const CSSGroupingRule = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSGroupingRule);

        pub const Meta = struct {
            pub const name = "CSSGroupingRule";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// @keyframes rule.
pub const CSSKeyframesRule = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSKeyframesRule);

        pub const Meta = struct {
            pub const name = "CSSKeyframesRule";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// @supports rule.
pub const CSSSupportsRule = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSSupportsRule);

        pub const Meta = struct {
            pub const name = "CSSSupportsRule";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};
