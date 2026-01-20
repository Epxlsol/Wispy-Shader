#include "/lib/all_the_libs.glsl"
uniform sampler2D lightmap;
uniform sampler2D gtexture;
// Remove this line: uniform sampler2D depthtex1; - depthtex1 is already declared by the framework

varying vec2 texcoord;
varying vec4 glcolor;
varying vec3 MixedLights;

/* DRAWBUFFERS:0 */

void main() {
    vec4 Color = texture2D(gtexture, texcoord) * glcolor;

    // Water color based on dimension
    #ifdef DIMENSION_OVERWORLD
    const vec3 deepBlue = vec3(0.0, 0.04, 0.2025);
    Color.rgb = deepBlue;
    Color.a = 0.22;

    // Add depth-based fog if underwater
    if (isEyeInWater == 1) {
        vec2 ScreenPos = gl_FragCoord.xy * resolutionInv;
        float TerrainDepth = texture2D(depthtex1, ScreenPos).x; // Now uses framework's declaration
        float WaterDepth = gl_FragCoord.z;
        float DepthDiff = linearize_depth(TerrainDepth) - linearize_depth(WaterDepth);
        float fogFactor = clamp(DepthDiff * (1.0/48.0), 0.0, 1.0) * WATER_FOG_STRENGTH;
        Color.a = min(Color.a + fogFactor, 1.0);
    }
    #elif defined DIMENSION_END
    const vec3 endWater = vec3(0.05, 0.0, 0.1);
    Color.rgb = endWater;
    Color.a = 0.3;
    #else
    const vec3 netherWater = vec3(0.15, 0.02, 0.0);
    Color.rgb = netherWater;
    Color.a = 0.4;
    #endif

    Color.rgb *= MixedLights;
    gl_FragData[0] = Color;
}
