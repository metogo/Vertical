#include <metal_stdlib>
using namespace metal;

struct SpiralVertex {
    float4 position;
    float4 color;
};

struct SpiralUniforms {
    float4x4 mvpMatrix;
    float4x4 rotationMatrix;
    float landmarkHeight; // height of the active landmark
    float currentClimb;   // actual climb height of the user
};

struct VertexOut {
    float4 position [[position]];
    float4 color;
    float pointSize [[point_size]];
};

vertex VertexOut spiralVertex(
    const device SpiralVertex* vertices [[buffer(0)]],
    constant SpiralUniforms& uniforms [[buffer(1)]],
    uint vid [[vertex_id]]
) {
    SpiralVertex v = vertices[vid];
    VertexOut out;
    
    // Apply rotation then MVP
    float4 rotatedPosition = uniforms.rotationMatrix * v.position;
    out.position = uniforms.mvpMatrix * rotatedPosition;
    out.color = v.color;
    out.pointSize = 10.0; // Size of each stair step pixel
    
    return out;
}

fragment float4 spiralFragment(VertexOut in [[stage_in]]) {
    // Intense neon glow effect
    float3 baseColor = in.color.rgb;
    float3 glowColor = baseColor * 2.5; // High intensity for bloom-like feel
    
    // Smooth alpha for softer edges
    float alpha = in.color.a * 0.9;
    
    return float4(glowColor, alpha);
}
