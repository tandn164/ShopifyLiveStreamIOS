//
//  StatisticInfo.swift
//  shopify-livestream
//
//  Created by Nguyễn Đức Tân on 05/08/2022.
//


import Foundation
import AgoraRtcKit

struct StatisticsInfo {
    struct LocalInfo {
        var channelStats = AgoraChannelStats()
        var videoStats = AgoraRtcLocalVideoStats()
        var audioStats = AgoraRtcLocalAudioStats()
    }
    
    struct RemoteInfo {
        var videoStats = AgoraRtcRemoteVideoStats()
        var audioStats = AgoraRtcRemoteAudioStats()
    }
    
    enum StatisticsType {
        case local(LocalInfo), remote(RemoteInfo)
        
        var isLocal: Bool {
            switch self {
            case .local:  return true
            case .remote: return false
            }
        }
    }
    
    var dimension = CGSize.zero
    var fps:UInt = 0
    
    var type: StatisticsType
    
    init(type: StatisticsType) {
        self.type = type
    }
    
    mutating func updateChannelStats(_ stats: AgoraChannelStats) {
        guard self.type.isLocal else {
            return
        }
        switch type {
        case .local(let info):
            var new = info
            new.channelStats = stats
            self.type = .local(new)
        default:
            break
        }
    }
    
    mutating func updateLocalVideoStats(_ stats: AgoraRtcLocalVideoStats) {
        guard self.type.isLocal else {
            return
        }
        switch type {
        case .local(let info):
            var new = info
            new.videoStats = stats
            self.type = .local(new)
        default:
            break
        }
        dimension = CGSize(width: Int(stats.encodedFrameWidth), height: Int(stats.encodedFrameHeight))
        fps = stats.sentFrameRate
    }
    
    mutating func updateLocalAudioStats(_ stats: AgoraRtcLocalAudioStats) {
        guard self.type.isLocal else {
            return
        }
        switch type {
        case .local(let info):
            var new = info
            new.audioStats = stats
            self.type = .local(new)
        default:
            break
        }
    }
    
    mutating func updateVideoStats(_ stats: AgoraRtcRemoteVideoStats) {
        switch type {
        case .remote(let info):
            var new = info
            new.videoStats = stats
            dimension = CGSize(width: Int(stats.width), height: Int(stats.height))
            fps = stats.rendererOutputFrameRate
            self.type = .remote(new)
        default:
            break
        }
    }
    
    mutating func updateAudioStats(_ stats: AgoraRtcRemoteAudioStats) {
        switch type {
        case .remote(let info):
            var new = info
            new.audioStats = stats
            self.type = .remote(new)
        default:
            break
        }
    }
    
    func description(audioOnly:Bool) -> String {
        var full: String
        switch type {
        case .local(let info):  full = localDescription(info: info, audioOnly: audioOnly)
        case .remote(let info): full = remoteDescription(info: info, audioOnly: audioOnly)
        }
        return full
    }
    
    func localDescription(info: LocalInfo, audioOnly: Bool) -> String {
        
        let dimensionFps = "\(Int(dimension.width))×\(Int(dimension.height)),\(fps)fps"
        
        let lastmile = "LM Delay: \(info.channelStats.lastmileDelay)ms"
        let videoSend = "VSend: \(info.videoStats.sentBitrate)kbps"
        let audioSend = "ASend: \(info.audioStats.sentBitrate)kbps"
        let cpu = "CPU: \(info.channelStats.cpuAppUsage)%/\(info.channelStats.cpuTotalUsage)%"
        let vSendLoss = "VSend Loss: \(info.videoStats.txPacketLossRate)%"
        let aSendLoss = "ASend Loss: \(info.audioStats.txPacketLossRate)%"
        
        if(audioOnly) {
            return [lastmile,audioSend,cpu,aSendLoss].joined(separator: "\n")
        }
        return [dimensionFps,lastmile,videoSend,audioSend,cpu,vSendLoss,aSendLoss].joined(separator: "\n")
    }
    
