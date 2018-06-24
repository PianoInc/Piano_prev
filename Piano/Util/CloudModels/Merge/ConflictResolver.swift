//
//  ConflictResolver.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 4. 3..
//  Copyright © 2018년 piano. All rights reserved.
//

import CloudKit

extension RxCloudDatabase {
    //!!일반적인 머지로직의 경우 modified 일자를 확인하여 더 최신의 정보를 반영한다.
    
    /**
     조상, 클라이언트, 서버 버전의 레코드를 받는다.
     노트레코드의 경우 등록된 synchronizer가 있을땐 synchronizer을 통해 머지,
     나머지는 임의로 머지 로직을 등록해준다.
     */
    func merge(ancestor: CKRecord, myRecord: CKRecord, serverRecord: CKRecord, completion: @escaping (Bool)->()) {
        let myModified = myRecord.modificationDate ?? Date()
        let serverModified = serverRecord.modificationDate ?? Date()
        
        //노트를 제외한 레코드들은 case를 따로만들어 머지 로직 추가
        switch ancestor.recordType {
        case RealmNoteModel.recordTypeString:
            mergeNote(ancestor: ancestor, myRecord: myRecord, serverRecord: serverRecord, myModified: myModified, serverModified: serverModified, completion: completion)
            
        case RealmTagsModel.recordTypeString:
            
            if myModified.compare(serverModified) == .orderedDescending {
                serverRecord[Schema.Tags.tags] = myRecord[Schema.Tags.tags]
                completion(true)
            } else {
                completion(false)
            }
        default: break
        }
        
        
    }
    
    /**
     노트를 머지하는 로직. synchronizer가 존재하는지 확인(노트 화면이 떠있는경우).
     없는 경우 일반적인 머지 실시(노트의 내용은 서버버전으로 업로드). 즉 태그정보만 머지 실시.
     synchronizer가 존재하는경우 머지는 synchronizer의 메소드를 사용하여 실시 한다.
     
     */
    private func mergeNote(ancestor: CKRecord, myRecord: CKRecord, serverRecord: CKRecord, myModified: Date, serverModified: Date, completion: @escaping (Bool) -> ()) {
        
        if let synchronizer = synchronizers[myRecord.recordID.recordName] {
            //DO diff3 here with ancestor: myrecord, a: textView.text b: b
            synchronizer.resolveConflict(ancestorRecord: ancestor, myRecord: myRecord, serverRecord: serverRecord, completion: completion)
            return
        }
        
        
        if myModified.compare(serverModified) == .orderedDescending {
            
            if let serverCategory = serverRecord[Schema.Note.tags] as? String,
                let myCategory = myRecord[Schema.Note.tags] as? String,
                serverCategory != myCategory {
                
                serverRecord[Schema.Note.tags] = myRecord[Schema.Note.tags]
                completion(true)
                return
            }
            
        }
        
        completion(false)
    }
    
}
