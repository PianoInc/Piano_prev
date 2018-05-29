//
//  NoteCalendarCell.swift
//  Piano
//
//  Created by Kevin Kim on 24/05/2018.
//  Copyright © 2018 Piano. All rights reserved.
//

import UIKit

struct NoteCalendar: CollectionDatable {
    
    let title: String
    let startDate: Date
    let endDate: Date
    var sectionTitle: String?
    var sectionIdentifier: String?
    
    init(title: String, startDate: Date, endDate: Date, sectionTitle: String? = nil, sectionIdentifier: String? = nil) {
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.sectionTitle = sectionTitle
        self.sectionIdentifier = sectionIdentifier
    }
    //1개일때 마진 2개 : 뷰의 가로 길이가 320 * 2 + 마진 * 3 개 보다 작으면 셀 1개, 셀의 가로 사이즈는 (뷰의 가로길이 - 마진 * 2)
    //2개일 때 마진 3개: 뷰의 가로 길이가 320 * 3 + 마진 * 4 개 보다 작으면 셀 2개, 셀의 가로 사이즈는 (뷰의 가로길이 - 마진 * 3) / 2
    //3개일 때 마진 4개: 뷰의 가로 길이가 320 * 4 + 마진 * 5 개 보다 작으면 셀 3개, 셀의 가로 사이즈는 (뷰의 가로길이 - 마진 * 4) / 3
    //n개일 때 마진 n+1개: 뷰의 가로길이(viewWidth)가 320 * (n+1) + 마진 * (n+2)개 보다 작으면 셀 n개, 셀의 가로 사이즈 cellWidth는 (뷰의 가로길이 - 마진 * (n+1)) / n
    
    //320 * n
    
    
    func size(maximumWidth: CGFloat) -> CGSize {
        var cellCount = 1
        while true {
            if maximumWidth < minimumCellWidth * CGFloat(cellCount + 1) + minimumInteritemSpacing * CGFloat(cellCount) + sectionInset.left + sectionInset.right {
                let cellWidth = (maximumWidth - (minimumInteritemSpacing * CGFloat(cellCount - 1) + sectionInset.left + sectionInset.right))/CGFloat(cellCount)
                return CGSize(width: cellWidth - 3, height: 87)
            }
            cellCount += 1
        }
    }
    
    var headerSize: CGSize {
        return CGSize(width: 100, height: 56)
    }
    
    var minimumInteritemSpacing: CGFloat {
        return 12
    }
    
    var minimumLineSpacing: CGFloat {
        return 11
    }
    
    func didSelectItem(fromVC viewController: ViewController) {
        //TODO: 캘린더 여는 화면 띄우기
    }
    
}

class NoteCalendarCell: UICollectionViewCell, CollectionDataAcceptable {
    
    var data: CollectionDatable? {
        didSet {
            
        }
    }
    
    
}
