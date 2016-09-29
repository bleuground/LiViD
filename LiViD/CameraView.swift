//
//  ViewController.swift
//  VideoRecording
//
//  Created by Drashti B Lakhani on 16/06/16.
//  Copyright © 2016 drashtilakhani. All rights reserved.
//

import UIKit
import AVFoundation

class CameraView: UIViewController,AVCaptureFileOutputRecordingDelegate {
    @IBOutlet weak var btnCameraReverse: UIButton!
    
    //MARK: - Variable Declaration
    @IBOutlet weak var vwPreviewLayer: UIView!
    
    @IBOutlet weak var vwStartStopRecording: UIView!
    
    var captureSession : AVCaptureSession?
    var videoOutput : AVCaptureMovieFileOutput?
    var previewLayer : AVCaptureVideoPreviewLayer?
    var lpgr : UILongPressGestureRecognizer?
    var captureDevice : AVCaptureDevice?
    var recordDelegate : AVCaptureFileOutputRecordingDelegate?
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //vwStartStopRecording.layer.cornerRadius = self.vwStartStopRecording.frame.size.width / 2
        //vwStartStopRecording.clipsToBounds = true
        
        lpgr = UILongPressGestureRecognizer(target: self, action: #selector(self.action(_:)))
        
        
        lpgr!.minimumPressDuration = 0.75
        
        vwStartStopRecording.addGestureRecognizer(lpgr!)
        
        beginSession()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.sendSubview(toBack: vwPreviewLayer)
        previewLayer?.frame = vwPreviewLayer.bounds

    }
    
    //MARK: - BEGIN SESSION
    func beginSession() {
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = AVCaptureSessionPresetHigh // 0.139 -> 1.377, 0.378 -> 1.3764
        //captureSession?.sessionPreset = AVCaptureSessionPresetHigh // 1.89 -> 1.0
    //    captureSession?.sessionPreset = AVCaptureSessionPreset1280x720 // 1.4
        
    //    captureSession?.sessionPreset = AVCaptureSessionPreset1920x1080 //1 sec video:  1.8181734085083
        captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        //        let backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        //        captureDevice! = backCamera!
        var input : AVCaptureDeviceInput?
        let _ : NSError?
        do {
            input = try AVCaptureDeviceInput(device: captureDevice)
        } catch let error as NSError? {
            print(error)
            return//Stop rest of code
        }
        let audioCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
        let audioInput : AVCaptureDeviceInput?
        let _ : NSError?
        do{
            audioInput = try AVCaptureDeviceInput(device: audioCaptureDevice)
        }
        catch let error as NSError? {
            print(error)
            return//Stop rest of code
        }
        
        if (captureSession?.canAddInput(audioInput))!{
            captureSession?.addInput(audioInput)
        }
        
        
        if (captureSession?.canAddInput(input))!{
            captureSession?.addInput(input)
            
            videoOutput = AVCaptureMovieFileOutput()
            //videoOutput?.outputSettings = [AVVideoCodecKey : AVVideoCodecKey]
            
            if ((captureSession?.canAddOutput(videoOutput)) != nil){
                captureSession?.addOutput(videoOutput)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
                previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.portrait
                vwPreviewLayer.layer.addSublayer(previewLayer!)
                captureSession?.startRunning()
            }
        }
        
    }
    
    //MARK: - Long Press Gesture Action
    var state : Bool = false
    var timer = Timer()

    @IBOutlet weak var progressBar: UIProgressView!
    func changeState() {
        var count = 0
        while count < 100 {
            progressBar.setProgress(Float(count), animated: true)
            
            count += 1
            
        }
        timer.invalidate()
        state = true
        
    }
    

