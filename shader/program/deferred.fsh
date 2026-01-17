#include "/lib/all_the_libs.glsl"
#include "/global/sky.glsl"
#include "/global/fog.glsl"
#include "/global/post/ssao.glsl"

varying vec2 texcoord;

/* DRAWBUFFERS:0 */

void main() {
    vec4 Color = texture2D(colortex0, texcoord);
    float Depth = texture2D(depthtex0, texcoord).r;

    // Early exit for hand/UI - critical for performance
    if (Depth < 0.56) {
        gl_FragData[0] = Color;
        return;
    }

    // Optimized DH detection
    bool IsDH = false;
    #ifdef DISTANT_HORIZONS
    float dhDepth = texture2D(dhDepthTex, texcoord).r;
    IsDH = (Depth >= 1.0 && dhDepth < 1.0);
    #endif

    // Sky check
    bool IsSky = (Depth > 0.9999f);

    // === SKY RENDERING ===
    if (IsSky && !IsDH) {
        #ifdef DIMENSION_OVERWORLD
        // Optimized sky calculations - pack operations efficiently
        vec3 ScreenPos = vec3(texcoord, Depth);
        vec3 ViewPos = to_view_pos(ScreenPos, false);
        vec3 ViewPosN = normalize(ViewPos);
        vec3 PlayerPosN = normalize(to_player_pos(ViewPos));

        float VdotL = dot(ViewPosN, sunPosN);
        vec3 SunGlare = get_sun_glare(VdotL);
        vec3 SkyColor = get_sky_main(ViewPosN, PlayerPosN, SunGlare);

        #ifdef ROUND_SUN
        SkyColor += round_sun(VdotL);
        #else
        // Preserve vanilla sun/moon when custom sun is disabled
        Color.rgb = mix(Color.rgb, SkyColor, 0.5);
        #endif

        // Stars only when looking up
        if (PlayerPosN.y > 0.0) {
            Color.rgb += get_stars(to_player_pos(ViewPos));
        }

        #elif defined DIMENSION_END
        vec3 ScreenPos = vec3(texcoord, Depth);
        vec3 ViewPos = to_view_pos(ScreenPos, false);
        vec3 ViewPosN = normalize(ViewPos);
        vec3 PlayerPosN = normalize(to_player_pos(ViewPos));

        Color.rgb = get_end_sky(ViewPosN, PlayerPosN);

        if (PlayerPosN.y > 0.0) {
            Color.rgb += get_stars(to_player_pos(ViewPos));
        }

        #else
        Color.rgb = vec3(0.0);
        #endif

        gl_FragData[0] = Color;
        return;
    }

    // === DH TERRAIN ===
    if (IsDH) {
        gl_FragData[0] = Color;
        return;
    }

    // === TERRAIN RENDERING ===
    vec3 ScreenPos = vec3(texcoord, Depth);
    vec3 ViewPos = to_view_pos(ScreenPos, false);

    // Compute dither once and reuse for all effects
    float Dither = dither(gl_FragCoord.xy);

    #ifdef SSAO
    Color.rgb = ssao(Color.rgb, ViewPos, Dither, false);
    #endif

    #if defined ATMOSPHERIC_FOG || defined BORDER_FOG || defined DIMENSION_END
    vec3 PlayerPos = to_player_pos(ViewPos);
    vec3 ViewPosN = normalize(ViewPos);
    float VdotL = dot(ViewPosN, sunPosN);

    vec3 PlayerPosN = normalize(PlayerPos);
    vec3 SunGlare = get_sun_glare(VdotL);
    vec3 SkyColor = get_sky_main(ViewPosN, PlayerPosN, SunGlare);

    Color.rgb = get_fog_main(ScreenPos, PlayerPos, Color.rgb, Depth, SkyColor, VdotL, Dither, false);
    #endif

    gl_FragData[0] = Color;
}
