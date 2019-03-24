import Cocoa

import SceneKit
import PlaygroundSupport

enum Direction {
    case foward
    case back
    case right
    case left
}

//create scene & add to playground liveview
let vc = SceneViewController()
PlaygroundPage.current.liveView = vc

class SceneViewController: NSViewController {
    public let scene = Scene()
    
    let leftArrow: UInt16 = 0x7B
    let rightArrow: UInt16 = 0x7C
    let downArrow: UInt16 = 0x7D
    let upArrow: UInt16 = 0x7E
    
    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 650, height: 650))
        
        self.view.addSubview(scene.sceneView)
        
        scene.sceneView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scene.sceneView.topAnchor.constraint(equalTo: self.view.topAnchor),
            scene.sceneView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            scene.sceneView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            scene.sceneView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
    }
    
    override func keyDown(with event: NSEvent) {
        handleKeyPresses(event)
    }
    
    func handleKeyPresses(_ event: NSEvent) {
        if event.keyCode == downArrow {
            scene.userCharachter.move(in: .back)
        } else if event.keyCode == upArrow {
            scene.userCharachter.move(in: .foward)
        } else if event.keyCode == rightArrow {
            scene.userCharachter.move(in: .right)
        } else if event.keyCode == leftArrow {
            scene.userCharachter.move(in: .left)
        } else {
            return
        }
    }
}

class Scene: SCNScene, SCNSceneRendererDelegate {
    var sceneView: SCNView = SCNView(frame: CGRect(x: 0, y: 0, width: 650, height: 650))
    
    static public let fieldSize = 18
    
    public var charachters: [BlockCharachter] = []
    public var charachterMap: [[BlockCharachter?]] = []
    
    let userCharachter = UserCharachter(position: SCNVector3(x: 8, y: 0, z: 8), happinessLevel: 0)
    
    override init() {
        super.init()
        
        sceneView.delegate = self
        sceneView.scene = self
        sceneView.allowsCameraControl = false
        sceneView.showsStatistics = true
        
        //CAMERA & LIGHTING
        let cameraNode = createCameraNode(following: userCharachter.node)
        cameraNode.position = userCharachter.node.position
        rootNode.addChildNode(cameraNode)
        
        let ambientLightNodeYellow = SCNNode()
        ambientLightNodeYellow.position = SCNVector3(x: 10, y: 10, z: -5)
        let ambientLightYellow = SCNLight()
        ambientLightYellow.color = NSColor(hue: 0.135, saturation: 0.5, brightness: 1, alpha: 1)
        ambientLightYellow.intensity = 500
        ambientLightNodeYellow.light = ambientLightYellow
        ambientLightYellow.type = .omni
        
        let ambientLightNodeRed = SCNNode()
        ambientLightNodeRed.position = SCNVector3(x: 25, y: 10, z: 10)
        let ambientLightRed = SCNLight()
        ambientLightRed.color = NSColor(hue: 0, saturation: 0.5, brightness: 1, alpha: 1)
        ambientLightRed.intensity = 500
        ambientLightNodeRed.light = ambientLightRed
        ambientLightRed.type = .omni
        
        rootNode.addChildNode(ambientLightNodeYellow)
        rootNode.addChildNode(ambientLightNodeRed)
        
        self.background.contents = NSColor.black
        
        //GEOMETRY
        //Floor
        let floorGeometry = SCNFloor()
        let floorNode = SCNNode(geometry: floorGeometry)
        floorNode.position = SCNVector3(0, -0.51, 0)
        
        let floorMaterial = floorGeometry.firstMaterial
        floorMaterial?.lightingModel = .physicallyBased
        
        floorGeometry.reflectivity = 0
        floorMaterial?.diffuse.contents = NSColor(white: 0.02, alpha: 1)
        floorMaterial?.metalness.contents = NSColor(white: 0.8, alpha: 1)
        floorMaterial?.roughness.contents = NSImage(imageLiteralResourceName: "grid.png")
        floorMaterial?.roughness.wrapT = .mirror
        floorMaterial?.roughness.wrapS = .mirror
        floorMaterial?.roughness.contentsTransform = SCNMatrix4MakeScale(100, 100, 1)
        
        self.rootNode.addChildNode(floorNode)
        
        
        //User Charachter
        var previousLocations: [CGPoint] = [CGPoint(x: 9, y: 9)]
        self.rootNode.addChildNode(userCharachter.node)
        self.rootNode.addChildNode(userCharachter.lightNode)
        charachters.append(userCharachter)
        
        
        //Other Charachters
        for x in 0...35 {
            var uniquePoint = CGPoint(x: -1, y: -1)
            while previousLocations.contains(uniquePoint) || uniquePoint.x == -1 || (uniquePoint.x == 8 && uniquePoint.y == 8){
                let randomX = Int.random(in: 0..<Scene.fieldSize)
                let randomZ = Int.random(in: 0..<Scene.fieldSize)
                uniquePoint = CGPoint(x: randomX, y: randomZ)
            }
            
            previousLocations.append(uniquePoint)
            
            //make new charachter
            let newCharachter = BlockCharachter(position: SCNVector3(uniquePoint.x, 0, uniquePoint.y), happinessLevel: Double.random(in: 0...1))
            charachters.append(newCharachter)
            self.rootNode.addChildNode(newCharachter.node)
            self.rootNode.addChildNode(newCharachter.lightNode)
        }
        
        //INITIALLY RUN
        charachterMap = makeInitialMap()
        assignNewMap()
    }
    
