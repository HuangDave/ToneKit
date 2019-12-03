#include <metal_stdlib>
using namespace metal;

kernel void ComputeLookup(
  texture2d<float, access::sample> input_texture [[texture(0)]],
  texture2d<float, access::sample> lookup_texture [[texture(1)]],
  texture2d<float, access::write>  output_texture [[texture(2)]],
  constant float & intensity [[buffer(0)]],
  uint2 gid [[thread_position_in_grid]])
{
  float4 color_in = input_texture.read(gid);
  float blue = color_in.b * 63.0;

  float2 quad1;
  quad1.y = floor(floor(blue) / 8.0);
  quad1.x = floor(blue) - (quad1.y * 8.0);

  float2 quad2;
  quad2.y = floor(ceil(blue) / 8.0);
  quad2.x = ceil(blue) - (quad2.y * 8.0);

  float2 texture_position1 = float2(
    (quad1.x * 0.125) + 0.5 / 512.0 + ((0.125 - 1.0 / 512.0) * color_in.r),
    (quad1.y * 0.125) + 0.5 / 512.0 + ((0.125 - 1.0 / 512.0) * color_in.g));
  float2 texture_position2 = float2(
    (quad2.x * 0.125) + 0.5 / 512.0 + ((0.125 - 1.0 / 512.0) * color_in.r),
    (quad2.y * 0.125) + 0.5 / 512.0 + ((0.125 - 1.0 / 512.0) * color_in.g));

  constexpr sampler s(coord::normalized);
  float4 new_color1 = lookup_texture.sample(s, texture_position1);
  float4 new_color2 = lookup_texture.sample(s, texture_position2);
  float4 color = mix(new_color1, new_color2, fract(blue));

  output_texture.write(mix(color_in, float4(color.rgb, color_in.a), intensity), gid);
}
