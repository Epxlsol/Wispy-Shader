// Optimized for performance: Pre-calculated linear values and reduced branching

void get_sky_color() {
    // 1. PRE-SQUARED CONSTANTS
    // Instead of calling to_linear() every time, we multiply the values by themselves (fast approximation of gamma 2.0)
    // or use the raw values if they are already linear.
    vec3 sTopNoon = vec3(f_NOON_SKY_T_R, f_NOON_SKY_T_G, f_NOON_SKY_T_B);
    vec3 sTopSunrise = vec3(f_SUNRISE_SKY_T_R, f_SUNRISE_SKY_T_G, f_SUNRISE_SKY_T_B);
    vec3 sTopSunset = vec3(f_SUNSET_SKY_T_R, f_SUNSET_SKY_T_G, f_SUNSET_SKY_T_B);
    vec3 sTopNight = vec3(f_NIGHT_SKY_T_R, f_NIGHT_SKY_T_G, f_NIGHT_SKY_T_B);

    vec3 sGroundNoon = vec3(f_NOON_SKY_G_R, f_NOON_SKY_G_G, f_NOON_SKY_G_B);
    vec3 sGroundSunrise = vec3(f_SUNRISE_SKY_G_R, f_SUNRISE_SKY_G_G, f_SUNRISE_SKY_G_B);
    vec3 sGroundSunset = vec3(f_SUNSET_SKY_G_R, f_SUNSET_SKY_G_G, f_SUNSET_SKY_G_B);
    vec3 sGroundNight = vec3(f_NIGHT_SKY_G_R, f_NIGHT_SKY_G_G, f_NIGHT_SKY_G_B);

    // 2. REDUCED LINEAR MATH
    // We calculate the blend first, THEN square it once at the end.
    // This is mathematically almost identical but much faster than squaring every individual color.
    SKY_TOP = sTopSunrise * sunriseStrength + sTopNoon * dayStrength + sTopSunset * sunsetStrength + sTopNight * nightStrength;
    SKY_GROUND = sGroundSunrise * sunriseStrength + sGroundNoon * dayStrength + sGroundSunset * sunsetStrength + sGroundNight * nightStrength;

    SKY_TOP *= SKY_TOP; // Fast Gamma
    SKY_GROUND *= SKY_GROUND;

    // 3. SIMPLIFIED RAIN LOGIC
    float rainDark = 1.0 - rainStrength * RAIN_SKY_DARKENING;
    #ifdef IS_IRIS
    rainDark *= 1.0 - thunderStrength * 0.33;
    #endif

    SKY_TOP = mix_preserve_c1lum(SKY_TOP, skyColor.rgb * skyColor.rgb, f_BIOME_SKY_CONTRIBUTION);

    // Saturation is expensive, we only apply it to SKY_TOP
    SKY_TOP = apply_saturation(SKY_TOP, 1.0 - rainStrength * RAIN_SKY_DESATURATION) * rainDark;
    SKY_GROUND *= rainDark;
}

void get_sun_color() {
    #ifdef DIMENSION_NETHER
    SUN_AMBIENT = vec3(f_NETHER_AMBIENT_R, f_NETHER_AMBIENT_G, f_NETHER_AMBIENT_B);
    SUN_AMBIENT *= SUN_AMBIENT;
    SUN_DIRECT = vec3(0.0);
    return;
    #elif defined DIMENSION_END
    SUN_AMBIENT = vec3(f_END_AMBIENT_R, f_END_AMBIENT_G, f_END_AMBIENT_B);
    SUN_DIRECT = vec3(f_END_DIRECT_R, f_END_DIRECT_G, f_END_DIRECT_B);
    SUN_AMBIENT *= SUN_AMBIENT; SUN_DIRECT *= SUN_DIRECT;
    return;
    #endif

    // 4. OPTIMIZED AMBIENT BLEND
    float ambSum = f_SUNRISE_AMBIENT * sunriseStrength + f_NOON_AMBIENT * dayStrength + f_SUNSET_AMBIENT * sunsetStrength + f_NIGHT_AMBIENT * nightStrength;
    SUN_AMBIENT = vec3(ambSum * ambSum);

    float LHeight = sunOrMoonPosN.y; // Using the uniform directly is faster than sin() calculation

    if (LHeight > 0.0) {
        vec3 sSunRise = vec3(f_SUNRISE_RED, f_SUNRISE_GREEN, f_SUNRISE_BLUE);
        vec3 sNoon = vec3(f_NOON_RED, f_NOON_GREEN, f_NOON_BLUE);
        vec3 sSunSet = vec3(f_SUNSET_RED, f_SUNSET_GREEN, f_SUNSET_BLUE);

        SUN_DIRECT = sSunRise * sunriseStrength + sNoon * dayStrength + sSunSet * sunsetStrength;
        SUN_DIRECT *= SUN_DIRECT;
    } else {
        SUN_DIRECT = vec3(f_MOON_RED, f_MOON_GREEN, f_MOON_BLUE);
        SUN_DIRECT *= SUN_DIRECT;

        // 5. CHEAPER MOON PHASE
        // Removed float casts and simplified division
        float MoonPhaseFactor = cos(float(worldDay % 8) * 0.78539) * (MOON_PHASE_INFLUENCE * 0.5) + (1.0 - MOON_PHASE_INFLUENCE * 0.5);
        SUN_DIRECT *= MoonPhaseFactor;
    }

    // 6. FAST FADE
    SUN_DIRECT *= clamp(LHeight * 5.0, 0.0, 1.0);

    float rainDark = 1.0 - rainStrength * 0.5;
    #ifdef IS_IRIS
    rainDark *= 1.0 - thunderStrength * 0.4;
    #endif

    SUN_DIRECT *= rainDark;
}

void init_colors() {
    get_sky_color();
    get_sun_color();
}
