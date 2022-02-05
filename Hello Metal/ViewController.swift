//
//  ViewController.swift
//  Hello Metal
//
//  Created by Keith Sharp on 20/05/2019.
//  Copyright © 2019 Passback Systems. All rights reserved.
//

import Cocoa
import MetalKit

class ViewController: NSViewController {

    // Outlets for the views in the Storyboard
    @IBOutlet var splitView: NSSplitView!
    @IBOutlet weak var mtkView: MTKView!
    @IBOutlet weak var shapePopUpButton: NSPopUpButton!
    @IBOutlet weak var renderAsWireframe: NSButton!
    @IBOutlet weak var scaleSlider: NSSlider!
    
    // The delegate of the MTKView that does the drawing
    var renderer: Renderer!

    // Used to construct the shapePopUpButton
    private let shapes = ["Triangle", "Cube"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up the NSSplitView
        splitView.setPosition(250.0, ofDividerAt: 0)
        splitView.setHoldingPriority(.defaultHigh, forSubviewAt: 0)
        
        // Get the default GPU and assign it to the MTKView
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            fatalError("Could not create default Metal device")
        }
        mtkView.device = defaultDevice
        
        // When the MTKView is cleared between frames set it to black
        mtkView.clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        
        // Create the renderer object and set it as the MTKView delegate
        guard let tmpRenderer = Renderer(mtkView: self.mtkView) else {
            fatalError("Could not initialise Renderer class")
        }
        renderer = tmpRenderer
        mtkView.delegate = renderer
        
        // Configure the shapePopUpButton
        shapePopUpButton.removeAllItems()
        shapePopUpButton.addItems(withTitles: shapes)
        shapePopUpButton.selectItem(at: 0)
        
        // Set the initial shape to be drawn
        guard let shape = Shape(rawValue: shapePopUpButton.indexOfSelectedItem) else { return }
        renderer.model = Model(shape: shape)
        
        // Get the scale value
        let scale = scaleSlider.floatValue
        
        // Not implemented yet - translation value
        let translation: SIMD3<Float> = [0.0, 0.0, 0.0]
        
        // Not implemented yet - rotation around X, Y, and Z
        let rx: float_t = 0.0
        let ry: float_t = 0.0
        let rz: float_t = 0.0
        
        // Set transformationMatrix
        renderer.uniforms.modelMatrix = float4x4.createTransformationMatrix(translation: translation,
                                                                                     rx: rx, ry: ry, rz: rz,
                                                                                     scale: scale)
    }

    // When the selection in the shapePopUpButton changes, change the shape to be drawn
    @IBAction func shapeChanged(_ sender: NSPopUpButton) {
        guard let shape = Shape(rawValue: shapePopUpButton.indexOfSelectedItem) else { return }
        renderer.model = Model(shape: shape)
    }
    
    // Toggle between wireframe and solid
    @IBAction func renderStyleChanged(_ sender: NSButton) {
        switch sender.state {
        case .on:
            renderer.uniforms.wireframe = true
        default:
            renderer.uniforms.wireframe =  false
        }
    }
    
    // Change the scale of the model - translation and rotation values are ignored
    @IBAction func scaleValueChanged(_ sender: NSSlider) {
        renderer.uniforms.modelMatrix = float4x4.createTransformationMatrix(translation: [0.0, 0.0, 0.0], rx: 0.0, ry: 0.0, rz: 0.0, scale: sender.floatValue)
    }
    
}

