#include "/lib/all_the_libs.glsl"

uniform sampler2D lightmap;
uniform sampler2D gtexture;

varying vec2 texcoord;
varying vec4 glcolor;
varying vec3 MixedLights;

/* DRAWBUFFERS:0 */

void main() {
    // 1. Basic Texture and Color
    vec4 Color = texture2D(gtexture, texcoord) * glcolor;
    Color.rgb *= Color.rgb; // Fast gamma
    
    // 2. Add Water Quality Logic
    // Using a define that we will add to shaders.properties
    #if WATER_QUALITY >= 1
        // Fancy/Medium: Simple Alpha Blending
        vec3 screenCol = texture2D(colortex0, gl_FragCoord.xy / vec2(viewWidth, viewHeight)).rgb;
        Color.rgb = mix(screenCol, Color.rgb * MixedLights, Color.a);
    #else
        // Low/Fast: Simple Tint (Standard behavior)
        Color.rgb *= MixedLights;
    #endif

    gl_FragData[0] = Color;
}
