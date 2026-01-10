#include "/lib/all_the_libs.glsl"

varying vec2 texcoord;

#ifdef GODRAYS
vec3 godrays(vec3 Color, vec2 ScreenPos, float Depth) {
    if (Depth < 0.56) return Color;
    
    vec2 sunScreen = vec2(0.5) + sunPosN.xy * 0.5;
    vec2 delta = (sunScreen - ScreenPos) / float(GODRAYS_QUALITY);
    
    float illumination = 0.0;
    vec2 pos = ScreenPos;
    
    for(int i = 0; i < GODRAYS_QUALITY; i++) {
        float d = texture2D(depthtex0, pos).r;
        if(d >= 0.9999) illumination += 1.0;
        pos += delta;
    }
    
    illumination /= float(GODRAYS_QUALITY);
    illumination *= max(0.0, sunPosN.z) * (1.0 - rainStrength);
    
    return Color + SKY_GROUND * illumination * 0.15;
}
#endif

/* DRAWBUFFERS:0 */
void main() {
    vec3 Color = texture2D(colortex0, texcoord).rgb;
    
    #ifdef GODRAYS
    float Depth = texture2D(depthtex0, texcoord).r;
    Color = godrays(Color, texcoord, Depth);
    #endif
    
    gl_FragData[0] = vec4(Color, 1.0);
}
