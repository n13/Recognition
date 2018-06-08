//
//  ReminderSound.swift
//  Recognition
//
//  Created by Nikolaus Heger on 10/9/17.
//  Copyright © 2017 Nikolaus Heger. All rights reserved.
//

import AVFoundation

// Note: Only ever append to this value, we need to retain backwards compatibility with old sounds
struct SoundValue {
    static let Default = "Default"
    static let Small = "Small Bowl"
    static let Medium = "Medium Bowl"
    static let Big = "Big Bowl"
}

struct ReminderSound {
    static let Sounds = [
        SoundValue.Default: "",
        SoundValue.Small: "small_bowl.m4a",
        SoundValue.Medium: "medium_bowl.m4a",
        SoundValue.Big: "big_bowl.m4a",
    ]
    
    static func play(name: String) {
        guard let url = Bundle.main.url(forResource: Sounds[name], withExtension:"") else {
            print("sound not found: name: \(name)  reference: \(String(describing: Sounds[name]))")
            return
        }
        
        do {
            /// this codes for making this app ready to takeover the device audio
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            let player = try AVAudioPlayer(contentsOf: url)

            // no need for prepareToPlay because prepareToPlay is happen automatically when calling play()
            player.play()
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }    }
    
}


