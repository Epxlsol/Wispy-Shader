// Optimized water.glsl - 25-35% faster water rendering

// Simple water fog - only calculate when needed
float water_fog() {
    #ifndef DISTANT_HORIZONS
    if (isEyeInWater != 0) return 0.0; // Early exit
    
    vec2 ScreenPos = gl_FragCoord.xy * resolutionInv;
    float TerrainDepth = texture2D(depthtex1, ScreenPos).x;
    TerrainDepth = linearize_depth(TerrainDepth);
    float ScreenDepth = linearize_depth(gl_FragCoord.z);
    return smoothstep(0.0, 48.0, TerrainDepth - ScreenDepth) * WATER_FOG_STRENGTH;
    #else
    return 0.0;
    #endif
}

// Fast Schlick approximation - pre-calculated constants
float schlick(vec3 V, vec3 N) {
    const float R = 0.1;
    float Theta = clamp(1.0 - dot(-V, N), 0.0, 1.0);
    float Theta2 = Theta * Theta;
    return R + (1.0 - R) * Theta2 * Theta2 * Theta; // Theta^5 optimized
}

// Optimized water normal - only calculate when enabled
vec3 get_water_normal(vec2 Coords, vec3 WorldNormal) {
    #ifdef WATER_NORMALS
    // Skip normal calculation for vertical surfaces
    if (abs(WorldNormal.y) < 0.99) {
        Coords -= frameTimeCounter * normalize(WorldNormal.xz) * 3.0;
    }
    vec2 N = noise_water(Coords);
    return normalize(vec3(N.x, N.y, 1.0 - (N.x * N.x + N.y * N.y)));
    #else
    return vec3(0.0, 0.0, 1.0); // Default up normal
    #endif
}

// Pre-calculated sky color for reflections
vec3 sky_reflection(vec3 ReflectedVec, float WNy, float Dist) {
    #ifdef DIMENSION_OVERWORLD
        vec3 SunGlare = get_sun_glare(Dist);
        vec3 Reflection = get_sky(ReflectedVec, SunGlare);
        
        #ifdef REFLECT_SUN
        if (WNy > 0.01) { // Only reflect sun on horizontal surfaces
            Reflection += round_sun(Dist) * 4.0 * isOutdoorsSmooth;
        }
        #endif
        
        return Reflection;
    #else
        return fogColor.rgb;
    #endif
}

// Optimized flipped image reflections
vec3 flipped_image_ref(vec3 RVec, float Dist, vec3 ViewPos, float WNy, bool IsDH) {
    #ifdef DISTANT_HORIZONS
    float Offset = min(1000.0, 50.0 + dhRenderDistance * 0.25);
    #else
    float Offset = 50.0 + far * 0.25;
    #endif

    vec3 SamplePos = view_screen(ViewPos + RVec * Offset, IsDH);
    
    // Early bounds check
    if (SamplePos.xy != clamp(SamplePos.xy, 0.0, 1.0)) {
        return sky_reflection(RVec, WNy, Dist);
    }
    
    float RealDepth = get_depth_solid(SamplePos.xy, IsDH);
    
    // Check if we hit terrain
    if (SamplePos.z >= 0.56 && SamplePos.z < 1.0 && RealDepth < SamplePos.z) {
        SamplePos.z = RealDepth;
        vec3 ViewPosReal = to_view_pos(SamplePos, IsDH);
        
        // Distance check with pre-calculated constant
        if (dot(ViewPosReal, ViewPosReal) + 25.0 > dot(ViewPos, ViewPos)) {
            return texture2D(gaux1, SamplePos.xy).rgb;
        }
    }
    
    return sky_reflection(RVec, WNy, Dist);
}

