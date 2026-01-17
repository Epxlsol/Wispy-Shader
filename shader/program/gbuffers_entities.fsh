#include "/lib/all_the_libs.glsl"
uniform sampler2D gtexture;
varying vec2 texcoord;
varying vec4 glcolor;

#include "/global/lighting.fsh"

void main() {
    // PERFORMANCE: Direct texture sampling
    vec4 Color = texture(gtexture, texcoord) * glcolor;

    // PERFORMANCE: Fast linear conversion - use the library function but optimize call
    Color.rgb = to_linear(Color.rgb); // Keep original function for correctness

    if (entityId == 10001) {
        Color.a = 1.0;
    }
    else {
        // PERFORMANCE: Single mix operation
        Color.xyz = mix(Color.rgb, entityColor.rgb, entityColor.a);

        // PERFORMANCE: Minimal lightmap application
        vec3 TweakedLM = tweak_lightmap();
        Color.xyz *= max(TweakedLM, 0.15); // Still use max() for speed
    }

    // PERFORMANCE: Efficient alpha handling
    Color.a = max(Color.a, 0.01);
    if (Color.a < 0.05) {
        discard;
    }

    gl_FragData[0] = Color;
}
