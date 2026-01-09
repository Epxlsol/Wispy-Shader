// ============================================
// WISPY SHADERS - OPTIMIZED SETTINGS
// Complete standalone file - no external includes needed
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
// COLOR SCHEME SELECTION
// ============================================
#define COLOR_SCHEME 1 // [1 2 3 4 5]
// 1 = Default (balanced)
// 2 = Vanilla (closer to MC defaults)
// 3 = Choc v7 (darker, moodier)
// 4 = Visually Vibrant (saturated)
// 5 = Winter (cool tones)

// ============================================
// COLOR CONSTANTS - DO NOT MODIFY DIRECTLY
// Use COLOR_SCHEME slider to change presets
// ============================================
#define max_const(x) ( x > 0.0 ? x : 0.0)

// Default Color Scheme
#if COLOR_SCHEME == 1

const float f_LM_RED = max_const(1.2 + LM_RED);
const float f_LM_GREEN = max_const(0.9 + LM_GREEN);
const float f_LM_BLUE = max_const(0.6 + LM_BLUE);

const float f_NOON_RED = max_const(1.2 + 0.0);
const float f_NOON_GREEN = max_const(1.1 + 0.0);
const float f_NOON_BLUE = max_const(1.0 + 0.0);

const float f_SUNRISE_RED = max_const(0.8 + 0.0);
const float f_SUNRISE_GREEN = max_const(0.6 + 0.0);
const float f_SUNRISE_BLUE = max_const(0.4 + 0.0);

const float f_SUNSET_RED = max_const(0.8 + 0.0);
const float f_SUNSET_GREEN = max_const(0.5 + 0.0);
const float f_SUNSET_BLUE = max_const(0.2 + 0.0);

const float f_MOON_RED = max_const(0.4 + 0.0);
const float f_MOON_GREEN = max_const(0.4 + 0.0);
const float f_MOON_BLUE = max_const(0.5 + 0.0);

const float f_NOON_SKY_T_R = max_const(0.2 + 0.0);
const float f_NOON_SKY_T_G = max_const(0.35 + 0.0);
const float f_NOON_SKY_T_B = max_const(0.7 + 0.0);

const float f_SUNRISE_SKY_T_R = max_const(0.0 + 0.0);
const float f_SUNRISE_SKY_T_G = max_const(0.25 + 0.0);
const float f_SUNRISE_SKY_T_B = max_const(0.5 + 0.0);

const float f_SUNSET_SKY_T_R = max_const(0.00 + 0.0);
const float f_SUNSET_SKY_T_G = max_const(0.15 + 0.0);
const float f_SUNSET_SKY_T_B = max_const(0.25 + 0.0);

const float f_NIGHT_SKY_T_R = max_const(0.0 + 0.0);
const float f_NIGHT_SKY_T_G = max_const(0.025 + 0.0);
const float f_NIGHT_SKY_T_B = max_const(0.075 + 0.0);

const float f_END_SKY_T_R = max_const(0.15 + 0.0);
const float f_END_SKY_T_G = max_const(0.1 + 0.0);
const float f_END_SKY_T_B = max_const(0.2 + 0.0);

const float f_NOON_SKY_G_R = max_const(0.5 + 0.0);
const float f_NOON_SKY_G_G = max_const(0.55 + 0.0);
const float f_NOON_SKY_G_B = max_const(0.6 + 0.0);

const float f_SUNRISE_SKY_G_R = max_const(0.5 + 0.0);
const float f_SUNRISE_SKY_G_G = max_const(0.4 + 0.0);
const float f_SUNRISE_SKY_G_B = max_const(0.4 + 0.0);

const float f_SUNSET_SKY_G_R = max_const(0.3 + 0.0);
const float f_SUNSET_SKY_G_G = max_const(0.25 + 0.0);
const float f_SUNSET_SKY_G_B = max_const(0.25 + 0.0);

const float f_NIGHT_SKY_G_R = max_const(0.15 + 0.0);
const float f_NIGHT_SKY_G_G = max_const(0.2 + 0.0);
const float f_NIGHT_SKY_G_B = max_const(0.25 + 0.0);

const float f_SUN_GLARE_R = max_const(0.8 + 0.0);
const float f_SUN_GLARE_G = max_const(0.45 + 0.0);
const float f_SUN_GLARE_B = max_const(0.0 + 0.0);

const float f_NETHER_AMBIENT_R = max_const(0.48 + 0.0);
const float f_NETHER_AMBIENT_G = max_const(0.24 + 0.0);
const float f_NETHER_AMBIENT_B = max_const(0.18 + 0.0);

