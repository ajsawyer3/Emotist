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
    
    let userCharachter = UserCharachter(position: SCNVector3(x: 8, y: 0, z: 8))
    
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
        var previousLocations: [CGPoint] = [CGPoint(x: 8, y: 8)]
        userCharachter.happinessLevel = 0.5
        self.rootNode.addChildNode(userCharachter.node)
        self.rootNode.addChildNode(userCharachter.lightNode)
        charachters.append(userCharachter)
        
        
        let charachterCount = 75
        for x in 0...charachterCount {
            let fieldSize = 16
            
            var uniquePoint = CGPoint(x: -1, y: -1)
            while previousLocations.contains(uniquePoint) || uniquePoint.x == -1 || (uniquePoint.x == 8 && uniquePoint.y == 8){
                let randomX = Int.random(in: 1...fieldSize)
                let randomZ = Int.random(in: 1...fieldSize)
                uniquePoint = CGPoint(x: randomX, y: randomZ)
            }
            
            previousLocations.append(uniquePoint)
            
            //make new charachter
            let newCharachter = BlockCharachter(position: SCNVector3(uniquePoint.x, 0, uniquePoint.y))
            charachters.append(newCharachter)
            newCharachter.happinessLevel = Double.random(in: 0...1)
            self.rootNode.addChildNode(newCharachter.node)
            self.rootNode.addChildNode(newCharachter.lightNode)
            
            
            let random1 = CGFloat.random(in: 0...255)
            let random2 = CGFloat.random(in: 0...255)
            let random3 = CGFloat.random(in: 0...255)
            self.charachters[x].changeColorTo(NSColor(red: random1/255, green: random2/255, blue: random3/255, alpha: 1))
        }
        
        
        
        //make new charachter
        //            let test1newCharachter = BlockCharachter(position: SCNVector3(0, 0, 0))
        //            charachters.append(test1newCharachter)
        //            test1newCharachter.happinessLevel = 1
        //            self.rootNode.addChildNode(test1newCharachter.node)
        //            self.rootNode.addChildNode(test1newCharachter.lightNode)
        //
        //            let test1pnewCharachter = BlockCharachter(position: SCNVector3(1, 0, 0))
        //            charachters.append(test1pnewCharachter)
        //            test1pnewCharachter.happinessLevel = 1
        //            self.rootNode.addChildNode(test1pnewCharachter.node)
        //            self.rootNode.addChildNode(test1pnewCharachter.lightNode)
        //
        //            let test2newCharachter = BlockCharachter(position: SCNVector3(15, 0, 15))
        //            charachters.append(test2newCharachter)
        //            test2newCharachter.happinessLevel = 1
        //            self.rootNode.addChildNode(test2newCharachter.node)
        //            self.rootNode.addChildNode(test2newCharachter.lightNode)
        
        
        
        
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
        calculateEmotions()
    }
    
    func calculateEmotions() {
//        DispatchQueue.global(qos: .background).async {
            let originalMap = self.makeArrayMap()
            let newMap = self.calculateNewHappiness(map: originalMap)
            self.assignNewMap(newMap: newMap)
        
//            self.assignNewMap(newMap: self.calculateNewHappiness(map: self.makeArrayMap()))
//        }
    }
    
    func assignNewMap(newMap: [[Double?]]) {
        let flatMap = newMap.flatMap { $0 }.compactMap { $0 }
        print(flatMap)
        for i in 0...(charachters.count-1) {
            let newValue = flatMap[i]
            charachters[i].happinessLevel = newValue
        }
    }
    
    func calculateNewHappiness(map: [[Double?]]) ->  [[Double?]]{
        var newMap: [[Double?]] = []
        
        for x in 0...15 {
            newMap.append([])
            for y in 0...15 {
                newMap[x].append(map[x][y])
                
                if let refCharachter = map[x][y] {
                    var happinessTotal = 0.0
                    var contributorCount = 0.0

                    for y2 in -1...1 {
                        let rowSelection = y+y2
                        if map.indices.contains(rowSelection) {
                            let row = map[rowSelection]
                            for x2 in -1...1 {
                                if row.indices.contains(x + x2) {
                                    guard let happinessValue = row[x+x2] else { break }
                                    happinessTotal += happinessValue
                                    contributorCount += 1
                                }
                            }
                        }

                        if contributorCount != 0 {
                            newMap[x][y] = (((happinessTotal / contributorCount) + refCharachter)/2)
                        }
                    }
                }
            }
        }
        return newMap
    }
    
    
    func makeArrayMap() -> [[Double?]] {
        var charachtersOnGrid: [[Double?]] = []
        for x in 0...15 {
            charachtersOnGrid.append([])
            for _ in 0...15 {
                charachtersOnGrid[x].append(nil)
            }
        }
        
        
        for charachter in charachters {
            charachtersOnGrid[Int(charachter.node.position.z-1)][Int(charachter.node.position.x-1)] = charachter.happinessLevel
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
    
    var happinessLevel = 0.5 {
        didSet {
            let hue: CGFloat = CGFloat(happinessLevel * 0.138)
            let newColor = NSColor(hue: hue, saturation: 1, brightness: 1, alpha: 1)
            changeColorTo(newColor)
        }
    }
    
    init(position: SCNVector3) {
        
        let geometry = SCNBox(width: 0.95, height: 0.95, length: 0.95, chamferRadius: 0.26)
        
        
        node = SCNNode(geometry: geometry)
        node.position = position
        
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
        SCNTransaction.animationDuration = 0.1
        node.geometry?.firstMaterial?.diffuse.contents = newColor
        lightNode.light?.color = newColor
        SCNTransaction.commit()
    }
}













class UserCharachter: BlockCharachter {
    func move(in direction: Direction) {
        let rotateAction: SCNAction
        let moveAction: SCNAction
        if direction == .back {
            print("BACKWARDS")
            rotateAction = SCNAction.rotateBy(x: 0, y: 0, z: -1.5708*2, duration: 0.4)
            moveAction = SCNAction.moveBy(x: 0, y: 0, z: 1, duration: 0.4)
        } else if direction == .foward {
            print("FOWARD")
            rotateAction = SCNAction.rotateBy(x: 0, y: 0, z: 1.5708*2, duration: 0.4)
            moveAction = SCNAction.moveBy(x: 0, y: 0, z: -1, duration: 0.4)
        } else if direction == .right {
            print("RIGHT")
            rotateAction = SCNAction.rotateBy(x: 1.5708*2, y: 0, z: 0, duration: 0.4)
            moveAction = SCNAction.moveBy(x: 1, y: 0, z: 0, duration: 0.4)
        } else if direction == .left {
            print("LEFT")
            rotateAction = SCNAction.rotateBy(x: -1.5708*2, y: 0, z: 0, duration: 0.4)
            moveAction = SCNAction.moveBy(x: -1, y: 0, z: 0 , duration: 0.4)
        } else {
            return
        }
        
        let moveUpAction = SCNAction.customAction(duration: 0.4) { (node, time) in
            //-16.79375(x-0.2)^2+0.67175
            let position = (-16.79375*pow(time-0.2, 2)) + 0.67175
            node.position.y = position
        }
        //moveUpAction, rotateAction
        super.node.runAction((SCNAction.group([moveAction]))) {
            //change reference point
            
            //            super.node.rotation = SCNVector4(0, 0, 0, 1.5708*2)
            //            super.node.position.y = 0
            
            //move light
            
            //calculate emotions
            DispatchQueue.global(qos: .background).async {
                vc.scene.calculateEmotions()
            }
            
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

