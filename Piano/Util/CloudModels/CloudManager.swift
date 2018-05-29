//
//  CloudManager.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 4. 2..
//  Copyright © 2018년 piano. All rights reserved.
//

import Foundation
import CloudKit
import RealmSwift


class CloudManager {
    
    static let shared = CloudManager()
    
    private static let userIDKey = "CKCurrentUserID"
    public let privateDatabase: CloudPrivateDatabase
    public let sharedDatabase: CloudSharedDatabase
    public let publicDatabase: CloudPublicDatabase //Facebook 게시물 최근 Date()
    public var userID: CKRecordID?
    
    private init() {
        self.userID = CloudManager.getUserID()
        Realm.setDefaultRealmForUser(username: userID?.recordName ?? "")
        
        self.privateDatabase = CloudPrivateDatabase(database: CKContainer.default().privateCloudDatabase)
        self.sharedDatabase = CloudSharedDatabase(database: CKContainer.default().sharedCloudDatabase)
        self.publicDatabase = CloudPublicDatabase(database: CKContainer.default().publicCloudDatabase)
        
        defer {
            resumeLongLivedOperationIfPossible()
            
            DispatchQueue.main.async {
                self.setupNotificationHandling()
                
                self.requestUserInfo()
            }
        }
    }
    
    
    private static func save(userID: CKRecordID) {
        let userData = NSKeyedArchiver.archivedData(withRootObject: userID)
        UserDefaults.standard.set(userData, forKey: userIDKey)
    }
    
    private static func getUserID() -> CKRecordID? {
        if let userData = UserDefaults.standard.data(forKey: userIDKey) {
            return NSKeyedUnarchiver.unarchiveObject(with: userData) as? CKRecordID
        }
        return nil
    }
    
    
    /**
     * This function enables every offline local change operation to wait for reconnect
     * and resumes them all at once whenever the connection is made again
     */
    private func resumeLongLivedOperationIfPossible() {
        
        CKContainer.default().fetchAllLongLivedOperationIDs { ( operationIDs, error) in
            guard error == nil,
                let ids = operationIDs else {return}
            
            ids.forEach {
                CKContainer.default().fetchLongLivedOperation(withID: $0) { operation, error in
                    guard error == nil else { return }
                    if let operation = operation {
                        CKContainer.default().add(operation)
                    }
                }
            }
            
        }
    }
    
    fileprivate func setupNotificationHandling() {
        // Helpers
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(accountDidChange(_:)), name: Notification.Name.CKAccountChanged, object: nil)
        
    }
    
    func requestUserInfo() {
        let container = CKContainer.default()
        container.fetchUserRecordID() { [weak self] recordID, error in
            if error != nil {
                if let ckError = error as? CKError, ckError.isSpecificErrorCode(code: .notAuthenticated) {
                    //If not authenticated, request for authentication
                }
                print("Error!!!!")
                print(error!.localizedDescription)
            } else {
                guard let recordID = recordID else {return}
                
                if self?.userID != recordID {
                    self?.icloudIDChanged(with: recordID)
                }
            }
        }
    }
    
    private func icloudIDChanged(with recordID: CKRecordID) {
        print("Changed!!!")
        self.userID = recordID
        CloudManager.save(userID: recordID)
        Realm.setDefaultRealmForUser(username: recordID.recordName)
        //TODO: refresh UI when this notification observed
        //TODO: check for error messages!!
        CloudNotificationCenter.shared.postICloudUserChanged()
        
        privateDatabase.handleNotification()
        sharedDatabase.handleNotification()
    }
    
    @objc private func accountDidChange(_ notification: Notification) {
        // Request Account Status
        DispatchQueue.main.async { self.requestUserInfo() }
    }
}