const float f_END_AMBIENT_R = max_const(0.2 + 0.0);
const float f_END_AMBIENT_G = max_const(0.17 + 0.0);
const float f_END_AMBIENT_B = max_const(0.25 + 0.0);

const float f_END_DIRECT_R = max_const(0.3 + 0.0);
const float f_END_DIRECT_G = max_const(0.23 + 0.0);
const float f_END_DIRECT_B = max_const(0.45 + 0.0);

const float f_END_AURORA1_R = max_const(0.0 + 0.0);
const float f_END_AURORA1_G = max_const(0.45 + 0.0);
const float f_END_AURORA1_B = max_const(0.25 + 0.0);

const float f_END_AURORA2_R = max_const(0.45 + 0.0);
const float f_END_AURORA2_G = max_const(0.3 + 0.0);
const float f_END_AURORA2_B = max_const(0.1 + 0.0);

const float f_SUNRISE_AMBIENT = max_const(0.45 + 0.0);
const float f_NOON_AMBIENT = max_const(0.6 + 0.0);
const float f_SUNSET_AMBIENT = max_const(0.5 + 0.0);
const float f_NIGHT_AMBIENT = max_const(0.2 + 0.0);

const float f_WATER_RED = max_const(0.0 + 0.0);
const float f_WATER_GREEN = max_const(0.35 + 0.0);
const float f_WATER_BLUE = max_const(0.25 + 0.0);
const float f_WATER_ALPHA = max_const(0.4 + 0.0);

const float f_BIOME_WATER_CONTRIBUTION = max_const(0.5 + 0.0);
const float f_BIOME_SKY_CONTRIBUTION = max_const(0.3 + 0.0);

// Vanilla Color Scheme
#elif COLOR_SCHEME == 2

const float f_LM_RED = max_const(1.1 + LM_RED);
const float f_LM_GREEN = max_const(0.9 + LM_GREEN);
const float f_LM_BLUE = max_const(0.7 + LM_BLUE);

const float f_NOON_RED = max_const(1.05 + 0.0);
const float f_NOON_GREEN = max_const(1.0 + 0.0);
const float f_NOON_BLUE = max_const(1.0 + 0.0);

const float f_SUNRISE_RED = max_const(0.9 + 0.0);
const float f_SUNRISE_GREEN = max_const(0.73 + 0.0);
const float f_SUNRISE_BLUE = max_const(0.5 + 0.0);

const float f_SUNSET_RED = max_const(0.9 + 0.0);
const float f_SUNSET_GREEN = max_const(0.73 + 0.0);
const float f_SUNSET_BLUE = max_const(0.5 + 0.0);

const float f_MOON_RED = max_const(0.4 + 0.0);
const float f_MOON_GREEN = max_const(0.4 + 0.0);
const float f_MOON_BLUE = max_const(0.5 + 0.0);

const float f_NOON_SKY_T_R = max_const(0.25 + 0.0);
const float f_NOON_SKY_T_G = max_const(0.38 + 0.0);
const float f_NOON_SKY_T_B = max_const(0.7 + 0.0);

const float f_SUNRISE_SKY_T_R = max_const(0.22 + 0.0);
const float f_SUNRISE_SKY_T_G = max_const(0.37 + 0.0);
const float f_SUNRISE_SKY_T_B = max_const(0.67 + 0.0);

const float f_SUNSET_SKY_T_R = max_const(0.22 + 0.0);
const float f_SUNSET_SKY_T_G = max_const(0.37 + 0.0);
const float f_SUNSET_SKY_T_B = max_const(0.67 + 0.0);

const float f_NIGHT_SKY_T_R = max_const(0.0 + 0.0);
const float f_NIGHT_SKY_T_G = max_const(0.025 + 0.0);
const float f_NIGHT_SKY_T_B = max_const(0.075 + 0.0);

const float f_END_SKY_T_R = max_const(0.12 + 0.0);
const float f_END_SKY_T_G = max_const(0.1 + 0.0);
const float f_END_SKY_T_B = max_const(0.15 + 0.0);

const float f_NOON_SKY_G_R = max_const(0.5 + 0.0);
const float f_NOON_SKY_G_G = max_const(0.55 + 0.0);
const float f_NOON_SKY_G_B = max_const(0.6 + 0.0);

const float f_SUNRISE_SKY_G_R = max_const(0.47 + 0.0);
const float f_SUNRISE_SKY_G_G = max_const(0.52 + 0.0);
const float f_SUNRISE_SKY_G_B = max_const(0.55 + 0.0);

