//
//  LiveViewController.swift
//  YoutubeClone
//
//  Created by Nguyễn Đức Tân on 10/07/2022.
//

import UIKit
import AgoraRtcKit
import SocketIO
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class LiveViewController: BaseViewController {
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var videoContainer: AGEVideoContainer!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var viewersButton: UIButton!
    @IBOutlet weak var productCollectionView: UICollectionView!
    @IBOutlet weak var broadcasterActionsView: UIStackView!
    @IBOutlet weak var chatView: UIView!
    @IBOutlet weak var videoMuteButton: UIButton!
    @IBOutlet weak var audioMuteButton: UIButton!
    @IBOutlet weak var thumbnail: UIImageView!
    
    var roomInfo: Room?
    var isConnecting = false
    var mSocket = SocketHandler.sharedInstance.getSocket()
    var localView: UIView!
    var agoraKit: AgoraRtcEngineKit?
    var chatGradientLayer: CAGradientLayer!
    var chatMessage: [ChatMessage] = []
    var liveProduct: [LiveProduct] = []
    var liveTimer: Timer?
    var startTime: Int64 = 0
    var myUserName: String = "viewer"
    var myChannelName: String = ""
    var myUid: UInt?
    var videoViews: [UInt:VideoView] = [:]
    
    let db = Firestore.firestore()

    private var isMutedVideo = true {
        didSet {
            // mute local video
            agoraKit?.enableLocalVideo(isMutedVideo)
            videoMuteButton.isSelected = isMutedVideo
        }
    }
    
    private var isMutedAudio = true {
        didSet {
            // mute local audio
            agoraKit?.enableLocalAudio(isMutedAudio)
            audioMuteButton.isSelected = isMutedAudio
        }
    }
    
    private var isSwitchCamera = false {
        didSet {
            agoraKit?.switchCamera()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let userInfo = DataLocal.getData(forKey: AppKey.userInfo) as? User {
            myUserName = userInfo.email ?? "viewer"
            myUid = userInfo.agoraUID ?? 0
        }
        myChannelName = roomInfo?.name ?? ""
        liveProduct = roomInfo?.liveProduct ?? []

        initView()
        initializeAndJoinChannel()
        createGradientLayer()
        chatTableView.delegate = self
        chatTableView.dataSource = self
        productCollectionView.delegate = self
        productCollectionView.dataSource = self
        chatTableView.registerCellByNib(ChatTableViewCell.self)
        chatTableView.registerCellByNib(MyChatTableViewCell.self)
        productCollectionView.registerCellByNib(AddProductCollectionViewCell.self)
        productCollectionView.registerCellByNib(LiveProductCollectionViewCell.self)
        
        chatTableView.estimatedRowHeight = 88.0
        chatTableView.rowHeight = UITableView.automaticDimension
        setupSocketChat()
        var param = Parameter()
        param.addParam("channel", value: myChannelName)
        param.addParam("role", value: "audience")
        param.addParam("tokenType", value: "uid")
        param.addParam("UID", value: myUid)
        GetAgoraTokenAPI(params: param).send {[weak self] token, error in
            guard let self = self,
                  let rtcToken = token?.rtcToken else {
                      return
                  }
            self.joinStream(token: rtcToken)
        }
    }

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func setupSocketChat() {
        mSocket.on("message") { [weak self] (dataArray, ack) -> Void in
            do {
                guard let self = self else {
                    return
                }
                let dat = try JSONSerialization.data(withJSONObject: dataArray)
                let res = try JSONDecoder().decode([ChatMessage].self,from: dat)
                self.chatMessage.append(res[0])
                self.chatTableView.reloadData()
                self.chatTableView.scrollToBottom()
            }
            catch {
                print(error)
            }
        }
        
        mSocket.on("product") { [weak self] (dataArray, ack) -> Void in
            do {
                let dat = try JSONSerialization.data(withJSONObject: dataArray)
                let res = try JSONDecoder().decode([LiveProduct].self,from: dat)
                if !(self?.liveProduct.contains(where: { product in
                    product.productId == res[0].productId
                }) ?? true) {
                    self?.liveProduct.append(res[0])
                    self?.productCollectionView.reloadData()
                }
            }
            catch {
                print(error)
            }
        }
        
        mSocket.on("remove_product") { [weak self] (dataArray, ack) -> Void in
            do {
                let dat = try JSONSerialization.data(withJSONObject: dataArray)
                let res = try JSONDecoder().decode([LiveProduct].self,from: dat)
                guard let self = self else {
                    return
                }
                if let index = self.liveProduct.firstIndex { product in
                    return product.productId == res[0].productId
                } {
                    self.liveProduct.remove(at: index)
                }
                self.productCollectionView.reloadData()
            }
            catch {
                print(error)
            }
        }
        
        mSocket.on("roomUsers") { [weak self] (dataArray, ack) -> Void in
            do {
                let dat = try JSONSerialization.data(withJSONObject: dataArray)
                let res = try JSONDecoder().decode([RoomInfo].self,from: dat)
                self?.viewersButton.setTitle("\(Util.formatTokens(amount: ((res[0].users?.count ?? 1) - 1)))", for: .normal)
            }
            catch {
                print(error)
            }
        }
        
        mSocket.on("invite") { [weak self] (dataArray, ack) -> Void in
            do {
                let dat = try JSONSerialization.data(withJSONObject: dataArray)
                let res = try JSONDecoder().decode([InvitationModel].self,from: dat)
                if res[0].userId == Auth.auth().currentUser?.uid {
                    self?.showAlert(title: "Invitation",
                                    message: "You have been invited to join stream!!!",
                                    buttonTitles: ["Cancel", "Join now"],
                                    highlightedButtonIndex: 1, completion: { index in
                        if index == 1 {
                            self?.joinStreamAsHost()
                        }
                    })
                }
            }
            catch {
                print(error)
            }
        }
                
        mSocket.on("kick") { [weak self] (dataArray, ack) -> Void in
            do {
                let dat = try JSONSerialization.data(withJSONObject: dataArray)
                let res = try JSONDecoder().decode([InvitationModel].self,from: dat)
                if res[0].userId == Auth.auth().currentUser?.uid {
                    self?.joinStreamAsAudience()
                }
            }
            catch {
                print(error)
            }
        }
        
        mSocket.on("end") { [weak self] (dataArray, ack) -> Void in
            self?.leaveChannel()
        }
        
        self.mSocket.emit("joinRoom", ["username": self.myUserName,
                                       "room": self.myChannelName,
                                       "userId": Auth.auth().currentUser?.uid,
                                       "agoraId": self.myUid
                                      ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        localView.frame = self.videoContainer.bounds
    }
    
    @IBAction func showChatAction(_ sender: UIButton) {
        chatView.isHidden.toggle()
    }
    
    @IBAction func leaveCohostMode(_ sender: UIButton) {
        joinStreamAsAudience()
    }
    
    @IBAction func donateAction(_ sender: UIButton) {
        
    }
    
    func joinStreamAsHost() {
        guard let myUid = myUid else {
            return
        }
        let options: AgoraClientRoleOptions = AgoraClientRoleOptions()
        options.audienceLatencyLevel = AgoraAudienceLatencyLevelType.lowLatency
        agoraKit?.setClientRole(.broadcaster, options: options)
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = myUid
        videoCanvas.renderMode = .hidden
        let localVideo = Bundle.loadVideoView(type: .local, audioOnly: false)
        videoCanvas.view = localVideo.videoView
        agoraKit?.setupLocalVideo(videoCanvas)
        videoViews[myUid] = localVideo
        videoContainer.layoutStream(views: self.sortedViews())
        agoraKit?.setDefaultAudioRouteToSpeakerphone(true)
        
        broadcasterActionsView.isHidden = false
    }
    
    func joinStreamAsAudience() {
        guard let myUid = myUid else {
            return
        }
        let options: AgoraClientRoleOptions = AgoraClientRoleOptions()
        options.audienceLatencyLevel = AgoraAudienceLatencyLevelType.lowLatency
        agoraKit?.setClientRole(.audience, options: options)
        self.videoViews.removeValue(forKey: myUid)
        self.videoContainer.layoutStream(views: sortedViews())
        self.videoContainer.reload(level: 0, animated: true)
        
        broadcasterActionsView.isHidden = true
    }
    
    @IBAction func rolateCameraAction(_ sender: UIButton) {
        isSwitchCamera.toggle()
    }
    
    @IBAction func muteVideoAction(_ sender: UIButton) {
        isMutedVideo.toggle()
    }
    
    @IBAction func muteAudioAction(_ sender: UIButton) {
        isMutedAudio.toggle()
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        leaveChannel()
    }
    
    func leaveChannel() {
        agoraKit?.leaveChannel(nil)
        mSocket.emit("disconnect", with: [])
        mSocket.off("message")
        mSocket.off("product")
        mSocket.off("remove_product")
        mSocket.off("roomUsers")
        mSocket.off("invite")
        mSocket.off("kick")
        mSocket.off("end")

        isConnecting = false
        AgoraRtcEngineKit.destroy()
        self.dismiss(animated: true)
    }
    
    @IBAction func sendMessageAction(_ sender: UIButton) {
        self.mSocket.emit("chatMessage", ["msg": messageTextField.text])
        messageTextField.text = ""
    }
    
    func initView() {
        localView = UIView()
        self.videoContainer.addSubview(localView)
    }
    
    func stopLiveTimer() {
        //        streamerLiveController.media.endedAt = Util.currentTime()
        liveTimer?.invalidate()
        liveTimer = nil
    }
    
    func createGradientLayer() {
        chatGradientLayer = CAGradientLayer()
        chatGradientLayer.frame = CGRect(x: 0,
                                         y: 0,
                                         width: chatTableView.frame.width,
                                         height: chatTableView.frame.height)
        chatGradientLayer.locations = [0.0, 0.7]
        chatGradientLayer.colors = [UIColor.black.withAlphaComponent(0.1).cgColor,
                                UIColor.clear]
        chatGradientLayer.cornerRadius = 5
        let backgroundView = UIView(frame: chatTableView.bounds)
        backgroundView.cornerRadiusX = 5
        backgroundView.layer.insertSublayer(chatGradientLayer, at: 0)
        
        chatTableView.backgroundView = backgroundView
    }
    
    func initializeAndJoinChannel() {
        thumbnail.image = UIImage(named: "broadcaster")
        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: AppConfig.agoraAppID, delegate: self)
        agoraKit?.enableVideo()

        broadcasterActionsView.isHidden = true
        agoraKit?.setChannelProfile(.liveBroadcasting)
        let options: AgoraClientRoleOptions = AgoraClientRoleOptions()
        options.audienceLatencyLevel = AgoraAudienceLatencyLevelType.lowLatency
        agoraKit?.setClientRole(.audience, options: options)
    }
    
    func joinStream(token: String) {
        guard let myUid = myUid else {
            return
        }
        agoraKit?.joinChannel(byToken: token,
                              channelId: myChannelName,
                              info: nil,
                              uid: myUid,
                              joinSuccess: { (channel, uid, elapsed) in
            print("join stream")
        })
    }
    
    func sortedViews() -> [VideoView] {
        return Array(videoViews.values).sorted(by: { $0.uid < $1.uid })
    }
}

extension LiveViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        liveProduct.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueCell(LiveProductCollectionViewCell.self, forIndexPath: indexPath) else {
            return UICollectionViewCell()
        }
        cell.indexPath = indexPath
        cell.liveProduct = liveProduct[indexPath.item]
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
}


extension LiveViewController: AgoraRtcEngineDelegate {
    // This callback is triggered when a remote host joins the channel
//    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
//        let videoCanvas = AgoraRtcVideoCanvas()
//        videoCanvas.uid = uid
//        videoCanvas.renderMode = .hidden
//        videoCanvas.view = localView
//        agoraKit?.setupRemoteVideo(videoCanvas)
//        placeholderImageView.isHidden = true
//    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        
        let remoteVideo = Bundle.loadVideoView(type: .remote, audioOnly: false)
        remoteVideo.uid = uid
        
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        // the view to be binded
        videoCanvas.view = remoteVideo.videoView
        videoCanvas.renderMode = .hidden
        agoraKit?.setupRemoteVideo(videoCanvas)
        
        self.videoViews[uid] = remoteVideo
        self.videoContainer.layoutStream(views: sortedViews())
        self.videoContainer.reload(level: 0, animated: true)
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        // the view to be binded
        videoCanvas.view = nil
        videoCanvas.renderMode = .hidden
        agoraKit?.setupRemoteVideo(videoCanvas)
        
        //remove remote audio view
        self.videoViews.removeValue(forKey: uid)
        self.videoContainer.layoutStream(views: sortedViews())
        self.videoContainer.reload(level: 0, animated: true)
    }
    
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurError errorCode: AgoraErrorCode) {
        print(errorCode.rawValue)
    }
}


