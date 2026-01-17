// program/gbuffers_skytextured.fsh
#include "/lib/all_the_libs.glsl"

uniform sampler2D gtexture;

varying vec2 texcoord;
varying vec4 glcolor;

/* DRAWBUFFERS:0 */

void main() {
	// Render vanilla sun/moon texture
	vec4 Color = texture2D(gtexture, texcoord) * glcolor;

	// Skip rendering if ROUND_SUN is enabled (custom sun in deferred.fsh)
	#ifdef ROUND_SUN
	discard;
	return;
	#endif

	Color.rgb = to_linear(Color.rgb);
	gl_FragData[0] = Color;
}
