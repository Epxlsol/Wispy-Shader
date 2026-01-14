#include "/lib/all_the_libs.glsl"
#include "/global/sky.glsl"
#include "/global/fog.glsl"

varying vec2 texcoord;

void main() {
    vec4 Color = texture2D(colortex0, texcoord);
    float Depth = texture2D(depthtex0, texcoord).r;

    bool IsDH = Depth > 0.0 && Depth < 1.0;

    #if !defined ATMOSPHERIC_FOG && !defined BORDER_FOG && !defined DIMENSION_END
    if (Depth < 0.9999) {
        gl_FragData[0] = Color;
        return;
    }
    #endif

    vec3 ScreenPos = vec3(texcoord, Depth);
    vec3 ViewPos   = to_view_pos(ScreenPos, IsDH);
    vec3 PlayerPos = to_player_pos(ViewPos);

    vec3 ViewPosN   = normalize(ViewPos);
    float VdotL     = dot(ViewPosN, sunPosN);

    vec3 SkyColor = vec3(0.0);

    // --- SKY PASS ---
    if (Depth >= 0.9999 && !IsDH) {
        #ifndef CUSTOM_SKYBOXES
        vec3 SunGlare = get_sun_glare(VdotL);
        SkyColor = get_sky_main(ViewPosN, ViewPosN, SunGlare);

        #ifndef DIMENSION_OVERWORLD
        Color.rgb = vec3(0.0);
        #else
        #ifdef ROUND_SUN
        SkyColor += round_sun(VdotL);
        #endif
        Color.rgb += SkyColor;

        if (ViewPosN.y > 0.0) {
            Color.rgb += get_stars(ViewPosN);
        }
        #endif
        #endif
    }
    // --- FOG PASS ---
    else if (!IsDH) {
        #if defined ATMOSPHERIC_FOG || defined BORDER_FOG || defined DIMENSION_END
        vec3 SunGlare = get_sun_glare(VdotL);
        SkyColor = get_sky_main(ViewPosN, ViewPosN, SunGlare);

        float Dither = dither(gl_FragCoord.xy);
        Color.rgb = get_fog_main(ScreenPos, PlayerPos, Color.rgb, Depth, SkyColor, VdotL, Dither, IsDH);
        #endif
    }

    gl_FragData[0] = Color;
}