    func remoteDescription(info: RemoteInfo, audioOnly: Bool) -> String {
        let dimensionFpsBit = "\(Int(dimension.width))×\(Int(dimension.height)), \(fps)fps"
        
        var audioQuality: AgoraNetworkQuality
        if let quality = AgoraNetworkQuality(rawValue: info.audioStats.quality) {
            audioQuality = quality
        } else {
            audioQuality = AgoraNetworkQuality.unknown
        }
        
        let videoRecv = "VRecv: \(info.videoStats.receivedBitrate)kbps"
        let audioRecv = "ARecv: \(info.audioStats.receivedBitrate)kbps"
        
        let videoLoss = "VLoss: \(info.videoStats.packetLossRate)%"
        let audioLoss = "ALoss: \(info.audioStats.audioLossRate)%"
        let aquality = "AQuality: \(audioQuality.description())"
        if(audioOnly) {
            return [audioRecv,audioLoss,aquality].joined(separator: "\n")
        }
        return [dimensionFpsBit,videoRecv,audioRecv,videoLoss,audioLoss,aquality].joined(separator: "\n")
    }
}

extension AgoraErrorCode {
    var description: String {
        var text: String
        switch self {
        case .joinChannelRejected:  text = "join channel rejected"
        case .leaveChannelRejected: text = "leave channel rejected"
        case .invalidAppId:         text = "invalid app id"
        case .invalidToken:         text = "invalid token"
        case .invalidChannelId:     text = "invalid channel id"
        default:                    text = "\(self.rawValue)"
        }
        return text
    }
}

extension AgoraWarningCode {
    var description: String {
        var text: String
        switch self {
        case .invalidView: text = "invalid view"
        default:           text = "\(self.rawValue)"
        }
        return text
    }
}

extension AgoraNetworkQuality {
    func description() -> String {
        switch self {
        case .excellent:   return "excel"
        case .good:        return "good"
        case .poor:        return "poor"
        case .bad:         return "bad"
        case .vBad:        return "vBad"
        case .down:        return "down"
        case .unknown:     return "NA"
        case .unsupported: return "unsupported"
        case .detecting:   return "detecting"
        default:           return "NA"
        }
    }
}

extension AgoraVideoOutputOrientationMode {
    func description() -> String {
        switch self {
        case .fixedPortrait: return "fixed portrait".localized
        case .fixedLandscape: return "fixed landscape".localized
        case .adaptative: return "adaptive".localized
        default: return "\(self.rawValue)"
        }
    }
}

extension AgoraClientRole {
    func description() -> String {
        switch self {
        case .broadcaster: return "Broadcaster".localized
        case .audience: return "Audience".localized
        default:
            return "\(self.rawValue)"
        }
    }
}

extension AgoraAudioProfile {
    func description() -> String {
        switch self {
        case .default: return "Default".localized
        case .musicStandard: return "Music Standard".localized
        case .musicStandardStereo: return "Music Standard Stereo".localized
        case .musicHighQuality: return "Music High Quality".localized
        case .musicHighQualityStereo: return "Music High Quality Stereo".localized
        case .speechStandard: return "Speech Standard".localized
        default:
            return "\(self.rawValue)"
        }
    }
    static func allValues() -> [AgoraAudioProfile] {
        return [.default, .speechStandard, .musicStandard, .musicStandardStereo, .musicHighQuality, .musicHighQualityStereo]
    }
}

extension AgoraAudioScenario {
    func description() -> String {
        switch self {
        case .default: return "Default".localized
        case .chatRoomGaming: return "Chat Room Gaming".localized
        case .education: return "Education".localized
        case .gameStreaming: return "Game Streaming".localized
        case .chatRoomEntertainment: return "Chat Room Entertainment".localized
        case .showRoom: return "Show Room".localized
        default:
            return "\(self.rawValue)"
        }
    }
    
    static func allValues() -> [AgoraAudioScenario] {
        return [.default, .chatRoomGaming, .education, .gameStreaming, .chatRoomEntertainment, .showRoom]
    }
}

