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
        
        sceneView.showsStatistics = true
        
        sceneView.allowsCameraControl = true
        self.background.contents = NSColor.black
        
        let camera = SCNCamera()
        camera.automaticallyAdjustsZRange = true
        camera.fStop = 1.6
//        camera.apertureBladeCount = 5
        camera.focalLength = 24
        camera.focusDistance = 10
        camera.wantsDepthOfField = true
        camera.wantsHDR = true
        
        
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 0, 0)
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
        
//        material?.roughness.contents = NSColor(white: 0.4, alpha: 1)
        material?.metalness.contents = NSColor(white: 0.8, alpha: 1)
        material?.roughness.contents = NSImage(imageLiteralResourceName: "grid.png")
        material?.roughness.wrapT = .mirror
        material?.roughness.wrapS = .mirror
        material?.roughness.contentsTransform = SCNMatrix4MakeScale(100, 100, 1)
        
        self.rootNode.addChildNode(floorNode)
        
        //create & add charachters to scene (where no other charachters exist)
        for x in 0...99 {
            var randomX = Int.random(in: 0...12)
            var randomZ = Int.random(in: 0...12)
            
            for charachter in charachters {
                while Int(exactly: charachter.node.position.x) == randomX {
                    randomX = Int.random(in: 0...20)
                }
                
                while Int(exactly: charachter.node.position.z) == randomZ {
                    randomZ = Int.random(in: 0...20)
                }
            }
            
            charachters.append(HarrisCharachter(position: SCNVector3(randomX, 0, randomZ)))
            self.rootNode.addChildNode(charachters[x].node)
            self.rootNode.addChildNode(charachters[x].lightNode)
            
            let random1 = CGFloat.random(in: 0...255)
            let random2 = CGFloat.random(in: 0...255)
            let random3 = CGFloat.random(in: 0...255)
            self.charachters[x].changeColorTo(NSColor(red: random1/255, green: random2/255, blue: random3/255, alpha: 1))
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
    
    //    @objc private var material: SCNMaterial
    private let light = SCNLight()
    
    init(position: SCNVector3) {
        //emotion levels key: -1 = sad, +1 = happy
        emotionLevel = 0
        
        let geometry = SCNBox(width: 0.99, height: 0.99, length: 0.99, chamferRadius: 0.26)
        
        //cube material
        if let firstMaterial = geometry.firstMaterial {
            firstMaterial.lightingModel = .physicallyBased
            
            firstMaterial.diffuse.contents = NSColor(red: 0.2, green: 0.3, blue: 0.8, alpha: 1)
            
            firstMaterial.metalness.contents = NSColor(white: 0.8, alpha: 1)
            firstMaterial.roughness.contents = NSImage(imageLiteralResourceName: "normal.png")
        }
        
        node = SCNNode(geometry: geometry)
        node.position = position
        
        
        //inside light
        light.intensity = 10
        light.attenuationEndDistance = 4
        
        light.type = SCNLight.LightType.omni
        
        lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = node.position
        lightNode.position.y += 0.01
    }
    
    func changeColorTo(_ newColor: NSColor) {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 10
        node.geometry?.firstMaterial?.diffuse.contents = newColor
        lightNode.light?.color = newColor
        SCNTransaction.commit()
    }
    
    func calculateEmotionLevel() {
        print("calculate")
    }
}


//create scene & add to playground liveview
let testScene = Scene()
PlaygroundPage.current.liveView = testScene.sceneView
