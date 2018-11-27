//
//  ViewController.swift
//  Ar-Card
//
//  Created by David Gunawan on 27/11/18.
//  Copyright © 2018 David. All rights reserved.
//

import UIKit
import ARKit

class DeckViewController: UIViewController, ARSessionDelegate {
    @IBOutlet var sceneView: ARSCNView!
    
    enum Card: String { case clubAce, club2, club3, club4, club5, club6, club12, club8, club9, club10, clubJack, clubQueen, clubKing }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self

        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let triggerImages = ARReferenceImage.referenceImages(inGroupNamed: "deck", bundle: nil)!
        
        // Image tracking
        let configuration = ARImageTrackingConfiguration()
        configuration.trackingImages = triggerImages
        
        //    // World tracking
        //    let configuration = ARWorldTrackingConfiguration()
        //    configuration.detectionImages = triggerImages
        
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
}

extension DeckViewController : ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        if let imageAnchor = anchor as? ARImageAnchor {
            let overlayNode = createCardOverlayNode(for: imageAnchor)
            let infoPanelNode = createInfoPanelNode(for: imageAnchor)
            overlayNode.addChildNode(infoPanelNode)
            return overlayNode
        }
        
        return nil
    }
}

extension DeckViewController {
    func createInfoPanelNode(for anchor: ARImageAnchor) -> SCNNode {
        let cardName = anchor.referenceImage.name ?? "Unknown card"
        
        let plane = SCNPlane(width: anchor.referenceImage.physicalSize.width, height: anchor.referenceImage.physicalSize.height / 12)
        plane.cornerRadius = 0.0015
        let labelSize = CGSize(width: 100, height: 100 * plane.height / plane.width)
        let labelVerticalOffset = plane.height / 2
        
        let material = SCNMaterial()
        
        DispatchQueue.main.sync {
            let label = UILabel()
            
            label.backgroundColor = UIColor.clear
            label.textColor = UIColor.darkGray
            label.text = cardName
            label.frame.size = labelSize
            label.textAlignment = .center
            
            material.diffuse.contents = label
        }
        
        material.transparency = 0.8
        plane.materials = [material]
        
        
        let node = SCNNode(geometry: plane)
        
        let translation = SCNMatrix4MakeTranslation(0, Float(anchor.referenceImage.physicalSize.height / 2 + labelVerticalOffset + 0.001), 0)
        let rotation = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
        let transform = SCNMatrix4Mult(translation, rotation)
        node.transform = transform
        
        SCNTransaction.animationDuration = 2.0
        
        let height = plane.height
        let animation = CABasicAnimation(keyPath: "height")
        animation.fromValue = 0.0
        animation.toValue = height
        animation.duration = 1.0
        animation.autoreverses = false
        animation.repeatCount = 0
        plane.addAnimation(animation, forKey: "height")
        
        return node
    }
    
    func createCardOverlayNode(for anchor: ARImageAnchor) -> SCNNode {
        let box = SCNBox(width: anchor.referenceImage.physicalSize.width, height: 0.0001, length: anchor.referenceImage.physicalSize.height, chamferRadius: 0)
        if let material = box.firstMaterial {
            material.diffuse.contents = UIColor.red
            material.transparency = 0.3
        }
        
        return SCNNode(geometry: box)
    }
}
