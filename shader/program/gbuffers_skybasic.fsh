// program/gbuffers_skybasic.fsh
#include "/lib/all_the_libs.glsl"

/* DRAWBUFFERS:0 */

void main() {
	// This shader renders the vanilla sun/moon/sky color
	// If ROUND_SUN is defined, this discards to let deferred render the sun

	#ifdef ROUND_SUN
	// Let deferred.fsh handle sun/moon rendering
	discard;
	return;
	#endif

	// Otherwise render vanilla sky color (should be overwritten by deferred anyway)
	gl_FragData[0] = vec4(0, 0, 0, 1);
}
