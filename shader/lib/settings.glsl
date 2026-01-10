// ===== LIGHTING =====
#define LM_RED 0.0
#define LM_GREEN 0.0
#define LM_BLUE 0.0
#define LM_FALLOFF_CURVE 1.6 // [0.0 0.2 0.4 0.6 0.8 1.0 1.2 1.4 1.6 1.8 2.0]
#define HANDHELD_FALLOFF_CURVE 1.4 // [0.0 0.2 0.4 0.6 0.8 1.0 1.2 1.4 1.6 1.8 2.0]
#define LM_FLICKER
#define LM_FLICKER_STRENGTH 0.25 // [0.0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5]
#define MIN_LIGHT_AMOUNT 0.15 // [0.0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4]
// #define HANDHELD_LIGHTS // Disabled by default for performance

// ===== SUN & MOON COLORS =====
#define NOON_RED 0.0
#define NOON_GREEN 0.0
#define NOON_BLUE 0.0
#define SUNRISE_RED 0.0
#define SUNRISE_GREEN 0.0
#define SUNRISE_BLUE 0.0
#define SUNSET_RED 0.0
#define SUNSET_GREEN 0.0
#define SUNSET_BLUE 0.0
#define MOON_RED 0.0
#define MOON_GREEN 0.0
#define MOON_BLUE 0.0
#define MOON_PHASE_INFLUENCE 0.3 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]

// ===== SKY COLORS =====
#define NOON_SKY_T_R 0.0
#define NOON_SKY_T_G 0.0
#define NOON_SKY_T_B 0.0
#define SUNRISE_SKY_T_R 0.0
#define SUNRISE_SKY_T_G 0.0
#define SUNRISE_SKY_T_B 0.0
#define SUNSET_SKY_T_R 0.0
#define SUNSET_SKY_T_G 0.0
#define SUNSET_SKY_T_B 0.0
#define NIGHT_SKY_T_R 0.0
#define NIGHT_SKY_T_G 0.0
#define NIGHT_SKY_T_B 0.0
#define END_SKY_T_R 0.0
#define END_SKY_T_G 0.0
#define END_SKY_T_B 0.0

#define NOON_SKY_G_R 0.0
#define NOON_SKY_G_G 0.0
#define NOON_SKY_G_B 0.0
#define SUNRISE_SKY_G_R 0.0
#define SUNRISE_SKY_G_G 0.0
#define SUNRISE_SKY_G_B 0.0
#define SUNSET_SKY_G_R 0.0
#define SUNSET_SKY_G_G 0.0
#define SUNSET_SKY_G_B 0.0
#define NIGHT_SKY_G_R 0.0
#define NIGHT_SKY_G_G 0.0
#define NIGHT_SKY_G_B 0.0

#define SUN_GLARE_R 0.0
#define SUN_GLARE_G 0.0
#define SUN_GLARE_B 0.0

// ===== DIMENSION COLORS =====
#define NETHER_AMBIENT_R 0.0
#define NETHER_AMBIENT_G 0.0
#define NETHER_AMBIENT_B 0.0
#define END_AMBIENT_R 0.0
#define END_AMBIENT_G 0.0
#define END_AMBIENT_B 0.0
#define END_DIRECT_R 0.0
#define END_DIRECT_G 0.0
#define END_DIRECT_B 0.0
#define END_AURORA1_R 0.0
#define END_AURORA1_G 0.0
#define END_AURORA1_B 0.0
#define END_AURORA2_R 0.0
#define END_AURORA2_G 0.0
#define END_AURORA2_B 0.0

#define SUNRISE_AMBIENT 0.0
#define NOON_AMBIENT 0.0
#define SUNSET_AMBIENT 0.0
#define NIGHT_AMBIENT 0.0

