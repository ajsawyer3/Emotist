import Cocoa

import SceneKit
import PlaygroundSupport

enum Direction {
    case foward
    case back
    case right
    case left
}

class Scene: SCNScene, SCNSceneRendererDelegate {
    
    
    var sceneView: SCNView = SCNView(frame: CGRect(x: 0, y: 0, width: 400, height: 800))
    public var charachters: [BlockCharachter] = []
    
//    let userCharachter = UserCharachter(position: SCNVector3(x: 1, y: 0, z: 1), happinessLevel: 0)
    let userCharachter = UserCharachter(position: SCNVector3(x: 18, y: 0, z: 18), happinessLevel: 0)
    
    override init() {
        super.init()
        
        sceneView.delegate = self
        sceneView.scene = self
        sceneView.allowsCameraControl = true
        sceneView.showsStatistics = true
        
        //GEOMETRY
        //floor
        let floorGeometry = SCNFloor()
        let floorNode = SCNNode(geometry: floorGeometry)
        floorNode.position = SCNVector3(0, -0.51, 0)
        
        //        floorNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: SCNBox(width:1000, height:0.0001, length:1000, chamferRadius: 0), options: nil))
        
        
        //floor material
        
        let material = floorGeometry.firstMaterial
        material?.lightingModel = .physicallyBased
        
        //        floorGeometry.reflectivity = 0.01
        floorGeometry.reflectivity = 0
        material?.diffuse.contents = NSColor(white: 0.02, alpha: 1)
        material?.metalness.contents = NSColor(white: 0.8, alpha: 1)
        material?.roughness.contents = NSImage(imageLiteralResourceName: "grid.png")
        material?.roughness.wrapT = .mirror
        material?.roughness.wrapS = .mirror
        material?.roughness.contentsTransform = SCNMatrix4MakeScale(100, 100, 1)
        
        self.rootNode.addChildNode(floorNode)
        
        //create & add charachters to scene (in unique location)
        //        let charachterCount = 99
        
        
        
        //make user charachter
        var previousLocations: [CGPoint] = [CGPoint(x: 9, y: 9)]
        self.rootNode.addChildNode(userCharachter.node)
        self.rootNode.addChildNode(userCharachter.lightNode)
        charachters.append(userCharachter)
        
        
        let charachterCount = 75
        //        for x in 0...charachterCount {
        //            let fieldSize = 16
        //
        //            var uniquePoint = CGPoint(x: -1, y: -1)
        //            while previousLocations.contains(uniquePoint) || uniquePoint.x == -1 || (uniquePoint.x == 8 && uniquePoint.y == 8){
        //                let randomX = Int.random(in: 1...fieldSize)
        //                let randomZ = Int.random(in: 1...fieldSize)
        //                uniquePoint = CGPoint(x: randomX, y: randomZ)
        //            }
        //
        //            previousLocations.append(uniquePoint)
        //
        //            //make new charachter
        //            let newCharachter = BlockCharachter(position: SCNVector3(uniquePoint.x, 0, uniquePoint.y))
        //            charachters.append(newCharachter)
        //            newCharachter.happinessLevel = Double.random(in: 0...1)
        //            self.rootNode.addChildNode(newCharachter.node)
        //            self.rootNode.addChildNode(newCharachter.lightNode)
        //
        //
        //            let random1 = CGFloat.random(in: 0...255)
        //            let random2 = CGFloat.random(in: 0...255)
        //            let random3 = CGFloat.random(in: 0...255)
        //            self.charachters[x].changeColorTo(NSColor(red: random1/255, green: random2/255, blue: random3/255, alpha: 1))
        //        }
        
        
        
        //make new charachter
        let test1newCharachter = BlockCharachter(position: SCNVector3(0, 0, 0), happinessLevel: 1)
        charachters.append(test1newCharachter)
        self.rootNode.addChildNode(test1newCharachter.node)
        self.rootNode.addChildNode(test1newCharachter.lightNode)
        
//        let test1pnewCharachter = BlockCharachter(position: SCNVector3(0, 0, 1), happinessLevel: 1)
//        charachters.append(test1pnewCharachter)
//        self.rootNode.addChildNode(test1pnewCharachter.node)
//        self.rootNode.addChildNode(test1pnewCharachter.lightNode)
        
        let test2newCharachter = BlockCharachter(position: SCNVector3(19, 0, 19), happinessLevel: 1)
        charachters.append(test2newCharachter)
        self.rootNode.addChildNode(test2newCharachter.node)
        self.rootNode.addChildNode(test2newCharachter.lightNode)
        
        
        
        
        //CAMERA & LIGHTING
        let cameraNode = createCameraNode(following: userCharachter.node)
        cameraNode.position = userCharachter.node.position
        rootNode.addChildNode(cameraNode)
        
        
        //        test move user object
        //        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
        //            userCharachter.node.runAction(SCNAction.moveBy(x: 15, y: 0, z: 10, duration: 50))
        //
        //            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
        //                for x in 0...99 {
        //                    self.charachters[x].calculateEmotionLevel(charachters: self.charachters)
        //                }
        //                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
        //                    for x in 0...99 {
        //                        self.charachters[x].calculateEmotionLevel(charachters: self.charachters)
        //                    }
        //                    userCharachter.happinessLevel = 1
        //                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
        //                        for x in 0...99 {
        //                            self.charachters[x].calculateEmotionLevel(charachters: self.charachters)
        //                        }
        //                    }
        //                }
        //            }
        //        }
        
        //lighting
        let environment = NSImage(named: "hdri.jpg")
        self.lightingEnvironment.contents = environment
        self.lightingEnvironment.intensity = 2.0
        
        self.background.contents = NSColor.black
        
        
        
        
        //initally run
        //        calculateEmotions()
    }
    
