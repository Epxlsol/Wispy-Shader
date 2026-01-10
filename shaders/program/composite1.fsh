#include "/lib/all_the_libs.glsl"

#include "/global/sky.glsl"
#include "/global/fog.glsl"

varying vec2 texcoord;

/* DRAWBUFFERS:0 */

void main() {
    vec4 Color = texture2D(colortex0, texcoord);
    float Depth = texture2D(depthtex0, texcoord).r;

    // 1. EARLY EXIT: If this is near terrain, stop immediately.
    // This saves the GPU from calculating sky math for your house or the ground.
    if (Depth < 0.56) {
        gl_FragData[0] = Color;
        return;
    }

    // 2. DH Detection
    bool IsDH = Depth < 0.56001;
    vec3 ScreenPos = vec3(texcoord, Depth);
    vec3 ViewPos = to_view_pos(ScreenPos, IsDH);
    vec3 ViewPosN = fast_normalize(ViewPos);

    // 3. SKY PASS (Infinite distance)
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
        // Optimization: Only calculate stars if looking up and at night
        if (PlayerPosN.y > 0.0 && nightStrength > 0.01) {
            Color.rgb += get_stars(PlayerPos);
        }
        #endif
        #endif
    }
    // 4. FOG PASS (DH or Distant Terrain)
    else {
        #if defined ATMOSPHERIC_FOG || defined BORDER_FOG || defined DIMENSION_END
        vec3 PlayerPos = to_player_pos(ViewPos);
        float VdotL = dot(ViewPosN, sunPosN);

        // Re-using calculations to avoid redundant normalize calls
        vec3 PlayerPosN = fast_normalize(PlayerPos);
        vec3 SunGlare = get_sun_glare(VdotL);
        vec3 SkyColor = get_sky_main(ViewPosN, PlayerPosN, SunGlare);

        float Dither = dither(gl_FragCoord.xy);
        Color.rgb = get_fog_main(ScreenPos, PlayerPos, Color.rgb, Depth, SkyColor, VdotL, Dither, IsDH);
        #endif
    }

    gl_FragData[0] = Color;
}
