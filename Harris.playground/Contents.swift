import UIKit
import SceneKit
import PlaygroundSupport



class Scene: SCNScene, SCNSceneRendererDelegate {
    
    var sceneView: SCNView = SCNView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
    var charachters: [HarrisCharachter] = []
    
    var updateTime = TimeInterval(exactly: 2)
    
    override init() {
        super.init()
        
        sceneView.delegate = self
        sceneView.scene = self
        
        sceneView.autoenablesDefaultLighting = true
        sceneView.allowsCameraControl = true
        
//        let camera = SCNCamera()
//        camera.zFar = 1000
//        camera.zNear = 0.1
//        let cameraNode = SCNNode()
//        cameraNode.camera = camera
//        cameraNode.position = SCNVector3(0, 5, 2)
//        self.rootNode.addChildNode(cameraNode)
        
        let floorGeometry = SCNFloor()
        let floorNode = SCNNode(geometry: floorGeometry)
        floorGeometry.firstMaterial?.diffuse.contents = UIColor.red
        floorNode.position = SCNVector3(0, -0.51, 0)
        self.rootNode.addChildNode(floorNode)
        
        //create & add charachters to scene (where no other charachters exist)
        for x in 0...5 {
            var randomX = Int.random(in: 0...9)
            var randomZ = Int.random(in: 0...9)

            for charachter in charachters {
                while Int(exactly: charachter.node.position.x) == randomX {
                    randomX = Int.random(in: 0...9)
                }

                while Int(exactly: charachter.node.position.z) == randomZ {
                    randomZ = Int.random(in: 0...9)
                }
            }
            
            charachters.append(HarrisCharachter(position: SCNVector3(randomX, 0, randomZ)))
            self.rootNode.addChildNode(charachters[x].node)
        }
    }
    
    //runs every frame
    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        guard let updateTime = self.updateTime, let timeTillNextUpdate = TimeInterval(exactly: 2) else { return }
        //runs every 2 seconds
        if time >= updateTime {
            self.updateTime = time + timeTillNextUpdate
            
            for charachter in charachters {
                charachter.calculateEmotionLevel()
            }
        }
    }

    //idk what this is
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class HarrisCharachter {
    var node: SCNNode
    var emotionLevel: Double
    
    init(position: SCNVector3) {
        print("created new character")
        
        //emotion levels key: -1 = sad, +1 = happy
        emotionLevel = 0
        
        let geometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.2)
        node = SCNNode(geometry: geometry)
        node.position = position
    }
    
    func changeColorTo(color: UIColor) {
        
    }
    
    func calculateEmotionLevel() {
        print("calculate")
    }
}


//create scene & add to playground liveview
let testScene = Scene()
PlaygroundPage.current.liveView = testScene.sceneView
