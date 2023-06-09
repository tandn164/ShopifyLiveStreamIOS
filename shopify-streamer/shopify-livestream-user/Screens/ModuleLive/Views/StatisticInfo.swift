//
//  StatisticInfo.swift
//  YoutubeClone
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
        case .fixedPortrait: return "fixed portrait"
        case .fixedLandscape: return "fixed landscape"
        case .adaptative: return "adaptive"
        default: return "\(self.rawValue)"
        }
    }
}

extension AgoraClientRole {
    func description() -> String {
        switch self {
        case .broadcaster: return "Broadcaster"
        case .audience: return "Audience"
        default:
            return "\(self.rawValue)"
        }
    }
}

extension AgoraAudioProfile {
    func description() -> String {
        switch self {
        case .default: return "Default"
        case .musicStandard: return "Music Standard"
        case .musicStandardStereo: return "Music Standard Stereo"
        case .musicHighQuality: return "Music High Quality"
        case .musicHighQualityStereo: return "Music High Quality Stereo"
        case .speechStandard: return "Speech Standard"
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
        case .default: return "Default"
        case .chatRoomGaming: return "Chat Room Gaming"
        case .education: return "Education"
        case .gameStreaming: return "Game Streaming"
        case .chatRoomEntertainment: return "Chat Room Entertainment"
        case .showRoom: return "Show Room"
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
        case .voiceChangerOff:return "Off"
        case .generalBeautyVoiceFemaleFresh:return "FemaleFresh"
        case .generalBeautyVoiceFemaleVitality:return "FemaleVitality"
        case .generalBeautyVoiceMaleMagnetic:return "MaleMagnetic"
        case .voiceBeautyVigorous:return "Vigorous"
        case .voiceBeautyDeep:return "Deep"
        case .voiceBeautyMellow:return "Mellow"
        case .voiceBeautyFalsetto:return "Falsetto"
        case .voiceBeautyFull:return "Full"
        case .voiceBeautyClear:return "Clear"
        case .voiceBeautyResounding:return "Resounding"
        case .voiceBeautyRinging:return "Ringing"
        case .voiceBeautySpacial:return "Spacial"
        case .voiceChangerEthereal:return "Ethereal"
        case .voiceChangerOldMan:return "Old Man"
        case .voiceChangerBabyBoy:return "Baby Boy"
        case .voiceChangerBabyGirl:return "Baby Girl"
        case .voiceChangerZhuBaJie:return "ZhuBaJie"
        case .voiceChangerHulk:return "Hulk"
        default:
            return "\(self.rawValue)"
        }
    }
}

extension AgoraVoiceBeautifierPreset{
    func description() -> String {
        switch self {
        case .voiceBeautifierOff:return "Off"
        case .chatBeautifierFresh:return "FemaleFresh"
        case .chatBeautifierMagnetic:return "MaleMagnetic"
        case .chatBeautifierVitality:return "FemaleVitality"
        case .timbreTransformationVigorous:return "Vigorous"
        case .timbreTransformationDeep:return "Deep"
        case .timbreTransformationMellow:return "Mellow"
        case .timbreTransformationFalsetto:return "Falsetto"
        case .timbreTransformationFull:return "Full"
        case .timbreTransformationClear:return "Clear"
        case .timbreTransformationResounding:return "Resounding"
        case .timbreTransformationRinging:return "Ringing"
        default:
            return "\(self.rawValue)"
        }
    }
}

extension AgoraAudioReverbPreset {
    func description() -> String {
        switch self {
        case .off:return "Off"
        case .fxUncle:return "FxUncle"
        case .fxSister:return "FxSister"
        case .fxPopular:return "Pop"
        case .popular:return "Pop(Old Version)"
        case .fxRNB:return "R&B"
        case .rnB:return "R&B(Old Version)"
        case .rock:return "Rock"
        case .hipHop:return "HipHop"
        case .fxVocalConcert:return "Vocal Concert"
        case .vocalConcert:return "Vocal Concert(Old Version)"
        case .fxKTV:return "KTV"
        case .KTV:return "KTV(Old Version)"
        case .fxStudio:return "Studio"
        case .studio:return "Studio(Old Version)"
        case .fxPhonograph:return "Phonograph"
        case .virtualStereo:return "Virtual Stereo"
        default:
            return "\(self.rawValue)"
        }
    }
}

extension AgoraAudioEffectPreset {
    func description() -> String {
        switch self {
        case .audioEffectOff:return "Off"
        case .voiceChangerEffectUncle:return "FxUncle"
        case .voiceChangerEffectOldMan:return "Old Man"
        case .voiceChangerEffectBoy:return "Baby Boy"
        case .voiceChangerEffectSister:return "FxSister"
        case .voiceChangerEffectGirl:return "Baby Girl"
        case .voiceChangerEffectPigKing:return "ZhuBaJie"
        case .voiceChangerEffectHulk:return "Hulk"
        case .styleTransformationRnB:return "R&B"
        case .styleTransformationPopular:return "Pop"
        case .roomAcousticsKTV:return "KTV"
        case .roomAcousticsVocalConcert:return "Vocal Concert"
        case .roomAcousticsStudio:return "Studio"
        case .roomAcousticsPhonograph:return "Phonograph"
        case .roomAcousticsVirtualStereo:return "Virtual Stereo"
        case .roomAcousticsSpacial:return "Spacial"
        case .roomAcousticsEthereal:return "Ethereal"
        case .roomAcoustics3DVoice:return "3D Voice"
        case .pitchCorrection:return "Pitch Correction"
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
        case .dryLevel:     return "Dry Level"
        case .wetLevel:     return "Wet Level"
        case .roomSize:     return "Room Size"
        case .wetDelay:     return "Wet Delay"
        case .strength:     return "Strength"
        @unknown default:
            return "\(self.rawValue)"
        }
    }
}

extension AgoraVoiceConversionPreset {
    func description() -> String {
        switch self {
        case .conversionOff:
            return "Off"
        case .changerNeutral:
            return "Neutral"
        case .changerSweet:
            return "Sweet"
        case .changerSolid:
            return "Solid"
        case .changerBass:
            return "Bass"
        @unknown default:
            return "\(self.rawValue)"
        }
    }
}

extension UIAlertController {
    func addCancelAction() {
        self.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
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
