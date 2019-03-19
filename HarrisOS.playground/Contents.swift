import Cocoa

import SceneKit
import PlaygroundSupport



class Scene: SCNScene, SCNSceneRendererDelegate {
    
    var sceneView: SCNView = SCNView(frame: CGRect(x: 0, y: 0, width: 400, height: 800))
    var charachters: [HarrisCharachter] = []
    
    override init() {
        super.init()
        
        sceneView.delegate = self
        sceneView.scene = self
        sceneView.allowsCameraControl = true
        sceneView.showsStatistics = true
        sceneView.loops = true
        
        //GEOMETRY
        //floor
        let floorGeometry = SCNFloor()
        let floorNode = SCNNode(geometry: floorGeometry)
        floorNode.position = SCNVector3(0, -0.51, 0)
        
        
        
        //floor material
        
        let material = floorGeometry.firstMaterial
        material?.lightingModel = .physicallyBased
        
        floorGeometry.reflectivity = 0.01
        material?.diffuse.contents = NSColor(white: 0.02, alpha: 1)
        material?.metalness.contents = NSColor(white: 0.8, alpha: 1)
        material?.roughness.contents = NSImage(imageLiteralResourceName: "grid.png")
        material?.roughness.wrapT = .mirror
        material?.roughness.wrapS = .mirror
        material?.roughness.contentsTransform = SCNMatrix4MakeScale(100, 100, 1)
        
        self.rootNode.addChildNode(floorNode)
        
        //create & add charachters to scene (in unique location)
        let charachterCount = 99
        for x in 0...charachterCount {
            let fieldSize = 15
            var randomX = Int.random(in: 0...fieldSize)
            var randomZ = Int.random(in: 0...fieldSize)
            
            for charachter in charachters {
                while Int(exactly: charachter.node.position.x) == randomX {
                    randomX = Int.random(in: 0...fieldSize)
                }
                
                while Int(exactly: charachter.node.position.z) == randomZ {
                    randomZ = Int.random(in: 0...fieldSize)
                }
            }
            
            charachters.append(HarrisCharachter(position: SCNVector3(randomX, 0, randomZ)))
            self.rootNode.addChildNode(charachters[x].node)
            //            self.rootNode.addChildNode(charachters[x].lightNode)
            
            let random1 = CGFloat.random(in: 0...255)
            let random2 = CGFloat.random(in: 0...255)
            let random3 = CGFloat.random(in: 0...255)
            self.charachters[x].changeColorTo(NSColor(red: random1/255, green: random2/255, blue: random3/255, alpha: 1))
        }
        
        let userCharachter = charachters[0]
        userCharachter.happinessLevel = 1
        
        //CAMERA & LIGHTING
        let cameraNode = createCameraNode(following: userCharachter.node)
        //        cameraNode.position = SCNVector3(x: 6, y: 6, z: 6)
        cameraNode.position = userCharachter.node.position
        rootNode.addChildNode(cameraNode)
        
        
        
        //        test move user object
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                        userCharachter.node.runAction(SCNAction.moveBy(x: 15, y: 0, z: 10, duration: 50))
             for x in 0...99 {
            self.charachters[x].calculateEmotionLevel(charachters: self.charachters)
            }
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
//                for x in 0...99 {
//                    self.charachters[x].calculateEmotionLevel(charachters: self.charachters)
//                }
//                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
//                    for x in 0...99 {
//                        self.charachters[x].calculateEmotionLevel(charachters: self.charachters)
//                    }
//                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
//                        userCharachter.happinessLevel = 0.2
//                        for x in 0...99 {
//                            self.charachters[x].calculateEmotionLevel(charachters: self.charachters)
//                        }
//                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
//                            for x in 0...99 {
//                                self.charachters[x].calculateEmotionLevel(charachters: self.charachters)
//                            }
//                        }
//                    }
//                }
//            }
            
        }
        
        
        //lighting
        let environment = NSImage(named: "hdri.jpg")
        self.lightingEnvironment.contents = environment
        self.lightingEnvironment.intensity = 2.0
        