const float f_SUNSET_SKY_G_R = max_const(0.47 + 0.0);
const float f_SUNSET_SKY_G_G = max_const(0.52 + 0.0);
const float f_SUNSET_SKY_G_B = max_const(0.55 + 0.0);

const float f_NIGHT_SKY_G_R = max_const(0.07 + 0.0);
const float f_NIGHT_SKY_G_G = max_const(0.1 + 0.0);
const float f_NIGHT_SKY_G_B = max_const(0.13 + 0.0);

const float f_SUN_GLARE_R = max_const(0.75 + 0.0);
const float f_SUN_GLARE_G = max_const(0.5 + 0.0);
const float f_SUN_GLARE_B = max_const(0.0 + 0.0);

const float f_NETHER_AMBIENT_R = max_const(0.45 + 0.0);
const float f_NETHER_AMBIENT_G = max_const(0.3 + 0.0);
const float f_NETHER_AMBIENT_B = max_const(0.22 + 0.0);

const float f_END_AMBIENT_R = max_const(0.3 + 0.0);
const float f_END_AMBIENT_G = max_const(0.3 + 0.0);
const float f_END_AMBIENT_B = max_const(0.35 + 0.0);

const float f_END_DIRECT_R = max_const(0.25 + 0.0);
const float f_END_DIRECT_G = max_const(0.3 + 0.0);
const float f_END_DIRECT_B = max_const(0.3 + 0.0);

const float f_END_AURORA1_R = max_const(0.0 + 0.0);
const float f_END_AURORA1_G = max_const(0.45 + 0.0);
const float f_END_AURORA1_B = max_const(0.25 + 0.0);

const float f_END_AURORA2_R = max_const(0.45 + 0.0);
const float f_END_AURORA2_G = max_const(0.3 + 0.0);
const float f_END_AURORA2_B = max_const(0.1 + 0.0);

const float f_SUNRISE_AMBIENT = max_const(0.5 + 0.0);
const float f_NOON_AMBIENT = max_const(0.5 + 0.0);
const float f_SUNSET_AMBIENT = max_const(0.5 + 0.0);
const float f_NIGHT_AMBIENT = max_const(0.3 + 0.0);

const float f_WATER_RED = max_const(0.0 + 0.0);
const float f_WATER_GREEN = max_const(0.35 + 0.0);
const float f_WATER_BLUE = max_const(0.25 + 0.0);
const float f_WATER_ALPHA = max_const(0.6 + 0.0);

const float f_BIOME_WATER_CONTRIBUTION = clamp(0.7 + 0.0, 0, 1);
const float f_BIOME_SKY_CONTRIBUTION = max_const(0.8 + 0.0);

// Other color schemes (3, 4, 5) use Default for now
// You can expand these later if needed
#else

const float f_LM_RED = max_const(1.2 + LM_RED);
const float f_LM_GREEN = max_const(0.9 + LM_GREEN);
const float f_LM_BLUE = max_const(0.6 + LM_BLUE);

const float f_NOON_RED = max_const(1.2 + 0.0);
const float f_NOON_GREEN = max_const(1.1 + 0.0);
const float f_NOON_BLUE = max_const(1.0 + 0.0);

const float f_SUNRISE_RED = max_const(0.8 + 0.0);
const float f_SUNRISE_GREEN = max_const(0.6 + 0.0);
const float f_SUNRISE_BLUE = max_const(0.4 + 0.0);

const float f_SUNSET_RED = max_const(0.8 + 0.0);
const float f_SUNSET_GREEN = max_const(0.5 + 0.0);
const float f_SUNSET_BLUE = max_const(0.2 + 0.0);

const float f_MOON_RED = max_const(0.4 + 0.0);
const float f_MOON_GREEN = max_const(0.4 + 0.0);
const float f_MOON_BLUE = max_const(0.5 + 0.0);

const float f_NOON_SKY_T_R = max_const(0.2 + 0.0);
const float f_NOON_SKY_T_G = max_const(0.35 + 0.0);
const float f_NOON_SKY_T_B = max_const(0.7 + 0.0);

const float f_SUNRISE_SKY_T_R = max_const(0.0 + 0.0);
const float f_SUNRISE_SKY_T_G = max_const(0.25 + 0.0);
const float f_SUNRISE_SKY_T_B = max_const(0.5 + 0.0);

const float f_SUNSET_SKY_T_R = max_const(0.00 + 0.0);
const float f_SUNSET_SKY_T_G = max_const(0.15 + 0.0);
const float f_SUNSET_SKY_T_B = max_const(0.25 + 0.0);

const float f_NIGHT_SKY_T_R = max_const(0.0 + 0.0);
const float f_NIGHT_SKY_T_G = max_const(0.025 + 0.0);
const float f_NIGHT_SKY_T_B = max_const(0.075 + 0.0);

