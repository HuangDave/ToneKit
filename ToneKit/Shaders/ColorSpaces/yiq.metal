#include <metal_stdlib>
using namespace metal;

#include "yiq.h"

float3 yiq::rgb_to_yiq(float3 rgb)
{
    return rgb * float3x3(float3(0.299,  0.587,  0.114),
                          float3(0.596, -0.274, -0.322),
                          float3(0.212, -0.523,  0.311));
}

float3 yiq::yiq_to_rgb(float3 yiq)
{
    return yiq * float3x3(float3(1.0,  0.956,  0.621),
                          float3(1.0, -0.272, -0.647),
                          float3(1.0, -1.105,  1.702));
}
