//
//  CloudDatabase.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 4. 2..
//  Copyright © 2018년 piano. All rights reserved.
//

import CloudKit
import UIKit

class CloudPublicDatabase: RxCloudDatabase {

    public override init(database: CKDatabase) {
        super.init(database: database)

        /*
         Public database는 latest event record만 사용하기 때문에 해당
         레코드에 대한 subscription만 등록
         */
        saveQuerySubscription(for: RealmRecordTypeString.latestEvent.rawValue)
    }

    public func handleNotification() {
        query(for: RealmRecordTypeString.latestEvent.rawValue)
    }
}

class CloudPrivateDatabase: RxCloudDatabase {

    public override init(database: CKDatabase) {
        super.init(database: database)

        /*
         Private database에서 사용하는 tags, note, image
         레코드에 대한 subscription 등록
         */
        
        saveQuerySubscription(for: RealmTagsModel.recordTypeString)
        saveQuerySubscription(for: RealmNoteModel.recordTypeString)
        saveQuerySubscription(for: RealmImageModel.recordTypeString)
    }

    public func handleNotification() {
        let customZone = CKRecordZone(zoneName: RxCloudDatabase.privateRecordZoneName)
        fetchZoneChanges(in: [customZone.zoneID])
    }
    
}

class CloudSharedDatabase: RxCloudDatabase {
    public override init(database: CKDatabase) {
        super.init(database: database)

        /*
         Share database는 query subscription을 등록할 수 없기 때문에
         database subscription 등록
         */
        
        saveDatabaseSubscription()
    }

    public func handleNotification() {
        fetchDatabaseChanges()
    }
}

