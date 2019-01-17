#include <metal_stdlib>
using namespace metal;

#include "blend_modes.h"

kernel void compute_soft_light_blend(texture2d<float, access::sample> input_texture   [[texture(0)]],
                                     texture2d<float, access::sample> overlay_texture [[texture(1)]],
                                     texture2d<float, access::write>  output_texture  [[texture(2)]],
                                     constant float & intensity [[buffer(0)]],
                                     uint2 gid [[thread_position_in_grid]])
{
    constexpr sampler s(coord::normalized);
    // f(a,b) = 2ab + (a^2)(1 - 2b),  if b < 0.5
    //        = 2a(1-b) + √a(2b - 1), if otherwise
    float4 a = input_texture.read(gid);
    float4 b = overlay_texture.sample(s, float2(gid));
    float4 output_color = float4(b.r < 0.5 ? (2.0 * a.r * b.r + a.r * a.r * (1.0 - 2.0 * b.r))
                                            : (2.0 * a.r * (1.0 - b.r) + sqrt(a.r) * (2.0 * b.r - 1.0)),
                                 b.g < 0.5 ? (2.0 * a.g * b.g + a.g * a.r * (1.0 - 2.0 * b.g))
                                            : (2.0 * a.g * (1.0 - b.g) + sqrt(a.g) * (2.0 * b.g - 1.0)),
                                 b.b < 0.5 ? (2.0 * a.b * b.b + a.b * a.r * (1.0 - 2.0 * b.b))
                                            : (2.0 * a.b * (1.0 - b.b) + sqrt(a.b) * (2.0 * b.b - 1.0)),
                                 1.0);
    output_color = blend_modes::alpha(a, output_color, intensity);
    output_texture.write(output_color, gid);
}
