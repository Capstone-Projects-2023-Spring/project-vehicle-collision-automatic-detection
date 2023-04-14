//
//  VoiceManager.swift
//  VC
//
//  Created/Modified by Thanh N & Nathan A.
//

import Foundation
import Speech
import UIKit

class VoiceManager: UIViewController, SFSpeechRecognizerDelegate {
    
    private let audioEngine = AVAudioEngine()
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    public var voiceDetected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        speechRecognizer?.delegate = self
        requestAuthorization()
    }
    
    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            switch authStatus {
            case .authorized:
                print("Speech recognition authorized")
            case .denied:
                print("User denied access to speech recognition")
            case .restricted:
                print("Speech recognition restricted on this device")
            case .notDetermined:
                print("Speech recognition not yet authorized")
            @unknown default:
                fatalError("Unknown case encountered")
            }
        }
    }
    
    func startRecording() throws {
        recognitionTask?.cancel()
        recognitionTask = nil
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .mixWithOthers])
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        recognitionRequest.shouldReportPartialResults = true
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            var isFinal = false
            if let result = result {
                //print(result.bestTranscription.formattedString)
                isFinal = result.isFinal
                if result.bestTranscription.formattedString.lowercased().contains("cancel") {
                    // Perform the cancel action
                    print("Cancel detected!")
                    self.voiceDetected = true
                    self.stopRecording()
                }
            }
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        print("Recording started")
    }
    
    func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        print("Recording stopped")
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            print("Speech recognizer available")
        } else {
            print("Speech recognizer not available")
        }
    }
    
}
