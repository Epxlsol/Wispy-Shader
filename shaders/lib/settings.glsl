// ============================================
// WISPY SHADERS - OPTIMIZED SETTINGS
// Removed duplicate/unused settings
// Fixed color scheme organization
// ============================================

// ============================================
// LIGHTING SETTINGS
// ============================================
#define LM_RED 0.0 // [-1.0 to 1.0]
#define LM_GREEN 0.0
#define LM_BLUE 0.0
#define LM_FALLOFF_CURVE 1.6 // [0.0 to 2.0]

#define HANDHELD_FALLOFF_CURVE 1.4 // [0.0 to 2.0]
#define MIN_LIGHT_AMOUNT 0.15 // [0.0 to 0.4]

// ============================================
// COLOR PRESETS (Choose one)
// ============================================
#define COLOR_SCHEME 1 // [1 2 3 4 5]
// 1 = Default (balanced)
// 2 = Vanilla (closer to MC defaults)
// 3 = Choc v7 (darker, moodier)
// 4 = Visually Vibrant (saturated)
// 5 = Winter (cool tones)

// Only include selected color scheme
#if COLOR_SCHEME == 1
    #include "/lib/colors_default.glsl"
#elif COLOR_SCHEME == 2
    #include "/lib/colors_vanilla.glsl"
#elif COLOR_SCHEME == 3
    #include "/lib/colors_choc.glsl"
#elif COLOR_SCHEME == 4
    #include "/lib/colors_vibrant.glsl"
#elif COLOR_SCHEME == 5
    #include "/lib/colors_winter.glsl"
#endif

// ============================================
// WATER SETTINGS
// ============================================
#define WATER_FOG_STRENGTH 0.3 // [0.0 to 0.5]

#define WATER_NORMALS
#define WATER_NORMAL_SIZE 1.0 // [0.2 to 2.0]
#define WATER_NORMAL_STRENGTH 1.0 // [0.25 to 2.0]
#define WATER_NORMAL_SPEED 1.0 // [0.5 to 2.0]

#define FANCY_WATER
#define REFLECTIONS 3 // [0 1 2 3]
// 0 = Off, 1 = Sky Only, 2 = Raytraced, 3 = Flipped Image
#define SSR_STEPS 8 // [4 6 8 10 12 16 20]
#define REFLECT_SUN
#define WATER_TEXTURE_MODE 1 // [0 1 2]
// 0 = Vanilla, 1 = Tinted, 2 = No Texture

// ============================================
// FOG SETTINGS
// ============================================
#define BORDER_FOG
#define ATMOSPHERIC_FOG
#define ATM_FOG_STRENGTH 0.25 // [0.0 to 0.5]

// ============================================
// POST PROCESSING
// ============================================
#define EXPOSURE 2.3 // [0.0 to 3.0]
#define SATURATION 1.0 // [0.0 to 2.0]
#define VIBRANCE 1.1 // [0.0 to 2.0]
#define CONTRAST 0.95 // [0.5 to 1.0]

#define TONEMAP_MIN_R 0.0 // [0.0 to 0.15]
#define TONEMAP_MIN_G 0.0
#define TONEMAP_MIN_B 0.0

#define BLOOM
#define BLOOM_STRENGTH 0.4 // [0.0 to 1.0]
#define BLOOM_CURVE 0.4 // [0.1 to 1.0]

// ============================================
// SKY SETTINGS
// ============================================
#define FANCY_CLOUDS
#define CLOUD_AMOUNT 22 // [12 to 26]
#define CLOUD_OPACITY 0.24 // [0.0 to 0.4]
#define CLOUD_SPEED 2 // [0 to 6]
#define CLOUD_QUALITY 2 // [2 to 9]

#define AURORA_BOREALIS
#define AURORA_STRENGTH 0.2 // [0.1 to 0.5]
#define AURORA_HEIGHT 3.0 // [1.0 to 10.0]

