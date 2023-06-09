//
//  Constant.swift
//  shopify-livestream
//
//  Created by Nguyễn Đức Tân on 18/04/2022.
//

import Foundation
import UIKit

class Constant {
    class RepositoryParam {
        static let groupId = "groupId"
        static let requestParams = "request_params"
        static let dbFilter = "db_filter"
        static let cacheFilter = "cache_filter"
        static let pivot = "pivot"
    }

    class RequestParam {
        class Pagination {
            // Type
            static let cursor = "cursor"
            static let brute = "brute"
            static let cursor2 = "cursor2"

            // Main params
            static let type = "p_type"
            static let field = "p_field"
            static let before = "p_before"
            static let after = "p_after"
            static let limit = "limit"
            static let offset = "offset"
        }
    }

    static let requestAuthToken = "auth_token"
    static let headerAuthToken = "x-auth-token"
    static let headerVersion = "x-client-version"
    
    static let commandReceiveSocketData = 1000
    static let commandSocketError = 1001
    static let commandReceiveGlobalData = 1002
    static let commandRoomChanged = 1003
    static let commandUserJoinLive = 1004
    static let commandErrorLiveStream = 1005
}

extension Constant {
    static let shareMyMediaKey = "share_my_media_message"
    static let shareOtherMediaKey = "share_other_media_message"
    static let mediaPath = "play"
    static let mediaParam = "mediaId"
    
    static var appVersion: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
    
    static var appBuild: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    }

    static var appIdentifier: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as! String
    }

    static let tableBackgroundColor = UIColor(red:0.96, green:0.96, blue:0.96, alpha:1.0)
    static let positiveColor = UIColor(red: 126 / 255.0, green: 211 / 255.0, blue: 33 / 255.0, alpha: 1)
    static let negativeColor = UIColor(red: 1, green: 34 / 255.0, blue: 82 / 255.0, alpha: 1)
    
    class ViewController {
        static let switcher = "SwitcherViewController"
        static let mainNavigation = "MainNavigationViewController"
        static let main = "MainViewController"
        static let inbox = "InboxViewController"
        static let live = "LiveViewController"
        static let player = "PlayerViewController"
        static let login = "NewLoginViewController"
        static let level = "LevelViewController"
        static let maintenance = "MaintenanceViewController"
        static let webView = "WebViewViewController"
        static let endLivePopup = "EndLivePopupViewController"
    }
    
    class ViewId {
        static let commonCell = "Cell"
        static let loadingCell = "LoadingCell"
        static let captionCell = "CaptionCell"
        static let temporaryCell = "TemporaryCell"
        static let promotionCell = "PromotionCell"
        static let topCell = "TopCell"
        static let mediaCell = "MediaCell"
        static let mainMenuCellNotification = "MainMenuCellNotification"
        static let mainMenuCellNormal = "MainMenuCellNormal"
        static let mainMenuCellProgress = "MainMenuCellProgress"
        static let receivedMessageCell = "ReceivedMessageCell"
        static let sentMessageCell = "SentMessageCell"
        static let receivedGiftCell = "ReceivedGiftCell"
        static let sentGiftCell = "SentGiftCell"
        static let giftCell = "GiftCell"
        static let policyCell = "PolicyCell"
        static let receivedTimeAgoCell = "ReceivedTimeAgoCell"
        static let sentTimeAgoCell = "SentTimeAgoCell"
        static let emailConfirmCell = "EmailConfirmCell"
        static let passwordChangeCell = "PasswordChangeCell"
        static let passwordChangeSuccessCell = "PasswordChangeSuccessCell"
        static let tagCell = "TagCell"
        static let accountCell = "AccountCell"
        static let profileCell = "ProfileCell"
        static let accountHeaderCell = "AccountHeaderCell"
        static let emptyHeaderCell = "EmptyHeaderCell"
        static let groupRequestCell = "GroupRequestCell"
        static let groupInviteCell = "GroupInviteCell"
        static let profileHeaderCell = "ProfileHeaderCell"
    }
    
    class ViewParam {
        static let media = "Media"
        static let campaign = "Campaign"
        static let donatePercent = "DonatePercent"
        static let user = "User"
        static let userId = "UserId"
        static let isLiving = "isLiving"
        static let backToChat = "backToChat"
        static let conversationId = "conversationId"
        static let senderName = "senderName"
        static let mediaListType = "MediaListType"
        static let criteria = "Criteria"
        static let keyword = "Keyword"
        static let item = "item"
        static let quantity = "quantity"
        static let banLevel = "banLevel"
        static let range = "range"
        static let period = "period"
        static let asset = "asset"
        static let imagePicker = "imagePicker"
        static let caption = "caption"
        static let isPremium = "isPremium"
        static let share = "share"
        static let confirmationData = "confirmationData"
        static let rect = "rect"
        static let mediaParams = "mediaParams"
        static let fanPremium = "fanPremium"
        static let type = "type"
        static let authData = "authData"
        static let offset = "offset"
        static let scrollView = "scrollView"
        static let error = "error"
        static let savedFilter = "SavedFilter"
        static let filterSelector = "FilterSelector"
        static let filterChanged = "FilterChanged"
        static let id = "id"
        static let action = "action"
        static let controller = "controller"
        static let url = "url"
        static let title = "title"
        static let level = "level"
        static let purchaseMessage = "PurchaseMessage"
        static let userJoin = "UserId"
        
        static let fromLive = "FromLive"
        static let countRequestMessage = "CountRequestMessage"
    }
    
    class Period {
        static let day = "day"
        static let week = "week"
        static let month = "month"
    }
    
    class MediaCriteria {
        class Leaderboard {
            static let mostViewers = "most_viewers"
            static let newest = "newest"
            static let nearby = "near_by"
        }
        class Search {
            static let people = "owner_name"
            static let title = "title"
            static let hashtag = "hashtag"
        }
    }
    
    class MediaType {
        static let photo = "1"
        static let streamed = "2"
        static let streaming = "3"
    }

    class BanLevel {
        static let banned = 2
        static let muted = 1
    }
    
    class SocketNamespace {
        static let global = "/me"
        static let liveStream = "/live_stream"
        static let conversation = "/conversation"
    }
    
    enum Social: String {
        case facebook = "facebook"
        case twitter = "twitter"
        case google = "google"
    }
    
    enum ConversationLineType: Int {
        case
        text = 1,
        media = 2,
        gift = 3
    }
    
    enum UserLevel: Int {
        case
        admin = 1,
        channel = 2,
        actor = 3,
        user = 4
    }
    
    enum VoiceState: Int {
        case
        none = -1,
        on = 0,
        off = 1
    }
    
    enum LiveType: String {
        case single = "single"
        case two = "two"
        case four = "four"
        case six = "six"
        case nine = "nine"
    }
    
    enum Language: String {
        case EN = "en"
        case JA = "ja"
    }
    
    enum InputError : Error {
        case Empty
        case EmailErrorFormat
        case EmailEmpty
        case PasswordEmpty
        case PasswordErrorFormat
        case NewPasswordErrorMatch
        case ConfirmPasswordErrorFormat
        case ConfirmPasswordEmpty
        case CodeVerificationEmpty
        case ConfirmPasswordNotMatch
        case CurrentPasswordEmpty
        case CurrentPasswordErrorFormat
        case UserNameEmpty
        case GenderEmpty
        case BirthdateEmpty
        case HeightTooShort
        case HeightTooHigh
    }
    
    enum RightBarButtonStyle {
        case None
        case Search
        case Save
        case Cancel
        case Edit
        case Profile
    }
    
    class IapItemType {
        static let subscription = "subscription"
        static let coin = "coin"
    }

    class BuzzEffectType {
        static let broadcast = 1
    }
    
    class Gender {
        static let male = "male"
        static let female = "female"
        static let other = "other"
    }
    
    static let unknownId: Int = -1
    static let responseVersion = "version"
    static let kUserId = "kUserId"
    static let kAuthToken = "kAuthToken"
    static let kDeviceId = "kDeviceId"
    static let minGestureDistance: CGFloat = 50.0
    static let animationDuration: TimeInterval = 0.35
    static let loadingImageName = "cat_loading_"
    static let largeLoadingImageName = "big_cat_loading_"
    static let maxTag: Int = 5

    class ErrorCode {
        static let msg_01 = "MSG_01"
        static let msg_02 = "MSG_02"
        static let msg_03 = "MSG_03"
        static let msg_04 = "MSG_04"
        static let msg_05 = "MSG_05"
        static let msg_06 = "MSG_06"
        static let msg_07 = "MSG_07"
        static let msg_08 = "MSG_08"
        static let msg_09 = "MSG_09"
        static let msg_10 = "MSG_10"
        static let msg_11 = "MSG_11"
        static let msg_28 = "MSG_28"
        static let msg_40 = "MSG_40"
    }
}

