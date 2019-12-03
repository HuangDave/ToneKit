#include <metal_stdlib>
using namespace metal;

kernel void ComputePassthrough(texture2d<float, access::read> input_texture [[texture(0)]],
                               texture2d<float, access::write> output_texture [[texture(1)]],
                               uint2 gid [[thread_position_in_grid]])
{
  output_texture.write(input_texture.read(gid), gid);
}
