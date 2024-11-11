//
//  ViewController.swift
//  AudioTagLib
//
//  Created by farid-applab on 11/06/2024.
//  Copyright (c) 2024 farid-applab. All rights reserved.
//

import UIKit
import AudioTagLib

class ViewController: UIViewController {
    struct track {
        var name: String
        var ext: String
    }
    
    let trackArr: [track] = [
        track(name: "05. Ashq Bhi flac", ext: "flac"),
        track(name: "Cheap Thrills (feat. Sean Paul) m4a", ext: "m4a"),
        track(name: "Demo song 1 wav", ext: "wav"),
        track(name: "Demo Song 3 m4a", ext: "m4a"),
        track(name: "Demo song 5 caf", ext: "caf"),
        track(name: "Demo song 6 aac", ext: "aac"),
        track(name: "ek-pyar-ka flac", ext: "flac"),
        track(name: "Let Me Down Slowly mp3", ext: "mp3"),
        track(name: "lose-my-mind-20931 mp3", ext: "mp3"),
        track(name: "Otilia mp3", ext: "mp3")
    ]
    
    @IBOutlet weak var artwork: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        debugPrint("viewDidLoad")

        let track = trackArr[0]
        let fileManager = FileManager.default
        let audioExtension = track.ext
        if let path = Bundle.main.path(forResource: track.name, ofType: audioExtension) {
            let url = URL(fileURLWithPath: path)
            let metadata = TaglibWrapper.getMetadata(url.path)
            debugPrint("Metadata: \(String(describing: metadata))")
            
            if let artwork = TaglibWrapper.getArtwork(url.path) {
                debugPrint("artwork: \(String(describing: artwork))")
                self.artwork.image = UIImage(data: artwork)
            } else {
                debugPrint("No artwork")
                self.artwork.image = UIImage()
            }
            
            if let uiimage = UIImage(named: "coverArt2.png") {
                if  let data = UIImagePNGRepresentation(uiimage) {
                    debugPrint("image data: \(data)")
                    let isOk = TaglibWrapper.setArtwork(url.path, artwork: data)
                    debugPrint("Set artwork status: \(isOk)")
                }
            }

            if let artwork = TaglibWrapper.getArtwork(url.path) {
                debugPrint("new artwork: \(String(describing: artwork))")
                self.artwork.image = UIImage(data: artwork)
            } else {
                debugPrint("No artwork")
                //self.artwork.image = UIImage()
            }
            
        } else {
            debugPrint("no path finding")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}



// 86490 bytes
// new one 256947 bytes

