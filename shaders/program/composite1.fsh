#include "/lib/all_the_libs.glsl"

#include "/global/sky.glsl"
#include "/global/fog.glsl"

varying vec2 texcoord;

/* DRAWBUFFERS:0 */

void main() {
    vec4 Color = texture2D(colortex0, texcoord);
    float Depth = texture2D(depthtex0, texcoord).r;

    if (Depth < 0.56) {
        gl_FragData[0] = Color;
        return;
    }

    bool IsDH = Depth < 0.56001;
    vec3 ScreenPos = vec3(texcoord, Depth);
    vec3 ViewPos = to_view_pos(ScreenPos, IsDH);
    vec3 ViewPosN = fast_normalize(ViewPos);

    if (Depth >= 0.9999) {
        vec3 PlayerPos = to_player_pos(ViewPos);
        vec3 PlayerPosN = fast_normalize(PlayerPos);

        float VdotL = dot(ViewPosN, sunPosN);
        vec3 SunGlare = get_sun_glare(VdotL);
        vec3 SkyColor = get_sky_main(ViewPosN, PlayerPosN, SunGlare);

        #ifndef CUSTOM_SKYBOXES
        #ifndef DIMENSION_OVERWORLD
        Color.rgb = vec3(0.0);
        #elif defined ROUND_SUN
        SkyColor += round_sun(VdotL);
        #endif

        Color.rgb += SkyColor;

        #if defined DIMENSION_OVERWORLD || defined DIMENSION_END
        if (PlayerPosN.y > 0.0 && nightStrength > 0.01) {
            Color.rgb += get_stars(PlayerPos);
            #ifdef AURORA_BOREALIS
            float Dither = dither(gl_FragCoord.xy);
            Color.rgb += get_aurora(PlayerPosN, Dither);
            #endif
        }
        #endif
        #endif
    }
    else {
        #if defined ATMOSPHERIC_FOG || defined BORDER_FOG || defined DIMENSION_END
        vec3 PlayerPos = to_player_pos(ViewPos);
        float VdotL = dot(ViewPosN, sunPosN);

        vec3 PlayerPosN = fast_normalize(PlayerPos);
        vec3 SunGlare = get_sun_glare(VdotL);
        vec3 SkyColor = get_sky_main(ViewPosN, PlayerPosN, SunGlare);

        float Dither = dither(gl_FragCoord.xy);
        Color.rgb = get_fog_main(ScreenPos, PlayerPos, Color.rgb, Depth, SkyColor, VdotL, Dither, IsDH);
        #endif
    }

    gl_FragData[0] = Color;
}
