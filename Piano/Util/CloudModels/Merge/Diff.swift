//
//  Diff.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 4. 3..
//  Copyright © 2018년 piano. All rights reserved.
//

import Foundation

enum DiffBlock: CustomStringConvertible {
    var description: String {
        switch self {
        case .empty : return "empty"
        case .add(let index, let range): return "add \(range) at \(index)"
        case .change(let aRange, let bRange): return "change \(aRange) with \(bRange)"
        case .delete(let range): return "delete \(range)"
        }
    }
    
    case empty // for diff3 merge
    case add(Int, NSRange)
    case change(NSRange, NSRange)
    case delete(NSRange, Int)
    
    func getARange() -> NSRange {
        switch self {
        case .add(let index, _): return NSMakeRange(index, 0)
        case .change(let range, _): return range
        case .delete(let range, _): return range
        default: return NSMakeRange(0, 0) // not called
        }
    }
    
    func getBRange() -> NSRange {
        switch self {
        case .add(_, let range): return range
        case .change(_, let range): return range
        case .delete(_, let index): return NSMakeRange(index, 0)
        default: return NSMakeRange(0, 0)
        }
    }
}

struct Pair {
    let x: Int
    let y: Int
    
    ///점과 점사이의 거리가 1일때 true
    func isAdjacent(to pair: Pair) -> Bool {
        let absX = abs(x-pair.x)
        let absY = abs(y-pair.y)
        return absX + absY == 1
    }
}

extension Pair: Hashable {
    
    static func ==(lhs: Pair, rhs: Pair) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
    
    var hashValue: Int {
        return x.hashValue ^ y.hashValue &* 16777619
    }
    
    
}

/// [http://www.xmailserver.org/diff2.pdf](http://www.xmailserver.org/diff2.pdf) 의 구현체
class DiffMaker {
    
    let aChunks: [String]
    let bChunks: [String]
    private let separator: String
    
    private var mapping: [Int: Int]
    private var v: [Int]
    private var path: [[Pair: Pair]] = []
    
    private var m: Int { return aChunks.count }
    private var n: Int { return bChunks.count }
    private var matchD = -1
    
    let aRealRanges: [NSRange]
    let bRealRanges: [NSRange]
    let startOffset: Int
    
    ///aString -> bString까지 가는데 최소한의 edit script를 구한다. separator는 각 string을 어떻게 chunk로 나눌지에 대한 parameter이다. separator가 empty일 경우 각 character를 하나의 chunk로 간주한다.
    
    init(aString: String, bString: String, separator: String = "\n") {
        self.separator = separator
        let aInitialChunks = separator.isEmpty ? aString.map(String.init): aString.components(separatedBy: separator)
        let bInitialChunks = separator.isEmpty ? bString.map(String.init): bString.components(separatedBy: separator)
        
        let aChunks = aInitialChunks.enumerated().map{ $0.offset == (aInitialChunks.count - 1) ? $0.element : $0.element + separator}
        let bChunks = bInitialChunks.enumerated().map{ $0.offset == (bInitialChunks.count - 1) ? $0.element : $0.element + separator}
        
        //separator로 나눈 chunk들
        self.aChunks = aChunks
        self.bChunks = bChunks
        
        var lowerBound = 0
        
        //후에 chunk index가 아닌 real index를 구하기 위해 미리 indexing을 해놓는다.
        self.aRealRanges = self.aChunks.map{
            let range = NSMakeRange(lowerBound, $0.count)
            lowerBound += $0.count
            return range
        }
        
        lowerBound = 0
        
        self.bRealRanges = self.bChunks.map {
            let range = NSMakeRange(lowerBound, $0.count)
            lowerBound += $0.count
            return range
        }
        
        
        let max = aChunks.count+bChunks.count
        var offset  = 0
        
        //offset은 a와 b가 같은 최대 prefix index
        while offset < aChunks.count && offset < bChunks.count && aChunks[offset] == bChunks[offset] {
            offset += 1
        }
        
        self.startOffset = offset
        
        self.v = Array<Int>(repeating: offset, count: 2*(max)+1)
        
        self.mapping = stride(from: -(max), through: max, by: 1).enumerated().reduce([Int: Int]()) { (resultDic, enumerated) in
            var dict = resultDic
            dict[enumerated.element] = enumerated.offset
            return dict
        }
        
        path.append([:])
        
    }
    
    ///chunk range -> real range
    func realRange(from range: NSRange, inA: Bool) -> NSRange {
        let realRanges = inA ? aRealRanges : bRealRanges
        
        let lowerBound = realRanges[range.lowerBound].lowerBound
        let upperBound = realRanges[range.upperBound-1].upperBound
        return NSMakeRange(lowerBound, upperBound - lowerBound)
    }
    
