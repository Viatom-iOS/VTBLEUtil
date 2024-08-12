//
//  VTRecordEcgController.swift
//  UncompressDemo
//
//  Created by anwu on 2024/8/8.
//

import Cocoa

@objcMembers class VTRecordEcgController: NSViewController {

    public var ecgPoints: [Double]?
    public var sampleRate: Int = 125
    
    @IBOutlet weak var waveView: VTRecordEcgWave!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        if ecgPoints != nil {
            waveView.sampleRate = sampleRate
            waveView.ecgPoints = ecgPoints!
        }
    }
}