const float f_END_SKY_T_R = max_const(0.15 + 0.0);
const float f_END_SKY_T_G = max_const(0.1 + 0.0);
const float f_END_SKY_T_B = max_const(0.2 + 0.0);

const float f_NOON_SKY_G_R = max_const(0.5 + 0.0);
const float f_NOON_SKY_G_G = max_const(0.55 + 0.0);
const float f_NOON_SKY_G_B = max_const(0.6 + 0.0);

const float f_SUNRISE_SKY_G_R = max_const(0.5 + 0.0);
const float f_SUNRISE_SKY_G_G = max_const(0.4 + 0.0);
const float f_SUNRISE_SKY_G_B = max_const(0.4 + 0.0);

const float f_SUNSET_SKY_G_R = max_const(0.3 + 0.0);
const float f_SUNSET_SKY_G_G = max_const(0.25 + 0.0);
const float f_SUNSET_SKY_G_B = max_const(0.25 + 0.0);

const float f_NIGHT_SKY_G_R = max_const(0.15 + 0.0);
const float f_NIGHT_SKY_G_G = max_const(0.2 + 0.0);
const float f_NIGHT_SKY_G_B = max_const(0.25 + 0.0);

const float f_SUN_GLARE_R = max_const(0.8 + 0.0);
const float f_SUN_GLARE_G = max_const(0.45 + 0.0);
const float f_SUN_GLARE_B = max_const(0.0 + 0.0);

const float f_NETHER_AMBIENT_R = max_const(0.48 + 0.0);
const float f_NETHER_AMBIENT_G = max_const(0.24 + 0.0);
const float f_NETHER_AMBIENT_B = max_const(0.18 + 0.0);

const float f_END_AMBIENT_R = max_const(0.2 + 0.0);
const float f_END_AMBIENT_G = max_const(0.17 + 0.0);
const float f_END_AMBIENT_B = max_const(0.25 + 0.0);

const float f_END_DIRECT_R = max_const(0.3 + 0.0);
const float f_END_DIRECT_G = max_const(0.23 + 0.0);
const float f_END_DIRECT_B = max_const(0.45 + 0.0);

const float f_END_AURORA1_R = max_const(0.0 + 0.0);
const float f_END_AURORA1_G = max_const(0.45 + 0.0);
const float f_END_AURORA1_B = max_const(0.25 + 0.0);

const float f_END_AURORA2_R = max_const(0.45 + 0.0);
const float f_END_AURORA2_G = max_const(0.3 + 0.0);
const float f_END_AURORA2_B = max_const(0.1 + 0.0);

const float f_SUNRISE_AMBIENT = max_const(0.45 + 0.0);
const float f_NOON_AMBIENT = max_const(0.6 + 0.0);
const float f_SUNSET_AMBIENT = max_const(0.5 + 0.0);
const float f_NIGHT_AMBIENT = max_const(0.2 + 0.0);

const float f_WATER_RED = max_const(0.0 + 0.0);
const float f_WATER_GREEN = max_const(0.35 + 0.0);
const float f_WATER_BLUE = max_const(0.25 + 0.0);
const float f_WATER_ALPHA = max_const(0.4 + 0.0);

const float f_BIOME_WATER_CONTRIBUTION = max_const(0.5 + 0.0);
const float f_BIOME_SKY_CONTRIBUTION = max_const(0.3 + 0.0);

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
#define SSR_STEPS 8 // [4 6 8 10 12 16 20]
#define REFLECT_SUN
#define WATER_TEXTURE_MODE 1 // [0 1 2]

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

// ============================================
// MISC SETTINGS
// ============================================
#define ENCHANT_GLINT_OPACITY 0.7 // [0.0 to 1.0]
//#define HANDHELD_LIGHTS
#define MOON_PHASE_INFLUENCE 0.3 // [0.0 to 1.0]

#define RAIN_SKY_DESATURATION 0.5 // [0.0 to 1.0]
#define RAIN_SKY_DARKENING 0.33 // [0.0 to 1.0]

const float sunPathRotation = -30; // [-40 to 40]

// ============================================
// DISTANT HORIZONS
// ============================================
#define DH_NOISE
#define DH_CUTOFF 16 // [0 16 32 48 64 80 96 128]
#define DH_NOISE_SIZE 8 // [2 4 8 16 32 64]

// ============================================
// DEBUG
// ============================================
//#define DEBUG_BUFFER
#define DEBUG_SHOW_BUFFER 0 // [0 1 2 3 4]
