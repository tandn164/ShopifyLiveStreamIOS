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
    @IBOutlet weak var liveTimeLabel: UILabel!
    @IBOutlet weak var viewersButton: UIButton!
    @IBOutlet weak var placeholderImageView: UIImageView!
    @IBOutlet weak var chatView: UIView!
    @IBOutlet weak var videoMuteButton: UIButton!
    @IBOutlet weak var audioMuteButton: UIButton!
    @IBOutlet weak var beautyEffectButton: UIButton!
    @IBOutlet weak var productCollectionView: UICollectionView!
    
    @IBOutlet weak var groupInviteView: GroupInviteView!
    @IBOutlet weak var interactorView: UIView!
    @IBOutlet weak var prepareView: UIView!
    @IBOutlet weak var inviteUserBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var roomNameTextField: UITextField!

    @IBOutlet weak var viewerView: UIView!
    var videoViews: [UInt:VideoView] = [:]
    
    var mSocket = SocketHandler.sharedInstance.getSocket()
    var localView: UIView!
    var agoraKit: AgoraRtcEngineKit?
    var chatGradientLayer: CAGradientLayer!
    var chatMessage: [ChatMessage] = []
    var liveProduct: [LiveProduct] = []
    var listUser: [Viewer] = []
    
    var myUserName: String = "store"
    var myChannelName: String = ""
    var myUid: UInt?
    var shopId: String = ""
    
    var liveTimer: Timer?
    var startTime: Int64 = 0
    var isConnecting = false
    
    let db = Firestore.firestore()
    var roomId: String?

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
            myUserName = userInfo.storeName ?? "store"
            myUid = userInfo.agoraUID ?? 0
            shopId = Auth.auth().currentUser?.uid ?? ""
        }
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
        viewerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showListUserAction)))
        groupInviteView.delegate = self
    }
    
    func showInviteUserView() {
        groupInviteView.listUser = listUser
        UIView.animate(withDuration: 0.35, animations: { [weak self] in
            guard let this = self else { return }
            this.inviteUserBottomConstraint.constant = 0
            this.view.layoutIfNeeded()
        })
    }

    func hideInviteUserView() {
        groupInviteView.listUser = listUser
        UIView.animate(withDuration: 0.35, animations: { [weak self] in
            guard let this = self else { return }
            this.inviteUserBottomConstraint.constant = -this.view.frame.height
            this.view.layoutIfNeeded()
        })
    }
    
    func setupSocketChat() {
        mSocket.on("message") { [weak self] (dataArray, ack) -> Void in
            do {
                let dat = try JSONSerialization.data(withJSONObject: dataArray)
                let res = try JSONDecoder().decode([ChatMessage].self,from: dat)
                self?.chatMessage.append(res[0])
                self?.chatTableView.reloadData()
                self?.chatTableView.scrollToBottom()
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
                if let roomId = self?.roomId {
                    self?.db.collection("rooms").document(roomId).setData([ "liveProduct": self?.liveProduct.map({ liveProduct in
                        return liveProduct.dictionary
                    })], merge: true)
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
                if let index = self.liveProduct.firstIndex(where: { product in
                    return product.productId == res[0].productId
                }) {
                    self.liveProduct.remove(at: index)
                }
                self.productCollectionView.reloadData()
               
                if let roomId = self.roomId {
                    self.db.collection("rooms").document(roomId).setData([ "liveProduct": self.liveProduct.map({ liveProduct in
                        return liveProduct.dictionary
                    })], merge: true)
                }
            }
            catch {
                print(error)
            }
        }
        
        
        mSocket.on("roomUsers") { [weak self] (dataArray, ack) -> Void in
            do {
                let dat = try JSONSerialization.data(withJSONObject: dataArray)
                let res = try JSONDecoder().decode([RoomInfo].self,from: dat)
                guard let self = self else {
                    return
                }
                self.listUser = res[0].users ?? []
                
                if let index = res[0].users?.firstIndex(where: { viewer in
                    viewer.userId == Auth.auth().currentUser?.uid
                }) {
                    self.listUser.remove(at: index)
                }
                
                self.viewersButton.setTitle("\(Util.formatTokens(amount: self.listUser.count))", for: .normal)
                
                if let roomId = self.roomId {
                    self.db.collection("rooms").document(roomId).setData([ "viewers": self.listUser.map({ user in
                        return user.dictionary
                    })], merge: true)
                }
            }
            catch {
                print(error)
            }
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
    
    func leaveChannel() {
        agoraKit?.setupLocalVideo(nil)
        agoraKit?.leaveChannel(nil)
        agoraKit?.stopPreview()
        mSocket.emit("endStream", with: [])
        mSocket.emit("disconnect", with: [])
        mSocket.off("message")
        mSocket.off("product")
        mSocket.off("remove_product")
        mSocket.off("roomUsers")
        isConnecting = false
        AgoraRtcEngineKit.destroy()
        stopLiveTimer()
        self.dismiss(animated: true)
    }
    
    @IBAction func sendMessageAction(_ sender: UIButton) {
        self.mSocket.emit("chatMessage", ["msg": messageTextField.text])
        messageTextField.text = ""
    }
    
    @IBAction func doSwitchCameraPressed(_ sender: UIButton) {
        isSwitchCamera.toggle()
    }
    
    @IBAction func doBeautyPressed(_ sender: UIButton) {
        chatView.isHidden.toggle()
    }
    
    @IBAction func doMuteVideoPressed(_ sender: UIButton) {
        isMutedVideo.toggle()
    }
    
    @IBAction func doMuteAudioPressed(_ sender: UIButton) {
        isMutedAudio.toggle()
    }
    
    @IBAction func doLeavePressed(_ sender: UIButton) {
        leaveChannel()
    }
    
    @IBAction func startLive(_ sender: UIButton) {
        guard let channelName = roomNameTextField.text, !channelName.isEmpty else {
            UIAlertController.show(message: "Please enter live stream name", title: nil)
            return
        }
        myChannelName = channelName
        prepareView.isHidden = true
        interactorView.isHidden = false
        setupSocketChat()
        
        var param = Parameter()
        param.addParam("channel", value: myChannelName)
        param.addParam("role", value: "publisher")
        param.addParam("tokenType", value: "uid")
        param.addParam("UID", value: myUid)
        let getTokenAPI = GetRTCTokenAPI(params: param)
        getTokenAPI.send { [weak self] token, error in
            guard let self = self,
                  let rtcToken = token?.rtcToken else {
                      return
                  }
            print(rtcToken)
            self.startLiveTime()
            self.startStream(token: rtcToken)
            let room = Room(name: self.myChannelName,
                            rtcToken: rtcToken,
                            startTime: Util.currentTime(),
                            endTime: 0,
                            roomOwnerId: Auth.auth().currentUser?.uid,
                            thumb: nil)
            
            var ref: DocumentReference? = nil
            ref = self.db.collection("rooms").addDocument(data: room.dictionary) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    self.roomId = ref!.documentID
                }
            }
        }
    }
    
    @objc func showListUserAction() {
        showInviteUserView()
    }
    
    func startLiveTime() {
        startTime = Util.currentTime()
        liveTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateLiveTime), userInfo: nil, repeats: true)
    }
    
    func stopLiveTimer() {
        liveTimer?.invalidate()
        liveTimer = nil
        guard let roomId = roomId else {
            return
        }
        let ref = db.collection("rooms").document(roomId)

        ref.updateData([
            "endTime": Util.currentTime() - startTime
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    @objc func updateLiveTime() {
        liveTimeLabel.text = Util.formatDuration(Int(Util.currentTime() - startTime))
    }
    
    func initView() {
        localView = UIView()
        self.videoContainer.addSubview(localView)
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
        guard let myUid = myUid else {
            return
        }
        
        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: AppConfig.agoraAppID, delegate: self)
        agoraKit?.enableVideo()
        agoraKit?.startPreview()

        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = myUid
        videoCanvas.renderMode = .hidden
        let localVideo = Bundle.loadVideoView(type: .local, audioOnly: false)
        videoCanvas.view = localVideo.videoView
        agoraKit?.setupLocalVideo(videoCanvas)
        videoViews[myUid] = localVideo
        videoContainer.layoutStream(views: self.sortedViews())
        
        // Set audio route to speaker
        agoraKit?.setDefaultAudioRouteToSpeakerphone(true)
    }
    
    func startStream(token: String) {
        guard let myUid = myUid else {
            return
        }
        
        agoraKit?.joinChannel(byToken: token,
                              channelId: myChannelName,
                              info: nil,
                              uid: myUid,
                              joinSuccess: { (channel, uid, elapsed) in
            self.placeholderImageView.isHidden = true
            print("start stream")
        })
    }
    
    func sortedViews() -> [VideoView] {
        return Array(videoViews.values).sorted(by: { $0.uid < $1.uid })
    }
}

extension LiveViewController: AgoraRtcEngineDelegate {
    func rtcEngine(_ engine: AgoraRtcEngineKit, remoteAudioStateChangedOfUid uid: UInt, state: AgoraAudioRemoteState, reason: AgoraAudioRemoteStateReason, elapsed: Int) {
    }
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
        
        
        if let index = listUser.firstIndex(where: { viewer in
            return viewer.agoraId ?? 0 == uid
        }) {
            listUser[index].isInvited = true
        }
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
        
        if let index = listUser.firstIndex(where: { viewer in
            return viewer.agoraId ?? 0 == uid
        }) {
            listUser[index].isInvited = false
        }
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

extension LiveViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        liveProduct.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == liveProduct.count {
            guard let cell = collectionView.dequeueCell(AddProductCollectionViewCell.self, forIndexPath: indexPath) else {
                return UICollectionViewCell()
            }
            return cell
        }
        guard let cell = collectionView.dequeueCell(LiveProductCollectionViewCell.self, forIndexPath: indexPath) else {
            return UICollectionViewCell()
        }
        cell.delegate = self
        cell.indexPath = indexPath
        cell.liveProduct = liveProduct[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == liveProduct.count {
            let vc = Search1View()
            vc.delegate = self
            present(vc, animated: true, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
}

extension LiveViewController: LiveProductCollectionViewCellDelegate {
    func removeProduct(at indexPath: IndexPath) {
        mSocket.emit("removeProduct", ["productId": liveProduct[indexPath.row].productId])
    }
}

extension LiveViewController: SearchDelegate {
    func showProduct(with product: Product?) {
        guard let product = product else {
            return
        }
        
        mSocket.emit("showProduct", ["shopId": shopId,
                                     "variantId": product.variants?.first?.id,
                                     "shopName": myUserName,
                                     "productId": product.id,
                                     "productTitle": product.title,
                                     "productThumbnail": product.image?.src,
                                     "productPrice": Int(product.variants?.first?.price ?? "0"),
                                     "productOriginPrice": Int(product.variants?.first?.compare_at_price ?? "0"),
                                     "productCategory": product.category
                                    ])
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
    let users: [Viewer]?
    
    enum CodingKeys: String, CodingKey {
        case room
        case users
    }
}

extension LiveViewController: GroupInviteViewDelegate {
    func inviteUser(user: Viewer) {
        mSocket.emit("inviteUser", ["userId": user.userId])
    }
    
    func kickUser(user: Viewer) {
        mSocket.emit("kickUser", ["userId": user.userId])
    }
    
    func closeList() {
        hideInviteUserView()
    }
}