extension AgoraEncryptionMode {
    func description() -> String {
        switch self {
        case .AES128GCM2: return "AES128GCM2"
        case .AES256GCM2: return "AES256GCM2"
        default:
            return "\(self.rawValue)"
        }
    }
    
    static func allValues() -> [AgoraEncryptionMode] {
        return [.AES128GCM2, .AES256GCM2]
    }
}

extension AgoraAudioVoiceChanger {
    func description() -> String {
        switch self {
        case .voiceChangerOff:return "Off".localized
        case .generalBeautyVoiceFemaleFresh:return "FemaleFresh".localized
        case .generalBeautyVoiceFemaleVitality:return "FemaleVitality".localized
        case .generalBeautyVoiceMaleMagnetic:return "MaleMagnetic".localized
        case .voiceBeautyVigorous:return "Vigorous".localized
        case .voiceBeautyDeep:return "Deep".localized
        case .voiceBeautyMellow:return "Mellow".localized
        case .voiceBeautyFalsetto:return "Falsetto".localized
        case .voiceBeautyFull:return "Full".localized
        case .voiceBeautyClear:return "Clear".localized
        case .voiceBeautyResounding:return "Resounding".localized
        case .voiceBeautyRinging:return "Ringing".localized
        case .voiceBeautySpacial:return "Spacial".localized
        case .voiceChangerEthereal:return "Ethereal".localized
        case .voiceChangerOldMan:return "Old Man".localized
        case .voiceChangerBabyBoy:return "Baby Boy".localized
        case .voiceChangerBabyGirl:return "Baby Girl".localized
        case .voiceChangerZhuBaJie:return "ZhuBaJie".localized
        case .voiceChangerHulk:return "Hulk".localized
        default:
            return "\(self.rawValue)"
        }
    }
}

extension AgoraVoiceBeautifierPreset{
    func description() -> String {
        switch self {
        case .voiceBeautifierOff:return "Off".localized
        case .chatBeautifierFresh:return "FemaleFresh".localized
        case .chatBeautifierMagnetic:return "MaleMagnetic".localized
        case .chatBeautifierVitality:return "FemaleVitality".localized
        case .timbreTransformationVigorous:return "Vigorous".localized
        case .timbreTransformationDeep:return "Deep".localized
        case .timbreTransformationMellow:return "Mellow".localized
        case .timbreTransformationFalsetto:return "Falsetto".localized
        case .timbreTransformationFull:return "Full".localized
        case .timbreTransformationClear:return "Clear".localized
        case .timbreTransformationResounding:return "Resounding".localized
        case .timbreTransformationRinging:return "Ringing".localized
        default:
            return "\(self.rawValue)"
        }
    }
}

extension AgoraAudioReverbPreset {
    func description() -> String {
        switch self {
        case .off:return "Off".localized
        case .fxUncle:return "FxUncle".localized
        case .fxSister:return "FxSister".localized
        case .fxPopular:return "Pop".localized
        case .popular:return "Pop(Old Version)".localized
        case .fxRNB:return "R&B".localized
        case .rnB:return "R&B(Old Version)".localized
        case .rock:return "Rock".localized
        case .hipHop:return "HipHop".localized
        case .fxVocalConcert:return "Vocal Concert".localized
        case .vocalConcert:return "Vocal Concert(Old Version)".localized
        case .fxKTV:return "KTV".localized
        case .KTV:return "KTV(Old Version)".localized
        case .fxStudio:return "Studio".localized
        case .studio:return "Studio(Old Version)".localized
        case .fxPhonograph:return "Phonograph".localized
        case .virtualStereo:return "Virtual Stereo".localized
        default:
            return "\(self.rawValue)"
        }
    }
}

