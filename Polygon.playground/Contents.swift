import UIKit
import SceneKit
import PlaygroundSupport

let scene = SCNScene()
let sceneView = SCNView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))

sceneView.scene = scene
sceneView.autoenablesDefaultLighting = true
sceneView.allowsCameraControl = true


//var heights: [Double] = []
//for x in 0...24 {
//    let num = Double.random(in: 0...1)
//    heights.append(num)
//}

var heights: [Double] = [0, 0, 1, 1, 1
                        ,0, 1, 1, 1, 1
                        ,1, 1, 1, 1, 1
                        ,1, 1, 1, 0, 0
                        ,1, 1, 1, 1, 1]




var currentSquare = 0
for z in 0...0 {
    for x in 0...3 {
        
        let tl = heights[currentSquare]
        let tr = heights[currentSquare+1]
        let bl = heights[currentSquare+5]
        let br = heights[currentSquare+6]
        
        print(currentSquare)
        print(tl, tr)
        print(bl, br)
        
        
        let vertices: [SCNVector3] = [SCNVector3(0, bl, 0), SCNVector3(0, tl, 1), SCNVector3(1, br, 0), SCNVector3(1, tr, 1)
                                     ]
        let indices: [UInt16] = [0,1,2
                                ,1,3,2]
        
        let verticesSource = SCNGeometrySource(vertices: vertices)
        let normalSource = SCNGeometrySource(normals: vertices)
        
        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        
        
        let planeGeometry = SCNGeometry(sources: [verticesSource, normalSource], elements: [element])
        
        
        let planeNode = SCNNode(geometry: planeGeometry)
        planeNode.position = SCNVector3(x, 0, z)
        
        planeGeometry.firstMaterial?.diffuse.contents = UIColor.red
        planeGeometry.firstMaterial?.isDoubleSided = true
        sceneView.scene?.rootNode.addChildNode(planeNode)
        
        currentSquare += 1
    }
//    currentSquare += 1
}



PlaygroundPage.current.liveView = sceneView
