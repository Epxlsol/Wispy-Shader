#include "/lib/all_the_libs.glsl"

// Fallback definition for the compiler
#ifndef WATER_QUALITY
    #define WATER_QUALITY 0
#endif

uniform sampler2D lightmap;
uniform sampler2D gtexture;

// REMOVED: The manual uniform sampler2D colortex0 declaration 
// It is already provided by all_the_libs.glsl

varying vec2 texcoord;
varying vec4 glcolor;
varying vec3 MixedLights;

/* DRAWBUFFERS:0 */

void main() {
    // 1. Basic Texture and Color
    vec4 Color = texture2D(gtexture, texcoord) * glcolor;
    Color.rgb *= Color.rgb; // Fast gamma
    
    // 2. Add Water Quality Logic
    #if WATER_QUALITY >= 1
        // Fancy/Medium: Simple Alpha Blending using Screen Texture
        // NOTE: colortex0 is being used here, but declared in the include above
        vec2 screenPos = gl_FragCoord.xy / vec2(viewWidth, viewHeight);
        vec3 screenCol = texture2D(colortex0, screenPos).rgb;
        
        Color.rgb = mix(screenCol, Color.rgb * MixedLights, Color.a);
    #else
        // Low/Fast: Simple Tint
        Color.rgb *= MixedLights;
    #endif

    gl_FragData[0] = Color;
}
