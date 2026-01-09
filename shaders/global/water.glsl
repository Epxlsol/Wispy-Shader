// ============================================
// WISPY SHADER - OPTIMIZED WATER SYSTEM
// ============================================

// Fast water fog calculation
float water_fog() {
    vec2 ScreenPos = gl_FragCoord.xy * resolutionInv;
    float TerrainDepth = texture2D(depthtex1, ScreenPos).x;
    TerrainDepth = linearize_depth(TerrainDepth);
    float ScreenDepth = linearize_depth(gl_FragCoord.z);
    
    float depth_diff = TerrainDepth - ScreenDepth;
    
    #if WATER_STYLE == 2 // Clear Minecraft style
        return smoothstep(0, 64, depth_diff) * WATER_FOG_STRENGTH * 0.5; // Half strength
    #else // Realistic style
        return smoothstep(0, 48, depth_diff) * WATER_FOG_STRENGTH;
    #endif
}

// Optimized Fresnel (fast approximation)
float schlick(vec3 V, vec3 N) {
    #if WATER_STYLE == 2 // Clear style - stronger reflections
        const float R = 0.02; // More reflective
    #else
        const float R = 0.1;  // Standard
    #endif
    
    float Theta = clamp(1.0 - dot(-V, N), 0.0, 1.0);
    // Fast pow5 approximation
    float Theta2 = Theta * Theta;
    return R + (1.0 - R) * (Theta2 * Theta2 * Theta);
}

// Fast water normal generation
vec3 get_water_normal(vec2 Coords, vec3 WorldNormal) {
    #ifdef WATER_NORMALS
        if (abs(WorldNormal.y) < 0.99) {
            Coords -= frameTimeCounter * normalize(WorldNormal.xz) * 3.0;
        }
        vec2 N = noise_water(Coords);
        
        #if WATER_STYLE == 2 // Clear style - subtle waves
            N *= 0.5;
        #endif
        
        return normalize(vec3(N.x, N.y, 1.0 - (N.x * N.x + N.y * N.y)));
    #else
        return vec3(0.0, 0.0, 1.0);
    #endif
}

// Sky reflection helper
vec3 sky_reflection(vec3 ReflectedVec, float WNy, float Dist) {
    #ifdef DIMENSION_OVERWORLD
        vec3 SunGlare = get_sun_glare(Dist);
        vec3 Reflection = get_sky(ReflectedVec, SunGlare);
        
        #ifdef REFLECT_SUN
            if (WNy > 0.01) {
                Reflection.rgb += round_sun(Dist) * 4.0 * isOutdoorsSmooth;
            }
        #endif
        
        // Brighten reflections for clear water
        #if WATER_STYLE == 2
            Reflection *= 1.2 * WATER_BRIGHTNESS;
        #else
            Reflection *= WATER_BRIGHTNESS;
        #endif
        
        return Reflection;
    #else
        return fogColor.rgb * WATER_BRIGHTNESS;
    #endif
}

// Flipped image reflection (fast)
vec3 flipped_image_ref(vec3 RVec, float Dist, vec3 ViewPos, float WNy, bool IsDH) {
    #ifdef DISTANT_HORIZONS
        float Offset = min(1000.0, 50.0 + dhRenderDistance * 0.25);
    #else
        float Offset = 50.0 + far * 0.25;
    #endif

    vec3 SamplePos = view_screen(ViewPos + RVec * Offset, IsDH);
    
    if(SamplePos.xy == clamp(SamplePos.xy, 0.0, 1.0)) {
        float RealDepth = get_depth_solid(SamplePos.xy, IsDH);
        if(SamplePos.z < 1.0 && SamplePos.z > 0.56 && RealDepth < SamplePos.z) {
            SamplePos.z = RealDepth;
            vec3 ViewPosReal = to_view_pos(SamplePos, IsDH);
            if(len2(ViewPosReal) + 25.0 > len2(ViewPos)) {
                vec3 reflection = texture2D(gaux1, SamplePos.xy).rgb;
                return reflection * WATER_BRIGHTNESS;
            }
        }
    }
    return sky_reflection(RVec, WNy, Dist);
}

