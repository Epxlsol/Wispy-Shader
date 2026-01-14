#include "/lib/all_the_libs.glsl"
#include "/global/sky.glsl"
#include "/global/fog.glsl"
#include "/global/post/ssao.glsl"

// This helps DH identify the pack as compatible if it scans the file
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

    bool IsDH = Depth < 0.56001;
    vec3 ViewPos = to_view_pos(vec3(texcoord, Depth), IsDH);

    // ViewPosN is for things that move with the camera (like sun glare)
    vec3 ViewPosN = normalize(ViewPos);

    // WorldDirN is for things that stay still (Stars and Sky Gradients)
    vec3 WorldDirN = normalize(mat3(gbufferModelViewInverse) * ViewPos);

    float VdotL = dot(WorldDirN, sunPosN);

    vec3 SkyColor = vec3(0.0);
    #if defined ATMOSPHERIC_FOG || defined BORDER_FOG || defined DIMENSION_END || 1
    {
        vec3 SunGlare = get_sun_glare(VdotL);
        // Using WorldDirN here ensures the horizon gradient doesn't shift
        SkyColor = get_sky_main(WorldDirN, WorldDirN, SunGlare);
    }
    #endif

    // --- SKY PASS ---
    if (Depth >= 0.9999) {
        #ifndef CUSTOM_SKYBOXES
        #ifndef DIMENSION_OVERWORLD
        Color.rgb = vec3(0.0);
        #else
        #ifdef ROUND_SUN
        SkyColor += round_sun(VdotL);
        #endif
        Color.rgb += SkyColor;

        // FIX: Stars now use WorldDirN so they don't slide when you look around
        if (WorldDirN.y > 0.0) {
            Color.rgb += get_stars(WorldDirN);
        }
        #endif
        #endif
    }
    // --- TERRAIN PASS ---
    else {
        float Dither = dither(gl_FragCoord.xy);

        // DH Bypass: Keep DH chunks clean, only run SSAO/Fog on real terrain
        if (IsDH) {
            float dhFog = smoothstep(0.8, 1.0, Depth);
            Color.rgb = mix(Color.rgb, SkyColor, dhFog * 0.2);
        } else {
            #ifdef SSAO
            Color.rgb = ssao(Color.rgb, ViewPos, Dither, false);
            #endif

            #if defined ATMOSPHERIC_FOG || defined BORDER_FOG || defined DIMENSION_END
            vec3 PlayerPos = to_player_pos(ViewPos);
            Color.rgb = get_fog_main(vec3(texcoord, Depth), PlayerPos, Color.rgb, Depth, SkyColor, VdotL, Dither, false);
            #endif
        }
    }

    // Tells DH that we are outputting a valid frame
    gl_FragData[0] = Color;
}