#define STAR_SIZE 1.0 // [0.25 to 1.5]
#define STAR_STRENGTH 0.5 // [0.25 to 2.0]

//#define ROUND_SUN
#ifndef DIMENSION_NETHER
    //#define CUSTOM_SKYBOXES
    #define CUSTOM_SKYBOX_BRIGHTNESS 0.5 // [0.0 to 1.0]
#endif

// ============================================
// TERRAIN ANIMATION
// ============================================
#define WAVY_PLANTS
#define WAVE_AMPLITUDE 0.1 // [0.025 to 0.2]
#define WAVE_SPEED 0.75 // [0.25 to 2.0]
#define WAVE_SIZE 1.5 // [0.25 to 3.0]
#define WAVE_LEAVES
#define RAIN_TILT_STRENGTH 1.2 // [0.5 to 1.5]

// ============================================
// ANTI-ALIASING
// ============================================
#define TAA_MODE 0 // [0 1 2 3 4]
// 0 = Off, 1 = Denoise Only, 2 = Regular, 3 = Fancy, 4 = Super Resolution
#define TAA_BLEND_FACTOR 0.9 // [0.85 to 0.95]
#define TAA_OFFCENTER_REJECTION 0.15 // [0.0 to 0.3]

//#define SMAA
#define SMAA_THRESHOLD 0.30 // [0.15 to 0.40]
#define SMAA_SEARCH_DISTANCE 16 // [8 16 24 32 48 64]

// ============================================
// ADVANCED POST PROCESSING
// ============================================
//#define SSAO
#define SSAO_STRENGTH 0.3 // [0.1 to 0.5]
#define SSAO_SCALE 0.5 // [0.25 to 0.75]

//#define GODRAYS
#define GODRAYS_QUALITY 4 // [2 to 8]

//#define DOF
#define DOF_APERTURE_SIZE 10 // [1 to 40]
#define DOF_BLUR_QUALITY 12 // [8 12 16 24 32]
#define DOF_FOCUS_ADJUSTMENT_SPEED 2.0 // [0.2 to 4.0]
//#define DOF_MANUAL_FOCUS
#define DOF_FOCUS_DISTANCE 32 // [1 to 159]

//#define MOTION_BLUR
#define MOTION_BLUR_STRENGTH 0.3 // [0.0 to 1.0]

//#define IMAGE_SHARPENING
#define SHARPENING 0.2 // [0.1 to 1.0]

//#define FILM_GRAIN
#define FILM_GRAIN_STRENGTH 0.05 // [0.025 to 0.2]

#define VIGNETTE_OPACITY 0.0 // [0.0 to 2.0]
#define VIGNETTE_FALLOFF 0.75 // [0.0 to 1.5]

#define TONEMAP_OPERATOR 1 // [1 2 3 4 5 6]
// 1 = ACES Simple, 2 = Reinhard-Jodie, 3 = ACES Fit
// 4 = Hejl 2015, 5 = Lottes, 6 = Uchimura

// ============================================
// MISC SETTINGS
// ============================================
#define ENCHANT_GLINT_OPACITY 0.7 // [0.0 to 1.0]
//#define HANDHELD_LIGHTS
#define MOON_PHASE_INFLUENCE 0.3 // [0.0 to 1.0]

#define RAIN_SKY_DESATURATION 0.5 // [0.0 to 1.0]
#define RAIN_SKY_DARKENING 0.33 // [0.0 to 1.0]

#define sunPathRotation -30 // [-40 to 40]

// ============================================
// DISTANT HORIZONS
// ============================================
#define DH_NOISE
#define DH_CUTOFF 16 // [0 16 32 48 64 80 96 128]
#define DH_NOISE_SIZE 8 // [2 4 8 16 32 64]

// ============================================
// DEBUG (Leave disabled for production)
// ============================================
//#define DEBUG_BUFFER
#define DEBUG_SHOW_BUFFER 0 // [0 1 2 3 4]
