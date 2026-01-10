// Fast fog helper functions
float get_fog_density(float dist, float strength) {
    return 1.0 - exp(-dist * strength);
}

// Lava fog (orange-red tint when in lava)
vec3 get_lava_fog_fast(float Dist, vec3 Color) {
    if (isEyeInWater != 2) return Color;
    
    float fog = get_fog_density(Dist * 0.5, 0.1);
    vec3 lavaColor = vec3(1.0, 0.3, 0.0);
    return mix(Color, lavaColor, fog);
}

// Blindness fog (darkness effect when blinded)
vec3 get_blindness_fog_fast(float Dist, vec3 Color) {
    if (blindness <= 0.0) return Color;
    
    float fog = get_fog_density(Dist * 0.3, 0.2) * blindness;
    return Color * (1.0 - fog);
}

// Border fog (fade to sky at render distance edge)
vec3 get_border_fog_fast(float normalizedDist, vec3 Color, vec3 SkyColor) {
    float fog = smoothstep(0.7, 1.0, normalizedDist);
    return mix(Color, SkyColor, fog);
}

// Atmospheric fog (distance haze with sun scattering)
vec3 get_atm_fog_fast(vec3 Color, vec3 PlayerPos, float Dist, float VdotL) {
    float heightFactor = clamp(PlayerPos.y * 0.01, 0.0, 1.0);
    float baseFog = get_fog_density(Dist * 0.005, fogAmount);
    
    // Sun scattering (makes fog glow near sun)
    float sunScatter = pow(max(VdotL * 0.5 + 0.5, 0.0), 8.0) * 0.3;
    vec3 fogColor = mix(SKY_GROUND, SKY_TOP, heightFactor);
    fogColor += SUN_DIRECT * sunScatter;
    
    float finalFog = baseFog * (1.0 - heightFactor * 0.5);
    return mix(Color, fogColor, finalFog);
}

// End dimension fog (void darkness)
vec3 get_end_fog_fast(float Dist, vec3 Color, vec3 PlayerPos) {
    float voidFog = smoothstep(0.0, -20.0, PlayerPos.y);
    vec3 voidColor = vec3(0.0);
    
    float distFog = get_fog_density(Dist * 0.002, 1.0);
    Color = mix(Color, vec3(f_END_SKY_T_R, f_END_SKY_T_G, f_END_SKY_T_B), distFog * 0.3);
    
    return mix(Color, voidColor, voidFog);
}

// Main fog function (called from composite passes)
vec3 get_fog_main(vec3 ScreenPos, vec3 PlayerPos, vec3 Color, float Depth, vec3 SkyColor, float VdotL, float Dither, bool IsDH) {
    float Dist = length(PlayerPos);

    // Distant Horizons early exit
    if (IsDH) {
        Color = get_lava_fog_fast(Dist, Color);
        Color = get_blindness_fog_fast(Dist, Color);
        return Color;
    }

    // Border fog (vanilla chunks only)
    #if defined BORDER_FOG && !defined CUSTOM_SKYBOXES
    if (Depth < 1.0) {
        Color = get_border_fog_fast(Dist / furthest, Color, SkyColor);
    }
    #endif

    // Atmospheric fog (Overworld only)
    #if defined DIMENSION_OVERWORLD && defined ATMOSPHERIC_FOG
    Color = get_atm_fog_fast(Color, PlayerPos, Dist, VdotL);
    #endif

    // End dimension fog
    #ifdef DIMENSION_END
    Color = get_end_fog_fast(Dist, Color, PlayerPos);
    #endif

    // Fluid fog
    Color = get_lava_fog_fast(Dist, Color);

    // Blindness/Darkness
    Color = get_blindness_fog_fast(Dist, Color);

    return Color;
}
