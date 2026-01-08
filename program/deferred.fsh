#include "/lib/all_the_libs.glsl"

#include "/global/sky.glsl"
#include "/global/fog.glsl"

varying vec2 texcoord;

/* DRAWBUFFERS:0 */

void main() {
    vec4 Color = texture2D(colortex0, texcoord);
    float Depth = texture2D(depthtex0, texcoord).r;
    
    // Fast early exit
    if (Depth < 0.56) {
        gl_FragData[0] = Color;
        return;
    }
    
    bool IsDH = Depth < 0.56001;
    vec3 ScreenPos = vec3(texcoord, Depth);
    
    // Only do expensive calculations for sky
    if (Depth >= 1) {
        vec3 ViewPos = to_view_pos(ScreenPos, IsDH);
        vec3 PlayerPos = mat3(gbufferModelViewInverse) * ViewPos;
        vec3 ViewPosN = normalize(ViewPos);
        vec3 PlayerPosN = normalize(PlayerPos);
        
        float VdotL = dot(ViewPosN, sunPosN);
        vec3 SunGlare = get_sun_glare(VdotL);
        vec3 SkyColor = get_sky_main(ViewPosN, PlayerPosN, SunGlare);
        
        #ifndef CUSTOM_SKYBOXES
            #ifndef DIMENSION_OVERWORLD
            Color = vec4(0, 0, 0, 1);
            #elif defined ROUND_SUN
            SkyColor += round_sun(VdotL);
            #endif
            
            Color.rgb += SkyColor;
            
            if (PlayerPos.y > 0) {
                #if defined DIMENSION_OVERWORLD || defined DIMENSION_END
                Color.rgb += get_stars(PlayerPos);
                #endif
            }
        #endif
    } else {
        // Terrain - simplified fog
        vec3 ViewPos = to_view_pos(ScreenPos, IsDH);
        vec3 PlayerPos = mat3(gbufferModelViewInverse) * ViewPos;
        vec3 ViewPosN = normalize(ViewPos);
        
        float VdotL = dot(ViewPosN, sunPosN);
        vec3 PlayerPosN = normalize(PlayerPos);
        vec3 SunGlare = get_sun_glare(VdotL);
        vec3 SkyColor = get_sky_main(ViewPosN, PlayerPosN, SunGlare);
        
        float Dither = dither(gl_FragCoord.xy);
        Color.rgb = get_fog_main(ScreenPos, PlayerPos, Color.rgb, Depth, SkyColor, VdotL, Dither, IsDH);
    }
    
    gl_FragData[0] = Color;
}