extension AgoraAudioEffectPreset {
    func description() -> String {
        switch self {
        case .audioEffectOff:return "Off".localized
        case .voiceChangerEffectUncle:return "FxUncle".localized
        case .voiceChangerEffectOldMan:return "Old Man".localized
        case .voiceChangerEffectBoy:return "Baby Boy".localized
        case .voiceChangerEffectSister:return "FxSister".localized
        case .voiceChangerEffectGirl:return "Baby Girl".localized
        case .voiceChangerEffectPigKing:return "ZhuBaJie".localized
        case .voiceChangerEffectHulk:return "Hulk".localized
        case .styleTransformationRnB:return "R&B".localized
        case .styleTransformationPopular:return "Pop".localized
        case .roomAcousticsKTV:return "KTV".localized
        case .roomAcousticsVocalConcert:return "Vocal Concert".localized
        case .roomAcousticsStudio:return "Studio".localized
        case .roomAcousticsPhonograph:return "Phonograph".localized
        case .roomAcousticsVirtualStereo:return "Virtual Stereo".localized
        case .roomAcousticsSpacial:return "Spacial".localized
        case .roomAcousticsEthereal:return "Ethereal".localized
        case .roomAcoustics3DVoice:return "3D Voice".localized
        case .pitchCorrection:return "Pitch Correction".localized
        default:
            return "\(self.rawValue)"
        }
    }
}

extension AgoraAudioEqualizationBandFrequency {
    func description() -> String {
        switch self {
        case .band31:     return "31Hz"
        case .band62:     return "62Hz"
        case .band125:     return "125Hz"
        case .band250:     return "250Hz"
        case .band500:     return "500Hz"
        case .band1K:     return "1kHz"
        case .band2K:     return "2kHz"
        case .band4K:     return "4kHz"
        case .band8K:     return "8kHz"
        case .band16K:     return "16kHz"
        @unknown default:
            return "\(self.rawValue)"
        }
    }
}

extension AgoraAudioReverbType {
    func description() -> String {
        switch self {
        case .dryLevel:     return "Dry Level".localized
        case .wetLevel:     return "Wet Level".localized
        case .roomSize:     return "Room Size".localized
        case .wetDelay:     return "Wet Delay".localized
        case .strength:     return "Strength".localized
        @unknown default:
            return "\(self.rawValue)"
        }
    }
}

extension AgoraVoiceConversionPreset {
    func description() -> String {
        switch self {
        case .conversionOff:
            return "Off".localized
        case .changerNeutral:
            return "Neutral".localized
        case .changerSweet:
            return "Sweet".localized
        case .changerSolid:
            return "Solid".localized
        case .changerBass:
            return "Bass".localized
        @unknown default:
            return "\(self.rawValue)"
        }
    }
}

extension UIAlertController {
    func addCancelAction() {
        self.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))
    }
}

extension OutputStream {

    /// Write `String` to `OutputStream`
    ///
    /// - parameter string:                The `String` to write.
    /// - parameter encoding:              The `String.Encoding` to use when writing the string. This will default to `.utf8`.
    /// - parameter allowLossyConversion:  Whether to permit lossy conversion when writing the string. Defaults to `false`.
    ///
    /// - returns:                         Return total number of bytes written upon success. Return `-1` upon failure.

    func write(_ string: String, encoding: String.Encoding = .utf8, allowLossyConversion: Bool = false) -> Int {

        if let data = string.data(using: encoding, allowLossyConversion: allowLossyConversion) {
            let ret = data.withUnsafeBytes {
                write($0, maxLength: data.count)
            }
            if(ret < 0) {
                print("write fail: \(streamError.debugDescription)")
            }
        }

        return -1
    }

}

extension Date {
   func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
}

extension String {
    
