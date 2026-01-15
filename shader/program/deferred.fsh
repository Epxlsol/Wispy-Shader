#include "/lib/all_the_libs.glsl"
#include "/global/sky.glsl"
#include "/global/fog.glsl"
#include "/global/post/ssao.glsl"

#define DISTANT_HORIZONS

varying vec2 texcoord;

/* DRAWBUFFERS:0 */

void main() {
    vec4 Color = texture2D(colortex0, texcoord);
    float Depth = texture2D(depthtex0, texcoord).r;

    // Early exit for hand/UI
    if (Depth < 0.56) {
        gl_FragData[0] = Color;
        return;
    }

    #ifdef DISTANT_HORIZONS
    float dhDepth = texture2D(dhDepthTex, texcoord).r;
    bool IsDH = (Depth >= 1.0 && dhDepth < 1.0);

    if (IsDH) {
        gl_FragData[0] = Color;
        return;
    }
    #endif

    vec3 ViewPos = to_view_pos(vec3(texcoord, Depth), false);
    vec3 ViewPosN = normalize(ViewPos);

    vec3 WorldDirN = normalize(mat3(gbufferModelViewInverse) * ViewPosN);

    float VdotL = dot(ViewPosN, sunPosN);

    vec3 SkyColor = vec3(0.0);

    // --- SKY PASS  ---
    if (Depth >= 0.9999) {
        #ifndef CUSTOM_SKYBOXES
        #ifndef DIMENSION_OVERWORLD
        Color.rgb = vec3(0.0);
        #else
        vec3 SunGlare = get_sun_glare(VdotL);
        SkyColor = get_sky_main(ViewPosN, ViewPosN, SunGlare);

        #ifdef ROUND_SUN
        SkyColor += round_sun(VdotL);
        #endif
        Color.rgb += SkyColor;

        if (WorldDirN.y > 0.0) {
            Color.rgb += get_stars(WorldDirN);
        }
        #endif
        #endif
    }
    // --- TERRAIN PASS ---
    else {
        #ifdef SSAO
        float Dither = dither(gl_FragCoord.xy);
        Color.rgb = ssao(Color.rgb, ViewPos, Dither, false);
        #endif

        #if defined ATMOSPHERIC_FOG || defined BORDER_FOG || defined DIMENSION_END
        vec3 SunGlare = get_sun_glare(VdotL);
        SkyColor = get_sky_main(ViewPosN, ViewPosN, SunGlare);
        vec3 PlayerPos = to_player_pos(ViewPos);
        float Dither = dither(gl_FragCoord.xy);
        Color.rgb = get_fog_main(vec3(texcoord, Depth), PlayerPos, Color.rgb, Depth, SkyColor, VdotL, Dither, false);
        #endif
    }

    gl_FragData[0] = Color;
}