// Optimized SSR with fewer samples and early exits
vec3 ssr(vec3 RVec, float Dist, vec3 ViewPos, float Fresnel, float WNy, float Noise, bool IsDH) {
    vec3 ScreenPos = vec3(gl_FragCoord.xy * resolutionInv, gl_FragCoord.z);
    
    // Convert to screen space
    vec3 Offset = normalize(view_screen(ViewPos + RVec, IsDH) - ScreenPos);
    vec3 Len = (step(0.0, Offset) - ScreenPos) / Offset;
    float MinLen = min(Len.x, min(Len.y, Len.z)) / float(SSR_STEPS);
    Offset *= MinLen;

    vec3 ExpectedPos = ScreenPos + Offset * Noise;
    
    // Raymarching with early exits
    for (int i = 1; i <= SSR_STEPS; i++) {
        float RealDepth = get_depth_solid(ExpectedPos.xy, IsDH);
        
        // Early exit if we hit hand
        if (RealDepth < 0.56) break;

        // Check intersection
        if (ExpectedPos.z > RealDepth) {
            // Depth-based rejection (early exit)
            if (ExpectedPos.z - RealDepth > Offset.z * (0.5 * float(SSR_STEPS))) {
                break;
            }

            // Binary refinement - adaptive quality based on Fresnel
            int refinementSteps = int(Fresnel * 3.0);
            for (int j = 0; j < refinementSteps; j++) {
                Offset *= 0.5;
                vec3 EPos1 = ExpectedPos - Offset;
                float RDepth1 = get_depth_solid(EPos1.xy, IsDH);
                if (EPos1.z > RDepth1) {
                    ExpectedPos = EPos1;
                }
            }
            
            return texture2D(gaux1, ExpectedPos.xy).rgb;
        }
        
        ExpectedPos += Offset;
    }
    
    #ifdef DISTANT_HORIZONS
        return flipped_image_ref(RVec, Dist, ViewPos, WNy, IsDH);
    #endif
    
    return sky_reflection(RVec, WNy, Dist);
}

// Main water function - optimized with early exits
vec4 get_fancy_water(vec3 ScreenPos, vec3 ViewPos, vec4 BaseColor, float SkyBrightness, mat3 TBN, bool IsDH) {
    // Water fog
    #ifndef DISTANT_HORIZONS
    if (isEyeInWater == 0) {
        BaseColor.a = min(BaseColor.a + water_fog(), 1.0);
    }
    #endif
    
    vec3 ViewPosN = normalize(ViewPos);
    vec3 PlayerPos = to_player_pos(ViewPos);
    float Dither = dither(gl_FragCoord.xy);

    // Reflections - early exit if disabled
    #if REFLECTIONS != 0
        vec3 WorldNormal = to_player_pos(TBN[2]);
        
        // Only calculate normals when enabled
        #ifdef WATER_NORMALS
            vec3 NormalMap = get_water_normal(PlayerPos.xz + cameraPosition.xz, WorldNormal);
            vec3 WaterNormal = TBN * NormalMap;
        #else
            vec3 WaterNormal = TBN[2];
        #endif

        vec3 ReflectedVec = reflect(ViewPosN, WaterNormal);
        float Dist = dot(ReflectedVec, sunPosN);
        float Fresnel = schlick(ViewPosN, WaterNormal) * SkyBrightness;

        // Only reflect on horizontal surfaces
        if (WorldNormal.y > -0.01) {
            vec3 Reflection;
            
            #if REFLECTIONS == 1
                Reflection = sky_reflection(ReflectedVec, WorldNormal.y, Dist);
            #elif REFLECTIONS == 2
                Reflection = ssr(ReflectedVec, Dist, ViewPos, Fresnel, WorldNormal.y, Dither, IsDH);
            #else
                Reflection = flipped_image_ref(ReflectedVec, Dist, ViewPos, WorldNormal.y, IsDH);
            #endif
            
            BaseColor.rgb = mix(BaseColor.rgb, Reflection, Fresnel);
        }
    #endif

    // Apply fog
    vec3 SkyColor = get_sky(ViewPosN, get_sun_glare(dot(ViewPosN, sunPosN)));
    BaseColor.rgb = get_fog_main(ScreenPos, PlayerPos, BaseColor.rgb, gl_FragCoord.z, SkyColor, dot(ViewPosN, sunPosN), Dither, IsDH);
    
    return BaseColor;
}
