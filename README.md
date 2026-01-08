# Wispy Shaders V1.1

A performance-optimized shader pack initially based on Mellow Shaders and outperforms many other so claimed 'potato' shaders.

## Credits

- **Original Shader**: [Mellow Shaders](https://modrinth.com/shader/mellow) by [TheCMK](https://modrinth.com/user/TheCMK)
- **Performance Optimizations**: [l_aggy](https://modrinth.com/user/l_aggy) 

## Features

-  **Ultra-optimized** for integrated graphics (iGPUs)
-  **250+ FPS** on integrated graphics (ULTRA_PERFORMANCE profile)
- **Color grading** and biome‑specific lighting for all dimensions.
- **Customizable atmosphere** with godrays, auroras, and configurable clouds and fog.
- **Reflective water** with biome‑aware water colors.
- **Cinematic post‑processing**: bloom, SSAO, SMAA, sharpening, tonemapping, DOF, motion blur, film grain, vignette.

## To-do

1. Skip Vanilla Sky
2. Weather Particle Reduction
3. Lightmap Throttling
4. More benchmarking

## Performance Profiles
- iGPU (8 Chunks) tested on i5-4570 (HD4600) on CachyOS
- dGPU (24 Chunks) tested on R9 8940HX (5060 Laptop=4060 desktop) on Windows 11
  
- Choose a profile in shader settings that matches your hardware:

| Profile | FPS (iGPU) | FPS (dGPU) | Description |
|---------|------------|------------|-------------|
| **ULTRA_PERFORMANCE** | 250+ | 400+ | Maximum FPS, minimal effects |
| **PERFORMANCE** | 250+ | ?? | Good balance for iGPU |
| **BALANCED** | 180+ | ?? | A mix of features |
| **QUALITY** | 100+ | ?? | More effects |
| **ULTRA_QUALITY** | 90+ | 300+ | Lowest FPS, All features |

## Installation

1. Install [Iris Shaders](https://irisshaders.dev/) or OptiFine
2. Download Wispy Shaders
3. Place the ZIP file in `.minecraft/shaderpacks/`
4. Select Wispy in Video Settings → Shaders
5. Choose a performance profile

## Compatibility

- ✅ Minecraft 1.8 - 1.21.x
- ✅ Iris Shaders
- ✅ OptiFine
- ✅ Works great with Sodium + Iris

## 🎯 Performance Optimizations

### Core Rendering
- **Fast gamma correction** - Replaced expensive polynomial `to_linear()` with `x*x` approximation (3x faster)
- **Optimized vertex lighting** - Eliminated `pow()` calls in per-vertex calculations, replaced with inline multiplication
- **Removed TAA jitter overhead** - Disabled expensive temporal anti-aliasing calculations when not needed
- **Streamlined composite pipeline** - Disabled 10+ unused composite passes by default (bloom, SMAA, DOF)

### Vertex Shaders
- **Fast wavy plants** - Replaced `sin()` with triangle wave approximation (3x faster, visually identical)
- **Efficient lighting calculations** - Removed per-vertex texture lookups for flicker effects
- **Optimized handheld lights** - Replaced `pow()` with direct multiplication for falloff
- **Removed lightning calculations** - Only computed when lightning actually present

### Fragment Shaders
- **Simplified fog system** - Removed expensive raymarching for godrays, replaced with analytical phase function
- **Fast atmospheric scattering** - Eliminated `fbm_fast()` fractal noise and `pow4()` calculations
- **Optimized water fog** - Fast gamma correction, reduced branching
- **Minimal post-processing** - Stripped unnecessary effects from final pass

### Shader Architecture
- **Early exit optimizations** - Skip expensive calculations for hand rendering and UI
- **Reduced buffer usage** - Removed unused render targets (normals, bloom when disabled)

### Memory & Bandwidth
- **Optimized composite passes** - Composites disable when features set to off
- **Optimized texture sampling** - Reduced redundant lightmap lookups
- **Streamlined uniforms** - Removed complex per-frame calculations

## License

MIT License (same as original Mellow Shaders)

## Links

- Original Mellow: https://modrinth.com/shader/mellow
- Report Issues: https://github.com/epxlsol/wispy-shader/issues

---

**Note**: This is a performance-focused fork. For the original experience with all features, use [Mellow Shaders](https://modrinth.com/shader/mellow).
