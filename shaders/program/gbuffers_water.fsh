#include "/lib/all_the_libs.glsl"

uniform sampler2D lightmap;
uniform sampler2D gtexture;

varying vec2 texcoord;
varying vec4 glcolor;
varying vec3 MixedLights;

/* DRAWBUFFERS:0 */

void main() {
    // 1. Get base texture color
    vec4 Color = texture2D(gtexture, texcoord) * glcolor;
    
    // 2. Fast gamma correction
    Color.rgb *= Color.rgb; 
    
    // 3. Apply your preferred defaults (0.25 RGB tint)
    // This makes the water base color significantly brighter/cleaner
    Color.rgb *= vec3(0.25, 0.25, 0.25);
    
    // 4. Apply World Lighting
    Color.rgb *= MixedLights;

    // 5. Force Opacity to 0.1
    // This ensures the water is clear and see-through
    Color.a = 0.1;

    gl_FragData[0] = Color;
}