    func calculateEmotions() {
        DispatchQueue.global(qos: .background).async {
            let originalMap = self.makeArrayMap()
            let newMap = self.calculateNewHappiness(map: originalMap)
            self.assignNewMap(newMap: newMap)
        }
    }
    
    func assignNewMap(newMap: [[Double?]]) {
        let flatMap = newMap.flatMap { $0 }.compactMap { $0 }
        
        for i in 0...(charachters.count-1) {
            let newValue = flatMap[i]
            let charachter = charachters[i]
            
            //*0.135
            let hue: CGFloat = CGFloat(charachter.happinessLevel) * 0.135
            let newColor = NSColor(hue: hue, saturation: 1, brightness: 1, alpha: 1)
            DispatchQueue.main.async {
                charachter.changeColorTo(newColor)
            }
            
        }
    }
    
    func calculateNewHappiness(map: [[BlockCharachter?]]) -> [[Double?]] {
        var charachtersUpdatedLevels: [[Double?]] = []
        for y in 0...19 {
            charachtersUpdatedLevels.append([])
            for x in 0...19 {
                //make charachtersUpdatedLevels = to currentlevels
                if let original = map[y][x] {
                    charachtersUpdatedLevels[y].append(original.happinessLevel)
                } else {
                    charachtersUpdatedLevels[y].append(nil)
                }
                
                //if refCharachter is not nil
                if let refCharachter = map[y][x] {
                    var happinessTotal = 0.0
                    var contributorCount = 0.0

//                    x, y+1
//                    x, y-1
//                    x+1, y
//                    x-1, y

                    // top item
                    if y - 1 >= 0, let topBlock = map[y-1][x] {
                        happinessTotal += topBlock.happinessLevel
                        contributorCount += 1
                    }

                    // left item
                    if x - 1 >= 0, let leftBlock = map[y][x - 1] {
                        happinessTotal += leftBlock.happinessLevel
                        contributorCount += 1
                    }

                    // right item
                    if x + 1 <= 19, let rightBlock = map[y][x + 1] {
                        happinessTotal += rightBlock.happinessLevel
                        contributorCount += 1
                    }

                    // bottom item
                    if y + 1 <= 19, let bottomItem = map[y + 1][x] {
                        happinessTotal += bottomItem.happinessLevel
                        contributorCount += 1
                    }


                    if contributorCount != 0 {
                        let influenceOfNeighbors = (happinessTotal / contributorCount) * 0.5
                        let influenceOfSelf = refCharachter.happinessLevel * 0.5
                        charachtersUpdatedLevels[y][x] = (influenceOfNeighbors + influenceOfSelf)
                    }
                }
            }
        }
        
        for row in charachtersUpdatedLevels {
            print(row)
        }
        
        return charachtersUpdatedLevels
    }
    
    
    func makeArrayMap() -> [[BlockCharachter?]] {
        var charachtersOnGrid: [[BlockCharachter?]] = []
        for x in 0...19 {
            charachtersOnGrid.append([])
            for _ in 0...19 {
                charachtersOnGrid[x].append(nil)
            }
        }
        
        
        for charachter in charachters {
            charachtersOnGrid[Int(round(charachter.node.position.z))][Int(round(charachter.node.position.x))] = charachter
        }
        
        
        return charachtersOnGrid
    }
    
    func createCameraNode(following target: SCNNode) -> SCNNode {
        let camera = SCNCamera()
        
        camera.focalLength = 24
        camera.focusDistance = 8.124
        
        camera.zFar = 1000
        camera.zNear = 0.1
        
        camera.fStop = 0.05
        camera.apertureBladeCount = 5
        //        camera.wantsDepthOfField = true
        
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
        looseFollowConstraint.damping = 0.7
        
        cameraNode.constraints = [replicateConstraint, lookAtConstraint, looseFollowConstraint]
        
        return cameraNode
    }
    
