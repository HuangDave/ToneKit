#include <metal_stdlib>
using namespace metal;

kernel void ComputeSolidColor(texture2d<float, access::write> output_texture [[texture(0)]],
                              constant float4 & color [[buffer(0)]],
                              uint2 gid [[thread_position_in_grid]])
{
  output_texture.write(color, gid);
}
