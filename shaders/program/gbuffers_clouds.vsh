#include "/lib/all_the_libs.glsl"

varying vec2 texcoord;
varying vec4 glcolor;

void main() {
	// 1. Standard transformation
	// Using ftransform() ensures the clouds stay where the game expects them
	gl_Position = ftransform();

	// 2. The "Cutting Out" Fix:
	// We slightly nudge the Z-position to prevent the clouds from
	// clipping into the 'Far Plane' of your render distance.
	gl_Position.z -= 0.00001;

	// 3. Pass data to the fragment shader
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	glcolor = gl_Color;
}
