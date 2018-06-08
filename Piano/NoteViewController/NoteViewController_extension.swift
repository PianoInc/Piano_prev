//
//  NoteViewController_extension.swift
//  Piano
//
//  Created by Kevin Kim on 2018. 6. 1..
//  Copyright © 2018년 Piano. All rights reserved.
//

import UIKit
import DynamicTextEngine_iOS
import CloudKit
import RealmSwift

extension NoteViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dataSource[indexPath.section][indexPath.item].didSelectItem(fromVC: self)
    }
}


extension NoteViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let data = dataSource[indexPath.section][indexPath.item]
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: data.identifier, for: indexPath) as! CollectionDataAcceptable & UICollectionViewCell
        cell.data = data
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource[section].count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: dataSource[indexPath.section][indexPath.item].sectionIdentifier ?? NotePeriodReusableView.identifier, for: indexPath) as! CollectionDataAcceptable & UICollectionReusableView
        reusableView.data = dataSource[indexPath.section][indexPath.item]
        return reusableView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return dataSource[section].first?.headerSize ?? CGSize.zero
    }
}

extension NoteViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        ()
    }
}

extension NoteViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return dataSource[section].first?.sectionInset ?? UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let maximumWidth = collectionView.bounds.width - (collectionView.marginLeft + collectionView.marginRight)
        return dataSource[indexPath.section][indexPath.item].size(maximumWidth: maximumWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return dataSource[section].first?.minimumLineSpacing ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return dataSource[section].first?.minimumInteritemSpacing ?? 0
    }
    
}


extension NoteViewController: DynamicTextViewDelegate {
    
    func attachment(with idForModel: String, cellId: String) {
        let attachment = CardAttachment(idForModel: idForModel, cellIdentifier: cellId)
        let attr = NSAttributedString(attachment: attachment)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = 30
        let mAttr = NSMutableAttributedString(attributedString: attr)
        mAttr.addAttributes([.paragraphStyle : paragraphStyle], range: NSMakeRange(0, mAttr.length))
        textView.textStorage.replaceCharacters(in: textView.selectedRange, with: mAttr)
        textView.selectedRange.location += mAttr.length
    }
    
}

extension NoteViewController: DynamicTextViewDataSource {
    func textView(_ textView: DynamicTextView, attachmentForCell attachment: DynamicTextAttachment) -> DynamicAttachmentCell {
        let cell = textView.dequeueReusableCell(withIdentifier: attachment.cellIdentifier)
        if let configuarableCell = cell as? AttributeModelConfigurable,
            let attachmentWithAttribute = attachment as? CardAttachment {
            configuarableCell.configure(with: attachmentWithAttribute.idForModel)
        }
        return cell
    }

}

@available(iOS 11.0, *)
extension NoteViewController: UITextDragDelegate, UITextDropDelegate {
    func textDraggableView(_ textDraggableView: UIView & UITextDraggable, itemsForDrag dragRequest: UITextDragRequest) -> [UIDragItem] {
        let location = textView.offset(from: textView.beginningOfDocument, to: dragRequest.dragRange.start)
        let length = textView.offset(from: dragRequest.dragRange.start, to: dragRequest.dragRange.end)
        
        let attributedString = NSAttributedString(attributedString:
            textView.textStorage.attributedSubstring(from: NSMakeRange(location, length)))
        
        let itemProvider = NSItemProvider(object: attributedString)
        
        
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = dragRequest.dragRange
        
        return [dragItem]
    }
    
    func textDraggableView(_ textDraggableView: UIView & UITextDraggable, dragPreviewForLiftingItem item: UIDragItem, session: UIDragSession) -> UITargetedDragPreview? {
        
        guard let textRange = item.localObject as? UITextRange else { return nil }
        let location = textView.offset(from: textView.beginningOfDocument, to: textRange.start)
        let length = textView.offset(from: textRange.start, to: textRange.end)
        let range = NSMakeRange(location, length)
        
        let preview: UIView
        let bounds = textView.layoutManager.boundingRect(forGlyphRange: range, in: textView.textContainer)
        if let attachment = textView.attributedText.attribute(.attachment, at: range.location, effectiveRange: nil) as? DynamicTextAttachment {
            //make it blurred
            preview = UIImageView(image: attachment.getPreviewForDragInteraction())
        } else {
            preview = UILabel(frame: bounds)
            (preview as! UILabel).attributedText = textView.textStorage.attributedSubstring(from: range)
        }
        
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let target = UIDragPreviewTarget(container: textView, center: center)
        
        return UITargetedDragPreview(view: preview, parameters: UIDragPreviewParameters(), target: target)
    }
    
