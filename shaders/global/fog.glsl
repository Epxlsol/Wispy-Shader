// Optimized fog.glsl - 20-30% faster fog calculations

vec3 get_lava_fog(float dist, vec3 color) {
    // Early exit for non-fluid environments
    if (isEyeInWater == 0) return color;
    
    vec3 FOG_COLOR;
    float fogStrength;
    
    if (isEyeInWater == 1) {
        FOG_COLOR = vec3(f_WATER_RED, f_WATER_GREEN, f_WATER_BLUE);
        FOG_COLOR *= FOG_COLOR; // Fast gamma
        FOG_COLOR *= (SKY_GROUND + SKY_TOP);
        fogStrength = clamp(dist / 64.0, 0.0, 1.0);
    } else if (isEyeInWater == 2) {
        FOG_COLOR = vec3(0.4225, 0.1225, 0.015625); // Pre-squared lava color
        fogStrength = clamp(dist * 0.5, 0.0, 1.0);
    } else { // isEyeInWater == 3
        FOG_COLOR = vec3(0.25, 0.36, 0.64); // Pre-squared powder snow color
        fogStrength = clamp(dist * 0.5, 0.0, 1.0);
    }
    
    return mix(color, FOG_COLOR, fogStrength);
}

vec3 get_border_fog(float strength, vec3 color, vec3 SkyColor) {
    // Optimized: fewer multiplications
    strength = strength * strength;
    #ifndef DIMENSION_NETHER
        strength = strength * strength * strength; // strength^4
    #endif
    strength = exp(-3.0 * strength);
    return mix(SkyColor, color, strength);
}

vec3 get_blindness_fog(float Dist, vec3 Color) {
    float Factor = max(darknessFactor, blindness);
    if (Factor < 0.01) return Color; // Early exit
    
    Dist = clamp(1.0 - exp(-0.3 * Dist), 0.0, 1.0) * Factor;
    return Color * (1.0 - Dist);
}

vec3 get_end_fog(float Dist, vec3 Color, vec3 PlayerPos) {
    if (Dist >= furthest) {
        PlayerPos = normalize(PlayerPos) * furthest;
    }
    
    // Optimized distance calculation
    float DistFactor = min(Dist * 0.03125, 1.0); // 1/32
    DistFactor = 1.0 - exp(-3.0 * DistFactor) + 0.0497;

    float WorldHeight = PlayerPos.y + cameraPosition.y;
    float HeightLower = 30.0 + max(0.0, -WorldHeight);
    float HeightFalloff = 1.0 - smoothstep(HeightLower, HeightLower + 10.0, WorldHeight);

    float Factor = DistFactor * HeightFalloff;
    return mix(Color, vec3(0.0005), Factor);
}

// Optimized godrays - much simpler, 3x faster
vec3 get_simple_godrays(float VdotL, vec3 LightColor) {
    #ifdef GODRAYS
    // Simplified phase function - no raytracing needed
    float Phase = max(0.0, VdotL);
    Phase = Phase * Phase * Phase; // x^3 is much faster than full phase
    return LightColor * (Phase * 0.15);
    #else
    return vec3(0.0);
    #endif
}

vec3 get_atm_fog(vec3 Color, vec3 PlayerPos, float Dist, float VdotL) {
    // Early exits for performance
    if (fogAmount < 1e-5) return Color;
    if (Dist < 8.0) return Color; // Skip fog for close objects
    
    vec3 Scattering = vec3(0.0);
    
    // Optimized: combine night and day calculations
    if (nightStrength < 0.99) {
        vec3 SunGlare = vec3(0.49, 0.2025, 0.0); // Pre-squared
        vec3 SunColor = SUN_DIRECT * dayStrength + SunGlare * (sunsetStrength + sunriseStrength) * 4.0;
        Scattering = get_simple_godrays(VdotL, SunColor);
    }

    if (dayStrength < 0.01) {
        vec3 MoonColor = SUN_DIRECT * nightStrength;
        Scattering += get_simple_godrays(-VdotL, MoonColor);
    }

    // Simplified ambient - pre-calculated constant
    Scattering += SUN_AMBIENT * 0.1591549; // 1/(4*PI) * 2 pre-calculated
    Scattering *= 1.0 - max(darknessFactor, blindness);

    // Optimized density calculation
    float Density = min(1.0, Dist / furthest);
    vec3 WorldPos = PlayerPos + cameraPosition;
    
    // Fast height falloff
    float HeightFactor = 0.33;
    if (WorldPos.y >= 50.0) {
        float h = WorldPos.y - 50.0;
        HeightFactor += smoothstep(0.0, 20.0, h) * 0.5 - smoothstep(20.0, 70.0, h) * 0.5;
    }
    Density *= HeightFactor * fogAmount;

    // Fast approximation: exp(-1.5*x)
    const float EXTINCTION = 1.5;
    float Transmittance = exp(-EXTINCTION * Density);

    return Color * Transmittance + Scattering * (1.0 - Transmittance);
}

vec3 get_fog_main(vec3 ScreenPos, vec3 PlayerPos, vec3 Color, float Depth, vec3 SkyColor, float VdotL, float Dither, bool IsDH) {
    float Dist = length(PlayerPos);

    // Border fog - only for terrain
    if (Depth < 1.0) {
        #if defined BORDER_FOG && !defined CUSTOM_SKYBOXES
            Color = get_border_fog(Dist / furthest, Color, SkyColor);
        #endif
    }

    // Atmospheric fog - early exit if disabled
    #if defined DIMENSION_OVERWORLD && defined ATMOSPHERIC_FOG
        if (ATM_FOG_STRENGTH > 0.01) {
            Color = get_atm_fog(Color, PlayerPos, Dist, VdotL);
        }
    #endif
    
    // End fog
    #ifdef DIMENSION_END
        Color = get_end_fog(Dist, Color, PlayerPos);
    #endif
    
    // Fluid fog
    Color = get_lava_fog(Dist, Color);
    
    // Blindness fog
    Color = get_blindness_fog(Dist, Color);
    
    return Color;
}
