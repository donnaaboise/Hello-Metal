//
//  Renderer.swift
//  Hello Metal
//
//  Created by Keith Sharp on 20/05/2019.
//  Copyright © 2019 Passback Systems. All rights reserved.
//

import MetalKit

class Renderer: NSObject {
    
    // Core Metal objects set up in advance of drawing
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private let pipelineState: MTLRenderPipelineState
    
    // The vertices and indices that will be drawn
    private var vertexBuffer: MTLBuffer?
    private var indexBuffer: MTLBuffer?
    
    // The model that will be drawn, create the vertex and index buffers when
    // the model is changed
    var model: Model? {
        didSet {
            vertexBuffer = model?.getVertexBuffer(device: device)
            indexBuffer = model?.getIndexBuffer(device: device)
        }
    }
    
    // Not used yet, will contain the tranform and view matrices
    var uniforms = Uniforms()
    
    // Configure whether to render model as a wireframe or solid
    var renderAsWireframe = false
    
    init?(mtkView: MTKView) {
        
        // Get the device for convenience
        guard let tmpDevice = mtkView.device else {
            return nil
        }
        self.device = tmpDevice
        
        // Create the CommandQueue
        guard let tmpCommandQueue = device.makeCommandQueue() else {
            return nil
        }
        commandQueue = tmpCommandQueue
        
        // Create the RenderPipelineState
        pipelineState = Renderer.createRenderPipeline(mtkView: mtkView)
        
        // Not used yet, set the transform and view matrices to the identity matrix
        uniforms.transformationMatrix = matrix_identity_float4x4
        uniforms.viewMatrix = matrix_identity_float4x4
    }
    
    class func createRenderPipeline(mtkView: MTKView) -> MTLRenderPipelineState {
        // Get the default shader library - this is the compiled version of Shaders.metal
        let library = mtkView.device?.makeDefaultLibrary()
        
        // Configure the shaders we want to use and the pixelFormat
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = library?.makeFunction(name: "vertex_main")
        pipelineDescriptor.fragmentFunction = library?.makeFunction(name: "fragment_main")
        pipelineDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
        
        // Create and return the RenderPipelineState, or crash with a fatal error
        guard let ps = try! mtkView.device?.makeRenderPipelineState(descriptor: pipelineDescriptor) else {
            fatalError("Could not make RenderPipelineState")
        }
        return ps
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // Recalculate viewMatrix here, only matters once we're doind 3D
    }
    
    // Called 60 times a second to update the contents of the MTKView
    func draw(in view: MTKView) {
        // Create a CommandBuffer and a RenderPassDescriptor
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        
        // Check we've got something to draw
        guard let vertexBuffer = self.vertexBuffer else { return }
        guard let indexBuffer = self.indexBuffer else { return }
        
        // Create the RenderCommandEncoder
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        
        // Set the pipeline state, i.e. tell the GPU which shader functions to use
        renderEncoder.setRenderPipelineState(pipelineState)
        
        // Tell the GPU which vertices we want to draw
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
        // Not used yet, tell the GPU about the uniforms
        renderEncoder.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: 1)
        renderEncoder.setFragmentBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: 1)
        
        // Configure wireframe or fill/solid rendering
        renderEncoder.setTriangleFillMode(renderAsWireframe ? .lines : .fill)
        
        // Draw the vertices as triangles in the order specified by the indices array of the model
        // which is encoded in the indexBuffer
        renderEncoder.drawIndexedPrimitives(type: .triangle,
                                            indexCount: model!.count,
                                            indexType: .uint16,
                                            indexBuffer: indexBuffer,
                                            indexBufferOffset: 0)
        
        // Finish encoding commands for the GPU and tell it to do some rendering to the MTKView
        renderEncoder.endEncoding()
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
    }
    
}
