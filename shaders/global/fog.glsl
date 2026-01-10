// Optimized fog calculations - reduced branching and calculations

vec3 get_lava_fog_fast(float dist, vec3 color) {
    // Early exit if not in fluid
    if (isEyeInWater == 0) return color;

    // Pre-squared colors (gamma correction)
    const vec3 LAVA_FOG = vec3(0.4225, 0.1225, 0.015625);
    const vec3 PSNOW_FOG = vec3(0.25, 0.36, 0.64);

    if (isEyeInWater == 1) {
        vec3 UnderwaterCol = vec3(f_WATER_RED, f_WATER_GREEN, f_WATER_BLUE);
        UnderwaterCol *= UnderwaterCol * (SKY_GROUND + SKY_TOP);
        float t = clamp(dist * (1.0/64.0), 0.0, 1.0);
        return mix(color, UnderwaterCol, t);
    }

    float t = clamp(dist * 0.5, 0.0, 1.0);
    vec3 fogCol = (isEyeInWater == 2) ? LAVA_FOG : PSNOW_FOG;
    return mix(color, fogCol, t);
}

vec3 get_border_fog_fast(float strength, vec3 color, vec3 SkyColor) {
    #ifdef DIMENSION_NETHER
    strength = strength * strength;
    #else
    strength = strength * strength;
    strength = strength * strength * strength;
    #endif

    float factor = exp(-3.0 * strength);
    return mix(SkyColor, color, factor);
}

vec3 get_blindness_fog_fast(float Dist, vec3 Color) {
    float darkness = max(darknessFactor, blindness);
    if (darkness < 0.001) return Color;

    float factor = clamp(1.0 - exp(-0.3 * Dist), 0.0, 1.0) * darkness;
    return Color * (1.0 - factor);
}

vec3 get_end_fog_fast(float Dist, vec3 Color, vec3 PlayerPos) {
    if (Dist >= furthest) {
        PlayerPos = normalize(PlayerPos) * furthest;
    }

    float t = min(Dist * (1.0/32.0), 1.0);
    t = 1.0 - exp(-3.0 * t) + 0.0497;

    float WorldHeight = PlayerPos.y + cameraPosition.y;
    float HeightLower = 30.0 + max(0.0, -WorldHeight);
    float HeightFalloff = 1.0 - smoothstep(HeightLower, HeightLower + 10.0, WorldHeight);

    float Factor = t * HeightFalloff;
    return mix(Color, vec3(0.0005), Factor);
}

vec3 get_simple_godrays_fast(float VdotL, vec3 LightColor) {
    #ifdef GODRAYS
    float Phase = max(0.0, VdotL);
    Phase = Phase * Phase * Phase;
    return LightColor * Phase * 0.15;
    #else
    return vec3(0.0);
    #endif
}

vec3 get_atm_fog_fast(vec3 Color, vec3 PlayerPos, float Dist, float VdotL) {
    if (fogAmount < 1e-5) return Color;

    vec3 Scattering = vec3(0.0);

    // Simplified godrays
    if (nightStrength < 0.99) {
        vec3 SunGlare = vec3(0.49, 0.2025, 0.0);
        vec3 SunColor = SUN_DIRECT * dayStrength + SunGlare * (sunsetStrength + sunriseStrength) * 4.0;
        Scattering += get_simple_godrays_fast(VdotL, SunColor);
    }

    if (dayStrength < 0.01) {
        Scattering += get_simple_godrays_fast(-VdotL, SUN_DIRECT * nightStrength);
    }

    Scattering += SUN_AMBIENT * (0.5 / PI);
    Scattering *= 1.0 - max(darknessFactor, blindness);

    float Density = min(1.0, Dist / furthest);
    vec3 WorldPos = PlayerPos + cameraPosition;

    // Simplified height falloff
    float HeightFalloff = (WorldPos.y >= 50.0)
    ? smoothstep(50.0, 70.0, WorldPos.y) - smoothstep(70.0, 120.0, WorldPos.y)
    : 0.0;

    Density *= (0.33 + HeightFalloff * 0.5) * fogAmount;

    const float EXTINCTION = 1.5;
    float Transmittance = exp(-EXTINCTION * Density);

    return Color * Transmittance + Scattering * (1.0 - Transmittance);
}

vec3 get_fog_main(vec3 ScreenPos, vec3 PlayerPos, vec3 Color, float Depth, vec3 SkyColor, float VdotL, float Dither, bool IsDH) {
    float Dist = length(PlayerPos);

    // Border fog
    #if defined BORDER_FOG && !defined CUSTOM_SKYBOXES
    if (Depth < 1.0) {
        Color = get_border_fog_fast(Dist / furthest, Color, SkyColor);
    }
    #endif

    // Atmospheric fog
    #if defined DIMENSION_OVERWORLD && defined ATMOSPHERIC_FOG
    Color = get_atm_fog_fast(Color, PlayerPos, Dist, VdotL);
    #endif

    // End fog
    #ifdef DIMENSION_END
    Color = get_end_fog_fast(Dist, Color, PlayerPos);
    #endif

    // Fluid fog
    Color = get_lava_fog_fast(Dist, Color);

    // Blindness/darkness
    Color = get_blindness_fog_fast(Dist, Color);

    return Color;
}
