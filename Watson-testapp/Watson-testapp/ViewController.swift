//
//  ViewController.swift
//  Watson-testapp
//
//  Created by Alvin  Andino  on 12/24/16.
//  Copyright © 2016 Alvin  Andino . All rights reserved.
//

import UIKit
import AVFoundation
import SpeechToTextV1
import TextToSpeechV1
import ConversationV1

class ViewController: UIViewController {
  
  private enum Credentials: String{
    case sttUser = "ccc49d14-7291-4f04-953d-b9930a7adb57"
    case sttPass = "lAda4ES3WgEr"
    case ttsUser = "38d8f7a1-2445-4dd1-bdd1-f13ec394a9b0"
    case ttsPass = "2JyNCKVSR5D3"
    case convoUser = "6722c1b3-5a57-4e05-bbbf-666de378d6ce"
    case convoPass = "vlzy8VwxdiIQ"
    
  }
  
  @IBOutlet weak var WatsonReplyLabel: UILabel!
  @IBOutlet weak var RequestLabel: UILabel!
  @IBOutlet weak var TalkButton: UIButton!
  
  private var convo: Conversation?
  
  private var stt: SpeechToText?
  private var tts: TextToSpeech?
  private var recorder: AVAudioRecorder?
  private var player: AVAudioPlayer?
  private var session = AVAudioSession.sharedInstance()
  
  @IBAction func ButtonPressed(_ sender: UIButton) {
    TalkButton.isEnabled = false
    startStreaming()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    instantiateSTT()
    instantiateTTS()
    instantiateConversation()
    /*
    let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    let filename = "STTRecording.wav"
    let filepath = NSURL(fileURLWithPath: documents + "/" + filename)
 */
  }
  
  private func instantiateSTT() {
    stt = SpeechToText(username: Credentials.sttUser.rawValue, password:  Credentials.sttPass.rawValue)
  }
  
  private func instantiateTTS() {
    tts = TextToSpeech(username: Credentials.ttsUser.rawValue, password: Credentials.ttsPass.rawValue)
  }
  
  private func instantiateConversation() {
    convo = Conversation(username: Credentials.convoUser.rawValue, password: Credentials.convoPass.rawValue, version: "2016-12-25")
  }
  
  private func startStreaming() {
    let settings = RecognitionSettings(contentType: .opus)
    
    // ensure SpeechToText service is up
    guard let stt = stt else {
      print("SpeechToText not properly set up.")
      return
    }
    let failure = { (error: Error) in print(error) }
    stt.recognizeMicrophone(settings: settings, failure: failure) { results in
      let transcript = results.bestTranscript
      self.RequestLabel.text = transcript
      self.WatsonReplyLabel.text = transcript
      self.replyToRequest(text: results.bestTranscript)
      
    }
  }
  
  private func replyToRequest(text: String) {
    //conversation model
    synthesizeText(text: text)
    self.TalkButton.isEnabled = true
  }
  
  func synthesizeText(text: String) {
    guard let tts = tts else {
      print ("no text to speech service")
      return
    }
    tts.synthesize(text,
                   voice: SynthesisVoice.gb_Kate.rawValue,
                   audioFormat: AudioFormat.wav,
                   failure: { error in
                    print("error was generated \(error)")
    }) { data in
      do {
        self.player = try AVAudioPlayer(data: data)
        self.player!.play()
      } catch {
        print("Couldn't create player.")
      }
    }
  }
  
}

