#include <metal_stdlib>
using namespace metal;

// MARK: - Shared Types
// Layout must match Swift Particle struct exactly (48 bytes)

struct Particle {
    float2 position;        // 8 bytes, offset 0
    float2 velocity;        // 8 bytes, offset 8
    float4 color;           // 16 bytes, offset 16
    float lifetime;         // 4 bytes, offset 32
    float initialLifetime;  // 4 bytes, offset 36
    float size;             // 4 bytes, offset 40
    float _padding;         // 4 bytes, offset 44
    // Total: 48 bytes
};

struct ParticleUniforms {
    float speedMultiplier;
    float deltaTime;
    float colorFactor;
    float activationFactor;
};

struct VertexOut {
    float4 position [[position]];
    float4 color;
    float pointSize [[point_size]];
};

// MARK: - Compute Shader (Update Particles)

kernel void updateParticles(
    device Particle* particles [[buffer(0)]],
    constant ParticleUniforms& uniforms [[buffer(1)]],
    uint id [[thread_position_in_grid]]
) {
    Particle p = particles[id];
    
    // Update lifetime
    p.lifetime -= uniforms.deltaTime;
    
    // Respawn if dead
    if (p.lifetime <= 0) {
        // Reset to bottom of screen with random x
        uint seed = id * 1103515245 + 12345 + uint(uniforms.deltaTime * 10000);
        float randomX = fract(sin(float(seed) * 12.9898) * 43758.5453) * 2.0 - 1.0;
        float randomLifetime = 2.0 + fract(sin(float(seed + 1) * 78.233) * 43758.5453) * 2.0;
        float randomSize = 2.0 + fract(sin(float(seed + 2) * 45.678) * 43758.5453) * 4.0;
        
        p.position = float2(randomX, -1.2);
        p.lifetime = randomLifetime;
        p.initialLifetime = randomLifetime;
        p.size = randomSize;
        p.velocity.y = 0.3 + fract(sin(float(seed + 3) * 93.456) * 43758.5453) * 0.3;
    }
    
    // Update position based on velocity, speed multiplier and activation boost
    float activationBoost = 1.0 + uniforms.activationFactor * 1.5;
    float speed = max(0.5, uniforms.speedMultiplier) * activationBoost;
    p.position += p.velocity * uniforms.deltaTime * speed;
    
    // Color logic: Blue -> Pink (VAM) -> Gold (AMPK Activation)
    float3 blueColor = float3(0.1, 0.4, 1.0);
    float3 pinkColor = float3(1.0, 0.2, 0.6);
    float3 activeColor = float3(1.0, 0.8, 0.2); // Golden Flame
    
    float3 baseColor = mix(blueColor, pinkColor, uniforms.colorFactor);
    float3 finalColor = mix(baseColor, activeColor, uniforms.activationFactor);
    
    // Alpha based on lifetime
    float alpha = clamp(p.lifetime / p.initialLifetime, 0.0, 1.0);
    
    // Size and Glow modulation
    float finalSize = p.size * (1.0 + uniforms.activationFactor * 0.5);
    p.color = float4(finalColor, alpha * (0.6 + uniforms.activationFactor * 0.4));
    p.size = finalSize;
    
    particles[id] = p;
}

// MARK: - Vertex Shader

vertex VertexOut particleVertex(
    const device Particle* particles [[buffer(0)]],
    uint vertexId [[vertex_id]]
) {
    Particle p = particles[vertexId];
    
    VertexOut out;
    out.position = float4(p.position, 0.0, 1.0);
    out.color = p.color;
    out.pointSize = p.size;
    
    return out;
}

// MARK: - Fragment Shader

fragment float4 particleFragment(
    VertexOut in [[stage_in]],
    float2 pointCoord [[point_coord]]
) {
    // Create soft circular particles
    float dist = length(pointCoord - float2(0.5));
    float alpha = 1.0 - smoothstep(0.3, 0.5, dist);
    
    return float4(in.color.rgb, in.color.a * alpha);
}
