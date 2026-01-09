// Fix for the "Undeclared" error
#if !defined f_BIOME_SKY_CONTRIBUTION
    #define f_BIOME_SKY_CONTRIBUTION 1.0
#endif

// Fix for the "Redeclared" error
#ifndef COLORTEX_SAMPLERS
    #define COLORTEX_SAMPLERS
    uniform sampler2D colortex0;
    // Add others if needed: uniform sampler2D colortex1;
#endif
#extension GL_EXT_gpu_shader4 : enable

#include "/lib/settings.glsl"
#include "/lib/colors.glsl"
#include "/lib/all_the_uniforms.glsl"
#include "/lib/util.glsl"
#include "/lib/noise.glsl"
#include "/lib/distant_horizons.glsl"
#include "/lib/tonemap_operators.glsl"
#include "/lib/tonemap.glsl"
