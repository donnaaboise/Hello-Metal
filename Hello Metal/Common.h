//
//  Common.h
//  Hello Metal
//
//  Created by Keith Sharp on 20/05/2019.
//  Copyright © 2019 Passback Systems. All rights reserved.
//

// Data structures that are shared between the main program written in Swift
// and the shader programs on the GPU
// This works by defining this file as the bridging header in the Xcode project

#ifndef Common_h
#define Common_h

#include <simd/simd.h>

// Define the structure of a vertex as:
//  - position vector or three floats representing the x, y, and z coordinates
//  - colour vector of three floats representing red, green, and blue values
struct Vertex {
    vector_float3 pos;
    vector_float3 col;
};

#endif /* Common_h */
