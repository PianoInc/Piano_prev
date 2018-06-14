//
//  CameraView.swift
//  PianoNote
//
//  Created by JangDoRi on 2018. 4. 3..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit
import AVFoundation

class CameraView: UIView {
    
    let previewView = UIView()
    private let flashButton = view(UIButton()) {
        $0.setImage(#imageLiteral(resourceName: "flash_off"), for: .normal)
        $0.setImage(#imageLiteral(resourceName: "flash_off"), for: .highlighted)
    }
    private let cancelButton = view(UIButton()) {
        $0.setTitle("cancel".loc, for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 17)
    }
    private let shotButton = view(UIButton()) {
        $0.setImage(#imageLiteral(resourceName: "shot"), for: .normal)
        $0.setImage(#imageLiteral(resourceName: "shot"), for: .highlighted)
    }
    private let rotateButton = view(UIButton()) {
        $0.setImage(#imageLiteral(resourceName: "rotate"), for: .normal)
        $0.setImage(#imageLiteral(resourceName: "rotate"), for: .highlighted)
    }
    
    var captureSession: AVCaptureSession?
    var captureOutput: AVCapturePhotoOutput?
    var inputBack: AVCaptureDeviceInput?
    var inputFront: AVCaptureDeviceInput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var flashMode = AVCaptureDevice.FlashMode.off
    
    var captureCompletion: ((UIImage?) -> ())?
    var cameraShoted: ((UIImage?) -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        viewDidLoad()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        viewDidLoad()
    }
    
    private func viewDidLoad() {
        initView()
        initConst()
        device(orientationDidChange: { [weak self] _ in self?.initConst()})
    }
    
    private func initView() {
        backgroundColor = .black
        flashButton.addTarget(self, action: #selector(action(flash:)), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(action(close:)), for: .touchUpInside)
        shotButton.addTarget(self, action: #selector(action(shot:)), for: .touchUpInside)
        rotateButton.addTarget(self, action: #selector(action(rotate:)), for: .touchUpInside)
        addSubview(previewView)
        addSubview(flashButton)
        addSubview(cancelButton)
        addSubview(shotButton)
        addSubview(rotateButton)
        
        DispatchQueue.global().async {
            self.initDevice()
            DispatchQueue.main.async {
                self.initPreview()
            }
        }
    }
    
    private func initConst() {
        flashButton.anchor {
            $0.leading.equalTo(0)
            $0.top.equalTo(0)
            $0.width.equalTo(50)
            $0.height.equalTo(flashButton.widthAnchor)
        }
        cancelButton.anchor {
            $0.leading.equalTo(25)
            $0.bottom.equalTo(-25)
            $0.width.equalTo(50)
            $0.height.equalTo(cancelButton.widthAnchor)
        }
        shotButton.anchor {
            $0.leading.equalTo(mainSize.width / 2 - 50)
            $0.bottom.equalTo(0)
            $0.width.equalTo(100)
            $0.height.equalTo(shotButton.widthAnchor)
        }
        rotateButton.anchor {
            $0.trailing.equalTo(-25)
            $0.bottom.equalTo(-25)
            $0.width.equalTo(50)
            $0.height.equalTo(rotateButton.widthAnchor)
        }
        previewView.anchor {
            $0.leading.equalTo(0)
            $0.trailing.equalTo(0)
            $0.top.equalTo(50)
            $0.bottom.equalTo(-100)
        }
    }
    
    @objc private func action(flash: UIButton) {
        flashButton.isSelected = !flash.isSelected
        flashMode = flashButton.isSelected ? .on : .off
        flashButton.setImage(flashButton.isSelected ? #imageLiteral(resourceName: "flash_on") : #imageLiteral(resourceName: "flash_off"), for: .normal)
        flashButton.setImage(flashButton.isSelected ? #imageLiteral(resourceName: "flash_on") : #imageLiteral(resourceName: "flash_off"), for: .highlighted)
    }
    
    @objc private func action(close: UIButton) {
        DispatchQueue.global().async {
            self.captureSession?.stopRunning()
            DispatchQueue.main.async {
                self.cameraShoted?(nil)
            }
        }
    }
    
    @objc private func action(shot: UIButton) {
        cameraShot(completion: {
            self.captureSession?.stopRunning()
            self.cameraShoted?($0)
        })
    }
    
    @objc private func action(rotate: UIButton) {
        reloadDevice()
    }
    
}

