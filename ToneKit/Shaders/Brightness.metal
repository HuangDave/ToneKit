#include <metal_stdlib>
using namespace metal;

kernel void ComputeBrightness(texture2d<float, access::sample> input_texture [[texture(0)]],
                              texture2d<float, access::write> output_texture [[texture(1)]],
                              constant float & brightness [[buffer(0)]],
                              uint2 gid [[thread_position_in_grid]])
{
  float4 color_in = input_texture.read(gid);
  float4 color_out = float4(color_in.rgb + brightness, 1.0);
  output_texture.write(color_out, gid);
}