extension Constant.RepositoryParam {
    static let isGetPrevious = "getPrevious"
    static let requestNewsfeed = "RequestNewsfeed"
    static let requestExplore = "RequestExplore"
    static let requestSearch = "requestSearch"
    static let requestSearchFriends = "requestSearchFriends"
    static let requestFacebookFriends = "requestFacebookFriends"
    static let requestTwitterFriends = "requestTwitterFriends"
    static let requestGoogleFriends = "requestGoogleFriends"
    static let userId = "userId"
    static let subscribe = "subscribe"
    static let requestUserStream = "requestUserStream"
    static let requestPendingList = "requestPendingList"
    static let socialNetwork = "socialNetwork"
    static let ignoreConversation = "ignoreConversation"
    static let commentId = "commentId"
    static let mediaId = "mediaId"
}

extension Constant.RequestParam {
    static let viewerId = "viewerId"
    static let duration = "duration"
    static let banLevel = "banLevel"
    static let keyword = "value"
    static let criteria = "criteria"
    static let type = "type"
    static let isLiving = "isLiving"
    static let streamId = "streamId"
    static let trophyId = "trophyId"
    static let fbAccessToken = "fb_access_token"
    static let ggAccessToken = "accessToken"
    static let ggRefreshToken = "refreshToken"
    static let twAccessToken = "tokenKey"
    static let twAccessTokenSecret = "tokenSecret"
    
    static let iapId = "iapId"
    static let transactionId = "transactionId"
    static let receipt = "receipt"
    static let purchasedAt = "purchasedAt"
    static let expiredAt = "expiredAt"
    static let canceledAt = "canceledAt"
    static let isPremium = "isPremium"
    static let name = "name"
    static let searchText = "searchText"
    
    static let content = "content"
    
    static let email = "email"
    static let code = "code"
    static let oldPassword = "oldPassword"
    static let password = "password"
    static let userTypeActor = "store"
    static let fullName = "fullName"
    static let shortDescription = "shortDescription"
    static let fromAge = "fromAge"
    static let toAge = "toAge"
    static let gender = "gender"
    static let role = "role"

    static let deviceId = "deviceId"
    static let deviceToken = "deviceToken"
    static let os = "os"
    static let deviceType = "device"
    static let iOsDevice = "2"
    
    static let snsType = "snsType"
    static let url = "url"
}

struct AppKey {
    static let userInfo = "user_info"
    static let shopifyToken = "shopify_token"
}

struct FirebaseKey {
    static let users = "users"
}
