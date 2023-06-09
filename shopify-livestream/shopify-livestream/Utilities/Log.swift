//
//  Log.swift
//  CoreApp
//
//  Created by Nguyễn Đức Tân on 28/04/2022.
//

import Foundation

public func DLog(_ message: @autoclosure () -> String,
                 filename: String = #file,
                 function: String = #function, line: Int = #line) {
    #if DEV
    print("[\(URL(string: filename)?.lastPathComponent ?? filename):\(line)]",
        "\(function)",
        message(),
        separator: " - ")
    #else
    #endif
}
