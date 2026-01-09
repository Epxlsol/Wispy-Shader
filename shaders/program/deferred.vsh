#version 120

// 1. Define the version and necessary extensions
#extension GL_EXT_gpu_shader4 : enable

// 2. Include settings first so variables like NOON_RED are defined
#include "/lib/settings.glsl"

// 3. Include the library
#include "/lib/all_the_libs.glsl"

// 4. Set up the attributes/varyings
varying vec2 texcoord;

// 5. Use a check to prevent the redeclaration error in the light_colors file
#ifndef LIGHT_COLORS_INCLUDED
    #define LIGHT_COLORS_INCLUDED
    #include "/global/light_colors.vsh"
#endif

void main() {
    // Initialize the color system
    init_colors();

    // Standard vertex transformation
    gl_Position = ftransform();
    
    // Map the texture coordinates
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}
