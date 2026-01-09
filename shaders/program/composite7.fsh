#include "/lib/all_the_libs.glsl"
varying vec2 texcoord;
varying vec2 BloomTilePos;
#include "/global/post/bloom.glsl"

/* DRAWBUFFERS:0 */

void main() {
    vec4 Color = texture2D(colortex0, texcoord);

    #ifdef BLOOM
    // Sample final bloom with reduced cost
    vec3 FinalBloom = blur3x3(colortex1, BloomTilePos);
    FinalBloom *= 0.333333; // Pre-calculated 1/3
    
    // Optimized bloom factor calculation
    float BloomFactor = dot(FinalBloom, vec3(0.299, 0.587, 0.114)) * BLOOM_CURVE + (1.0 - BLOOM_CURVE);
    BloomFactor += 0.2 * rainStrength * isOutdoorsSmooth;
    BloomFactor *= 0.6; // Pre-calculated adjustment
    
    // Apply bloom
    Color.rgb = mix(Color.rgb, FinalBloom, BloomFactor * BLOOM_STRENGTH);
    #endif

    gl_FragData[0] = Color;
}
