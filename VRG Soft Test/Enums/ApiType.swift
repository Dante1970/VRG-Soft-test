//
//  ApiType.swift
//  VRG Soft Test
//
//  Created by Сергей Белоусов on 21.05.2023.
//

enum ApiType {
    case mostEmailed(days: Days)
    case mostShared(days: Days)
    case mostViewed(days: Days)
    
    enum Days {
        case lastDay
        case lastWeek
        case lastMonth
        
        var value: Int {
            switch self {
            case .lastDay: return 1
            case .lastWeek: return 7
            case .lastMonth: return 30
            }
        }
    }
    
    var section: String {
        switch self {
        case .mostEmailed: return "emailed"
        case .mostShared: return "shared"
        case .mostViewed: return "viewed"
        }
    }
    
    var days: Days {
        switch self {
        case .mostEmailed(let days): return days
        case .mostShared(let days): return days
        case .mostViewed(let days): return days
        }
    }
}