    @objc func calculateEmotions() {
        DispatchQueue.global(qos: .background).async {
            self.calculateNewHappiness()
        }
    }
    
    func makeInitialMap() -> [[BlockCharachter?]] {
        //make nil filled array
        var map: [[BlockCharachter?]] = []
        for x in 0..<Scene.fieldSize {
            map.append([])
            for _ in 0..<Scene.fieldSize {
                map[x].append(nil)
            }
        }
        
        //fill array with charachters
        for charachter in charachters {
            map[Int(round(charachter.node.position.z))][Int(round(charachter.node.position.x))] = charachter
        }
        
        return map
    }
    
    func calculateNewHappiness() {
        var updatedCharachterMap = charachterMap
        
        for y in 0..<Scene.fieldSize {
            for x in 0..<Scene.fieldSize {
                //if reference charachter is not nil
                if let refCharachter = charachterMap[y][x] {
                    var happinessTotal = 0.0
                    var contributorCount = 0.0
                    
                    // top item
                    if y - 1 >= 0, let topBlock = charachterMap[y-1][x] {
                        happinessTotal += topBlock.happinessLevel
                        contributorCount += 1
                    }
                    
                    // left item
                    if x - 1 >= 0, let leftBlock = charachterMap[y][x - 1] {
                        happinessTotal += leftBlock.happinessLevel
                        contributorCount += 1
                    }
                    
                    // right item
                    if x + 1 < Scene.fieldSize, let rightBlock = charachterMap[y][x + 1] {
                        happinessTotal += rightBlock.happinessLevel
                        contributorCount += 1
                    }
                    
                    // bottom item
                    if y + 1 < Scene.fieldSize, let bottomItem = charachterMap[y + 1][x] {
                        happinessTotal += bottomItem.happinessLevel
                        contributorCount += 1
                    }
                    
                    
                    if contributorCount != 0 {
                        var referenceCharachterInfluence = 0.5, secondaryCharachterInfluence = 0.5
                        
                        if refCharachter is UserCharachter {
                            referenceCharachterInfluence = 0.8
                            secondaryCharachterInfluence = 0.2
                        }
                        
                        let referenceCharachterPortion = refCharachter.happinessLevel * referenceCharachterInfluence
                        let secondaryCharachtersPortion = (happinessTotal / contributorCount) * secondaryCharachterInfluence
                        
                        updatedCharachterMap[y][x]?.happinessLevel = (referenceCharachterPortion + secondaryCharachtersPortion)
                    }
                }
            }
        }
        
        charachterMap = updatedCharachterMap
        assignNewMap()
    }
    
