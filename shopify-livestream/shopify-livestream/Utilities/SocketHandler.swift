//
//  SocketHandler.swift
//  shopify-livestream
//
//  Created by Nguyễn Đức Tân on 11/07/2022.
//

import Foundation
import SocketIO

class SocketHandler: NSObject {
    static let sharedInstance = SocketHandler()
    let socket = SocketManager(socketURL: URL(string: "https://c1cb-42-112-171-236.ap.ngrok.io")!, config: [.log(true), .compress])
    var mSocket: SocketIOClient!
    var delegate: BaseViewController?

    override init() {
        super.init()
        mSocket = socket.defaultSocket
    }

    func getSocket() -> SocketIOClient {
        return mSocket
    }

    func establishConnection() {
        mSocket.connect()
    }

    func closeConnection() {
        mSocket.disconnect()
    }
}
