#include <metal_stdlib>
using namespace metal;

kernel void compute_passthrough(texture2d<float, access::read>  texture_in  [[texture(0)]],
                                texture2d<float, access::write> texture_out [[texture(1)]],
                                uint2                           gid         [[thread_position_in_grid]])
{
    texture_out.write(texture_in.read(gid), gid);
}