extension LiveViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessage.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if chatMessage[indexPath.row].username == myUserName {
            guard let cell = tableView.dequeueCell(MyChatTableViewCell.self, forIndexPath: indexPath) else {
                return UITableViewCell()
            }
            cell.data = chatMessage[indexPath.row]
            return cell
        } else {
            guard let cell = tableView.dequeueCell(ChatTableViewCell.self, forIndexPath: indexPath) else {
                return UITableViewCell()
            }
            cell.data = chatMessage[indexPath.row]
            return cell
        }
    }
}

extension LiveViewController: LiveProductCollectionViewCellDelegate {
    func didSelect(at indexPath: IndexPath) {
        guard let userId = roomInfo?.roomOwnerId else {
            return
        }
        let vc = Cart4View()
        vc.delegate = self
        vc.product = liveProduct[indexPath.row]
        db.collection("users").document(userId).getDocument { document, error in
            if let error = error {
                UIAlertController.show(message: error.localizedDescription, title: nil)
                return
            }
            let user = User(dictionary: document?.data() ?? [:])
            vc.shopToken = user.shopifyToken
            self.present(vc, animated: true, completion: nil)
        }
    }
}

extension LiveViewController: Cart4ViewDelegate {
    func goToCheckout() {
        let vc = CartViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
}

struct InvitationModel: Codable {
    let userId: String?
    
    enum CodingKeys: String, CodingKey {
        case userId
    }
}

struct ChatMessageModel: Codable {
    let message: [ChatMessage]
    
    enum CodingKeys: String, CodingKey {
        case message
    }
}

struct ChatMessage: Codable {
    let username: String?
    let text: String?
    let time: String?
    
    enum CodingKeys: String, CodingKey {
        case username
        case text
        case time
    }
}

struct RoomInfo: Codable {
    let room: String?
    let users: [RoomUserInfo]?
    
    enum CodingKeys: String, CodingKey {
        case room
        case users
    }
}

struct RoomUserInfo: Codable {
    let id: String?
    let room: String?
    let username: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case room
        case username
    }
}