// Optimized SSR
vec3 ssr(vec3 RVec, float Dist, vec3 ViewPos, float Fresnel, float WNy, float Noise, bool IsDH) {
    vec3 ScreenPos = vec3(gl_FragCoord.xy * resolutionInv, gl_FragCoord.z);
    vec3 Offset = normalize(view_screen(ViewPos + RVec, IsDH) - ScreenPos);
    vec3 Len = (step(0.0, Offset) - ScreenPos) / Offset;
    float MinLen = min(Len.x, min(Len.y, Len.z)) / float(SSR_STEPS);
    Offset *= MinLen;

    vec3 ExpectedPos = ScreenPos + Offset * Noise;
    
    for (int i = 1; i <= SSR_STEPS; i++) {
        float RealDepth = get_depth_solid(ExpectedPos.xy, IsDH);
        if (RealDepth < 0.56) break;

        if (ExpectedPos.z > RealDepth) {
            if (ExpectedPos.z - RealDepth > Offset.z * (0.5 * float(SSR_STEPS))) {
                break;
            }

            // Binary refinement (1 pass for performance)
            Offset *= 0.5;
            vec3 EPos1 = ExpectedPos - Offset;
            float RDepth1 = get_depth_solid(EPos1.xy, IsDH);
            if (EPos1.z > RDepth1) {
                ExpectedPos = EPos1;
            }
            
            vec3 reflection = texture2D(gaux1, ExpectedPos.xy).rgb;
            return reflection * WATER_BRIGHTNESS;
        }
        ExpectedPos += Offset;
    }
    
    #ifdef DISTANT_HORIZONS
        return flipped_image_ref(RVec, Dist, ViewPos, WNy, IsDH);
    #endif
    return sky_reflection(RVec, WNy, Dist);
}

// Main water rendering function
vec4 get_fancy_water(vec3 ScreenPos, vec3 ViewPos, vec4 BaseColor, float SkyBrightness, mat3 TBN, bool IsDH) {
    
    // Apply water clarity based on style
    #if WATER_STYLE == 0
        // Vanilla - no changes
        return BaseColor;
    #endif
    
    // Adjust base color brightness
    BaseColor.rgb *= WATER_BRIGHTNESS;
    
    #ifndef DISTANT_HORIZONS
        if (isEyeInWater == 0) {
            float fog = water_fog();
            
            #if WATER_STYLE == 2 // Clear style
                BaseColor.a = mix(WATER_CLARITY, 1.0, fog);
            #else // Realistic style
                BaseColor.a = min(BaseColor.a + fog, 1.0);
            #endif
        }
    #endif
    
    vec3 ViewPosN = normalize(ViewPos);
    vec3 PlayerPos = to_player_pos(ViewPos);
    float Dither = dither(gl_FragCoord.xy);

    #if REFLECTIONS != 0
        vec3 WorldNormal = to_player_pos(TBN[2]);
        
        #ifdef WATER_NORMALS
            vec3 NormalMap = get_water_normal(PlayerPos.xz + cameraPosition.xz, WorldNormal);
            vec3 WaterNormal = TBN * NormalMap;
        #else
            vec3 WaterNormal = TBN[2];
        #endif

        vec3 ReflectedVec = reflect(ViewPosN, WaterNormal);
        float Dist = dot(ReflectedVec, sunPosN);
        float Fresnel = schlick(ViewPosN, WaterNormal) * SkyBrightness;

        if (WorldNormal.y > -0.01) {
            #if REFLECTIONS == 1 // Sky only
                vec3 Reflection = sky_reflection(ReflectedVec, WorldNormal.y, Dist);
            #elif REFLECTIONS == 2 // SSR
                vec3 Reflection = ssr(ReflectedVec, Dist, ViewPos, Fresnel, WorldNormal.y, Dither, IsDH);
            #else // Flipped image
                vec3 Reflection = flipped_image_ref(ReflectedVec, Dist, ViewPos, WorldNormal.y, IsDH);
            #endif
            
            // Enhanced reflection mixing for clear water
            #if WATER_STYLE == 2
                Fresnel = max(Fresnel, 0.15); // Ensure visible reflections
            #endif
            
            BaseColor.rgb = mix(BaseColor.rgb, Reflection, Fresnel);
        }
    #endif

    // Apply fog
    vec3 SkyColor = get_sky(ViewPosN, get_sun_glare(dot(ViewPosN, sunPosN)));
    BaseColor.rgb = get_fog_main(ScreenPos, PlayerPos, BaseColor.rgb, gl_FragCoord.z, SkyColor, dot(ViewPosN, sunPosN), Dither, IsDH);
    
    return BaseColor;
}
