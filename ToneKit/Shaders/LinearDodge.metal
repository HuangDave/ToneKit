#include <metal_stdlib>
using namespace metal;

#include "blend_modes.h"

kernel void compute_linear_dodge_blend(texture2d<float, access::sample> input_texture   [[texture(0)]],
                                       texture2d<float, access::sample> overlay_texture [[texture(1)]],
                                       texture2d<float, access::write>  output_texture  [[texture(2)]],
                                       constant float & intensity [[buffer(0)]],
                                       uint2 gid [[thread_position_in_grid]])
{
    constexpr sampler s(coord::normalized);
    // f(a,b) = a + b
    float4 a = input_texture.read(gid);
    float4 b = overlay_texture.sample(s, float2(gid));
    float4 output_color = a + b;
    output_color = blend_modes::alpha(a, output_color, intensity);
    output_texture.write(output_color, gid);
}
