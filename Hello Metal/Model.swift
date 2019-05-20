//
//  Model.swift
//  Hello Metal
//
//  Created by Keith Sharp on 20/05/2019.
//  Copyright © 2019 Passback Systems. All rights reserved.
//

import MetalKit

// What type of shape do we want to model
enum Shape: Int {
    case triangle
    case cube
}

struct Model {
    
    // The vertices that make up the shape
    private let vertices: [Vertex]
    
    // The order in which the vertices should be drawn, as triangles
    // Note that by default Metal expects triangles to be described as a clockwise list of vertsices
    private let indices: [uint16]
    
    // Number of indices that make up the shape
    let count: Int
    
    init(shape: Shape) {
        switch shape {
        // Create a triangle or a cube and make each vertex a different colour
        case .triangle:
            self.vertices = [Vertex(pos: [0.0, 1.0, 0], col: [1.0, 0.0, 0.0]),
                             Vertex(pos: [1.0, -1.0, 0], col: [0.0, 1.0, 0.0]),
                             Vertex(pos: [-1.0, -1.0, 0], col: [0.0, 0.0, 1.0])]
            
            self.indices = [0, 1, 2] // Top middle, bottom right, bottom left
        case .cube:
            self.vertices = [Vertex(pos: [-1.0, 1.0, 0], col: [1.0, 0.0, 0.0]),
                             Vertex(pos: [1.0, 1.0, 0], col: [0.0, 1.0, 0.0]),
                             Vertex(pos: [1.0, -1.0, 0], col: [0.0, 0.0, 1.0]),
                             Vertex(pos: [-1.0, -1.0, 0], col: [1.0, 1.0, 1.0]),
                             Vertex(pos: [-1.0, 1.0, 1.0], col: [1.0, 0.0, 0.0]),
                             Vertex(pos: [1.0, 1.0, 1.0], col: [0.0, 1.0, 0.0]),
                             Vertex(pos: [1.0, -1.0, 1.0], col: [0.0, 0.0, 1.0]),
                             Vertex(pos: [-1.0, -1.0, 1.0], col: [1.0, 1.0, 1.0])
                            ]
            
            self.indices = [0, 1, 4, 1, 2, 3, // Front
                            1, 5, 2, 5, 6, 2, // Right
                            5, 4, 6, 4, 7, 6, // Rear
                            4, 0, 7, 0, 3, 7, // Left
                            4, 1, 0, 4, 5, 1, // Top
                            3, 7, 2, 7, 6, 2] // Bottom
        }
        self.count = self.indices.count
    }
    
    // Convert the vertices to an MTLBuffer on the GPU
    func getVertexBuffer(device: MTLDevice) -> MTLBuffer {
        guard let vertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<Vertex>.stride, options: []) else {
            fatalError("Could not create MTLBuffer")
        }
        return vertexBuffer
    }
    
    // Convert the indeices to an MTLBuffer on the GPU
    func getIndexBuffer(device: MTLDevice) -> MTLBuffer {
        guard let indexBuffer = device.makeBuffer(bytes: indices, length: indices.count * MemoryLayout<uint>.stride, options: []) else {
            fatalError("Could not create MTLBuffer")
        }
        return indexBuffer
    }
}