// ===== WATER SETTINGS =====
#define WATER_RED 0.0
#define WATER_GREEN 0.0
#define WATER_BLUE 0.0
#define WATER_ALPHA 0.0
#define BIOME_WATER_CONTRIBUTION 0.0
#define BIOME_SKY_CONTRIBUTION 0.0
#define WATER_FOG_STRENGTH 0.3 // [0.0 0.1 0.2 0.3 0.4 0.5]

// #define WATER_NORMALS // Disabled for performance
#define WATER_NORMAL_SIZE 1.0 // [0.5 0.75 1.0 1.25 1.5 1.75 2.0]
#define WATER_NORMAL_STRENGTH 1.0 // [0.25 0.5 0.75 1.0 1.25 1.5 1.75 2.0]
#define WATER_NORMAL_SPEED 1.0 // [0.5 0.75 1.0 1.25 1.5 1.75 2.0]

// #define FANCY_WATER // Disabled for performance
#define SSR_STEPS 8 // [4 6 8 10 12 16 20]
#define REFLECTIONS 0 // [0 1 2 3] // Disabled for performance
// #define REFLECT_SUN // Disabled for performance
#define WATER_TEXTURE_MODE 1 // [0 1 2]

// ===== FOG SETTINGS =====
#define BORDER_FOG
#define ATMOSPHERIC_FOG
#define ATM_FOG_STRENGTH 0.5 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]

// ===== COLOR GRADING =====
#define EXPOSURE 2.3 // [0.0 0.5 1.0 1.5 2.0 2.5 3.0]
#define SATURATION 1.0 // [0.0 0.5 1.0 1.5 2.0]
#define VIBRANCE 1.1 // [0.0 0.5 1.0 1.5 2.0]
#define CONTRAST 0.95 // [0.5 0.75 0.9 0.95 1.0]
#define TONEMAP_MIN_R 0.0 // [0.0 0.05 0.1 0.15]
#define TONEMAP_MIN_G 0.0 // [0.0 0.05 0.1 0.15]
#define TONEMAP_MIN_B 0.0 // [0.0 0.05 0.1 0.15]
#define TONEMAP_OPERATOR 1 // [1 2 3 4 5 6]

// ===== POST PROCESSING =====
// #define BLOOM // Disabled for performance
#define BLOOM_STRENGTH 0.4 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define BLOOM_CURVE 0.4 // [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]

// #define FANCY_CLOUDS // Disabled for performance
#define CLOUD_AMOUNT 22 // [12 14 16 18 20 22 24 26]
#define CLOUD_OPACITY 0.24 // [0.0 0.1 0.2 0.3 0.4]
#define CLOUD_SPEED 2 // [0 1 2 3 4 5 6]
#define CLOUD_QUALITY 1 // [1 2 3 4 5] // Reduced for performance

// #define AURORA_BOREALIS // Disabled for performance
#define AURORA_STRENGTH 0.2 // [0.1 0.2 0.3 0.4 0.5]
#define AURORA_HEIGHT 3.0 // [1.0 2.0 3.0 4.0 5.0]
// #define AURORA_EVERYWHERE

#define VANILLA_CLOUD_DISTANCE 128 // [32 64 96 128]

// #define FILM_GRAIN // Disabled for performance
#define FILM_GRAIN_STRENGTH 0.05 // [0.025 0.05 0.075 0.1]

// #define ROUND_SUN // Disabled for performance

#define RAIN_SKY_DESATURATION 0.5 // [0.0 0.25 0.5 0.75 1.0]
#define RAIN_SKY_DARKENING 0.33 // [0.0 0.25 0.5 0.75 1.0]

#ifndef DIMENSION_NETHER
    // #define CUSTOM_SKYBOXES // Disabled for performance
    #define CUSTOM_SKYBOX_BRIGHTNESS 0.5 // [0.0 0.25 0.5 0.75 1.0]
#endif

