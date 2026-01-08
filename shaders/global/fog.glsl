vec3 get_lava_fog(float dist, vec3 color) {
    vec3 LAVA_FOG_COLOR = vec3(0.65, 0.35, 0.125);
    LAVA_FOG_COLOR *= LAVA_FOG_COLOR;
    
    vec3 PSNOW_FOG_COLOR = vec3(0.5, 0.6, 0.8);
    PSNOW_FOG_COLOR *= PSNOW_FOG_COLOR;

    if (isEyeInWater == 1) {
        vec3 UnderwaterCol = vec3(f_WATER_RED, f_WATER_GREEN, f_WATER_BLUE);
        UnderwaterCol *= UnderwaterCol;
        UnderwaterCol *= (SKY_GROUND+SKY_TOP);
        dist = clamp(dist / 64, 0, 1);
        return mix(color, UnderwaterCol, dist);
    }
    else if (isEyeInWater == 2) {
        dist = clamp(dist / 2, 0, 1);
        return mix(color, LAVA_FOG_COLOR, dist);
    }
    else if (isEyeInWater == 3) {
        dist = clamp(dist / 2, 0, 1);
        return mix(color, PSNOW_FOG_COLOR, dist);
    }
    return color;
}

vec3 get_border_fog(float strength, vec3 color, vec3 SkyColor) {
    strength *= strength;
    #ifndef DIMENSION_NETHER
    strength *= strength;
    strength *= strength;
    #endif
    strength = exp(-3.0 * strength);
    return mix(SkyColor, color, strength);
}

vec3 get_blindness_fog(float Dist, vec3 Color) {
    Dist = clamp(1.0 - exp(-3.0 * Dist / 10), 0, 1) * max(darknessFactor, blindness);
    return Color * (1 - Dist);
}

vec3 get_end_fog(float Dist, vec3 Color, vec3 PlayerPos) {
    if(Dist >= furthest) {
        PlayerPos = normalize(PlayerPos) * furthest;
    }
    Dist = min(Dist / 32, 1);
    Dist = 1.0 - exp(-3.0 * Dist) + 0.0497;

    float WorldHeight = PlayerPos.y + cameraPosition.y;
    float HeightLower = 30 + max(0, -WorldHeight);
    float HeightFalloff = 1 - smoothstep(HeightLower, HeightLower + 10, WorldHeight);

    float Factor = Dist * HeightFalloff;
    return mix(Color, vec3(0.0005), Factor);
}

// Simplified godrays (no raymarching)
vec3 get_simple_godrays(float VdotL, vec3 LightColor) {
    #ifdef GODRAYS
    // Simple phase function without raytracing
    float Phase = max(0, VdotL);
    Phase = Phase * Phase * Phase; // Cheap x^3
    return LightColor * Phase * 0.15;
    #else
    return vec3(0);
    #endif
}

vec3 get_atm_fog(vec3 Color, vec3 PlayerPos, float Dist, float VdotL) {
    if(fogAmount < 1e-5) return Color;
    vec3 Scattering = vec3(0);

    // Simplified scattering (no raymarching!)
    if(nightStrength < 0.99) {
        vec3 SunGlare = vec3(0.7, 0.45, 0.0);
        SunGlare *= SunGlare;
        vec3 SunColor = (SUN_DIRECT * dayStrength + SunGlare * (sunsetStrength + sunriseStrength) * 4);
        Scattering += get_simple_godrays(VdotL, SunColor);
    }

    if(dayStrength < 0.01) {
        vec3 MoonColor = (SUN_DIRECT * nightStrength);
        Scattering += get_simple_godrays(-VdotL, MoonColor);
    }

    Scattering += SUN_AMBIENT / (4 * PI) * 2;
    Scattering *= 1 - max(darknessFactor, blindness);

    float Density = min(1, Dist / furthest);
    vec3 WorldPos = PlayerPos + cameraPosition;
    float HeightFalloff = WorldPos.y >= 50 ? smoothstep(50, 70, WorldPos.y) - smoothstep(70, 120, WorldPos.y) : 0;
    Density *= 0.33 + HeightFalloff * 0.5;
    Density *= fogAmount;

    const float EXTINCTION = 1.5;
    float Transmittance = exp(-EXTINCTION * Density);

    return Color * Transmittance + Scattering * (1 - Transmittance);
}

vec3 get_fog_main(vec3 ScreenPos, vec3 PlayerPos, vec3 Color, float Depth, vec3 SkyColor, float VdotL, float Dither, bool IsDH) {
    float Dist = length(PlayerPos);

    if (Depth < 1) {
        #if defined BORDER_FOG && !defined CUSTOM_SKYBOXES
            Color.rgb = get_border_fog(Dist / furthest, Color.rgb, SkyColor);
        #endif
    }

    #if defined DIMENSION_OVERWORLD && defined ATMOSPHERIC_FOG
        Color.rgb = get_atm_fog(Color.rgb, PlayerPos, Dist, VdotL);
    #endif
    #ifdef DIMENSION_END
        Color.rgb = get_end_fog(Dist, Color.rgb, PlayerPos);
    #endif
    Color.rgb = get_lava_fog(Dist, Color.rgb);
    Color.rgb = get_blindness_fog(Dist, Color.rgb);
    return Color;
}
