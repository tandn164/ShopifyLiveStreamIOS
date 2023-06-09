//
//  AppUtil.swift
//  shopify-livestream-user
//
//  Created by Nguyễn Đức Tân on 09/08/2022.
//

import UIKit
class Util {

    static func formatNumber(_ amount: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value: amount))?.replacingOccurrences(of: ".", with: ",") ?? "0"
    }

    static func formatDuration(_ duration: Int) -> String {
        var remain = duration / 1000
        let seconds = remain % 60
        remain /= 60
        let minutes = remain % 60
        let hours = remain / 60
        var timeString = ""
        if hours > 0 {
            timeString = String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            timeString = String(format: "%02d:%02d", minutes, seconds)
        }
        return timeString
    }
    
    public static func currentTime() -> Int64 {
        let time = Date().timeIntervalSince1970
        return Int64(time * 1000)
    }
    
    static func formatTokens(amount: Int) -> String {
        if amount >= 1000000 {
            let m = Float(amount) / 1000000
            if m < 10 {
                return String(format: "%.2fM", m)
            } else {
                return String(format: "\(Int(m))M")
            }
        } else if amount >= 1000 {
            let k = Float(amount) / 1000
            if k < 10 {
                return String(format: "%.2fK", k)
            } else {
                return String(format: "\(Int(k))K")
            }
        } else {
            return "\(amount)"
        }
    }
}
