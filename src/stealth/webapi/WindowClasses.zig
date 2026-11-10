// STEALTHPANDA: src/stealth/webapi/WindowClasses.zig
// Presence-grade window classes Chrome exposes that stock lightpanda lacks.
//
// Generated from the measured Chrome-vs-lightpanda window diff (120
// classes: CSS rule/typed-OM types, SVG filter/animation types, WebGL
// object types, misc HTML elements). Sensors enumerate these
// (typeof / instanceof) � Akamai's boot script registers a fixed class
// list and crashes with "Right-hand side of 'instanceof' is not an
// object" when any is undefined (macys, williams-sonoma traces).
//
// Presence-grade: correct class shape (name, toString, prototype);
// these interfaces are not constructible from script in Chrome.
//
// New file in the stealthpanda fork (AGPL-3.0); no bladebro code.

const js = @import("../../browser/js/js.zig");

pub fn registerTypes() []const type {
    return &.{
        CSSAnimation,
        CSSConditionRule,
        CSSContainerRule,
        CSSCounterStyleRule,
        CSSFontFaceRule,
        CSSFontFeatureValuesRule,
        CSSFontPaletteValuesRule,
        CSSFunctionDeclarations,
        CSSFunctionDescriptors,
        CSSFunctionRule,
        CSSKeyframeRule,
        CSSLayerBlockRule,
        CSSLayerStatementRule,
        CSSMarginRule,
        CSSNamespaceRule,
        CSSNestedDeclarations,
        CSSPageRule,
        CSSPropertyRule,
        CSSPseudoElement,
        CSSScopeRule,
        CSSStartingStyleRule,
        CSSViewTransitionRule,
        CSSPositionTryDescriptors,
        CSSPositionTryRule,
        CSSImageValue,
        CSSKeywordValue,
        CSSMathClamp,
        CSSMathInvert,
        CSSMathMax,
        CSSMathMin,
        CSSMathNegate,
        CSSMathProduct,
        CSSMathSum,
        CSSMathValue,
        CSSMatrixComponent,
        CSSNumericArray,
        CSSNumericValue,
        CSSPerspective,
        CSSPositionValue,
        CSSRotate,
        CSSScale,
        CSSSkew,
        CSSSkewX,
        CSSSkewY,
        CSSStyleValue,
        CSSTransition,
        CSSTransformComponent,
        CSSTransformValue,
        CSSTranslate,
        CSSUnitValue,
        CSSUnparsedValue,
        CSSVariableReferenceValue,
        HTMLCameraElement,
        HTMLGeolocationElement,
        HTMLMenuElement,
        HTMLMicrophoneElement,
        HTMLSelectedContentElement,
        HTMLUserMediaElement,
        SVGAnimateElement,
        SVGAnimateMotionElement,
        SVGAnimateTransformElement,
        SVGAnimatedAngle,
        SVGAnimatedBoolean,
        SVGAnimatedInteger,
        SVGAnimatedLengthList,
        SVGAnimatedNumberList,
        SVGAnimatedRect,
        SVGAnimationElement,
        SVGComponentTransferFunctionElement,
        SVGFEBlendElement,
        SVGFEColorMatrixElement,
        SVGFEComponentTransferElement,
        SVGFECompositeElement,
        SVGFEConvolveMatrixElement,
        SVGFEDiffuseLightingElement,
        SVGFEDisplacementMapElement,
        SVGFEDistantLightElement,
        SVGFEDropShadowElement,
        SVGFEFloodElement,
        SVGFEFuncAElement,
        SVGFEFuncBElement,
        SVGFEFuncGElement,
        SVGFEFuncRElement,
        SVGFEGaussianBlurElement,
        SVGFEImageElement,
        SVGFEMergeElement,
        SVGFEMergeNodeElement,
        SVGFEMorphologyElement,
        SVGFEOffsetElement,
        SVGFEPointLightElement,
        SVGFESpecularLightingElement,
        SVGFESpotLightElement,
        SVGFETileElement,
        SVGFETurbulenceElement,
        SVGFilterElement,
        SVGLengthList,
        SVGMPathElement,
        // STEALTHPANDA: SVGMatrix/SVGPoint/SVGRect moved to real legacy
        // aliases of DOMMatrix/DOMPoint/DOMRect (see those files'
        // Meta.constructor_alias) — presence-grade stubs here broke
        // instanceof (getBBox()/getPointAtLength() results vs the window
        // globals); the aliases share the prototype so instanceof holds,
        // matching Chrome.
        SVGNumberList,
        SVGScriptElement,
        SVGSetElement,
        SVGStyleElement,
        SVGUnitTypes,
        WebGLActiveInfo,
        WebGLBuffer,
        WebGLContextEvent,
        WebGLFramebuffer,
        WebGLObject,
        WebGLProgram,
        WebGLQuery,
        WebGLRenderbuffer,
        WebGLSampler,
        WebGLShader,
        WebGLSync,
        WebGLTexture,
        WebGLTransformFeedback,
        WebGLUniformLocation,
        WebGLVertexArrayObject,
    };
}