    func assignNewMap() {
        for y in 0..<Scene.fieldSize {
            for x in 0..<Scene.fieldSize {
                if let charachter = charachterMap[y][x] {
                    let hue: CGFloat = CGFloat(charachter.happinessLevel) * 0.3
                    let newColor = NSColor(hue: hue, saturation: 1, brightness: 1, alpha: 1)
                    
                    DispatchQueue.main.async {
                        charachter.changeColorTo(newColor)
                    }
                }
            }
        }
    }
    
    func createCameraNode(following target: SCNNode) -> SCNNode {
        let camera = SCNCamera()
        
        camera.focalLength = 30
        camera.focusDistance = 8.124
        
        camera.zFar = 1000
        camera.zNear = 0.1
        
        camera.fStop = 0.01
        camera.apertureBladeCount = 5
        camera.wantsDepthOfField = true
        
        camera.bloomBlurRadius = 4
        camera.bloomIntensity = 0.3
        camera.bloomThreshold = 0.3
        
        camera.vignettingIntensity = 0.4
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class BlockCharachter {
    var node: SCNNode
    
    let lightNode = SCNNode()
    
    var happinessLevel = 0.0
    
    init(position: SCNVector3, happinessLevel: Double) {
        
        let geometry = SCNBox(width: 0.95, height: 0.95, length: 0.95, chamferRadius: 0.25)
        
        node = SCNNode(geometry: geometry)
        node.position = position
        self.happinessLevel = happinessLevel
        
        //cube material
        if let firstMaterial = geometry.firstMaterial {
            firstMaterial.lightingModel = .physicallyBased
            
            firstMaterial.diffuse.contents = NSColor(hue: 0, saturation: 0, brightness: 0, alpha: 1)
            
            firstMaterial.metalness.contents = NSColor(white: 0.8, alpha: 1)
            firstMaterial.roughness.contents = NSImage(imageLiteralResourceName: "normal.png")
            
            firstMaterial.transparency = 0.99
            firstMaterial.fresnelExponent = 3.2
            firstMaterial.transparencyMode = .dualLayer
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
        self.node.geometry?.firstMaterial?.diffuse.contents = newColor
        self.lightNode.light?.color = newColor
    }
}


class UserCharachter: BlockCharachter {
    override init(position: SCNVector3, happinessLevel: Double) {
        super.init(position: position, happinessLevel: happinessLevel)
    }
    
    func move(in direction: Direction) {
        let moveAction: SCNAction
        
        let currentZ = Int(round(node.position.z))
        let currentX = Int(round(node.position.x))
        
        if direction == .back && (currentZ + 1 < Scene.fieldSize && vc.scene.charachterMap[currentZ + 1][currentX] == nil) {
            vc.scene.charachterMap[currentZ + 1][currentX] = self
            moveAction = SCNAction.moveBy(x: 0, y: 0, z: 1, duration: 0.3)
            
        } else if direction == .foward && (currentZ - 1 >= 0 && vc.scene.charachterMap[currentZ - 1][currentX] == nil) {
            vc.scene.charachterMap[currentZ - 1][currentX] = self
            moveAction = SCNAction.moveBy(x: 0, y: 0, z: -1, duration: 0.3)
            
        } else if direction == .right && (currentX + 1 < Scene.fieldSize && vc.scene.charachterMap[currentZ][currentX + 1] == nil) {
            vc.scene.charachterMap[currentZ][currentX + 1] = self
            moveAction = SCNAction.moveBy(x: 1, y: 0, z: 0, duration: 0.3)
            
        } else if direction == .left && (currentX - 1 >= 0 && vc.scene.charachterMap[currentZ][currentX - 1] == nil){
            vc.scene.charachterMap[currentZ][currentX - 1] = self
            moveAction = SCNAction.moveBy(x: -1, y: 0, z: 0 , duration: 0.3)
        } else {
            return
        }
        
        vc.scene.charachterMap[currentZ][currentX] = nil
        
        let moveUpAction = SCNAction.customAction(duration: 0.2) { (node, time) in
            //(-16.79375(x-0.2)^2+0.67175)/3
            let height = ((-67.175*pow(time-0.1, 2)) + 0.67175)/3
            node.position.y = height
        }
        
        self.node.runAction((SCNAction.group([moveAction, moveUpAction]))) {
            vc.scene.calculateEmotions()
        }
    }
}
