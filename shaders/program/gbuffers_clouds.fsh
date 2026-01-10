#include "/lib/all_the_libs.glsl"
#include "/global/sky.glsl"

uniform sampler2D texture;
varying vec2 texcoord;
varying vec4 glcolor;

void main() {
	// We use gl_FragCoord to track where the cloud is on your screen
	vec3 ScreenPos = vec3(gl_FragCoord.xy * resolutionInv, gl_FragCoord.z);

	vec4 Color = texture2D(texture, texcoord) * glcolor;

	#ifdef FANCY_CLOUDS
	// 1. Calculate Normals for 3D Shading
	// This makes the blocks look solid instead of flat
	vec3 normal = normalize(cross(dFdx(ScreenPos), dFdy(ScreenPos)));

	// 2. Face Shading (Top is bright, sides are darker)
	float faceShading = clamp(dot(normal, vec3(0.0, 1.0, 0.0)) * 0.4 + 0.6, 0.5, 1.0);

	// 3. Transparency and Lighting
	Color.a *= 0.8;
	Color.rgb = to_linear(Color.rgb) * (SKY_GROUND + 0.06) * 2.2 * faceShading;
	#else
	// Fast/Vanilla path
	Color.rgb = to_linear(Color.rgb) * (SKY_GROUND + 0.02) * 1.5;
	#endif

	#ifdef BORDER_FOG
	// This handles the fading at the edge of your render distance
	vec3 ViewPos = to_view_pos(ScreenPos, false);
	vec3 PlayerPos = to_player_pos(ViewPos);
	float HorizontalDist = len2(PlayerPos.xz);

	HorizontalDist /= pow2(far); // Fade based on your actual vanilla render distance

	Color.a *= exp(-3.0 * HorizontalDist);
	Color.a *= 1.0 - max(darknessFactor, blindness);
	#endif

	/* DRAWBUFFERS:0 */
	gl_FragData[0] = Color;
}