    func textDroppableView(_ textDroppableView: UIView & UITextDroppable, willBecomeEditableForDrop drop: UITextDropRequest) -> UITextDropEditability {
        
        return (textView.isSyncing || isSaving) ? .no : .yes
    }
    
    func textDroppableView(_ textDroppableView: UIView & UITextDroppable, proposalForDrop drop: UITextDropRequest) -> UITextDropProposal {
        return UITextDropProposal(operation: .move)
    }
    
    
    func textDroppableView(_ textDroppableView: UIView & UITextDroppable, dropSessionDidEnd session: UIDropSession) {
        saveText(isDeallocating: false)
    }
}

@available(iOS 11.0, *)
extension NoteViewController: UITextPasteDelegate {
    func textPasteConfigurationSupporting(_ textPasteConfigurationSupporting: UITextPasteConfigurationSupporting, combineItemAttributedStrings itemStrings: [NSAttributedString], for textRange: UITextRange) -> NSAttributedString {
        
        if itemStrings.count == 1 {
            let attributedString = itemStrings[0]
            
            if let attachment = attributedString.attribute(.attachment, at: 0, effectiveRange: nil) as? DynamicTextAttachment {
                let newAttr = NSAttributedString(attachment: attachment.getCopyForDragInteraction())
                return newAttr
            }
        }
        
        return itemStrings.reduce(NSMutableAttributedString()) { (result, attr) -> NSMutableAttributedString in
            result.append(attr)
            return result
        }
    }
}

extension NoteViewController: UICloudSharingControllerDelegate, UIPopoverPresentationControllerDelegate {
    func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
        print(error)
    }
    
    func cloudSharingControllerDidSaveShare(_ csc: UICloudSharingController) {
        print("save!!!!!")
    }
    
    func cloudSharingControllerDidStopSharing(_ csc: UICloudSharingController) {
        print("Stoppedddd!!!!!!!!!!!1’")
    }
    
    func itemTitle(for csc: UICloudSharingController) -> String? {
        return "피아노 노트"
    }
    
    func itemThumbnailData(for csc: UICloudSharingController) -> Data? {
        return UIImageJPEGRepresentation(textView.getScreenShot(), 1.0)
    }
    
    private func share(rootRecord: CKRecord, urls: [URL], completion: @escaping (CKShare?, CKContainer?, Error?) -> Void) {
        let shareRecord = CKShare(rootRecord: rootRecord)
        let recordsToSave = [rootRecord, shareRecord]
        
        let operation = CKModifyRecordsOperation(recordsToSave: recordsToSave, recordIDsToDelete: [])
        operation.perRecordCompletionBlock = { (record, error) in
            if let error = error {
                print(error)
            } else {
                CloudManager.shared.privateDatabase.syncChanged(record: record, isShared: false)
            }
        }
        
        operation.modifyRecordsCompletionBlock = { (savedRecords, deletedRecordIDs, error) in
            urls.forEach {
                try? FileManager.default.removeItem(at: $0)
            }
            if let error = error {
                completion(nil,nil,error)
            } else {
                completion(shareRecord, CKContainer.default(), nil)
            }
        }
        
        
        CKContainer.default().privateCloudDatabase.add(operation)
    }
    
    func presentShare(_ sender: UIBarButtonItem) {
        guard let realm = try? Realm(),
            let note = realm.object(ofType: RealmNoteModel.self, forPrimaryKey: noteID) else {return}
        
        let dic = note.getRecordWithURL()
        let record = dic.object(forKey: Schema.dicRecordKey) as! CKRecord
        let urls = dic.object(forKey: Schema.dicURLsKey) as! [URL]
        
        let cloudSharingController = UICloudSharingController { [weak self] (controller, completion: @escaping (CKShare?, CKContainer?, Error?) -> Void) in
            self?.share(rootRecord: record, urls: urls, completion: completion)
        }
        
        cloudSharingController.availablePermissions = [.allowPrivate, .allowReadWrite]
        cloudSharingController.delegate = self
        
        if let popover = cloudSharingController.popoverPresentationController {
            popover.barButtonItem = sender
        }
        self.present(cloudSharingController, animated: true)
    }
}


extension NoteViewController {
    
    internal func registerKeyboardNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    internal func unRegisterKeyboardNotification(){
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        
        guard let userInfo = notification.userInfo,
            let kbHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height
            else { return }
        
        textView.contentInset.bottom = kbHeight
        textView.scrollIndicatorInsets.bottom = kbHeight
        
        
        
        
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue else { return }
        
        textView.scrollIndicatorInsets.bottom = 0
        UIView.animate(withDuration: duration) { [weak self] in
            self?.textView.contentInset = UIEdgeInsets.zero
        }
    }
    
}
