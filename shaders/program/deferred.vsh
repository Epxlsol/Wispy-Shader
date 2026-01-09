#include "/lib/all_the_libs.glsl"

#define f_BIOME_SKY_CONTRIBUTION 1.0 

varying vec2 texcoord;
#include "/global/light_colors.vsh"

void main() {
    init_colors();
    gl_Position = ftransform();
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}
