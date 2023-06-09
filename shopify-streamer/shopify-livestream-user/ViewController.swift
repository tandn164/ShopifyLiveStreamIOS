//
//  ViewController.swift
//  shopify-livestream-user
//
//  Created by Nguyễn Đức Tân on 18/04/2022.
//

import UIKit
import AgoraRtcKit

class ViewController: UIViewController {
    var remoteView: UIView!
    var agoraKit: AgoraRtcEngineKit?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        initializeAndJoinChannel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        remoteView.frame = self.view.bounds
    }
    
    override func viewDidDisappear(_ animated: Bool) {
           super.viewDidDisappear(animated)
           agoraKit?.leaveChannel(nil)
           AgoraRtcEngineKit.destroy()
     }
    
    func initView() {
        remoteView = UIView()
        self.view.addSubview(remoteView)
    }
    
    func initializeAndJoinChannel() {
        // Pass in your App ID here
        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: "7ff75b04bc1446b195bc329347fd4fae", delegate: self)
        // For a live streaming scenario, set the channel profile as liveBroadcasting.
        agoraKit?.setChannelProfile(.liveBroadcasting)
        // Set the client role as audience and the latency level as low latency.
        let options: AgoraClientRoleOptions = AgoraClientRoleOptions()
        options.audienceLatencyLevel = AgoraAudienceLatencyLevelType.lowLatency
        agoraKit?.setClientRole(.audience, options: options)
        // Video is disabled by default. You need to call enableVideo to start a video stream.
        agoraKit?.enableVideo()
        
        // Join the channel with a token. Pass in your token and channel name here
        agoraKit?.joinChannel(byToken: "0067ff75b04bc1446b195bc329347fd4faeIAAgndjXIHcKV4aSKabmy1LJ4PyMahNC/dmoUiIKsQxYXgx+f9gAAAAAEAAjgBf2aFVeYgEAAQBnVV5i", channelId: "test", info: nil, uid: 0, joinSuccess: { (channel, uid, elapsed) in
            print("join channel")
        })
    }
}

extension ViewController: AgoraRtcEngineDelegate {
     // This callback is triggered when a remote host joins the channel
     func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
         let videoCanvas = AgoraRtcVideoCanvas()
         videoCanvas.uid = uid
         videoCanvas.renderMode = .hidden
         videoCanvas.view = remoteView
         agoraKit?.setupRemoteVideo(videoCanvas)
     }
 }