    public var localized: String {
        let currentLocale = AppPreferences.instance.language
        guard
            let bundlePath = Bundle.main.path(forResource: currentLocale, ofType: "lproj"),
            let bundle = Bundle(path: bundlePath) else {
            return self
        }
        return NSLocalizedString(self, tableName: nil, bundle: bundle, value: "", comment: "")
        //        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
    
    public var localizedLowercase: String {
        return self.localized.lowercased()
    }
    
    public var localizedUppercase: String {
        return self.localized.uppercased()
    }
    
    public func index(with offset: Int) -> Index {
        return self.index(startIndex, offsetBy: offset)
    }
    
    public func subString(from offset: Int) -> String {
        let fromIndex = index(with: offset)
        return String(self[fromIndex...])
    }
    
    public func isValidEmail() -> Bool {
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)$", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
    
    public func isValidPassword() -> Bool {
        if self.contains(" ") {
            return false
        }
        let passwordRegex = "^(?=.*\\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[-(!#<>&@%+$*._)]).{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: self)
    }
    
    public var isDigits: Bool {
        if isEmpty { return false }
        // The inverted set of .decimalDigits is every character minus digits
        let nonDigits = CharacterSet.decimalDigits.inverted
        return rangeOfCharacter(from: nonDigits) == nil
    }
    
    func formatLocalized(_ args: CVarArg...) -> String {
        let format = NSLocalizedString(self, comment: self)
        let result = withVaList(args) {
            (NSString(format: format, locale: NSLocale.current, arguments: $0) as String)
        }
        
        return result
    }
    
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        return heightWithConstrainedWidth(width: width, attributes: [NSAttributedString.Key.font: font])
    }
    
    func heightWithConstrainedWidth(width: CGFloat, attributes: [NSAttributedString.Key: Any]) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect,
                                            options: [.usesLineFragmentOrigin, .usesFontLeading],
                                            attributes: attributes,
                                            context: nil)
        return ceil(boundingBox.height)
    }
    
    func widthWithFont(_ font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: UIScreen.main.bounds.width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect,
                                            options: [.usesLineFragmentOrigin, .usesFontLeading],
                                            attributes: [NSAttributedString.Key.font: font],
                                            context: nil)
        return boundingBox.width
    }
    
    func isEmtyString() -> Bool {
        if self.isEmpty {
            return true
        }
        if self.trimmingCharacters(in: .whitespaces).isEmpty {
            // string contains non-whitespace characters
            return true
        }
        return false
    }
    
    func trimSpace() -> String {
        return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    func isValidUrl() -> Bool {
        let urlRegEx = "^([-a-z0-9]{1,63}\\.)*?[a-z0-9][-a-z0-9]{0,61}[a-z0-9]\\.[a-z]{2,6}(/[-\\w@\\+\\.~#\\?&/=%]*)?$"
        let urlTest = NSPredicate(format:"SELF MATCHES %@", urlRegEx)
        let result = urlTest.evaluate(with: self)
        return result
    }
    
    func convertDate(currentFormat: String , formatConvert: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = currentFormat
        let showDate = inputFormatter.date(from: self)
        inputFormatter.dateFormat = formatConvert
        let resultDate = inputFormatter.string(from: showDate ?? Date())
        return resultDate
    }
    
    func toDouble(_ locale: Locale = Locale.current) -> Double? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = locale
        formatter.usesGroupingSeparator = true
        if let result = formatter.number(from: self)?.doubleValue {
            return result
        } else {
            return nil
        }
    }
    
    /// Assuming the current string is base64 encoded, this property returns a String
    /// initialized by converting the current string into Unicode characters, encoded to
    /// utf8. If the current string is not base64 encoded, nil is returned instead.
    var base64Decoded: String? {
        guard let base64 = Data(base64Encoded: self) else { return nil }
        let utf8 = String(data: base64, encoding: .utf8)
        return utf8
    }
    
    /// Returns a base64 representation of the current string, or nil if the
    /// operation fails.
    var base64Encoded: String? {
        let utf8 = self.data(using: .utf8)
        let base64 = utf8?.base64EncodedString()
        return base64
    }
    
}

class AppPreferences {
    private let kFacebookConnected = "connect_facebook"
    private let kTwitterConnected = "connect_twitter"
    private let kGoogleConnected = "connect_google"
    private let kShareFacebook = "share_facebook"
    private let kShareTwitter = "share_twitter"
    private let kShareGoogle = "share_google"
    private let kConnectedAccounts = "kConnectedAccounts"
    private let kReceiveNotifications = "kReceiveNotifications"
    private let kShowFansPublicly = "kShowFansPublicly"
    private let kTopFanRequirement = "kTopFanRequirement"
    private let kUseFrontCamera = "kUseFrontCamera"
    private let kSharePremiumOnly = "kSharePremiumOnly"
    private let kSuggestSubcribeCount = "kSuggestSubcribeCount"
    private let kFirstRun = "kFirstRun"
    private let kLatestVersion = "kLatestVersion"
    private let kExperienceLevel = "kExperienceLevel"
    private let kCurrentLocale = "kCurrentLocale"

