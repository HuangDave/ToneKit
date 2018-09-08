#include <metal_stdlib>
using namespace metal;

kernel void compute_brightness(texture2d<float, access::sample> texture_in  [[texture(0)]],
                               texture2d<float, access::write>  texture_out [[texture(1)]],
                               constant float & brightness [[buffer(0)]],
                               uint2 gid [[thread_position_in_grid]])
{
    float4 color_in = texture_in.read(gid);
    float4 color_out = float4(color_in.rgb + brightness, 1.0);
    texture_out.write(color_out, gid);
}
