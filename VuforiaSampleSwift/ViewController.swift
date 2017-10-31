//
//  ViewController.swift
//  VuforiaSample
//
//  Created by Yoshihiro Kato on 2016/07/02.
//  Copyright © 2016年 Yoshihiro Kato. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let vuforiaLicenseKey = "AcRSwx7/////AAAAGTJ0rgGnlEaYpo4A1XHXBUpU0wJKQ6XfrlCX4sO3zG1ryiq9kiCk3H6eWOJNYDC8hlJupUiLOuLuiFcIh83FG8qmNZ+6mMXjxCofp1BkUBbN3w1pHxWEWODcf7Z9LlTQQOWzfKU3eMTUvY1+scPH1L1uZDnf37sHGuHPDQRCgNiDxY/olmxL2b2KPRgQ64LXbr22sAiTQbCEhsfZEPvA4baxW8bwBsC7fgHlfbBJPQjsIVYU9dWyFrbOHnErAT9GZMal5J9mzOmmudgf2z4M8A7/Rw/SE1tyDXtwHC/uXBd3D9lOWva/2VjPGtGIdc/xWL/dKZVq3L+b3xv/KtG2ecDSw9moDqShTEsz+Fe06DUB"
    
    let engineDataSetFile = "Engine.xml"
    let batteryDataSetFile = "Battery.xml"
    
    let boxMaterial = SCNMaterial()
    
    fileprivate var vuforiaDataSetFile = ""
    fileprivate var vuforiaManager: VuforiaManager? = nil
    fileprivate var titleLabel = UILabel(frame: CGRect(x: 0, y: 607, width: 375, height: 60))
    fileprivate var selectedTrackable = VuforiaTrackable()
    fileprivate var lastSceneName: String? = nil
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showTargetOptions()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        do {
            try vuforiaManager?.stop()
        }catch let error {
            print("\(error)")
        }
    }
    
    func showDetails() {
        let detailView = DetailView.instanceFromNib(frame: CGRect(x: 30, y: 100, width: 315, height: 350))
        view.addSubview(detailView)
    }
    
    func showTargetOptions() {
        
        let actionSheet = UIAlertController(title: "Select target type", message: nil, preferredStyle: .actionSheet)
        
        let firstAction = UIAlertAction(title: "Battery", style: .default) { action -> Void in
            self.vuforiaDataSetFile = self.batteryDataSetFile
            self.lastSceneName = nil
            do {
                try self.vuforiaManager?.stop()
            }catch {}
            self.prepare()
        }
        
        let secondAction = UIAlertAction(title: "Engine", style: .default) { action -> Void in

            self.vuforiaDataSetFile = self.engineDataSetFile
            self.lastSceneName = nil
            do {
                try self.vuforiaManager?.stop()
            }catch {
            }
            self.prepare()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }
        
        actionSheet.addAction(firstAction)
        actionSheet.addAction(secondAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
}

private extension ViewController {
    func prepare() {
        
        vuforiaManager = VuforiaManager(licenseKey: vuforiaLicenseKey, dataSetFile: vuforiaDataSetFile)
        
        if let manager = vuforiaManager {
            manager.delegate = self
            manager.eaglView.sceneSource = self
            manager.eaglView.delegate = self
            manager.eaglView.setupRenderer()
            self.view = manager.eaglView
            
            titleLabel.backgroundColor = UIColor.lightGray
            titleLabel.text = "Point camera to your target"
            titleLabel.textAlignment = .center
            titleLabel.textColor = UIColor.black
            self.view.addSubview(titleLabel)
            
            let btn = UIButton(frame: CGRect(x: 10, y: 607, width: 40, height: 40))
            btn.backgroundColor = UIColor.clear
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
            btn.center = CGPoint(x: btn.center.x, y: titleLabel.center.y)
            btn.setImage(UIImage(named: "toolKit"), for: .normal)
            btn.setTitleColor(UIColor.white, for: .normal)
            btn.addTarget(self, action: #selector(showTargetOptions), for: .touchUpInside)
            self.view.addSubview(btn)
            
        }
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(didRecieveWillResignActiveNotification),
                                       name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(didRecieveDidBecomeActiveNotification),
                                       name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
        vuforiaManager?.prepare(with: .portrait)
    }
    
    func pause() {
        do {
            try vuforiaManager?.pause()
        }catch let error {
            print("\(error)")
        }
    }
    
    func resume() {
        do {
            try vuforiaManager?.resume()
        }catch let error {
            print("\(error)")
        }
    }
    
}

extension ViewController {
    func didRecieveWillResignActiveNotification(_ notification: Notification) {
        pause()
    }
    
    func didRecieveDidBecomeActiveNotification(_ notification: Notification) {
        resume()
    }
}

extension ViewController: VuforiaManagerDelegate {
    func vuforiaManagerDidFinishPreparing(_ manager: VuforiaManager!) {
        
        do {
            try vuforiaManager?.start()
            vuforiaManager?.setContinuousAutofocusEnabled(true)
        }catch let error {
            print("\(error)")
        }
    }
    
    func vuforiaManager(_ manager: VuforiaManager!, didFailToPreparingWithError error: Error!) {
        print("did fail to preparing \(error)\n")
    }
    
    func vuforiaManager(_ manager: VuforiaManager!, didUpdateWith state: VuforiaState!) {
        
        for index in 0 ..< state.numberOfTrackableResults {
            
            if let result = state.trackableResult(at: index) {
                selectedTrackable = (result.trackable)
            }
            
            if lastSceneName != "stones" {
                manager.eaglView.setNeedsChangeSceneWithUserInfo(["scene" : "stones"])
                lastSceneName = "stones"
                DispatchQueue.main.async {
                    self.titleLabel.text = "Tap on green icon for details"
                }
            }
            
        }
        
    }
    
    func showAlert(title: String) {
        
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
}

extension ViewController: VuforiaEAGLViewSceneSource, VuforiaEAGLViewDelegate {
    
    func scene(for view: VuforiaEAGLView!, userInfo: [String : Any]?) -> SCNScene! {
        guard let _ = userInfo else {
            return SCNScene()
        }
        
        return createBoxScene(with: view)
    }
    
    fileprivate func createBoxScene(with view: VuforiaEAGLView) -> SCNScene {
        
        let scene = SCNScene()
        
        boxMaterial.diffuse.contents = UIColor.red
        
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.light?.color = UIColor.lightGray
        lightNode.position = SCNVector3(x:0, y:10, z:10)
        scene.rootNode.addChildNode(lightNode)
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        let planeNode = SCNNode()
        planeNode.name = "plane"
        planeNode.geometry = SCNPlane(width: 75.0*view.objectScale, height: 75.0*view.objectScale)
        planeNode.position = SCNVector3Make(0, 0, -1)
        let planeMaterial = SCNMaterial()
        planeMaterial.diffuse.contents = UIColor.green //UIImage(named: "battery")
        planeMaterial.transparency = 0.9
        planeNode.geometry?.firstMaterial = planeMaterial
        scene.rootNode.addChildNode(planeNode)
        
        return scene
    }
    
    func vuforiaEAGLView(_ view: VuforiaEAGLView!, didTouchDownNode node: SCNNode!) {
        print("touch down \(node.name ?? "")\n")
        boxMaterial.transparency = 0.6
        //        showAlert(title: "You selected \(selectedTrackable.name)")
        showDetails()
    }
    
    func vuforiaEAGLView(_ view: VuforiaEAGLView!, didTouchUp node: SCNNode!) {
        print("touch up \(node.name ?? "")\n")
        boxMaterial.transparency = 1.0
    }
    
    func vuforiaEAGLView(_ view: VuforiaEAGLView!, didTouchCancel node: SCNNode!) {
        print("touch cancel \(node.name ?? "")\n")
        boxMaterial.transparency = 1.0
    }
}
