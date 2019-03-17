import Cocoa

import SceneKit
import PlaygroundSupport



class Scene: SCNScene, SCNSceneRendererDelegate {
    
    var sceneView: SCNView = SCNView(frame: CGRect(x: 0, y: 0, width: 400, height: 800))
    var charachters: [HarrisCharachter] = []
    
    var updateTime = TimeInterval(exactly: 2)
    
    override init() {
        super.init()
        
        sceneView.delegate = self
        sceneView.scene = self
        
        sceneView.allowsCameraControl = true
        self.background.contents = NSColor.black
        
        let camera = SCNCamera()
        camera.zFar = 1000
        camera.zNear = 0.1
        camera.bloomBlurRadius = 15
        camera.fStop = 0.1
        camera.apertureBladeCount = 5
        camera.focalLength = 18
        camera.focusDistance = 5
        camera.wantsDepthOfField = true
        camera.wantsHDR = true

        
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(19, 2, 19)
        self.rootNode.addChildNode(cameraNode)
        
        //lighting
        let environment = NSImage(named: "hdri.jpg")
        self.lightingEnvironment.contents = environment
        self.lightingEnvironment.intensity = 2.0
        
        
        //floor
        let floorGeometry = SCNFloor()
        let floorNode = SCNNode(geometry: floorGeometry)
        floorNode.position = SCNVector3(0, -0.51, 0)
        
        //floor material
        floorGeometry.reflectivity = 0
        let material = floorGeometry.firstMaterial
        material?.lightingModel = .physicallyBased
        
        material?.diffuse.contents = NSColor(white: 0.02, alpha: 1)
        material?.roughness.contents = NSColor(white: 0.4, alpha: 1)
        material?.metalness.contents = NSColor(white: 0.8, alpha: 1)
        
        self.rootNode.addChildNode(floorNode)
        
        //create & add charachters to scene (where no other charachters exist)
        for x in 0...99 {
            var randomX = Int.random(in: 0...19)
            var randomZ = Int.random(in: 0...19)
            
            for charachter in charachters {
                while Int(exactly: charachter.node.position.x) == randomX {
                    randomX = Int.random(in: 0...19)
                }
                
                while Int(exactly: charachter.node.position.z) == randomZ {
                    randomZ = Int.random(in: 0...19)
                }
            }
            
            charachters.append(HarrisCharachter(position: SCNVector3(randomX, 0, randomZ)))
            self.rootNode.addChildNode(charachters[x].node)
            self.rootNode.addChildNode(charachters[x].lightNode)
        }
    }
    
//    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
//        guard let updateTime = self.updateTime, let timeTillNextUpdate = TimeInterval(exactly: 2) else { return }
//        //runs every 2 seconds
//        if time >= updateTime {
//            self.updateTime = time + timeTillNextUpdate
//
//            for charachter in charachters {
//                charachter.calculateEmotionLevel()
//            }
//        }
//    }
    
    //idk what this is
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class HarrisCharachter {
    var node: SCNNode
    var lightNode: SCNNode
    
    var emotionLevel: Double
    
    init(position: SCNVector3) {
        print("created new character")
        
        //emotion levels key: -1 = sad, +1 = happy
        emotionLevel = 0
        
        let geometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.2)
        let material = geometry.firstMaterial
        material?.lightingModel = .physicallyBased
        
        let random1 = CGFloat.random(in: 0...255)
        let random2 = CGFloat.random(in: 0...255)
        let random3 = CGFloat.random(in: 0...255)
        
//        material?.transparency = 0.8
//        material?.fresnelExponent = 3.2
//        material?.isDoubleSided = true
//        material?.transparencyMode = .dualLayer
//        material?.metalness.contents = NSColor(white: 0.5, alpha: 1)

        material?.diffuse.contents = NSColor(deviceRed: random1/255, green: random2/255, blue: random3/255, alpha: 1)
        material?.roughness.contents = NSColor(white: 0.3, alpha: 1)
        node = SCNNode(geometry: geometry)
        node.position = position
        
//        inside light
        let light = SCNLight()
        light.intensity = 5
        light.attenuationEndDistance = 4
        light.color = NSColor(deviceRed: random1/255, green: random2/255, blue: random3/255, alpha: 1)
        light.type = SCNLight.LightType.omni

        lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = node.position
        lightNode.position.y += 0.01
    }
    
    func changeColorTo(color: NSColor) {
        
    }
    
    func calculateEmotionLevel() {
        print("calculate")
    }
}


//create scene & add to playground liveview
let testScene = Scene()
PlaygroundPage.current.liveView = testScene.sceneView
