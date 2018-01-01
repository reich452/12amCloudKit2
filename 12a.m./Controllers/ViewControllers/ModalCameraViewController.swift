//
//  ModalCameraViewController.swift
//  12a.m.
//
//  Created by Nick Reichard on 12/28/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import UIKit
import AVFoundation

class ModalCameraViewController: UIViewController {
    
    // MARK: - TODO:  Call the CamearController (Same functions, but doesn't work)
    
    // MARK: - Properties
    
    fileprivate let captureSession = AVCaptureSession()
    fileprivate var camera: AVCaptureDevice!
    fileprivate var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    fileprivate var cameraCaptureOutput: AVCapturePhotoOutput?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeCaptureSession()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        let topBorder = CALayer()
        topBorder.frame = CGRect(x: 0, y: 40, width: 1000, height: 0.5)
        topBorder.backgroundColor = UIColor.rgb(229, green: 231, blue: 235).cgColor
        self.navigationController?.navigationBar.layer.addSublayer(topBorder)
        self.navigationController?.navigationBar.clipsToBounds = true
    }
    
    // MARK: - Actions
    
    @IBAction func cameraToggleButton(_ sender: Any) {
        switchCameraInput()
    }
    
    @IBAction func takePicture(_ sender: Any) {
        
        takePicture()
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Main
    
    private func initializeCaptureSession() {
        
        captureSession.sessionPreset = AVCaptureSession.Preset.high
        camera = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            let cameraCaptureInput = try AVCaptureDeviceInput(device: camera)
            cameraCaptureOutput = AVCapturePhotoOutput()
            
            captureSession.addInput(cameraCaptureInput)
            captureSession.addOutput(cameraCaptureOutput!)
            
        } catch {
            print(error.localizedDescription)
        }
        
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.frame = view.bounds
        cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        
        view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
        
        captureSession.startRunning()
    }
    
    private func takePicture() {
        // Many settings to customize
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        cameraCaptureOutput?.capturePhoto(with: settings, delegate: self)
    }
    
    // MARK: - Toggle
    
    private func switchCameraInput() {
        self.captureSession.beginConfiguration()
        
        var existingConnection: AVCaptureDeviceInput?
        var newInput: AVCaptureDeviceInput?
        var newCamera: AVCaptureDevice?
        
        for connection in self.captureSession.inputs {
            guard let input = connection as? AVCaptureDeviceInput else { return }
            if input.device.hasMediaType(AVMediaType.video) {
                existingConnection = input
            }
        }
        self.captureSession.removeInput(existingConnection!)
        
        if let oldCamera = existingConnection {
            if oldCamera.device.position == .back {
                newCamera = self.cameraWithPosition(position: .front)
            } else {
                newCamera = self.cameraWithPosition(position: .back)
            }
        }
        
        do {                                        // TODO: Safley unwrap newCamera
            newInput = try AVCaptureDeviceInput(device: newCamera!)
            self.captureSession.addInput(newInput!)
        } catch {
            print("Error: Cannot Capure newInput \(error.localizedDescription)")
        }
        
        self.captureSession.commitConfiguration()
    }
}

extension ModalCameraViewController: AVCapturePhotoCaptureDelegate {
    
    // MARK: Display Photo
    
    fileprivate func displayCapturedPhoto(capturedPhoto : UIImage) {
        
        let imagePreviewViewController = storyboard?.instantiateViewController(withIdentifier: "ImagePreviewViewController") as! CameraPreviewViewController
        imagePreviewViewController.capturedImage = capturedPhoto
        navigationController?.pushViewController(imagePreviewViewController, animated: true)
    }
    
    //    func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
    //
    //        if let error = error {
    //            print(error.localizedDescription)
    //        } else {
    //            if let sampleBuffer = photoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer) {
    //
    //
    //                if let finalImage = UIImage(data: dataImage) {
    //
    //                    displayCapturedPhoto(capturedPhoto: finalImage)
    //                }
    //            }
    //        }
    //    }
    
    internal func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Did not finish processing photot \(error.localizedDescription)")
        }
        guard let dataImage = photo.fileDataRepresentation(),
            let finalImage = UIImage(data: dataImage) else { return }
        displayCapturedPhoto(capturedPhoto: finalImage)
    }
}

// MARK: - Handle Positions

extension ModalCameraViewController {
    
    fileprivate func cameraWithPosition(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        // A query for finding and monitoring available capture devices
        let discovery = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified) as AVCaptureDevice.DiscoverySession
        
        for device in discovery.devices as [AVCaptureDevice] {
            if device.position == position {
                return device
            }
        }
        return nil
    }
}
