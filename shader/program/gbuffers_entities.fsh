#include "/lib/all_the_libs.glsl"
uniform sampler2D lightmap;
uniform sampler2D gtexture;
varying vec2 texcoord;
varying vec4 glcolor;
#include "/global/lighting.fsh"
void main() {
    vec4 Color = texture2D(gtexture, texcoord) * glcolor;
    Color.rgb = to_linear(Color.rgb);
    if (entityId == 10001) {
        Color.a = 1.0;
    }
    else {
        Color.xyz = mix(Color.rgb, entityColor.rgb, entityColor.a);
        vec3 TweakedLM = tweak_lightmap();
        Color.xyz *= TweakedLM;
        #ifdef ENTITY_GLOW
        float brightness = get_luminance(Color.rgb);
        if (brightness > 0.7) {
            Color.rgb += Color.rgb * ENTITY_GLOW_STRENGTH * (brightness - 0.7) * 3.33;
        }
        #endif
        #ifdef CREEPER_FLASH
        if (entityColor.a > 0.5) {
            float flash = fract(frameTimeCounter * 4.0);
            flash = flash > 0.5 ? 1.0 : 0.0;
            Color.rgb += vec3(1.0, 1.0, 1.0) * flash * 0.3;
        }
        #endif
    }
    gl_FragData[0] = Color;
}