/// CSSAnimation � presence-grade (Chrome window global).
pub const CSSAnimation = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSAnimation);

        pub const Meta = struct {
            pub const name = "CSSAnimation";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// CSSConditionRule � presence-grade (Chrome window global).
pub const CSSConditionRule = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSConditionRule);

        pub const Meta = struct {
            pub const name = "CSSConditionRule";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// CSSContainerRule � presence-grade (Chrome window global).
pub const CSSContainerRule = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSContainerRule);

        pub const Meta = struct {
            pub const name = "CSSContainerRule";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// CSSCounterStyleRule � presence-grade (Chrome window global).
pub const CSSCounterStyleRule = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSCounterStyleRule);

        pub const Meta = struct {
            pub const name = "CSSCounterStyleRule";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// CSSFontFaceRule � presence-grade (Chrome window global).
pub const CSSFontFaceRule = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSFontFaceRule);

        pub const Meta = struct {
            pub const name = "CSSFontFaceRule";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// CSSFontFeatureValuesRule � presence-grade (Chrome window global).
pub const CSSFontFeatureValuesRule = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSFontFeatureValuesRule);

        pub const Meta = struct {
            pub const name = "CSSFontFeatureValuesRule";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// CSSFontPaletteValuesRule � presence-grade (Chrome window global).
pub const CSSFontPaletteValuesRule = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSFontPaletteValuesRule);

        pub const Meta = struct {
            pub const name = "CSSFontPaletteValuesRule";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// CSSFunctionDeclarations � presence-grade (Chrome window global).
pub const CSSFunctionDeclarations = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSFunctionDeclarations);

        pub const Meta = struct {
            pub const name = "CSSFunctionDeclarations";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// CSSFunctionDescriptors � presence-grade (Chrome window global).
pub const CSSFunctionDescriptors = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSFunctionDescriptors);

        pub const Meta = struct {
            pub const name = "CSSFunctionDescriptors";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// CSSFunctionRule � presence-grade (Chrome window global).
pub const CSSFunctionRule = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSFunctionRule);

        pub const Meta = struct {
            pub const name = "CSSFunctionRule";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// CSSKeyframeRule � presence-grade (Chrome window global).
pub const CSSKeyframeRule = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSKeyframeRule);

        pub const Meta = struct {
            pub const name = "CSSKeyframeRule";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// CSSLayerBlockRule � presence-grade (Chrome window global).
pub const CSSLayerBlockRule = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSLayerBlockRule);

        pub const Meta = struct {
            pub const name = "CSSLayerBlockRule";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// CSSLayerStatementRule � presence-grade (Chrome window global).
pub const CSSLayerStatementRule = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSLayerStatementRule);

        pub const Meta = struct {
            pub const name = "CSSLayerStatementRule";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// CSSMarginRule � presence-grade (Chrome window global).
pub const CSSMarginRule = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSMarginRule);

        pub const Meta = struct {
            pub const name = "CSSMarginRule";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// CSSNamespaceRule � presence-grade (Chrome window global).
pub const CSSNamespaceRule = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSNamespaceRule);

        pub const Meta = struct {
            pub const name = "CSSNamespaceRule";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// CSSNestedDeclarations � presence-grade (Chrome window global).
pub const CSSNestedDeclarations = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSNestedDeclarations);

        pub const Meta = struct {
            pub const name = "CSSNestedDeclarations";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// CSSPageRule � presence-grade (Chrome window global).
pub const CSSPageRule = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSPageRule);

        pub const Meta = struct {
            pub const name = "CSSPageRule";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// CSSPropertyRule � presence-grade (Chrome window global).
pub const CSSPropertyRule = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSPropertyRule);

        pub const Meta = struct {
            pub const name = "CSSPropertyRule";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// CSSPseudoElement � presence-grade (Chrome window global).
pub const CSSPseudoElement = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSPseudoElement);

        pub const Meta = struct {
            pub const name = "CSSPseudoElement";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// CSSScopeRule � presence-grade (Chrome window global).
pub const CSSScopeRule = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSScopeRule);

        pub const Meta = struct {
            pub const name = "CSSScopeRule";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// CSSStartingStyleRule � presence-grade (Chrome window global).
pub const CSSStartingStyleRule = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSStartingStyleRule);

        pub const Meta = struct {
            pub const name = "CSSStartingStyleRule";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// CSSViewTransitionRule � presence-grade (Chrome window global).
pub const CSSViewTransitionRule = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSViewTransitionRule);

        pub const Meta = struct {
            pub const name = "CSSViewTransitionRule";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// CSSPositionTryDescriptors � presence-grade (Chrome window global).
pub const CSSPositionTryDescriptors = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSPositionTryDescriptors);

        pub const Meta = struct {
            pub const name = "CSSPositionTryDescriptors";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// CSSPositionTryRule � presence-grade (Chrome window global).
pub const CSSPositionTryRule = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSPositionTryRule);

        pub const Meta = struct {
            pub const name = "CSSPositionTryRule";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// CSSImageValue � presence-grade (Chrome window global).
pub const CSSImageValue = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSImageValue);

        pub const Meta = struct {
            pub const name = "CSSImageValue";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// CSSKeywordValue � presence-grade (Chrome window global).
pub const CSSKeywordValue = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSKeywordValue);

        pub const Meta = struct {
            pub const name = "CSSKeywordValue";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// CSSMathClamp � presence-grade (Chrome window global).
pub const CSSMathClamp = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSMathClamp);

        pub const Meta = struct {
            pub const name = "CSSMathClamp";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// CSSMathInvert � presence-grade (Chrome window global).
pub const CSSMathInvert = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSMathInvert);

        pub const Meta = struct {
            pub const name = "CSSMathInvert";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// CSSMathMax � presence-grade (Chrome window global).
pub const CSSMathMax = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSMathMax);

        pub const Meta = struct {
            pub const name = "CSSMathMax";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// CSSMathMin � presence-grade (Chrome window global).
pub const CSSMathMin = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSMathMin);

        pub const Meta = struct {
            pub const name = "CSSMathMin";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// CSSMathNegate � presence-grade (Chrome window global).
pub const CSSMathNegate = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSMathNegate);

        pub const Meta = struct {
            pub const name = "CSSMathNegate";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// CSSMathProduct � presence-grade (Chrome window global).
pub const CSSMathProduct = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSMathProduct);

        pub const Meta = struct {
            pub const name = "CSSMathProduct";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// CSSMathSum � presence-grade (Chrome window global).
pub const CSSMathSum = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSMathSum);

        pub const Meta = struct {
            pub const name = "CSSMathSum";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// CSSMathValue � presence-grade (Chrome window global).
pub const CSSMathValue = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSMathValue);

        pub const Meta = struct {
            pub const name = "CSSMathValue";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// CSSMatrixComponent � presence-grade (Chrome window global).
pub const CSSMatrixComponent = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSMatrixComponent);

        pub const Meta = struct {
            pub const name = "CSSMatrixComponent";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// CSSNumericArray � presence-grade (Chrome window global).
pub const CSSNumericArray = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSNumericArray);

        pub const Meta = struct {
            pub const name = "CSSNumericArray";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// CSSNumericValue � presence-grade (Chrome window global).
pub const CSSNumericValue = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSNumericValue);

        pub const Meta = struct {
            pub const name = "CSSNumericValue";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// CSSPerspective � presence-grade (Chrome window global).
pub const CSSPerspective = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSPerspective);

        pub const Meta = struct {
            pub const name = "CSSPerspective";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// CSSPositionValue � presence-grade (Chrome window global).
pub const CSSPositionValue = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSPositionValue);

        pub const Meta = struct {
            pub const name = "CSSPositionValue";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// CSSRotate � presence-grade (Chrome window global).
pub const CSSRotate = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSRotate);

        pub const Meta = struct {
            pub const name = "CSSRotate";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// CSSScale � presence-grade (Chrome window global).
pub const CSSScale = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSScale);

        pub const Meta = struct {
            pub const name = "CSSScale";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// CSSSkew � presence-grade (Chrome window global).
pub const CSSSkew = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSSkew);

        pub const Meta = struct {
            pub const name = "CSSSkew";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// CSSSkewX � presence-grade (Chrome window global).
pub const CSSSkewX = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSSkewX);

        pub const Meta = struct {
            pub const name = "CSSSkewX";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// CSSSkewY � presence-grade (Chrome window global).
pub const CSSSkewY = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSSkewY);

        pub const Meta = struct {
            pub const name = "CSSSkewY";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// CSSStyleValue � presence-grade (Chrome window global).
pub const CSSStyleValue = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSStyleValue);

        pub const Meta = struct {
            pub const name = "CSSStyleValue";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// CSSTransformComponent � presence-grade (Chrome window global).
pub const CSSTransformComponent = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSTransformComponent);

        pub const Meta = struct {
            pub const name = "CSSTransformComponent";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// CSSTransformValue � presence-grade (Chrome window global).
pub const CSSTransformValue = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSTransformValue);

        pub const Meta = struct {
            pub const name = "CSSTransformValue";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// CSSTransition - presence-grade (Chrome window global).
pub const CSSTransition = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSTransition);

        pub const Meta = struct {
            pub const name = "CSSTransition";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// CSSTranslate � presence-grade (Chrome window global).
pub const CSSTranslate = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSTranslate);

        pub const Meta = struct {
            pub const name = "CSSTranslate";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// CSSUnitValue � presence-grade (Chrome window global).
pub const CSSUnitValue = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSUnitValue);

        pub const Meta = struct {
            pub const name = "CSSUnitValue";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// CSSUnparsedValue � presence-grade (Chrome window global).
pub const CSSUnparsedValue = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSUnparsedValue);

        pub const Meta = struct {
            pub const name = "CSSUnparsedValue";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// CSSVariableReferenceValue � presence-grade (Chrome window global).
pub const CSSVariableReferenceValue = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CSSVariableReferenceValue);

        pub const Meta = struct {
            pub const name = "CSSVariableReferenceValue";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// HTMLCameraElement � presence-grade (Chrome window global).
pub const HTMLCameraElement = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(HTMLCameraElement);

        pub const Meta = struct {
            pub const name = "HTMLCameraElement";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// HTMLGeolocationElement � presence-grade (Chrome window global).
pub const HTMLGeolocationElement = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(HTMLGeolocationElement);

        pub const Meta = struct {
            pub const name = "HTMLGeolocationElement";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// HTMLMenuElement � presence-grade (Chrome window global).
pub const HTMLMenuElement = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(HTMLMenuElement);

        pub const Meta = struct {
            pub const name = "HTMLMenuElement";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// HTMLMicrophoneElement � presence-grade (Chrome window global).
pub const HTMLMicrophoneElement = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(HTMLMicrophoneElement);

        pub const Meta = struct {
            pub const name = "HTMLMicrophoneElement";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// HTMLSelectedContentElement � presence-grade (Chrome window global).
pub const HTMLSelectedContentElement = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(HTMLSelectedContentElement);

        pub const Meta = struct {
            pub const name = "HTMLSelectedContentElement";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// HTMLUserMediaElement � presence-grade (Chrome window global).
pub const HTMLUserMediaElement = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(HTMLUserMediaElement);

        pub const Meta = struct {
            pub const name = "HTMLUserMediaElement";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// SVGAnimateElement � presence-grade (Chrome window global).
pub const SVGAnimateElement = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(SVGAnimateElement);

        pub const Meta = struct {
            pub const name = "SVGAnimateElement";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// SVGAnimateMotionElement � presence-grade (Chrome window global).
pub const SVGAnimateMotionElement = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(SVGAnimateMotionElement);

        pub const Meta = struct {
            pub const name = "SVGAnimateMotionElement";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// SVGAnimateTransformElement � presence-grade (Chrome window global).
pub const SVGAnimateTransformElement = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(SVGAnimateTransformElement);

        pub const Meta = struct {
            pub const name = "SVGAnimateTransformElement";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// SVGAnimatedAngle � presence-grade (Chrome window global).
pub const SVGAnimatedAngle = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(SVGAnimatedAngle);

        pub const Meta = struct {
            pub const name = "SVGAnimatedAngle";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// SVGAnimatedBoolean � presence-grade (Chrome window global).
pub const SVGAnimatedBoolean = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(SVGAnimatedBoolean);

        pub const Meta = struct {
            pub const name = "SVGAnimatedBoolean";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// SVGAnimatedInteger � presence-grade (Chrome window global).
pub const SVGAnimatedInteger = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(SVGAnimatedInteger);

        pub const Meta = struct {
            pub const name = "SVGAnimatedInteger";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// SVGAnimatedLengthList � presence-grade (Chrome window global).
pub const SVGAnimatedLengthList = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(SVGAnimatedLengthList);

        pub const Meta = struct {
            pub const name = "SVGAnimatedLengthList";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// SVGAnimatedNumberList � presence-grade (Chrome window global).
pub const SVGAnimatedNumberList = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(SVGAnimatedNumberList);

        pub const Meta = struct {
            pub const name = "SVGAnimatedNumberList";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// SVGAnimatedRect � presence-grade (Chrome window global).
pub const SVGAnimatedRect = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(SVGAnimatedRect);

        pub const Meta = struct {
            pub const name = "SVGAnimatedRect";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// SVGAnimationElement � presence-grade (Chrome window global).
pub const SVGAnimationElement = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(SVGAnimationElement);

        pub const Meta = struct {
            pub const name = "SVGAnimationElement";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// SVGComponentTransferFunctionElement � presence-grade (Chrome window global).
pub const SVGComponentTransferFunctionElement = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(SVGComponentTransferFunctionElement);

        pub const Meta = struct {
            pub const name = "SVGComponentTransferFunctionElement";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// SVGFEBlendElement � presence-grade (Chrome window global).
pub const SVGFEBlendElement = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(SVGFEBlendElement);

        pub const Meta = struct {
            pub const name = "SVGFEBlendElement";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// SVGFEColorMatrixElement � presence-grade (Chrome window global).
pub const SVGFEColorMatrixElement = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(SVGFEColorMatrixElement);

        pub const Meta = struct {
            pub const name = "SVGFEColorMatrixElement";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// SVGFEComponentTransferElement � presence-grade (Chrome window global).
pub const SVGFEComponentTransferElement = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(SVGFEComponentTransferElement);

        pub const Meta = struct {
            pub const name = "SVGFEComponentTransferElement";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// SVGFECompositeElement � presence-grade (Chrome window global).
pub const SVGFECompositeElement = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(SVGFECompositeElement);

        pub const Meta = struct {
            pub const name = "SVGFECompositeElement";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// SVGFEConvolveMatrixElement � presence-grade (Chrome window global).
pub const SVGFEConvolveMatrixElement = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(SVGFEConvolveMatrixElement);

        pub const Meta = struct {
            pub const name = "SVGFEConvolveMatrixElement";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// SVGFEDiffuseLightingElement � presence-grade (Chrome window global).
pub const SVGFEDiffuseLightingElement = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(SVGFEDiffuseLightingElement);

        pub const Meta = struct {
            pub const name = "SVGFEDiffuseLightingElement";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// SVGFEDisplacementMapElement � presence-grade (Chrome window global).
pub const SVGFEDisplacementMapElement = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(SVGFEDisplacementMapElement);

        pub const Meta = struct {
            pub const name = "SVGFEDisplacementMapElement";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// SVGFEDistantLightElement � presence-grade (Chrome window global).
pub const SVGFEDistantLightElement = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(SVGFEDistantLightElement);

        pub const Meta = struct {
            pub const name = "SVGFEDistantLightElement";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// SVGFEDropShadowElement � presence-grade (Chrome window global).
pub const SVGFEDropShadowElement = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(SVGFEDropShadowElement);

        pub const Meta = struct {
            pub const name = "SVGFEDropShadowElement";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// SVGFEFloodElement � presence-grade (Chrome window global).
pub const SVGFEFloodElement = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(SVGFEFloodElement);

        pub const Meta = struct {
            pub const name = "SVGFEFloodElement";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// SVGFEFuncAElement � presence-grade (Chrome window global).
pub const SVGFEFuncAElement = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(SVGFEFuncAElement);

        pub const Meta = struct {
            pub const name = "SVGFEFuncAElement";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// SVGFEFuncBElement � presence-grade (Chrome window global).
pub const SVGFEFuncBElement = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(SVGFEFuncBElement);

        pub const Meta = struct {
            pub const name = "SVGFEFuncBElement";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// SVGFEFuncGElement � presence-grade (Chrome window global).
pub const SVGFEFuncGElement = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(SVGFEFuncGElement);

        pub const Meta = struct {
            pub const name = "SVGFEFuncGElement";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// SVGFEFuncRElement � presence-grade (Chrome window global).
pub const SVGFEFuncRElement = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(SVGFEFuncRElement);

        pub const Meta = struct {
            pub const name = "SVGFEFuncRElement";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// SVGFEGaussianBlurElement � presence-grade (Chrome window global).
pub const SVGFEGaussianBlurElement = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(SVGFEGaussianBlurElement);

        pub const Meta = struct {
            pub const name = "SVGFEGaussianBlurElement";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// SVGFEImageElement � presence-grade (Chrome window global).
pub const SVGFEImageElement = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(SVGFEImageElement);

        pub const Meta = struct {
            pub const name = "SVGFEImageElement";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// SVGFEMergeElement � presence-grade (Chrome window global).
pub const SVGFEMergeElement = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(SVGFEMergeElement);

        pub const Meta = struct {
            pub const name = "SVGFEMergeElement";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// SVGFEMergeNodeElement � presence-grade (Chrome window global).
pub const SVGFEMergeNodeElement = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(SVGFEMergeNodeElement);

        pub const Meta = struct {
            pub const name = "SVGFEMergeNodeElement";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// SVGFEMorphologyElement � presence-grade (Chrome window global).
pub const SVGFEMorphologyElement = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(SVGFEMorphologyElement);

        pub const Meta = struct {
            pub const name = "SVGFEMorphologyElement";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// SVGFEOffsetElement � presence-grade (Chrome window global).
pub const SVGFEOffsetElement = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(SVGFEOffsetElement);

        pub const Meta = struct {
            pub const name = "SVGFEOffsetElement";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// SVGFEPointLightElement � presence-grade (Chrome window global).
pub const SVGFEPointLightElement = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(SVGFEPointLightElement);

        pub const Meta = struct {
            pub const name = "SVGFEPointLightElement";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// SVGFESpecularLightingElement � presence-grade (Chrome window global).
pub const SVGFESpecularLightingElement = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(SVGFESpecularLightingElement);

        pub const Meta = struct {
            pub const name = "SVGFESpecularLightingElement";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// SVGFESpotLightElement � presence-grade (Chrome window global).
pub const SVGFESpotLightElement = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(SVGFESpotLightElement);

        pub const Meta = struct {
            pub const name = "SVGFESpotLightElement";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// SVGFETileElement � presence-grade (Chrome window global).
pub const SVGFETileElement = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(SVGFETileElement);

        pub const Meta = struct {
            pub const name = "SVGFETileElement";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// SVGFETurbulenceElement � presence-grade (Chrome window global).
pub const SVGFETurbulenceElement = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(SVGFETurbulenceElement);

        pub const Meta = struct {
            pub const name = "SVGFETurbulenceElement";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// SVGFilterElement � presence-grade (Chrome window global).
pub const SVGFilterElement = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(SVGFilterElement);

        pub const Meta = struct {
            pub const name = "SVGFilterElement";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// SVGLengthList � presence-grade (Chrome window global).
pub const SVGLengthList = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(SVGLengthList);

        pub const Meta = struct {
            pub const name = "SVGLengthList";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// SVGMPathElement � presence-grade (Chrome window global).
pub const SVGMPathElement = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(SVGMPathElement);

        pub const Meta = struct {
            pub const name = "SVGMPathElement";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// SVGMatrix � presence-grade (Chrome window global).
pub const SVGMatrix = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(SVGMatrix);

        pub const Meta = struct {
            pub const name = "SVGMatrix";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// SVGNumberList � presence-grade (Chrome window global).
pub const SVGNumberList = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(SVGNumberList);

        pub const Meta = struct {
            pub const name = "SVGNumberList";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// SVGPoint � presence-grade (Chrome window global).
pub const SVGPoint = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(SVGPoint);

        pub const Meta = struct {
            pub const name = "SVGPoint";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// SVGRect � presence-grade (Chrome window global).
pub const SVGRect = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(SVGRect);

        pub const Meta = struct {
            pub const name = "SVGRect";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// SVGScriptElement � presence-grade (Chrome window global).
pub const SVGScriptElement = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(SVGScriptElement);

        pub const Meta = struct {
            pub const name = "SVGScriptElement";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// SVGSetElement � presence-grade (Chrome window global).
pub const SVGSetElement = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(SVGSetElement);

        pub const Meta = struct {
            pub const name = "SVGSetElement";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// SVGStyleElement � presence-grade (Chrome window global).
pub const SVGStyleElement = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(SVGStyleElement);

        pub const Meta = struct {
            pub const name = "SVGStyleElement";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// SVGUnitTypes � presence-grade (Chrome window global).
pub const SVGUnitTypes = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(SVGUnitTypes);

        pub const Meta = struct {
            pub const name = "SVGUnitTypes";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// WebGLActiveInfo � presence-grade (Chrome window global).
pub const WebGLActiveInfo = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(WebGLActiveInfo);

        pub const Meta = struct {
            pub const name = "WebGLActiveInfo";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// WebGLBuffer � presence-grade (Chrome window global).
pub const WebGLBuffer = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(WebGLBuffer);

        pub const Meta = struct {
            pub const name = "WebGLBuffer";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// WebGLContextEvent � presence-grade (Chrome window global).
pub const WebGLContextEvent = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(WebGLContextEvent);

        pub const Meta = struct {
            pub const name = "WebGLContextEvent";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// WebGLFramebuffer � presence-grade (Chrome window global).
pub const WebGLFramebuffer = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(WebGLFramebuffer);

        pub const Meta = struct {
            pub const name = "WebGLFramebuffer";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// WebGLObject � presence-grade (Chrome window global).
pub const WebGLObject = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(WebGLObject);

        pub const Meta = struct {
            pub const name = "WebGLObject";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// WebGLProgram � presence-grade (Chrome window global).
pub const WebGLProgram = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(WebGLProgram);

        pub const Meta = struct {
            pub const name = "WebGLProgram";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// WebGLQuery � presence-grade (Chrome window global).
pub const WebGLQuery = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(WebGLQuery);

        pub const Meta = struct {
            pub const name = "WebGLQuery";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// WebGLRenderbuffer � presence-grade (Chrome window global).
pub const WebGLRenderbuffer = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(WebGLRenderbuffer);

        pub const Meta = struct {
            pub const name = "WebGLRenderbuffer";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// WebGLSampler � presence-grade (Chrome window global).
pub const WebGLSampler = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(WebGLSampler);

        pub const Meta = struct {
            pub const name = "WebGLSampler";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// WebGLShader � presence-grade (Chrome window global).
pub const WebGLShader = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(WebGLShader);

        pub const Meta = struct {
            pub const name = "WebGLShader";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// WebGLSync � presence-grade (Chrome window global).
pub const WebGLSync = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(WebGLSync);

        pub const Meta = struct {
            pub const name = "WebGLSync";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// WebGLTexture � presence-grade (Chrome window global).
pub const WebGLTexture = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(WebGLTexture);

        pub const Meta = struct {
            pub const name = "WebGLTexture";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// WebGLTransformFeedback � presence-grade (Chrome window global).
pub const WebGLTransformFeedback = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(WebGLTransformFeedback);

        pub const Meta = struct {
            pub const name = "WebGLTransformFeedback";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// WebGLUniformLocation � presence-grade (Chrome window global).
pub const WebGLUniformLocation = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(WebGLUniformLocation);

        pub const Meta = struct {
            pub const name = "WebGLUniformLocation";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// WebGLVertexArrayObject � presence-grade (Chrome window global).
pub const WebGLVertexArrayObject = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(WebGLVertexArrayObject);

        pub const Meta = struct {
            pub const name = "WebGLVertexArrayObject";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};
