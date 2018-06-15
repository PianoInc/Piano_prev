//
// Created by 김범수 on 2018. 5. 18..
// Copyright (c) 2018 piano. All rights reserved.
//

import RealmSwift
import CloudKit

class RealmAddressModel: Object, Recordable {
    
    static let recordTypeString = "Image"
    
    @objc dynamic var id = ""
    @objc dynamic var address = ""
    
    @objc dynamic var recordName = ""
    @objc dynamic var ckMetaData = Data()
    
    @objc dynamic var isInSharedDB = false
    
    @objc dynamic var noteRecordName = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["recordTypeString"]
    }
    
    
    static func getNewModel(sharedZoneID: CKRecordZoneID? = nil, noteRecordName: String) -> RealmAddressModel {
        let zone = CKRecordZone(zoneName: RxCloudDatabase.privateRecordZoneName)
        let id = Util.share.getUniqueID()
        let zoneID = sharedZoneID ?? zone.zoneID
        let record = CKRecord(recordType: RealmImageModel.recordTypeString, zoneID: zoneID)
        
        let newModel = RealmAddressModel()
        newModel.recordName = record.recordID.recordName
        newModel.ckMetaData = record.getMetaData()
        newModel.id = id
        newModel.isInSharedDB = sharedZoneID != nil
        newModel.noteRecordName = noteRecordName
        
        return newModel
    }
}

class RealmImageModel: Object, Recordable {
    
    static let recordTypeString = "Image"
    
    @objc dynamic var id = ""
    @objc dynamic var image = Data()
    
    @objc dynamic var recordName = ""
    @objc dynamic var ckMetaData = Data()
    
    @objc dynamic var isInSharedDB = false
    @objc dynamic var isPhoto = true
    
    @objc dynamic var noteRecordName = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["recordTypeString"]
    }
    
    static func getNewModel(sharedZoneID: CKRecordZoneID? = nil, noteRecordName: String, image: UIImage? = nil) -> RealmImageModel {
        let zone = CKRecordZone(zoneName: RxCloudDatabase.privateRecordZoneName)
        let id = Util.share.getUniqueID()
        let zoneID = sharedZoneID ?? zone.zoneID
        let record = CKRecord(recordType: RealmImageModel.recordTypeString, zoneID: zoneID)
        
        let newModel = RealmImageModel()
        newModel.recordName = record.recordID.recordName
        newModel.ckMetaData = record.getMetaData()
        newModel.id = id
        newModel.isInSharedDB = sharedZoneID != nil
        newModel.noteRecordName = noteRecordName
        if let image = image {
            newModel.image = UIImageJPEGRepresentation(image, 1.0) ?? Data()
        }
        
        return newModel
    }
}

class RealmImageListModel: Object, Recordable {
    static let recordTypeString = "ImageList"
    
    @objc dynamic var id = ""
    
    @objc dynamic var recordName = ""
    @objc dynamic var ckMetaData = Data()
    @objc dynamic var isInSharedDB = false
    
    @objc dynamic var noteRecordName = ""
    
    @objc dynamic var imageIDs = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["recordTypeString"]
    }
    
    static func getNewModel(sharedZoneID: CKRecordZoneID? = nil, noteRecordName: String, imageIDs: [String]) -> RealmImageListModel {
        let zone = CKRecordZone(zoneName: RxCloudDatabase.privateRecordZoneName)
        let id = Util.share.getUniqueID()
        let zoneID = sharedZoneID ?? zone.zoneID
        let record = CKRecord(recordType: RealmImageListModel.recordTypeString, zoneID: zoneID)
        
        let newModel = RealmImageListModel()
        newModel.recordName = record.recordID.recordName
        newModel.ckMetaData = record.getMetaData()
        newModel.id = id
        newModel.isInSharedDB = sharedZoneID != nil
        newModel.noteRecordName = noteRecordName
        newModel.imageIDs = imageIDs.joined(separator: "|")
        
        return newModel
    }
}

class RealmEventModel: Object, Recordable {
    
    static let recordTypeString = "Event"
    
    @objc dynamic var id = ""
    @objc dynamic var event = ""
    
    @objc dynamic var recordName = ""
    @objc dynamic var ckMetaData = Data()
    
    @objc dynamic var isInSharedDB = false
    @objc dynamic var noteRecordName = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["recordTypeString"]
    }
    
    static func getNewModel(sharedZoneID: CKRecordZoneID? = nil, noteRecordName: String, event: String) -> RealmEventModel {
        let zone = CKRecordZone(zoneName: RxCloudDatabase.privateRecordZoneName)
        let id = Util.share.getUniqueID()
        let zoneID = sharedZoneID ?? zone.zoneID
        let record = CKRecord(recordType: RealmImageModel.recordTypeString, zoneID: zoneID)
        
        let newModel = RealmEventModel()
        newModel.recordName = record.recordID.recordName
        newModel.ckMetaData = record.getMetaData()
        newModel.id = id
        newModel.event = event
        newModel.isInSharedDB = sharedZoneID != nil
        newModel.noteRecordName = noteRecordName
        
        return newModel
    }
}

