#include "blend_modes.h"

float4 blend_modes::alpha(float4 a, float4 b, float intensity)
{
    return float4(mix(a.rgb, b.rgb, intensity), a.a);
}
