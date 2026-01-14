vec3 get_fog_main(
    vec3 ScreenPos,
    vec3 PlayerPos,
    vec3 Color,
    float Depth,
    vec3 SkyColor,
    float VdotL,
    float Dither,
    bool IsDH
) {
    float Dist = length(PlayerPos);

    // Border fog (safe for DH)
    #if defined BORDER_FOG && !defined CUSTOM_SKYBOXES
    if (Depth < 1.0) {
        Color = get_border_fog_fast(Dist / furthest, Color, SkyColor);
    }
    #endif

    // Atmospheric fog — DISABLED for Distant Horizons
    #if defined DIMENSION_OVERWORLD && defined ATMOSPHERIC_FOG
    if (!IsDH) {
        Color = get_atm_fog_fast(Color, PlayerPos, Dist, VdotL);
    }
    #endif

    // End fog (DH does not render End chunks anyway, but safe)
    #ifdef DIMENSION_END
    Color = get_end_fog_fast(Dist, Color, PlayerPos);
    #endif

    // Medium-based fog (lava / powder snow)
    Color = get_lava_fog_fast(Dist, Color);

    // Blindness & darkness (gameplay effects → always apply)
    Color = get_blindness_fog_fast(Dist, Color);

    return Color;
}
