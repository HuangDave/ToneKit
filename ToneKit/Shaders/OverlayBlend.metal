#include <metal_stdlib>
using namespace metal;

#include "BlendMode/blend_modes.h"

kernel void ComputeOverlayBlend(
  texture2d<float, access::sample> input_texture [[texture(0)]],
  texture2d<float, access::sample> overlay_texture [[texture(1)]],
  texture2d<float, access::write> output_texture [[texture(2)]],
  constant float & intensity [[buffer(0)]],
  uint2 gid [[thread_position_in_grid]])
{
    constexpr sampler s(coord::normalized);
    // f(a,b) = 2ab,                 if a < 0.5
    //        = 1 - 2(1 - a)(1 - b), if otherwise
    float4 a = input_texture.read(gid);
    float4 b = overlay_texture.sample(s, float2(gid));
    float4 output_color = float4(
      a.r < 0.5 ? (2.0 * a.r * b.r) : (1.0 - 2.0 * (1.0 - a.r) * (1.0 - b.r)),
      a.g < 0.5 ? (2.0 * a.g * b.g) : (1.0 - 2.0 * (1.0 - a.g) * (1.0 - b.g)),
      a.b < 0.5 ? (2.0 * a.b * b.b) : (1.0 - 2.0 * (1.0 - a.b) * (1.0 - b.b)),
      1.0);
    output_color = blendmode::Alpha(a, output_color, intensity);
    output_texture.write(output_color, gid);
}