        self.background.contents = NSColor.black
    }
    
    func createCameraNode(following target: SCNNode) -> SCNNode {
        let camera = SCNCamera()
        
        camera.focalLength = 24
        camera.focusDistance = 8.124
        
        camera.zFar = 1000
        camera.zNear = 0
        
        camera.fStop = 0.009
        camera.apertureBladeCount = 5
        camera.wantsDepthOfField = false
        
        camera.bloomBlurRadius = 8
        camera.bloomIntensity = 0.2
        camera.bloomThreshold = 0.3
        
        camera.vignettingIntensity = 0.3
        camera.vignettingPower = 1
        
        camera.wantsHDR = true
        
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        
        
        
        let lookAtConstraint = SCNLookAtConstraint(target: target)
        lookAtConstraint.isGimbalLockEnabled = true
        
        let replicateConstraint = SCNReplicatorConstraint(target: target)
        replicateConstraint.replicatesScale = false
        replicateConstraint.replicatesOrientation = false
        
        replicateConstraint.positionOffset = SCNVector3(x: -5, y: 4, z: 5)
        
        let looseFollowConstraint = SCNAccelerationConstraint()
        
        
        cameraNode.constraints = [replicateConstraint, lookAtConstraint, looseFollowConstraint]
        
        return cameraNode
    }
    
    
    //    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    //
    //    }
    
    
    //    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    
    //    }
    
    //idk what this is
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class HarrisCharachter {
    var node: SCNNode
    //    var lightNode: SCNNode
    
    var happinessLevel = Double.random(in: 0...1)
//    var happinessLevel = 0.5
    
    private let light = SCNLight()
    
    init(position: SCNVector3) {
        
        let geometry = SCNBox(width: 0.99, height: 0.99, length: 0.99, chamferRadius: 0.26)
        
        //cube material
        if let firstMaterial = geometry.firstMaterial {
            firstMaterial.lightingModel = .physicallyBased
            
            firstMaterial.diffuse.contents = NSColor(hue: 0, saturation: 0, brightness: 0, alpha: 1)
            
            firstMaterial.metalness.contents = NSColor(white: 0.8, alpha: 1)
            firstMaterial.roughness.contents = NSImage(imageLiteralResourceName: "normal.png")
        }
        
        
        node = SCNNode(geometry: geometry)
        node.position = position
        
        //inside light
        //        light.intensity = 10
        //        light.attenuationEndDistance = 5
        //
        //        light.type = SCNLight.LightType.omni
        //
        //        lightNode = SCNNode()
        //        lightNode.light = light
        //        lightNode.position = node.position
        //        lightNode.position.y += 0.01
    }
    
    
    
    func calculateEmotionLevel(charachters: [HarrisCharachter]) {
        var happinessSum = 0.0
        var nearbyCharachterCount = 0.0
        for charachter in charachters {
            let selfPostion = SCNVector3ToGLKVector3(self.node.worldPosition)
            let charachterPosition = SCNVector3ToGLKVector3(charachter.node.worldPosition)
            
            var distance = Double(GLKVector3Distance(selfPostion, charachterPosition))
            
            var correctDistance = (distance/21.25)
            if correctDistance < 0.1 {
                happinessSum += (1-correctDistance) * charachter.happinessLevel
                nearbyCharachterCount += 1
            } else {
                happinessSum += 0
            }
        }
        //        print("HAPINESS AVG: \(happinessAvg), nearby cc: \(nearbyCharachterCount)")
        
        happinessLevel = happinessSum/nearbyCharachterCount
        let newHue = CGFloat(happinessLevel*0.15)

        let newColor = NSColor(hue: newHue, saturation: 1, brightness: 1, alpha: 1)
//        changeColorTo(newColor)
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.5
        node.geometry?.firstMaterial?.diffuse.contents = newColor
        //                lightNode.light?.color = newColor
        SCNTransaction.commit()
    }
    
    func changeColorTo(_ newColor: NSColor) {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.5
        node.geometry?.firstMaterial?.diffuse.contents = newColor
        //                lightNode.light?.color = newColor
        
        SCNTransaction.commit()
    }
}


//create scene & add to playground liveview
let testScene = Scene()
PlaygroundPage.current.liveView = testScene.sceneView
