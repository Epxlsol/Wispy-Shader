// Optimized: Precompute constants

void get_sky_color() {
    const vec3 SKY_TOP_NOON = to_linear(vec3(f_NOON_SKY_T_R, f_NOON_SKY_T_G, f_NOON_SKY_T_B));
    const vec3 SKY_TOP_SUNRISE = to_linear(vec3(f_SUNRISE_SKY_T_R, f_SUNRISE_SKY_T_G, f_SUNRISE_SKY_T_B));
    const vec3 SKY_TOP_SUNSET = to_linear(vec3(f_SUNSET_SKY_T_R, f_SUNSET_SKY_T_G, f_SUNSET_SKY_T_B));
    const vec3 SKY_TOP_NIGHT = to_linear(vec3(f_NIGHT_SKY_T_R, f_NIGHT_SKY_T_G, f_NIGHT_SKY_T_B));

    const vec3 SKY_GROUND_NOON = to_linear(vec3(f_NOON_SKY_G_R, f_NOON_SKY_G_G, f_NOON_SKY_G_B));
    const vec3 SKY_GROUND_SUNRISE = to_linear(vec3(f_SUNRISE_SKY_G_R, f_SUNRISE_SKY_G_G, f_SUNRISE_SKY_G_B));
    const vec3 SKY_GROUND_SUNSET = to_linear(vec3(f_SUNSET_SKY_G_R, f_SUNSET_SKY_G_G, f_SUNSET_SKY_G_B));
    const vec3 SKY_GROUND_NIGHT = to_linear(vec3(f_NIGHT_SKY_G_R, f_NIGHT_SKY_G_G, f_NIGHT_SKY_G_B));

    // Single MAD operation per component
    SKY_TOP = SKY_TOP_SUNRISE * sunriseStrength + SKY_TOP_NOON * dayStrength
    + SKY_TOP_SUNSET * sunsetStrength + SKY_TOP_NIGHT * nightStrength;
    SKY_GROUND = SKY_GROUND_SUNRISE * sunriseStrength + SKY_GROUND_NOON * dayStrength
    + SKY_GROUND_SUNSET * sunsetStrength + SKY_GROUND_NIGHT * nightStrength;

    // Cached calculations
    float rainDarkening = 1.0 - rainStrength * RAIN_SKY_DARKENING;
    float rainDesat = 1.0 - rainStrength * RAIN_SKY_DESATURATION;

    #ifdef IS_IRIS
    float thunderFactor = 1.0 - thunderStrength * 0.33;
    rainDarkening *= thunderFactor;
    rainDesat *= thunderFactor;
    #endif

    SKY_TOP = mix_preserve_c1lum(SKY_TOP, to_linear(skyColor.rgb), f_BIOME_SKY_CONTRIBUTION);
    SKY_TOP = apply_saturation(SKY_TOP, rainDesat) * rainDarkening;
    SKY_GROUND *= rainDarkening;
}

void get_sun_color() {
    #ifdef DIMENSION_NETHER
    SUN_AMBIENT = to_linear(vec3(f_NETHER_AMBIENT_R, f_NETHER_AMBIENT_G, f_NETHER_AMBIENT_B));
    SUN_DIRECT = vec3(0);
    return;
    #elif defined DIMENSION_END
    SUN_AMBIENT = to_linear(vec3(f_END_AMBIENT_R, f_END_AMBIENT_G, f_END_AMBIENT_B));
    SUN_DIRECT = to_linear(vec3(f_END_DIRECT_R, f_END_DIRECT_G, f_END_DIRECT_B));
    return;
    #endif

    // Single weighted average
    SUN_AMBIENT = to_linear(vec3(
        f_SUNRISE_AMBIENT * sunriseStrength + f_NOON_AMBIENT * dayStrength
        + f_SUNSET_AMBIENT * sunsetStrength + f_NIGHT_AMBIENT * nightStrength
    ));

    float LHeight = sin(sunAngleAtHome * PI * 2);

    if (LHeight > 0.0) {
        const vec3 SUNRISE_SUN = to_linear(vec3(f_SUNRISE_RED, f_SUNRISE_GREEN, f_SUNRISE_BLUE));
        const vec3 NOON_SUN = to_linear(vec3(f_NOON_RED, f_NOON_GREEN, f_NOON_BLUE));
        const vec3 SUNSET_SUN = to_linear(vec3(f_SUNSET_RED, f_SUNSET_GREEN, f_SUNSET_BLUE));

        SUN_DIRECT = SUNRISE_SUN * sunriseStrength + NOON_SUN * dayStrength + SUNSET_SUN * sunsetStrength;
    } else {
        SUN_DIRECT = to_linear(vec3(f_MOON_RED, f_MOON_GREEN, f_MOON_BLUE));

        // Optimized moon phase (single trig call)
        float MoonPhaseFactor = cos(float(worldDay % 8) * 0.78539816) * (MOON_PHASE_INFLUENCE * 0.5)
        + (1.0 - MOON_PHASE_INFLUENCE * 0.5);
        SUN_DIRECT *= MoonPhaseFactor;
    }

    SUN_DIRECT *= smoothstep(0.0, 0.2, abs(LHeight));

    // Cached weather effects
    float darkening = 1.0 - rainStrength * 0.5;
    float desat = darkening;

    #ifdef IS_IRIS
    darkening *= 1.0 - thunderStrength * 0.5;
    desat *= 1.0 - thunderStrength * 0.33;
    #endif

    SUN_DIRECT = apply_saturation(SUN_DIRECT, desat) * darkening;
}

void init_colors() {
    get_sky_color();
    get_sun_color();
}
