//
//  AudioPlayer.swift
//  WakeUpAt
//
//  Created by Ahmed Osama on 9/1/18.
//  Copyright © 2018 Ahmed Osama. All rights reserved.
//

import UIKit
import AVFoundation

class AudioPlayer {

    fileprivate var player: AVAudioPlayer?
    
    func play(sound: Sound) {
        
        player?.stop()
        //guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            let data = (NSDataAsset(name: sound.rawValue)?.data)!
            player = try AVAudioPlayer(data: data, fileTypeHint: AVFileType.mp3.rawValue)
            
            //player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            //player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) //ios < 11
            
            guard let player = player else { return }
            
            player.numberOfLoops = -1
            //player.volume = 0
            
            player.play()
            //player.setVolume(1, fadeDuration: 0.5)
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func stop() {
        player?.stop()
    }
    
}

enum Sound: String {
    
    case one = "sound1", two = "sound2", three = "sound3"
    
    func toInt() -> Int {
        var value: Int!
        switch self {
        case .one:
            value = 0
        case .two:
            value = 1
        case .three:
            value = 2
        }
        return value
    }
    
    func toFriendlyString() -> String {
        var value: String!
        switch self {
        case .one:
            value = "One"
        case .two:
            value = "Two"
        case .three:
            value = "Three"
        }
        return value
    }
    
    static func fromInt(value: Int) -> Sound {
        var sound: Sound!
        switch value {
        case 0:
            sound = .one
        case 1:
            sound = .two
        case 2:
            sound = .three
        default:
            break
        }
        return sound
    }
    
}
