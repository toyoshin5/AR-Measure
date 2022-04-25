//
//  ViewController.swift
//  二点間の距離
//
//  Created by Shingo on 2018/04/08.
//  Copyright © 2018年 Toyoshin. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

extension  UIColor{//Class拡張
    class var sora:UIColor{
        get{
            return UIColor(red: 0, green: 180/256, blue:1, alpha: 1)
        }
    }
}

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
   
    var Another = SCNVector3()
    var turn = 0
    var SaveLine:SCNNode? = SCNNode()
    var SaveText:SCNNode? = SCNNode()
    
    let removeButton = UIButton()
    let ScanButton = UIButton()
    let centermarker = UIImageView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
         // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
//        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/ship.scn")!
//
//         // Set the scene to the view
//        sceneView.scene = scene
        
       
        
//        distLabel.frame = CGRect(x: sceneView.center.x, y: sceneView.center.y-150, width: 300, height: 40)
//        distLabel.font = UIFont.systemFont(ofSize: 40)
//        distLabel.text = "0.00cm"
        
        centermarker.image = #imageLiteral(resourceName: "centermarker")
        centermarker.frame = CGRect(x: 0, y: 0, width: view.frame.size.height/6, height: view.frame.size.height/6)
        centermarker.center = sceneView.center
        
        ScanButton.setImage(#imageLiteral(resourceName: "OFF"), for: .normal)
        ScanButton.frame = CGRect(x: 10, y: view.frame.size.height-210, width: view.frame.size.height/5, height: view.frame.size.height/5)
        
        
        removeButton.setImage(#imageLiteral(resourceName: "remove"), for: .normal)
        removeButton.frame = CGRect(x: view.frame.size.width-210, y: view.frame.size.height-210, width: view.frame.size.height/5, height: view.frame.size.height/5)
        
        sceneView.addSubview(centermarker)
//        sceneView.addSubview(distLabel)
        sceneView.addSubview(ScanButton)
        sceneView.addSubview(removeButton)
        
       
        removeButton.addTarget(self, action: #selector(ViewController.tapRemove), for: .touchUpInside)
        Timer.scheduledTimer(timeInterval: 1/60, target: self, selector: #selector(self.scaning), userInfo: nil, repeats: true)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    @objc func tapScanButton(){
        //回転
   
    

       
        
        var A = SCNVector3()
        switch turn {
        case 0:
            Another = getCenter()
             if Another.x == 0.0{
                print("取得失敗")
                return
            }
            A = Another
            turn = 1-turn   //startScan
           ScanButton.setImage(#imageLiteral(resourceName: "ON"), for: .normal)
        case 1:
            A = getCenter()
            turn = 1-turn   //endScan
            ScanButton.setImage(#imageLiteral(resourceName: "OFF"), for: .normal)
        default:
            return
        }
        
    
        drawpoint(location: A)
        SaveLine = nil
        SaveText = nil
    }
   
    @objc func tapRemove(){
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) -> Void in
            node.removeFromParentNode()//Node全消去
        }
        return
    }

    func drawpoint(location:SCNVector3) {
        let point = SCNNode(geometry: SCNSphere(radius: 0.003))
        point.position = location
        let mat = SCNMaterial()
        mat.diffuse.contents = UIColor.red
        point.geometry?.materials = [mat]
        sceneView.scene.rootNode.addChildNode(point)
        return
    }
    
    
    
    
    func drawline(){
        if SaveLine != nil {
            SaveLine?.removeFromParentNode()
        }
        let A = Another
        let C = getCenter()
        let Chuten = SCNVector3Make((A.x+C.x)/2, (A.y+C.y)/2, (A.z+C.z)/2)
        let dist = sqrt((A.x-C.x)*(A.x-C.x)+(A.y-C.y)*(A.y-C.y)+(A.z-C.z)*(A.z-C.z))
       let line = SCNNode(geometry: SCNCylinder(radius: 0.0010, height: CGFloat(dist)))
        let material = SCNMaterial()
        material.diffuse.contents = #imageLiteral(resourceName: "black-")
        line.geometry?.materials = [material]
        line.position = Chuten
        line.rotation = SCNVector4(A.x-Chuten.x+0,A.y-Chuten.y+dist/2,A.z-Chuten.z+0,Float.pi)

        
       
        SaveLine = line
        sceneView.scene.rootNode.addChildNode(line)
        
        return
    }
    
    
    func drawdist(){
        if SaveText != nil{
            SaveText?.removeFromParentNode()
        }
        //テキスト生成
        
        let distLabel = SCNText()
        let A = Another
        let C = getCenter()
        let Chuten = SCNVector3Make((A.x+C.x)/2, (A.y+C.y)/2, (A.z+C.z)/2)
        let distance = sqrt((A.x-C.x)*(A.x-C.x)+(A.y-C.y)*(A.y-C.y)+(A.z-C.z)*(A.z-C.z))
   print(distance)
        if distance > 1.0 {
            distLabel.string = String(format: "%0.4fm", distance)
        }else{
            distLabel.string = String(format:"%0.2fcm",distance*100)
        }
        let P:CGFloat = CGFloat(sqrt(pow(distance,1.2)))//拡大率指定P
        distLabel.extrusionDepth = 600*P//厚み
        distLabel.font = UIFont(name: "HiraginoSans-W6", size: CGFloat(3000*P))//フォントサイズ
        //テキスト->Node
        let LabelNode = SCNNode(geometry: distLabel)


        LabelNode.position = SCNVector3(Chuten.x,Chuten.y,Chuten.z)
        LabelNode.geometry?.materials.first?.diffuse.contents = #imageLiteral(resourceName: "redJPN")
        //LabelNode.rotation = SCNVector4(0,0,1,atan((A.y-C.y)/(A.x-C.x)))
        let camera = sceneView.pointOfView
        LabelNode.eulerAngles = (camera?.eulerAngles)!//カメラの向きに
        LabelNode.scale = SCNVector3(0.000015, 0.000015, 0.000015)//縮小
        SaveText = LabelNode
        sceneView.scene.rootNode.addChildNode(LabelNode)
    }
    
    
    @objc func getCenter() -> SCNVector3{
        // スマフォ画面の中央座標
        let Location = sceneView.center        // hitTestによる判定(リアルの座標が取得できそうか)
        let hitResults = sceneView.hitTest(Location, types: [.featurePoint])
        // 結果取得に成功
        if !hitResults.isEmpty {
            if let hitTResult = hitResults.first {
                // 実世界の座標をSCNVector3で返す
                let realPoint = SCNVector3(hitTResult.worldTransform.columns.3.x, hitTResult.worldTransform.columns.3.y, hitTResult.worldTransform.columns.3.z)
            
                return realPoint
            }
        }
        return SCNVector3(0,0,0)
    }

    @objc func scaning(){
        if turn == 0 {
            if getCenter().x != 0.0{
                 ScanButton.addTarget(self, action: #selector(ViewController.tapScanButton), for: .touchUpInside)
            }else{
                
            }
            return 
        }
        
        drawline()
        drawdist()
        return
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
