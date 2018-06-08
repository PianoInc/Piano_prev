//
//  LocalAuth.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 22..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import LocalAuthentication
import EventKit

class LocalAuth: NSObject {
    
    static let share = LocalAuth()
    
    /**
     기기 소유자의 인증 요청. (FaceID, TouchID, Passcode)
     - parameter auth : 요청에 대한 결과.
     */
    func request(auth: @escaping (() -> ())) {
        let laContext = LAContext()
        let bio = LAPolicy.deviceOwnerAuthenticationWithBiometrics
        let code = LAPolicy.deviceOwnerAuthentication
        let reason = "authReason".loc
        
        var laError: NSError?
        if laContext.canEvaluatePolicy(bio, error: &laError) {
            laContext.evaluatePolicy(code, localizedReason: reason) { success, error in
                if success {
                    DispatchQueue.main.async {auth()}
                } else if let error = error as NSError?, error.code == -3 {
                    laContext.evaluatePolicy(code, localizedReason: reason) { success, error in
                        if success {DispatchQueue.main.async {auth()}}
                    }
                }
            }
        } else {
            laContext.evaluatePolicy(code, localizedReason: reason) { success, error in
                if success {DispatchQueue.main.async {auth()}}
            }
        }
    }
    
    /**
     Camera 사용 권한 요청.
     - parameter camera : 요청에 대한 결과.
     */
    func request(camera: @escaping (() -> ())) {
        AVCaptureDevice.requestAccess(for: .video) { permission in
            DispatchQueue.main.async {
                if permission {
                    camera()
                } else {
                    self.alert(title: "", message: "requestCamera".loc)
                }
            }
        }
    }
    
    /**
     Photo album 사용 권한 요청.
     - parameter photo : 요청에 대한 결과.
     */
    func request(photo: @escaping (() -> ())) {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                if status == .authorized {
                    photo()
                } else {
                    self.alert(title: "", message: "requestPhoto".loc)
                }
            }
        }
    }
    
    /**
     Calendar 사용 권한 요청.
     - parameter calendar : 요청에 대한 결과.
     */
    func request(calendar: @escaping (() -> ())) {
        EKEventStore().requestAccess(to: .event) { (permission, _) in
            DispatchQueue.main.async {
                if permission {
                    calendar()
                } else {
                    self.alert(title: "", message: "requestCamera".loc)
                }
            }
        }
    }
    
    /**
     요청실패 알림창을 생성한다.
     - parameter title : 알림창 타이틀.
     - parameter message : 알림창 내용.
     */
    func alert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "cancel".loc, style: .cancel)
        let settingAction = UIAlertAction(title: "setting".loc, style: .default) { _ in
            UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!)
        }
        alert.addAction(settingAction)
        alert.addAction(dismissAction)
        
        if let topViewController = AppNavigator.currentViewController {
            topViewController.present(alert, animated: true)
        }
    }
    
}

