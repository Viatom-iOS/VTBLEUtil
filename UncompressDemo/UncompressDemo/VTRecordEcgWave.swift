//
//  VTRecordEcgWave.swift
//  UncompressDemo
//
//  Created by anwu on 2024/8/8.
//

import Cocoa

class VTRecordEcgWave: NSView {

    public var ecgPoints: [Double]! {
        didSet {
            refresh()
        }
    }
    public var sampleRate: Int = 125 {
        didSet {
            mmPerVal = Double(rate) / Double(sampleRate)
            ptPerVal = ptPerMm * mmPerVal
        }
    }
    
    let mmPerMV = 10.0
    let gridPerThick = 5
    let gridPerRow = 5 * 5
    let gridUpper = 5 * 3
    let gridLower = 5 * 2
    let ptPerMm: Double = 6.4
    let rate = 25
    var mmPerVal: Double! = 0.2
    var ptPerVal: Double! = 3.2
    var offset: Double! = 0.0
    
    lazy var waveLayer: CAShapeLayer = {
        waveLayer = CAShapeLayer.init()
        waveLayer.strokeColor = NSColor(red: 0.32, green: 0.83, blue: 0.42, alpha: 1.0).cgColor
        waveLayer.fillColor = NSColor.clear.cgColor
        waveLayer.lineWidth = 1.0
        layer?.addSublayer(waveLayer)
        return waveLayer
    }()
    
    lazy var thickLayer: CAShapeLayer = {
        thickLayer = CAShapeLayer.init()
        thickLayer.strokeColor = NSColor.gray.cgColor
        thickLayer.fillColor = NSColor.clear.cgColor
        thickLayer.lineWidth = 0.5
        layer?.addSublayer(thickLayer)
        return thickLayer
    }()
    
    lazy var thinLineLayer: CAShapeLayer = {
        
        thinLineLayer = CAShapeLayer.init()
        thinLineLayer.strokeColor = NSColor.gray.cgColor
        thinLineLayer.fillColor = NSColor.clear.cgColor
        thinLineLayer.lineWidth = 0.1
        layer?.addSublayer(thinLineLayer)
        return thinLineLayer

    }()
    
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.white.cgColor
        let gesture = NSPanGestureRecognizer(target: self, action: #selector(self.panGesture(recognizer:)))
        self.layer?.transform = CATransform3D()
        self.addGestureRecognizer(gesture)
    }
    
    override var isFlipped: Bool {
        return true
    }
    
    required init?(coder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: coder)
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.white.cgColor
        let gesture = NSPanGestureRecognizer(target: self, action: #selector(self.panGesture(recognizer:)))
        self.addGestureRecognizer(gesture)
    }

    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        refresh()
    }
    
    @objc func panGesture(recognizer: NSPanGestureRecognizer) {
        
        if recognizer.state == .changed {
            let point = recognizer.translation(in: self)

            offset -= point.y
            print("偏移量：",point.y)
            if offset < 0 {
                offset = 0
            }
            
            let valPerRow = floor(bounds.width / ptPerVal)
            let offsetLimitRow = ceil(Double(ecgPoints.count) / valPerRow)
            let offsetLimitPt = offsetLimitRow * Double(gridPerRow) * ptPerMm
            
            if offset > offsetLimitPt - bounds.height {
                offset = offsetLimitPt - bounds.height
            }
            recognizer.setTranslation(CGPointZero, in: self)
            refresh()
        }
    }
    
    func refresh() {
        drawGrid()
        drawEcgWave()
    }
    
    
    func drawGrid() {
        
        // 确定第一条数据基线
        let offsetMM = fmod(offset,  ptPerMm * Double(gridPerRow))
        let firstBaseLineY = Double(gridUpper) * ptPerMm  - offsetMM
        
        var lineY = firstBaseLineY
        var count = 0
        let thinPath = CGMutablePath()
        let thickPath = CGMutablePath()
        while lineY <= bounds.height {
            let startPoint = NSPoint(x: 0.0, y: lineY)
            let endPoint = NSPoint(x: bounds.width, y: lineY)
            thinPath.move(to: startPoint)
            thinPath.addLine(to: endPoint)
            if count % gridPerThick == 0 {
                thickPath.move(to: startPoint)
                thickPath.addLine(to: endPoint)
            }
            lineY += ptPerMm
            count += 1
        }
        lineY = firstBaseLineY
        count = 0
        while lineY >= 0 {
            let startPoint = CGPoint(x: 0.0, y: lineY)
            let endPoint = CGPoint(x: bounds.width, y: lineY)
            thinPath.move(to: startPoint)
            thinPath.addLine(to: endPoint)
            if count % gridPerThick == 0 {
                thickPath.move(to: startPoint)
                thickPath.addLine(to: endPoint)
            }
            lineY -= ptPerMm
            count += 1
        }
        
        var lineX: Double = 0.0
        count = 0
        while lineX <= bounds.width {
            let startPoint = CGPoint(x: lineX, y: 0)
            let endPoint = CGPoint(x: lineX, y: bounds.height)
            thinPath.move(to: startPoint)
            thinPath.addLine(to: endPoint)
            if count % gridPerThick == 0 {
                thickPath.move(to: startPoint)
                thickPath.addLine(to: endPoint)
            }
            lineX += ptPerMm
            count += 1
        }
        thinLineLayer.path = thinPath
        thickLayer.path = thickPath
    }
    
    func drawEcgWave() {
        let valPerRow = floor(bounds.width / ptPerVal)
        let offsetRow = floor(offset / (ptPerMm * Double(gridPerRow)))
        let mmFirstRow = fmod(offset,  ptPerMm * Double(gridPerRow))
        let firstIdx = Int(valPerRow * offsetRow)
        var i = firstIdx
        print(firstIdx, offset ?? 0)
        var canBreak = false
        let wavePath = CGMutablePath()
        while i < ecgPoints.count  {
            let val = ecgPoints[i]
            let mod = (i - firstIdx) % Int(valPerRow)
            let row = (i - firstIdx) / Int(valPerRow)
            let x = Double(mod) * ptPerVal
            let y0 = Double(row) * Double(gridPerRow)  + Double(gridUpper)
            let y = y0 * ptPerMm - val * 10 * ptPerMm  - mmFirstRow
            if mod != 0 {
                if y <= bounds.height {
                    canBreak = false
                }
                wavePath.addLine(to: CGPointMake(x, y))
            } else {
                if canBreak == true {
                    break
                }
                if y > bounds.height {
                    canBreak = true
                }
                wavePath.move(to: CGPointMake(x, y))
            }
            i += 1
        }
        waveLayer.path = wavePath
    }
    
}
