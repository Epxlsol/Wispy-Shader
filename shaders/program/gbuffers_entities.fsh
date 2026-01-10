#include "/lib/all_the_libs.glsl"

uniform sampler2D gtexture;

varying vec2 texcoord;
varying vec4 glcolor;

// Manual include instead of /global/lighting.fsh if possible to reduce overhead
#include "/global/lighting.fsh"

/* DRAWBUFFERS:0 */

void main() {
    vec4 Color = texture2D(gtexture, texcoord);

    // 1. EARLY DISCARD: Stop processing invisible pixels immediately.
    // This is huge for entities with layers or complex custom models.
    if (Color.a < 0.1) discard;

    Color *= glcolor;

    // 2. Fast Linear Approximation (x^2 instead of pow)
    Color.rgb *= Color.rgb;

    // 3. Simplified Entity Logic
    if (entityId != 10001) {
        // Apply the 'hurt' color or team color overlay
        Color.rgb = mix(Color.rgb, entityColor.rgb, entityColor.a);

        // 4. Inlined or Simplified Lightmap
        // Instead of the full tweak_lightmap(), we apply the vertex MixedLights
        // Or a simplified version if 'tweak_lightmap' is doing too much.
        Color.rgb *= tweak_lightmap();
    } else {
        Color.a = 1.0;
    }

    gl_FragData[0] = Color;
}