    static let _instance = AppPreferences()

    static var instance: AppPreferences {
        get {
            return _instance
        }
    }

    private init() {
        UserDefaults.standard.register(defaults: [
            kShareFacebook: true,
            kShareTwitter: true,
            kShareGoogle: true,
            kReceiveNotifications: true,
            kShowFansPublicly: true,
            kTopFanRequirement: 10000,
            kSuggestSubcribeCount: 3,
            kFirstRun: true,
            kExperienceLevel: 0,
            kCurrentLocale: Constant.Language.EN.rawValue
        ])
    }

    var isFacebookConnected: Bool {
        get {
            return UserDefaults.standard.bool(forKey: kFacebookConnected)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: kFacebookConnected)
        }
    }
    var isTwitterConnected: Bool {
        get {
            return UserDefaults.standard.bool(forKey: kTwitterConnected)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: kTwitterConnected)
        }
    }
    var isGoogleConnected: Bool {
        get {
            return UserDefaults.standard.bool(forKey: kGoogleConnected)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: kGoogleConnected)
        }
    }

    var isShareFacebook: Bool {
        get {
            return UserDefaults.standard.bool(forKey: kShareFacebook)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: kShareFacebook)
        }
    }

    var isShareTwitter: Bool {
        get {
            return UserDefaults.standard.bool(forKey: kShareTwitter)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: kShareTwitter)
        }
    }

    var isShareGoogle: Bool {
        get {
            return UserDefaults.standard.bool(forKey: kShareGoogle)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: kShareGoogle)
        }
    }

    var receiveNotifications: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: kReceiveNotifications)
        }
        get {
            return UserDefaults.standard.bool(forKey: kReceiveNotifications)
        }
    }

    var showFansPublicly: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: kShowFansPublicly)
        }
        get {
            return UserDefaults.standard.bool(forKey: kShowFansPublicly)
        }
    }

    var topFanRequirement: Int {
        set {
            UserDefaults.standard.set(newValue, forKey: kTopFanRequirement)
        }
        get {
            return UserDefaults.standard.integer(forKey: kTopFanRequirement)
        }
    }

    var useFrontCamera: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: kUseFrontCamera)
        }
        get {
            return UserDefaults.standard.bool(forKey: kUseFrontCamera)
        }
    }

    var isSharePremiumOnly: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: kSharePremiumOnly)
        }
        get {
            return UserDefaults.standard.bool(forKey: kSharePremiumOnly)
        }
    }

    var suggestSubscribeCount: Int {
        set {
            UserDefaults.standard.set(newValue, forKey: kSuggestSubcribeCount)
        }
        get {
            return UserDefaults.standard.integer(forKey: kSuggestSubcribeCount)
        }
    }

    var isFirstRun: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: kFirstRun)
        }
        get {
            return UserDefaults.standard.bool(forKey: kFirstRun)
        }
    }

    var lastestVersion: Int {
        set {
            UserDefaults.standard.set(newValue, forKey: kLatestVersion)
        }
        get {
            return UserDefaults.standard.integer(forKey: kLatestVersion)
        }
    }
    
    var experienceLevel: Int {
        set {
            UserDefaults.standard.set(newValue, forKey: kExperienceLevel)
        }
        get {
            return UserDefaults.standard.integer(forKey: kExperienceLevel)
        }
    }
    
    var language: Constant.Language.RawValue {
        set {
            UserDefaults.standard.set(newValue, forKey: kCurrentLocale)
        }
        get {
            return UserDefaults.standard.string(forKey: kCurrentLocale)!
        }
    }
}
