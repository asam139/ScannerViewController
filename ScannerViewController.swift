//
//  ScannerViewController.swift
//  iWShopping
//
//  Created by Saul Moreno Abril on 16/4/15.
//  Copyright (c) 2015 Saul Moreno Abril. All rights reserved.
//

import UIKit
import AVFoundation


protocol ScannerViewControllerDelegate {
    
    func codeDetected(code: String)
    
}

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UIAlertViewDelegate {

    var delegate: ScannerViewControllerDelegate?
    
    var device: AVCaptureDevice?
    var input: AVCaptureDeviceInput?
    var output: AVCaptureMetadataOutput?
    var session: AVCaptureSession?
    var preview: AVCaptureVideoPreviewLayer?
    
    var codeDetected: Bool = false
    var code:String?
    var canBeDisplayed = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupCamera()
    
        
        let button   = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        button.frame = CGRectMake(100, 100, 120, 50)
        button.backgroundColor = UIColor(red: 1.0, green: (127/255.0), blue: 0.0, alpha: 1.0)
        button.setTitle("Cancel", forState: UIControlState.Normal)
        button.titleLabel?.font = UIFont(name: "Chalkduster", size: 14)
        button.addTarget(self, action: "cancel:", forControlEvents: UIControlEvents.TouchUpInside)
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        self.view.addSubview(button)
        
        //Don't forget this line
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        
//        var constX = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
//        view.addConstraint(constX)
//        
//        var constY = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
//        view.addConstraint(constY)
        
        var constTrailingMargin = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: -50)
        //button.addConstraint(constTrailingMargin)
        view.addConstraint(constTrailingMargin)
        
         var constBottonMargin = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -50)
        //button.addConstraint(constBottonMargin)
        view.addConstraint(constBottonMargin)
        
        var constW = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 100)
        button.addConstraint(constW)
        //view.addConstraint(constW) also works
        
        var constH = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 50)
        button.addConstraint(constH)
        //view.addConstraint(constH) also works
    }
    
    func cancel(sender:UIButton!)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if !self.canBeDisplayed{
            self.showAlertError()
        
        }
        

    }
    
    override func viewDidDisappear(animated: Bool) {
        if let s = self.session{
            s.stopRunning()
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupCamera(){
        
        self.device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        if self.device == nil {
            println("No video camera on this device!")
            //self.dismissViewControllerAnimated(true, completion: nil)
            self.canBeDisplayed = false
            return
        }
        
        if let s = self.session{
            return
            
        }else{
            self.session = AVCaptureSession()
            
            if let s = self.session{
                
                self.input = AVCaptureDeviceInput.deviceInputWithDevice(self.device, error: nil) as? AVCaptureDeviceInput
                if s.canAddInput(self.input) {
                    s.addInput(self.input)
                }
                
                self.output = AVCaptureMetadataOutput()
                self.output?.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
                if s.canAddOutput(self.output) {
                    s.addOutput(self.output)
                }
                self.output?.metadataObjectTypes = self.output?.availableMetadataObjectTypes
                
                
                self.preview = AVCaptureVideoPreviewLayer(session: s)
                self.preview?.videoGravity = AVLayerVideoGravityResizeAspectFill
                self.preview?.frame = self.view.frame
                self.view.layer.insertSublayer(self.preview, atIndex: 0)
                
                s.startRunning()
            }
        }
        
        
        
    }
    
    func showAlertError(){
        
        var alertView = UIAlertView(
            title:"Atention",
            message:"Scanner can't be displayed",
            delegate:self,
            cancelButtonTitle:"OK")
        alertView.tag = 1
        
        alertView.show()
    }
    
    func showAlertCodeDetected(code: String){
        
        var alertView = UIAlertView(
            title:"Code Detected",
            message:"The code is: " + code,
            delegate:self,
            cancelButtonTitle:"Accept",
            otherButtonTitles: "Cancel")
        
        alertView.tag = 0
        
        alertView.show()
    }
    
    
    // MARK:  AVCaptureMetadataOutputObjectsDelegate
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        if !self.codeDetected{
            
            for data in metadataObjects {
                let metaData = data as! AVMetadataObject
                let transformed = self.preview?.transformedMetadataObjectForMetadataObject(metaData) as? AVMetadataMachineReadableCodeObject
                
                if let unwraped = transformed {
                    let code: String = unwraped.stringValue
                    println("CodeBar: " + code)
                    if !(code == ""){
                        self.codeDetected = true
                        self.code = code
                        //self.delegate?.codeDetected(code)
                        
                        //self.dismissViewControllerAnimated(true, completion: nil)
                        self.showAlertCodeDetected(code)
                    }
                }
            }
            
        }
    }
    
    // MARK:  UIAlertViewDelegate
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        
        if(alertView.tag == 0){
            
            if buttonIndex == 0{
                self.delegate?.codeDetected(self.code!)
                self.dismissViewControllerAnimated(true, completion: nil)
            }else if buttonIndex == 1{
                
                self.codeDetected = false
            }
            
            
        }else if(alertView.tag == 1){
        
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    
    

}
