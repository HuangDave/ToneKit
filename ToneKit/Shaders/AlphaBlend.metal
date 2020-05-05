#include <metal_stdlib>
using namespace metal;

#include "BlendMode/blend_modes.h"

kernel void ComputeAlphaBlend(texture2d<float, access::sample> input_texture [[texture(0)]],
                              texture2d<float, access::sample> overlay_texture [[texture(1)]],
                              texture2d<float, access::write> output_texture [[texture(2)]],
                              constant float & intensity [[buffer(0)]],
                              uint2 gid [[thread_position_in_grid]])
{
  constexpr sampler s(coord::normalized);
  float4 a = input_texture.read(gid);
  float4 b = overlay_texture.read(gid);
  output_texture.write(blendmode::Alpha(a, b, intensity), gid);
}
