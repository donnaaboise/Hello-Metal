//
//  Shaders.metal
//  Hello Metal
//
//  Created by Keith Sharp on 20/05/2019.
//  Copyright © 2019 Passback Systems. All rights reserved.
//

#include <metal_stdlib>
#include "Common.h" // Give access to the data structure definitions shared between the CPU and GPU code
using namespace metal;

// The data struct that is passed from the vertex shader to the rasteriser to the fragment shader
struct VertexOut {
    float4 pos [[position]]; // Coordinate vector - 4 values to make the matrix math work later
    float3 col; // Colour
};

// Pass through vertex shader
vertex VertexOut vertex_main(const device Vertex *vertexArray [[buffer(0)]],
                             unsigned int vid [[vertex_id]],
                             constant Uniforms &uniforms [[buffer(1)]])
{
    Vertex in = vertexArray[vid];
    
    VertexOut out;
    
    // Multiply the vertex position by the transformationMatrix to locate in world space
    out.pos = uniforms.transformationMatrix * float4(in.pos, 1);
    out.col = in.col;
    
    return out;
}

// Pass through fragment shader
fragment float4 fragment_main(VertexOut in [[stage_in]])
{
    return float4(in.col, 1);
}

