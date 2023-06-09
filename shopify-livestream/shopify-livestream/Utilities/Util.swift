//
//  Util.swift
//  shopify-livestream
//
//  Created by Nguyễn Đức Tân on 18/07/2022.
//

import UIKit

class Util {
    static func getHeadSubSet<T: Comparable>(_ data: [T], count: Int) -> [T] {
        let lastIndex = min(count, data.count)
        return Array(data[0 ..< lastIndex])
    }
    
    static func getTailSubSet<T: Comparable>(_ data: [T], count: Int) -> [T] {
        guard count <= data.count else { return [] }
        return Array(data[data.count - count ..< data.count])
    }
    
    static func getSetOfSmall<T: Comparable>(_ data: [T], pivot: T) -> [T] {
        var result = [T]()
        for element in data {
            if element < pivot {
                result.append(element)
            } else {
                break
            }
        }
        return result
    }
    
    public static func currentTime() -> Int64 {
        let time = Date().timeIntervalSince1970
        return Int64(time * 1000)
    }
    
    static func getSetOfBig<T: Comparable>(_ data: [T], pivot: T, count: Int) -> [T] {
        var result = [T]()
        // TODO: improve
        for element in data {
            if element <= pivot {
                continue
            }
            if result.count < count {
                result.append(element)
            }
        }
        return result
    }
    
    static func createBlurImage(source: UIImage, radius: CGFloat = 15) -> UIImage {
        let imageToBlur = CIImage(image: source)
        let blurfilter = CIFilter(name: "CIGaussianBlur")!
        blurfilter.setValue(imageToBlur, forKey: "inputImage")
        blurfilter.setValue(radius, forKey: "inputRadius")
        let resultImage = blurfilter.value(forKey: "outputImage") as! CIImage
        return UIImage(ciImage: resultImage)
    }
    
    static func formatCurrency(amount: Float) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: NSNumber(value: amount))!
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
    
    static func registerKeyboardEvent(_ observer: Any, showSelector: Selector, hideSelector: Selector) {
        NotificationCenter.default.addObserver(observer, selector: showSelector, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(observer, selector: hideSelector, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    static func removeKeyboardEvent(_ observer: Any) {
        NotificationCenter.default.removeObserver(observer, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(observer, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    static func loadAnimationImages(name: String) -> [UIImage] {
        var images: [UIImage] = []
        if let image = UIImage(named: "\(name)0") {
            images.append(image)
        }
        var index = 1
        while true {
            if let image = UIImage(named: "\(name)\(index)") {
                images.append(image)
                index += 1
            } else {
                break
            }
        }
        
        return images
    }
    
    static func isValidImage(_ filePath: NSURL) -> Bool {
        let fileStr = filePath.absoluteString?.lowercased() ?? ""
        if fileStr.hasSuffix("jpg") || fileStr.hasSuffix("jpeg") || fileStr.hasSuffix("png") || fileStr.hasSuffix("heic") {
            return true
        }
        return false
    }
    
    static func getCVPixelBuffer(_ image: CGImage) -> CVPixelBuffer? {
        let imageWidth = Int(image.width)
        let imageHeight = Int(image.height)
        
        let attributes: [NSObject: AnyObject] = [
            kCVPixelBufferCGImageCompatibilityKey: true as AnyObject,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true as AnyObject,
        ]
        
        var pxbuffer: CVPixelBuffer?
        CVPixelBufferCreate(kCFAllocatorDefault,
                            imageWidth,
                            imageHeight,
                            kCVPixelFormatType_32ARGB,
                            attributes as CFDictionary?,
                            &pxbuffer)
        
        if let _pxbuffer = pxbuffer {
            let flags = CVPixelBufferLockFlags(rawValue: 0)
            CVPixelBufferLockBaseAddress(_pxbuffer, flags)
            let pxdata = CVPixelBufferGetBaseAddress(_pxbuffer)
            
            let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
            let context = CGContext(data: pxdata,
                                    width: imageWidth,
                                    height: imageHeight,
                                    bitsPerComponent: 8,
                                    bytesPerRow: CVPixelBufferGetBytesPerRow(_pxbuffer),
                                    space: rgbColorSpace,
                                    bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
            
            if let _context = context {
                _context.draw(image, in: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight))
            } else {
                CVPixelBufferUnlockBaseAddress(_pxbuffer, flags)
                return nil
            }
            
            CVPixelBufferUnlockBaseAddress(_pxbuffer, flags)
            return _pxbuffer
        }
        
        return nil
    }
}
