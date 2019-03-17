import UIKit
import SceneKit
import PlaygroundSupport

enum Emotion {
    case happy
    case sad
    case nice
    case mean
}

class Scene {
    let sceneView: SCNView
    let scene: SCNScene
    
//    var userCharachter: HarrisCharachter
    var charachters: [HarrisCharachter] = []

    init() {
        sceneView = SCNView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
        scene = SCNScene()
        
        sceneView.scene = scene
        sceneView.autoenablesDefaultLighting = true
        sceneView.allowsCameraControl = true
        
        //floor
        let floorGeometry = SCNFloor()
        let floor = SCNNode(geometry: floorGeometry)
        scene.rootNode.addChildNode(floor)
        
        //create & add charachters to scene
        for x in 0...5 {
            charachters.append(HarrisCharachter())
            scene.rootNode.addChildNode(charachters[x].node)
        }
        
        
        
    }
}

class HarrisCharachter {
    var geometry: SCNGeometry
    var node: SCNNode
    var emotionLevel: Double
    
    init() {
        print("created new character")
        
        //emotion levels key: -1 = sad, +1 = happy
        emotionLevel = 0
        
        geometry = SCNBox(width: 10, height: 10, length: 10, chamferRadius: 2)
        node = SCNNode(geometry: geometry)
        
        node.position = 
    }
    
    func changeColorTo(color: UIColor) {
        
    }
}


//create scene & add to playground liveview
let testScene = Scene()
PlaygroundPage.current.liveView = testScene.sceneView
