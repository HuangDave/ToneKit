#include <metal_stdlib>
using namespace metal;

#include "ColorSpaces/yiq.h"

kernel void compute_white_balance(texture2d<float, access::sample> texture_in  [[texture(0)]],
                                  texture2d<float, access::write>  texture_out [[texture(1)]],
                                  constant float & temperature [[buffer(0)]],
                                  constant float & tint        [[buffer(1)]],
                                  uint2 gid [[thread_position_in_grid]])
{
    constexpr float3 warm_filter = float3(0.93, 0.54, 0.0);
    float4 color_in = texture_in.read(gid);
    float3 yiq = yiq::rgb_to_yiq(color_in.rgb);
    yiq.b = clamp(yiq.b + tint * 0.5226 * 0.1, -0.5226, 0.5226);
    float3 rgb = yiq::yiq_to_rgb(yiq);
    float3 color_out = float3((rgb.r < 0.5 ? (2.0 * rgb.r * warm_filter.r) : (1.0 - 2.0 * (1.0 - rgb.r) * (1.0 - warm_filter.r))),
                              (rgb.g < 0.5 ? (2.0 * rgb.g * warm_filter.g) : (1.0 - 2.0 * (1.0 - rgb.g) * (1.0 - warm_filter.g))),
                              (rgb.b < 0.5 ? (2.0 * rgb.b * warm_filter.b) : (1.0 - 2.0 * (1.0 - rgb.b) * (1.0 - warm_filter.b))));
    texture_out.write(float4(mix(rgb, color_out, temperature), color_in.a), gid);
}
