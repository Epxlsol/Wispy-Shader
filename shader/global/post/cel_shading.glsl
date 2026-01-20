#ifndef CEL_OUTLINE_TRANSPARENCY
#define CEL_OUTLINE_TRANSPARENCY 1.0
#endif
float getEdgeFactor(vec2 texcoord, float thickness) {
    float effectiveThickness = max(thickness, 1.0);
    vec2 offset = resolutionInv * effectiveThickness;
    float d0 = texture2D(depthtex1, texcoord).r;
    if (d0 >= 0.9999) return 0.0;
    float d1 = texture2D(depthtex1, texcoord + vec2(offset.x, 0)).r;
    float d2 = texture2D(depthtex1, texcoord - vec2(offset.x, 0)).r;
    float d3 = texture2D(depthtex1, texcoord + vec2(0, offset.y)).r;
    float d4 = texture2D(depthtex1, texcoord - vec2(0, offset.y)).r;
    float depthDiff1 = abs(d0 - d1);
    float depthDiff2 = abs(d0 - d2);
    float depthDiff3 = abs(d0 - d3);
    float depthDiff4 = abs(d0 - d4);
    float depthDiff = max(max(depthDiff1, depthDiff2), max(depthDiff3, depthDiff4));
    vec3 viewPos = to_view_pos(vec3(texcoord, d0), false);
    float dist = length(viewPos);
    float distFade = 1.0 - smoothstep(2.0, 160.0, dist);
    float baseThreshold = CEL_OUTLINE_DEPTH_THRESHOLD;
    float distanceThresholdFactor = 0.05;
    float distanceDependentThreshold = baseThreshold * (1.0 + dist * distanceThresholdFactor);
    float lowerThreshold = distanceDependentThreshold * 0.1;
    float upperThreshold = distanceDependentThreshold * 1.5;
    float edge = smoothstep(lowerThreshold, upperThreshold, depthDiff);
    return edge * distFade;
}
vec3 applyCelShading(vec3 color, vec2 texcoord) {
    float edgeFactor = getEdgeFactor(texcoord, CEL_OUTLINE_THICKNESS);
    vec3 outlineColor = vec3(CEL_OUTLINE_R, CEL_OUTLINE_G, CEL_OUTLINE_B);
    float finalEdgeFactor = edgeFactor * CEL_OUTLINE_TRANSPARENCY;
    return mix(color, outlineColor, finalEdgeFactor);
}