// ===== TERRAIN ANIMATION =====
#define WAVY_PLANTS
#define WAVE_AMPLITUDE 0.1 // [0.025 0.05 0.075 0.1 0.125 0.15 0.175 0.2]
#define WAVE_SPEED 0.75 // [0.25 0.5 0.75 1.0 1.25 1.5 1.75 2.0]
#define WAVE_SIZE 1.5 // [0.5 1.0 1.5 2.0 2.5 3.0]
#define WAVE_LEAVES
#define RAIN_TILT_STRENGTH 1.2 // [0.5 0.75 1.0 1.2 1.4 1.5]

// ===== CELESTIAL =====
#define STAR_SIZE 1.0 // [0.5 0.75 1.0 1.25 1.5]
#define STAR_STRENGTH 0.5 // [0.25 0.5 0.75 1.0 1.5 2.0]

// ===== CAMERA EFFECTS =====
#define VIGNETTE_FALLOFF 0.75 // [0.0 0.5 0.75 1.0 1.25 1.5]
#define VIGNETTE_OPACITY 0.0 // [0.0 0.5 1.0 1.5 2.0]

// #define GODRAYS // Disabled for performance
#define GODRAYS_QUALITY 4 // [2 3 4 5 6 7 8]

// #define MOTION_BLUR // Disabled for performance
#define MOTION_BLUR_STRENGTH 0.3 // [0.0 0.1 0.2 0.3 0.4 0.5]

// ===== ADVANCED EFFECTS =====
// #define SSAO // Disabled for performance
#define SSAO_STRENGTH 0.3 // [0.1 0.2 0.3 0.4 0.5]
#define SSAO_SCALE 0.5 // [0.25 0.35 0.45 0.5 0.65 0.75]

// #define DOF // Disabled for performance
#define DOF_APERTURE_SIZE 10 // [5 10 15 20 30 40]
#define DOF_BLUR_QUALITY 12 // [8 12 16 24 32]
#define DOF_FOCUS_ADJUSTMENT_SPEED 2.0 // [1.0 1.5 2.0 2.5 3.0 4.0]
// #define DOF_MANUAL_FOCUS
#define DOF_FOCUS_DISTANCE 32 // [8 16 32 64 96 128]
// #define DOF_SHOW_FOCUS

// ===== ANTI-ALIASING =====
#define TAA_MODE 0 // [0 1 2 3 4] // Disabled for performance
#define TAA_BLEND_FACTOR 0.9 // [0.85 0.87 0.9 0.92 0.95]
#define TAA_OFFCENTER_REJECTION 0.15 // [0.0 0.1 0.15 0.2 0.3]

// #define SMAA // Disabled for performance
#define SMAA_THRESHOLD 0.30 // [0.15 0.20 0.25 0.30 0.35 0.40]
#define SMAA_SEARCH_DISTANCE 16 // [8 16 24 32]

// #define IMAGE_SHARPENING // Disabled for performance
#define SHARPENING 0.2 // [0.1 0.2 0.3 0.4 0.5]

// ===== DISTANT HORIZONS =====
#define DH_NOISE
#define DH_CUTOFF 16 // [0 16 32 48 64 80 96 128]
#define DH_NOISE_SIZE 8 // [2 4 8 16 32 64]

// ===== OTHER =====
#define ENCHANT_GLINT_OPACITY 0.7 // [0.0 0.3 0.5 0.7 1.0]
#define sunPathRotation -30 // [-40 -30 -20 -10 0 10 20 30 40]
#define COLOR_SCHEME 1 // [1 2 3 4 5]

// ===== DEBUG =====
// #define DEBUG_OVERRIDE_SKY
#define DEBUG_SHOW_BUFFER 0 // [0 1 2 3 4]

// ===== PROFILE & INFO =====
#define PROFILE
#define INFO 0

// Dummy defines to prevent errors
#ifdef FANCY_CLOUDS
#endif
#ifdef PROFILE
#endif
#ifdef INFO
#endif
#ifdef ATMOSPHERIC_FOG
#endif
#ifdef GODRAYS
#endif
#ifdef SMAA
#endif
#ifdef DOF
#endif
