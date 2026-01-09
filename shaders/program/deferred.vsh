#include "/lib/all_the_libs.glsl"

// 1. Fix the "Undeclared" error
#ifndef f_BIOME_SKY_CONTRIBUTION
    #define f_BIOME_SKY_CONTRIBUTION 1.0 
#endif

// 2. Fix the "Redeclared" error
// We define this macro so that light_colors.vsh knows colortex0 is already here
#define COLORTEX0_EXISTS 

varying vec2 texcoord;

#include "/global/light_colors.vsh"

void main() {
    init_colors();
    gl_Position = ftransform();
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}
