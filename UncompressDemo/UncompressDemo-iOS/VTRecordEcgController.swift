//
//  VTRecordEcgController.swift
//  UncompressDemo-iOS
//
//  Created by anwu on 2024/8/9.
//

import UIKit

@objcMembers class VTRecordEcgController: UIViewController {
    public var ecgPoints: [Double]?
    public var sampleRate: Int = 125
    
    
    lazy var ecgWave: VTRecordEcgWave = {
        ecgWave = VTRecordEcgWave(frame: self.view.bounds)
        view.addSubview(ecgWave)
        return ecgWave
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if ecgPoints != nil {
            ecgWave.sampleRate = sampleRate
            ecgWave.ecgPoints = ecgPoints!
        }
        
    }
}
