const vec2 poisson_disk_2d[] = vec2[4](
    vec2(-0.1199, 0.7197),
                                       vec2(0.3170, 0.2211),
                                       vec2(-0.2640, -0.3332),
                                       vec2(0.0589, -0.1608)
);

vec3 ssao(vec3 Color, vec3 ViewPos, float Dither, bool IsDH) {
    float Depth = -ViewPos.z;

    // Faster Normal calculation (Avoids expensive normalize/sqrt where possible)
    vec3 Normal = normalize(vec3(dFdx(Depth), dFdy(Depth), 0.95));

    float Factor = 0.0, Hits = 0.0;
    float rotSin = sin(Dither * 6.2831);
    float rotCos = cos(Dither * 6.2831);
    mat2 rotMat = mat2(rotCos, -rotSin, rotSin, rotCos);

    float scale = SSAO_SCALE * (1.0 + float(IsDH));

    for (int i = 0; i < 4; i++) {
        // Optimization: Use a rotation matrix instead of calling rotate() function repeatedly
        vec2 rotatedSample = rotMat * poisson_disk_2d[i];
        vec3 Sample = vec3(rotatedSample * scale, 0.00015);

        Sample += Normal * 0.05 + ViewPos;

        vec3 ScreenSamplePos = view_screen(Sample, IsDH);

        // Quick boundary check
        if(clamp(ScreenSamplePos.xy, 0.0, 1.0) != ScreenSamplePos.xy) continue;

        bool IsDH2;
        float RealDepth = get_depth(ScreenSamplePos.xy, IsDH2);

        // Only re-project if the depth buffer switches between DH and standard
        if(IsDH != IsDH2) ScreenSamplePos = view_screen(Sample, IsDH2);

        if (RealDepth < 0.56) continue;

        Factor += step(RealDepth + 1e-5, ScreenSamplePos.z);
        Hits += 1.0;
    }

    Factor /= max(Hits, 1.0);
    return Color * (1.0 - Factor * SSAO_STRENGTH * (1.0 + float(IsDH)));
}
