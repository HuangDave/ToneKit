#include <metal_stdlib>
using namespace metal;

kernel void compute_solid_color(texture2d<float, access::write> texture_out [[texture(0)]],
                                constant float4                 & color     [[buffer(0)]],
                                uint2                           gid         [[thread_position_in_grid]])
{
    texture_out.write(color, gid);
}
