vec3 get_fog_main(vec3 ScreenPos, vec3 PlayerPos, vec3 Color, float Depth, vec3 SkyColor, float VdotL, float Dither, bool IsDH) {
    float Dist = length(PlayerPos);

    // 1. Distant Horizons Handling
    // If we are looking at DH chunks, we exit early.
    // This prevents the "double fog" wall and lets DH's internal fog take over.
    if (IsDH) {
        // We apply only the most basic fluid and blindness effects
        Color = get_lava_fog_fast(Dist, Color);
        Color = get_blindness_fog_fast(Dist, Color);
        return Color;
    }

    // 2. Standard Border Fog (Vanilla chunks only)
    // This fades the edge of your normal render distance into the sky.
    #if defined BORDER_FOG && !defined CUSTOM_SKYBOXES
    if (Depth < 1.0) {
        // 'furthest' is your vanilla render distance limit
        Color = get_border_fog_fast(Dist / furthest, Color, SkyColor);
    }
    #endif

    // 3. Atmospheric Fog (Overworld only)
    // This adds the "haze" and sun-based scattering.
    #if defined DIMENSION_OVERWORLD && defined ATMOSPHERIC_FOG
    Color = get_atm_fog_fast(Color, PlayerPos, Dist, VdotL);
    #endif

    // 4. Dimension-Specific & Status Effect Fog
    #ifdef DIMENSION_END
    Color = get_end_fog_fast(Dist, Color, PlayerPos);
    #endif

    // Apply fluid fog (Water/Lava)
    Color = get_lava_fog_fast(Dist, Color);

    // Apply Blindness/Darkness effects
    Color = get_blindness_fog_fast(Dist, Color);

    return Color;
}
