// Optimized water shader - reduces texture lookups and calculations

float water_fog() {
    vec2 ScreenPos = gl_FragCoord.xy * resolutionInv;
    float TerrainDepth = texture2D(depthtex1, ScreenPos).x;
    float DepthDiff = linearize_depth(TerrainDepth) - linearize_depth(gl_FragCoord.z);
    return clamp(DepthDiff * (1.0/48.0), 0.0, 1.0) * WATER_FOG_STRENGTH;
}

float schlick(vec3 V, vec3 N) {
    const float R = 0.1;
    float Theta = clamp(1 - dot(-V, N), 0, 1);
    float Theta2 = Theta * Theta;
    return R + (1 - R) * Theta2 * Theta2 * Theta; // Optimized x^5
}

vec3 get_water_normal(vec2 Coords, vec3 WorldNormal) {
    // Cache normal map lookups
    vec2 N = noise_water(Coords);
    float len_sq = N.x * N.x + N.y * N.y;
    return vec3(N.x, N.y, sqrt(max(0.0, 1.0 - len_sq)));
}

vec3 sky_reflection(vec3 ReflectedVec, float WNy, float VdotL) {
    #ifdef DIMENSION_OVERWORLD
    vec3 SunGlare = get_sun_glare(VdotL);
    vec3 Reflection = get_sky(ReflectedVec, SunGlare);

    #ifdef REFLECT_SUN
    if (WNy > 0.01) {
        Reflection.rgb += round_sun(VdotL) * 4.0 * isOutdoorsSmooth;
    }
    #endif
    return Reflection;
    #else
    return fogColor.rgb;
    #endif
}

vec3 ssr(vec3 RVec, float Dist, vec3 ViewPos, float Fresnel, float WNy, float Noise, bool IsDH) {
    vec3 ScreenPos = vec3(gl_FragCoord.xy * resolutionInv, gl_FragCoord.z);
    vec3 Offset = normalize(view_screen(ViewPos + RVec, IsDH) - ScreenPos);

    // Calculate max steps based on screen distance
    vec3 Len = (step(0.0, Offset) - ScreenPos) / Offset;
    float MinLen = min(Len.x, min(Len.y, Len.z)) / float(SSR_STEPS);
    Offset *= MinLen;

    vec3 ExpectedPos = ScreenPos + Offset * Noise;

    // Reduced binary refinement steps for performance
    int refinementSteps = int(Fresnel * 2.0 + 0.5);

    for (int i = 1; i <= SSR_STEPS; i++) {
        float RealDepth = get_depth_solid(ExpectedPos.xy, IsDH);

        if (RealDepth < 0.56) break;

        if (ExpectedPos.z > RealDepth) {
            if (ExpectedPos.z - RealDepth > Offset.z * (0.5 * float(SSR_STEPS))) {
                break;
            }

            // Binary refinement (reduced iterations)
            for (int j = 0; j < refinementSteps; j++) {
                Offset *= 0.5;
                vec3 EPos1 = ExpectedPos - Offset;
                if (EPos1.z > get_depth_solid(EPos1.xy, IsDH)) {
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
    return sky_reflection(ReflectedVec, WNy, VdotL);
}

vec4 get_fancy_water(vec3 ScreenPos, vec3 ViewPos, vec4 BaseColor, float SkyBrightness, mat3 TBN, bool IsDH) {
    // Simplified fog calculation
    #ifndef DISTANT_HORIZONS
    if (isEyeInWater == 0) {
        BaseColor.a = min(BaseColor.a + water_fog(), 1.0);
    }
    #endif

    vec3 ViewPosN = normalize(ViewPos);

    #if REFLECTIONS != 0
    vec3 WorldNormal = to_player_pos(TBN[2]);

    #ifdef WATER_NORMALS
    vec3 PlayerPos = to_player_pos(ViewPos);
    vec3 NormalMap = get_water_normal(PlayerPos.xz + cameraPosition.xz, WorldNormal);
    vec3 WaterNormal = TBN * NormalMap;
    #else
    vec3 WaterNormal = TBN[2];
    #endif

    vec3 ReflectedVec = reflect(ViewPosN, WaterNormal);
    float VdotL = dot(ReflectedVec, sunPosN);
    float Fresnel = schlick(ViewPosN, WaterNormal) * SkyBrightness;

    if (WorldNormal.y > -0.01) {
        vec3 Reflection;

        #if REFLECTIONS == 1
        Reflection = sky_reflection(ReflectedVec, WorldNormal.y, VdotL);
        #elif REFLECTIONS >= 2
        float Dither = dither(gl_FragCoord.xy);
        Reflection = ssr(ReflectedVec, VdotL, ViewPos, Fresnel, WorldNormal.y, Dither, IsDH);
        #endif

        BaseColor.rgb = mix(BaseColor.rgb, Reflection, Fresnel);
    }
    #endif

    // Simplified fog (only if needed)
    #if defined ATMOSPHERIC_FOG || defined BORDER_FOG || defined DIMENSION_END
    vec3 PlayerPos = to_player_pos(ViewPos);
    vec3 SkyColor = get_sky(ViewPosN, get_sun_glare(dot(ViewPosN, sunPosN)));
    float Dither = dither(gl_FragCoord.xy);
    BaseColor.rgb = get_fog_main(ScreenPos, PlayerPos, BaseColor.rgb, gl_FragCoord.z, SkyColor, dot(ViewPosN, sunPosN), Dither, IsDH);
    #endif

    return BaseColor;
}
