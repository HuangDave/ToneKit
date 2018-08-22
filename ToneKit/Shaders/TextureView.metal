#include <metal_stdlib>
using namespace metal;

typedef struct {
    float4 position           [[position]];
    float2 texture_coordinate [[user(texturecoord)]];
} VertexInOut;

vertex VertexInOut vertex_main(constant packed_float4 * position_in   [[buffer(0)]],
                               constant packed_float2 * coordinate_in [[buffer(1)]],
                               ushort                   vid           [[vertex_id]])
{
    VertexInOut vertex_out;
    vertex_out.position           = position_in[vid];
    vertex_out.texture_coordinate = coordinate_in[vid];
    return vertex_out;
}

fragment float4 fragment_passthrough(VertexInOut      vertex_in  [[stage_in]],
                                     texture2d<float> texture_in [[texture(0)]])
{
    constexpr sampler normalized_sampler(coord::normalized);
    return float4(texture_in.sample(normalized_sampler, vertex_in.texture_coordinate));
}
