//
//  DDLyricalPlayer.swift
//  DDLyrical
//
//  Created by Gu Jun on 2019/4/23.
//  Copyright © 2019 Gu Jun. All rights reserved.
//

import UIKit
import AVFoundation

protocol DDLyricalPlayerDelegate: UIViewController {
     func focusOn(line: Int)
}

class DDLyricalPlayer: NSObject {
    
    static let shared = DDLyricalPlayer()
    
    weak var delegate: DDLyricalPlayerDelegate?
    
    private static let TIMER_INTERVAL = 0.05
    
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    private var timings: Array<Double> = Array<Double>()
    private var tempTimingIndex: Int = 0
    
    private override init() {
    }
    
    func loadSong(forResource filename: String, withExtension ext: String, andTimings timings: Array<Double>) {
        self.timings = timings

        let url = formURL(forResource: filename, withExtension: ext)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
        } catch {
            audioPlayer = nil
        }
    }
    
    func play() {
        audioPlayer?.play()
        timer = Timer.scheduledTimer(timeInterval: DDLyricalPlayer.TIMER_INTERVAL, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
    }
    
    func pause() {
        audioPlayer?.pause()
    }
    
    func isPlaying() -> Bool {
        if audioPlayer != nil && audioPlayer!.isPlaying == true {
            return true
        }
        return false
    }

    @objc func timerFired() {
        if (tempTimingIndex >= timings.count - 1) {
            timer?.invalidate()
            return
        }
        if let currentTime = audioPlayer?.currentTime {
            if (currentTime > timings[tempTimingIndex + 1]) {
                tempTimingIndex += 1
                delegate?.focusOn(line: tempTimingIndex)
            
//            for (index, timing) in timings.enumerated() {
//                if (currentTime > timing) {
//                    delegate?.focusOn(line: index)
//                    break
//                }
            }
        }
    }
    
    private func formURL(forResource filename: String, withExtension ext: String) -> URL {
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let fullpath = path + "/" + filename + "." + ext
        //        print(fullpath)
        let url = URL(fileURLWithPath: fullpath)

        return url
    }
    
    private func formURL(forBundleResource filename: String, withExtension ext: String) -> URL? {
        return Bundle.main.url(forResource: filename, withExtension: ext)
    }
}