    //idk what this is
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class BlockCharachter {
    var node: SCNNode
    
    let lightNode = SCNNode()
    
    var happinessLevel = 0.0
    
    init(position: SCNVector3, happinessLevel: Double) {
        
        let geometry = SCNBox(width: 0.95, height: 0.95, length: 0.95, chamferRadius: 0.26)
        
        node = SCNNode(geometry: geometry)
//        node.pivot = SCNMatrix4MakeTranslation(0, 0, 0)
        node.position = position
        self.happinessLevel = happinessLevel
        
        //physics
        //        node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: geometry, options: nil))
        //        node.physicsBody?.allowsResting = true
        //                node.physicsBody?.restitution = 0
        
        
        //cube material
        if let firstMaterial = geometry.firstMaterial {
            firstMaterial.lightingModel = .physicallyBased
            
            firstMaterial.diffuse.contents = NSColor(hue: 0, saturation: 0, brightness: 0, alpha: 1)
            
            firstMaterial.metalness.contents = NSColor(white: 0.8, alpha: 1)
            firstMaterial.roughness.contents = NSColor(white: 0.3, alpha: 1)
            //            firstMaterial.roughness.contents = NSImage(imageLiteralResourceName: "normal.png")
        }
        
        //inside light
        let light = SCNLight()
        light.intensity = 10
        light.attenuationEndDistance = 5
        
        light.type = SCNLight.LightType.omni
        
        lightNode.light = light
        lightNode.position = node.position
        lightNode.position.y += 0.1
    }
    
    
    func changeColorTo(_ newColor: NSColor) {
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1
        self.node.geometry?.firstMaterial?.diffuse.contents = newColor
        self.lightNode.light?.color = newColor
        SCNTransaction.commit()
        
    }
}













class UserCharachter: BlockCharachter {
    func move(in direction: Direction) {
        let rotateAction: SCNAction
        let moveAction: SCNAction
        if direction == .back {
            print("BACKWARDS")
            rotateAction = SCNAction.rotateBy(x: 1.5708*2, y: 0, z: 0, duration: 0.2)
            moveAction = SCNAction.moveBy(x: 0, y: 0, z: 1, duration: 0.2)
        } else if direction == .foward {
            print("FOWARD")
            rotateAction = SCNAction.rotateBy(x: -1.5708*2, y: 0, z: 0, duration: 0.2)
            moveAction = SCNAction.moveBy(x: 0, y: 0, z: -1, duration: 0.2)
        } else if direction == .right {
            print("RIGHT")
            rotateAction = SCNAction.rotateBy(x: 0, y: 0, z: 1.5708*2, duration: 0.2)
            moveAction = SCNAction.moveBy(x: 1, y: 0, z: 0, duration: 0.2)
        } else if direction == .left {
            print("LEFT")
            rotateAction = SCNAction.rotateBy(x: 0, y: 0, z: -1.5708*2, duration: 0.2)
            moveAction = SCNAction.moveBy(x: -1, y: 0, z: 0 , duration: 0.2)
        } else {
            return
        }
        
        let moveUpAction = SCNAction.customAction(duration: 0.2) { (node, time) in
            //-16.79375(x-0.2)^2+0.67175
            let position = (-67.175*pow(time-0.1, 2)) + 0.67175
            node.position.y = position
        }
        //moveUpAction, rotateAction
        self.node.runAction((SCNAction.group([moveAction, moveUpAction]))) {
            //change reference point
            
            //move light
            
            //calculate emotions
            
            vc.scene.calculateEmotions()
            
            
        }
    }
}

















class SceneViewController: NSViewController {
    public let scene = Scene()
    
    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 400, height: 800))
        
        self.view.addSubview(scene.sceneView)
        
        scene.sceneView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scene.sceneView.topAnchor.constraint(equalTo: self.view.topAnchor),
            scene.sceneView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            scene.sceneView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            scene.sceneView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
    }
    
    override func keyUp(with event: NSEvent) {
        let leftArrow: UInt16 = 0x7B
        let rightArrow: UInt16 = 0x7C
        let downArrow: UInt16 = 0x7D
        let upArrow: UInt16 = 0x7E
        
        let userCharachter = self.scene.charachters[0] as! UserCharachter
        if event.keyCode == downArrow {
            userCharachter.move(in: .back)
        } else if event.keyCode == upArrow {
            userCharachter.move(in: .foward)
        } else if event.keyCode == rightArrow {
            userCharachter.move(in: .right)
        } else if event.keyCode == leftArrow {
            userCharachter.move(in: .left)
        }
    }
}

//create scene & add to playground liveview
let vc = SceneViewController()
PlaygroundPage.current.liveView = vc