    func action(_ gestureRecognizer:UILongPressGestureRecognizer) {
        if (lpgr!.state == UIGestureRecognizerState.began) {
            print("Began")
            StartStopOutlet.setImage(UIImage(named: "record_bttn2"), for: UIControlState())
            let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
            let documentsDirectory: AnyObject = paths[0] as AnyObject
            let format = DateFormatter()
            format.dateFormat="yyyy-MM-dd-HH-mm-ss"
            dataPath = documentsDirectory.appendingPathComponent("/video-\(format.string(from: Date())).mp4")
            url = URL(fileURLWithPath: dataPath!)
            
            videoOutput!.startRecording(toOutputFileURL: url, recordingDelegate: self)
            print("\(url)")
            
            UserDefaults.standard.set(url, forKey: "videoURL")
            UserDefaults.standard.synchronize()
            
            
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(CameraView.changeState), userInfo: nil, repeats: true)
        }
        
        if (lpgr!.state == UIGestureRecognizerState.ended) || (state == true){
            StartStopOutlet.setImage(UIImage(named: "record_bttn"), for: UIControlState())
            print("Ended")
            timer.invalidate()

            videoOutput!.stopRecording()
            
            
            self.url = UserDefaults.standard.url(forKey: "videoURL")
            let format = DateFormatter()
            format.dateFormat="yyyy-MM-dd-HH-mm-ss"
            let outputURl = self.url!.deletingLastPathComponent().appendingPathComponent("video\(format.string(from: Date())).mp4")
            print("\(outputURl)")
            Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(CameraView.doCompress), userInfo: nil, repeats: false)
            state == false
            performSegue(withIdentifier: "segueTest", sender: nil)
        }
    }
    
    //MARK: - Compress Video
    func compressVideo(_ inputURL: URL, outputURL: URL, handler:@escaping (_ session: AVAssetExportSession)-> Void)
    {
        let settings: [String: Any] = [(AVVideoCodecKey as NSString) as String : AVVideoCodecH264 as NSString
            , (AVVideoWidthKey as NSString) as String: 1080 as AnyObject ,
              (AVVideoHeightKey as NSString) as String: 1920 as AnyObject,
              (AVVideoCompressionPropertiesKey as NSString) as String : [AVVideoAverageBitRateKey as NSString: 100,
                                                             AVVideoProfileLevelKey as NSString: AVVideoProfileLevelH264Main31, AVVideoMaxKeyFrameIntervalKey as NSString: 30]]
        
        
        let writer_input: AVAssetWriterInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: settings)
