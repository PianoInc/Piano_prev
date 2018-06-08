//
//  CardMapController.swift
//  PianoNote
//
//  Created by JangDoRi on 2018. 5. 21..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit
import WebKit
import RealmSwift
import CloudKit

/// 연산용 상수값 (/place/)
private let constPlace = "/place/"
/// 연산용 상수값 (/@)
private let constAt = "/@"
/// 연산용 상수값 (z/)
private let constZoom = "z/"

/// 구글맵에서 주소 정보를 가져오는 ViewCtrl.
class CardMapController: UIViewController {
    
    @IBOutlet private var safeView: UIView!
    
    private let webView = WKWebView()
    private var mapData = MapData()
    
    /// 데이터 저장을 serial하게 하려는 group.
    private let dispatchGroup = DispatchGroup()
    /// 데이터 저장 여부 판단에 사용되는 임시 string.
    private var tempUrl = ""
    
    /**
     이 string이 nil이 아닐시 viewCtrl의 init과 함께 즉시 해당 keyword의 검색을 진행한다.
     */
    var keyword: String?
    var mapDismissed: ((String) -> ())?
    var noteID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    private func initView() {
        webView.addObserver(self, forKeyPath: "URL", options: .new, context: nil)
        webView.navigationDelegate = self
        safeView.addSubview(webView)
        webView.anchor {
            $0.leading.equalTo(0)
            $0.trailing.equalTo(0)
            $0.top.equalTo(0)
            $0.bottom.equalTo(0)
        }
        let baseURL = URL(string: "mapBaseUrl".loc)
        let request = URLRequest(url: baseURL!)
        webView.load(request)
    }
    
    @IBAction private func action(done: UIBarButtonItem) {
        guard let realm = try? Realm(),
            let noteModel = realm.object(ofType: RealmNoteModel.self, forPrimaryKey: noteID) else {return}
        let coder = NSKeyedUnarchiver(forReadingWith: noteModel.ckMetaData)
        coder.requiresSecureCoding = true
        guard let record = CKRecord(coder: coder) else {fatalError("Data poluted!!")}
        coder.finishDecoding()
        
        let model = RealmAddressModel.getNewModel(sharedZoneID: record.recordID.zoneID, noteRecordName: record.recordID.recordName)
        model.address = mapData.data
        ModelManager.saveNew(model: model)
        
        dismiss(animated: true) {
            self.mapDismissed?(model.id)
        }
    }
    
    @IBAction private func action(close: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    deinit {
        #if DEBUG
        print("deinit :", self)
        #endif
    }
    
}

extension CardMapController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let keyword = keyword else {return}
        webView.evaluateJavaScript(String(format: "mapQuery".loc, keyword)) { _, _ in
            webView.evaluateJavaScript("mapSearch".loc, completionHandler: nil)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        checkUrl()
    }
    
    /// Url이 변경될때 마다 주소정보 추출여부를 판단한다.
    private func checkUrl() {
        guard let url = webView.url?.absoluteString, url != "mapBaseUrl".loc else {return}
        
        let subTempUrl = tempUrl.sub(...tempUrl.index(of: constAt))
        guard url.sub(...url.index(of: constAt)) != subTempUrl else {return}
        tempUrl = url
        
        if url.contains(constPlace) {
            extractData()
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    /// WebView와 JS를 통한 주소정보 획득.
    private func extractData() {
        dispatchGroup.enter()
        DispatchQueue.main.async {
            self.webView.evaluateJavaScript("mapLocation".loc) { (data, _) in
                if let data = data as? String {
                    self.mapData.location = data
                    self.dispatchGroup.leave()
                } else {
                    self.webView.evaluateJavaScript("mapAddress".loc) { (data, _) in
                        self.mapData.location = data as? String ?? ""
                        self.dispatchGroup.leave()
                    }
                }
            }
        }
        dispatchGroup.enter()
        DispatchQueue.main.async {
            self.webView.evaluateJavaScript("mapTitle".loc) { (data, _) in
                self.mapData.title = data as? String ?? ""
                self.dispatchGroup.leave()
            }
        }
        dispatchGroup.enter()
        DispatchQueue.main.async {
            guard let url = self.webView.url?.absoluteString else {return}
            let start = url.index(lastOf: constAt); let end = url.index(of: constZoom, from: start)
            guard start != 0, end != 0 else {return}
            let result = url.sub(start...end).components(separatedBy: ",")
            self.mapData.coordinate = result.map {
                return Double($0)!
            }
            self.dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: .main) {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
}

/// 구글맵의 특정위치에 대한 Data.
struct MapData {
    
    init() {}
    init(with data: String) {
        let dataArray = data.components(separatedBy: "|")
        title = dataArray[0]
        location = dataArray[1]
        coordinate = [Double(dataArray[2])!, Double(dataArray[3])!, Double(dataArray[4])!]
    }
    
    /// 해당 위치가 가지는 이름.
    var title = ""
    /// 해당 위치의 주소.
    var location = ""
    /// 해당 위치의 googleMap coordinate. (lat, long, zoom)
    var coordinate = [0.0]
    /// 현 Data가 비었는지의 여부.
    var isEmpty: Bool {
        return title == "" && location == "" && coordinate == [0.0]
    }
    
    /// Realm 저장용 data.
    var data: String {
        guard !isEmpty else {return ""}
        return "\(title)|\(location)|\(coordinate[0])|\(coordinate[1])|\(coordinate[2])"
    }
    
}

