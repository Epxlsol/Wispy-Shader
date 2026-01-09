#include "/lib/all_the_libs.glsl"

// Bridge the menu settings to the shader logic
#ifndef WATER_QUALITY
    #define WATER_QUALITY 1 // [0 1 2]
#endif

uniform sampler2D lightmap;
uniform sampler2D gtexture;
uniform sampler2D colortex0; // Used for refraction

varying vec2 texcoord;
varying vec4 glcolor;
varying vec3 MixedLights;
varying vec3 viewVector; // Ensure this is passed from .vsh if you want refraction

/* DRAWBUFFERS:0 */

void main() {
    vec2 adjustedTexCoord = texcoord;

    // --- 1. Water Refraction ---
    #ifdef WATER_REFRACTION
    #if WATER_QUALITY >= 1
        // Small offset based on a sine wave for "wobbly" refraction
        float wave = sin(texcoord.y * 20.0 + frameTimeCounter * 3.0) * 0.002;
        adjustedTexCoord += wave;
    #endif
    #endif

    vec4 Color = texture2D(gtexture, adjustedTexCoord) * glcolor;
    
    // Fast gamma
    Color.rgb *= Color.rgb; 
    
    // --- 2. Water Transparency/Fog ---
    #if WATER_QUALITY == 0
        // Low: Simple tint
        Color.rgb *= MixedLights;
    #else
        // Medium/High: Mix with screen color for "real" transparency
        vec3 screenCol = texture2D(colortex0, gl_FragCoord.xy / vec2(viewWidth, viewHeight)).rgb;
        Color.rgb = mix(screenCol, Color.rgb * MixedLights, Color.a);
        Color.a = 0.8; // Force a consistent alpha for better visibility
    #endif

    // --- 3. Brightness Control ---
    #ifdef WATER_BRIGHTNESS
        Color.rgb *= WATER_BRIGHTNESS;
    #endif

    gl_FragData[0] = Color;
}