//        writer_input.requestMediaDataWhenReady(on: ) {
//            
//        }
        do{
            let fileLocation = URL(fileURLWithPath: inputURL.path)
            let videoData = try Data(contentsOf: fileLocation)
            print(" \n BEFORE COMPRESSION: " + mbSizeWithData(data: videoData) + "\n")
        } catch {}
        
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        
        let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetHighestQuality)
        
        exportSession!.outputURL = outputURL
        
        exportSession!.outputFileType = AVFileTypeQuickTimeMovie
        
        exportSession!.shouldOptimizeForNetworkUse = true
        
        exportSession!.exportAsynchronously { () -> Void in
            
            handler(exportSession!)
        }
        
    }
    
    //MARK: - recording Delegate
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        return
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        return
    }
    
    
    func deleteVideo(_ url : URL!) {
        print("removing file at \(url.absoluteString)")
        let fileManager = FileManager.default
        
        do {
            try fileManager.removeItem(at: url)
        } catch let error as NSError {
            print(error.localizedDescription)
        } catch {
            print("error deleting recording")
        }
    }
    @IBOutlet weak var StartStopOutlet: UIButton!
    
    //MARK: - IBAction Method
    @IBAction func btnCameraReverseClicked(_ sender: AnyObject) {
        
        if captureSession != nil {
            for input in captureSession!.inputs {
                captureSession!.removeInput(input as! AVCaptureInput)
            }
            
            let newCamera: AVCaptureDevice?
            if(captureDevice!.position == AVCaptureDevicePosition.back){
                print("Setting new camera with Front")
                newCamera = self.cameraWithPosition(AVCaptureDevicePosition.front)
                captureSession?.sessionPreset = AVCaptureSessionPreset1280x720
            } else {
                print("Setting new camera with Back")
                newCamera = self.cameraWithPosition(AVCaptureDevicePosition.back)
                captureSession?.sessionPreset = AVCaptureSessionPreset1280x720
            }
            
            let newVideoInput : AVCaptureDeviceInput?
            let _ : NSError?
            do {
                newVideoInput = try AVCaptureDeviceInput(device: newCamera)
            } catch let error as NSError? {
                print(error)
                return//Stop rest of code
            }
            if(newVideoInput != nil) {
                captureSession!.addInput(newVideoInput)
            } else {
                print("Error creating capture device input")
            }
            let audioCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
            let audioInput : AVCaptureDeviceInput?
            let _ : NSError?
            do{
                audioInput = try AVCaptureDeviceInput(device: audioCaptureDevice)
            }
            catch let error as NSError? {
                print(error)
                return//Stop rest of code
            }
            
            if (captureSession?.canAddInput(audioInput))!{
                captureSession?.addInput(audioInput)
            }
            captureDevice! = newCamera!
            
            captureSession!.commitConfiguration()
            
        }
        
    }
    
    func cameraWithPosition(_ position: AVCaptureDevicePosition) -> AVCaptureDevice {
        let devices = AVCaptureDevice.devices()
        for device in devices! {
            if((device as AnyObject).position == position){
                return device as! AVCaptureDevice
            }
        }
        return AVCaptureDevice()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "segueTest") {
            let svc = segue.destination as! PlayBackViewController;
            print("Variables saved")
            svc.VideoData = videoData
            svc.Url = url
            svc.DataPath = dataPath
            print(url)
        }
    }
    
    @IBOutlet weak var FlashOutlet: UIButton!
    @IBAction func btnFlashClicked(_ sender: AnyObject) {
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        if (device?.hasTorch)! {
            do {
                try device?.lockForConfiguration()
                if (device?.torchMode == AVCaptureTorchMode.on) {
                    device?.torchMode = AVCaptureTorchMode.off
                    FlashOutlet.setImage(UIImage(named: "flash_bttn2"), for: UIControlState())
                } else {
                    try device?.setTorchModeOnWithLevel(1.0)
                    FlashOutlet.setImage(UIImage(named: "flash_bttn"), for: UIControlState())
                }
                device?.unlockForConfiguration()
            } catch {
                print(error)
            }
        }
    }
    
    // The output below is limited by 4 KB.
    // Upgrade your plan to remove this limitation.
    
    var videoData : Data?
    var url : URL?
    var dataPath : String?
    func convertVideoToLowQuailty(withInputURL inputURL: URL, outputURL: URL, handler:@escaping (_ session: AVAssetExportSession)-> Void) {
        //setup video writer
        var videoAsset = AVURLAsset(url: inputURL, options: nil)
        var videoTrack = videoAsset.tracks(withMediaType: AVMediaTypeVideo)[0]
        var videoSize = videoTrack.naturalSize
        var videoWriterCompressionSettings: [String: AnyObject] = [
            AVVideoAverageBitRateKey : 1250000 as NSNumber
        ]
        
        var videoWriterSettings : [String: AnyObject] = [
            AVVideoCodecKey: AVVideoCodecH264 as NSString,
            AVVideoCompressionPropertiesKey : videoWriterCompressionSettings as NSDictionary,
            AVVideoWidthKey : videoSize.width as NSNumber,
            AVVideoHeightKey : videoSize.height as NSNumber,
        ]
        
        var videoWriterInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: videoWriterSettings)
        
        videoWriterInput.expectsMediaDataInRealTime = true
        videoWriterInput.transform = videoTrack.preferredTransform
        var videoWriter = try! AVAssetWriter(outputURL: outputURL, fileType: AVFileTypeMPEG4)
        videoWriter.add(videoWriterInput)
        //setup video reader
        var videoReaderSettings = [ (kCVPixelBufferPixelFormatTypeKey as String) : Int(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange) ]
        var videoReaderOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: videoReaderSettings)
        var videoReader = try! AVAssetReader(asset: videoAsset)
        videoReader.add(videoReaderOutput)
        //setup audio writer
        var audioWriterInput = AVAssetWriterInput(mediaType: AVMediaTypeAudio, outputSettings: nil)
        audioWriterInput.expectsMediaDataInRealTime = false
        videoWriter.add(audioWriterInput)
        //setup audio reader
        var audioTrack = videoAsset.tracks(withMediaType: AVMediaTypeAudio)[0]
        var audioReaderOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: nil)
        var audioReader = try! AVAssetReader(asset: videoAsset)
        audioReader.add(audioReaderOutput)
        videoWriter.startWriting()
        //start writing from video reader
        videoReader.startReading()
        videoWriter.startSession(atSourceTime: kCMTimeZero)
        var processingQueue = DispatchQueue(label: "processingQueue1")
        videoWriterInput.requestMediaDataWhenReady(on: processingQueue, using: {() -> Void in
            while videoWriterInput.isReadyForMoreMediaData {
                var sampleBuffer: CMSampleBuffer
                if videoReader.status == .reading /*&& (sampleBuffer == videoReaderOutput.copyNextSampleBuffer()!*/ {
                    sampleBuffer = audioReaderOutput.copyNextSampleBuffer()!
                    videoWriterInput.append(sampleBuffer)
                    
                }
                else {
                    videoWriterInput.markAsFinished()
                    if videoReader.status == .completed {
                        //start writing from audio reader
                        audioReader.startReading()
                        videoWriter.startSession(atSourceTime: kCMTimeZero)
                        var processingQueue = DispatchQueue(label: "processingQueue2")
                        audioWriterInput.requestMediaDataWhenReady(on: processingQueue, using: {() -> Void in
                            while audioWriterInput.isReadyForMoreMediaData {
                                var sampleBuffer : CMSampleBuffer
                                if audioReader.status == .reading/* && (sampleBuffer == (audioReaderOutput.copyNextSampleBuffer()!)) */{
                                    sampleBuffer = audioReaderOutput.copyNextSampleBuffer()!
                                    audioWriterInput.append(sampleBuffer)
                                }
                                else {
                                    audioWriterInput.markAsFinished()
                                    if audioReader.status == .completed {
                                        videoWriter.finishWriting(completionHandler: {() -> Void in
                                            self.sendMovieFile(url: outputURL)
                                        })
                                    }
                                }
                            }
                        })
                    }
                }
                
            }
        })
    }
    
    func sendMovieFile(url: URL) {
        let data = try? Data(contentsOf: self.url!)
        print("File size after compression: \(Double(data!.count / 1048576)) mb")

    }
    func doCompress() {
        self.url = UserDefaults.standard.url(forKey: "videoURL")
        print("\(self.url)")
        let format = DateFormatter()
        format.dateFormat="yyyy-MM-dd-HH-mm-ss"
        let outputURl = self.url!.deletingLastPathComponent().appendingPathComponent("video\(format.string(from: Date())).mp4")
        print("\(outputURl)")
        self.compressVideo(self.url!, outputURL: outputURl, handler: { (session) in
            if session.status == AVAssetExportSessionStatus.completed
            {
                //DEBUG :
                let tempData = try? Data(contentsOf: outputURl)
                print("\n AFTER COMPRESSION: " + mbSizeWithData(data: tempData!) + "\n")
                
                self.url! = outputURl
                print(self.url)
                let data = try? Data(contentsOf: self.url!)
                UserDefaults.standard.set(self.url, forKey: "videoURL")
                UserDefaults.standard.synchronize()
                
                print("File size after compression: \(Double(data!.count / 1048576)) mb")
                self.videoData = try? Data(contentsOf: self.url!)
                //print(self.videoData)
                
                
                
            }
                
            else if session.status == AVAssetExportSessionStatus.failed
            {
                print("failed")
            }
        })
    }
}