    ///chunk index -> chunk range
    func realIndex(from index: Int, inA: Bool) -> Int {
        let realRange = inA ? aRealRanges : bRealRanges
        
        return index == 0 ? 0 : realRange[index-1].upperBound
    }
    
    
    ///논문 6페이지의 edit script구하는 logic
    private func fillPath() {
        guard !(aChunks.isEmpty && bChunks.isEmpty) else {return}
        for d in 1...(m+n) {
            path.append([:])
            for k in stride(from: -d, through: d, by: 2) {
                
                let tk = mapping[k]!
                let prevK: Int
                let prevX: Int
                let prevY: Int
                
                var x: Int
                var y: Int
                if k == -d || k != d && v[tk-1] < v[tk+1] {
                    //vertical addition
                    x = v[tk+1]
                    y = x - k
                    prevK = k+1
                    prevX = x
                    prevY = prevX - prevK
                } else {
                    //horizontal deletion
                    x = v[tk-1] + 1
                    y = x - k
                    
                    prevK = k-1
                    prevX = x-1
                    prevY = prevX - prevK
                }
                
                while x-1 < m-1 && y-1 < n-1 && aChunks[x] == bChunks[y] {
                    x += 1
                    y += 1
                }
                
                path[d][Pair(x: x, y: y)] = Pair(x: prevX, y: prevY)
                v[tk] = x
                
                if x >= m && y >= n {
                    //break!!
                    
                    matchD = d
                    return
                }
            }
        }
    }
    
    
    ///fillPath()가 채운 path array를 기반으로 edit script 작성
    private func getPath() -> [DiffBlock] {
        guard !(aChunks.isEmpty && bChunks.isEmpty) else {return []}
        var currentPair = Pair(x: m, y: n)
        
        var paths: [Pair] = [currentPair]
        
        while matchD > 0 {
            
            guard let prevPath = path[matchD][currentPair] else {break}
            paths.insert(prevPath, at: 0)
            currentPair = prevPath
            
            matchD -= 1
        }
        
        var chunks: [DiffBlock] = []
        var prevAnchor: Pair?
        
        for (index, point) in paths.enumerated() {
            if let previousAnchor = prevAnchor {
                if point.isAdjacent(to: paths[index-1]) {
                    continue
                } else {
                    
                    let currentK = point.x - point.y
                    let previousK = paths[index-1].x - paths[index-1].y
                    
                    var xOffset = paths[index-1].x - previousAnchor.x
                    var yOffset = paths[index-1].y - previousAnchor.y
                    
                    if currentK > previousK {
                        //horizontal
                        xOffset += 1
                    } else {
                        //vertical
                        yOffset += 1
                    }
                    
                    if xOffset + yOffset > 0 {
                        if xOffset == 0 {
                            //add
                            chunks.append(.add(previousAnchor.x, NSMakeRange(previousAnchor.y, yOffset)))
                        } else if yOffset == 0 {
                            //delete
                            chunks.append(.delete(NSMakeRange(previousAnchor.x, xOffset), previousAnchor.y))
                        } else {
                            //change
                            chunks.append(.change(NSMakeRange(previousAnchor.x, xOffset), NSMakeRange(previousAnchor.y, yOffset)))
                        }
                        
                    }
                    
                    
                    
                    prevAnchor = point
                }
            } else {
                prevAnchor = point
            }
        }
        
        //add final adjacent paths with prevAnchor
        
        if prevAnchor != paths.last {
            if let prevAnchor = prevAnchor, let last = paths.last {
                let xOffset = last.x - prevAnchor.x
                let yOffset = last.y - prevAnchor.y
                
                if xOffset == 0 {
                    //add
                    chunks.append(.add(prevAnchor.x, NSMakeRange(prevAnchor.y, yOffset)))
                } else if yOffset == 0 {
                    //delete
                    chunks.append(.delete(NSMakeRange(prevAnchor.x, xOffset), prevAnchor.y))
                } else {
                    //change
                    chunks.append(.change(NSMakeRange(prevAnchor.x, xOffset), NSMakeRange(prevAnchor.y, yOffset)))
                }
            }
        }
        
        return chunks
    }
    
    ///Chunk index기반의 editscript 작성
    func parseTwoStrings() -> [DiffBlock] {
        fillPath()
        //merge adjacent blocks
        return getPath()
    }
    
    ///Real index기반의 editscript 작성
    func parseWithoutLineInterpreted() -> [DiffBlock] {
        return parseTwoStrings().map {
            
            switch $0 {
            case .add(let index, let range):
                let transformedIndex = realIndex(from: index, inA: true)
                let transformedRange = realRange(from: range, inA: false)
                
                return DiffBlock.add(transformedIndex, transformedRange)
            case .delete(let range, _):
                let transformedRange = realRange(from: range, inA: true)
                
                return DiffBlock.delete(transformedRange, 0)
            case .change(let aRange, let bRange):
                let transformedARange = realRange(from: aRange, inA: true)
                let transformedBRange = realRange(from: bRange, inA: false)
                
                return DiffBlock.change(transformedARange, transformedBRange)
            case .empty: return .empty
            }
        }
    }
}
