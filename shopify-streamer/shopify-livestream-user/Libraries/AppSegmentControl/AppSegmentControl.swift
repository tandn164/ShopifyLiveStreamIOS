//
//  AppSegmentControl.swift
//  CoreApp
//
//  Created by Nguyễn Đức Tân on 16/05/2022.
//

import UIKit

public enum SliderPositionStyle {
    case bottomWithHight(CGFloat)
    case topWidthHeight(CGFloat)
}

public enum WidthStyle {
    case fixedWidth(CGFloat)
    case adaptiveSpace(CGFloat)
}

public protocol AppSegmentControlSelectedProtocol: AnyObject {
    func segmentedControlSelectedIndex(_ index: Int, animated: Bool, segmentedControl: AppSegmentControl)
}

public class AppSegmentControl: UIView {
    
    public var bounces: Bool = false {
        didSet { scrollView.bounces = bounces }
    }
    
    public var selectedIndex: Int = 0 {
        didSet { updateScrollViewOffset() }
    }
    
    public var selectedScale: CGFloat = 1.0
    public weak var delegate: AppSegmentControlSelectedProtocol?
    
    public func setTitles(_ titles: [String], style: WidthStyle) {
        setTitleItems(titles: titles, style: style)
    }
    
    public func setImages(_ images: [UIImage], selectedImages: [UIImage?]? = nil, fixedWidth: CGFloat) {
        setImageItems(images: images, selectedImages: selectedImages, fixedWidth: fixedWidth)
    }
    
    public var textColor: UIColor = UIColor.gray {
        didSet {
            if itemsArray.count == 0 { return }
            itemsArray.forEach { $0.setTitleColor(textColor, for: .normal) }
            let index = min(max(selectedIndex, 0), itemsArray.count-1)
            let button = itemsArray[index]
            button.setTitleColor(textColor, for: .normal)
        }
    }
    
    public var textSelectedColor: UIColor = UIColor.blue {
        didSet {
            if itemsArray.count == 0 { return }
            itemsArray.forEach { $0.setTitleColor(textSelectedColor, for: .normal) }
            let index = min(max(selectedIndex, 0), itemsArray.count-1)
            let button = itemsArray[index]
            button.setTitleColor(textSelectedColor, for: .selected)
        }
    }

    public var textFont: UIFont = UIFont.systemFont(ofSize: 15) {
        didSet { itemsArray.forEach { $0.titleLabel?.font = textFont } }
    }
    
    public func setCover(color: UIColor, upDowmSpace: CGFloat = 0, cornerRadius: CGFloat = 0) {
        coverView.isHidden = false
        coverView.layer.cornerRadius = cornerRadius
        coverView.backgroundColor = color
        coverUpDownSpace = upDowmSpace
        updateCoverAndSliderFrame(originFrame: coverView.frame, upSpace: upDowmSpace)
    }

    public func contentScrollViewDidScroll(_ scrollView: UIScrollView) {
        updataCoverAndSliderByContentScrollView(scrollView)
    }
    
    public func contentScrollViewWillBeginDragging() {
        contentScrollViewWillDragging = true
    }
  
    public func setSilder(backgroundColor: UIColor,position: SliderPositionStyle, widthStyle: WidthStyle) {
        var sliderFrame = slider.frame
        switch position {
        case .bottomWithHight(let height):
            sliderFrame.origin.y = frame.size.height-height
            sliderFrame.size.height = height
        case .topWidthHeight(let height):
            sliderFrame.origin.y = 0
            sliderFrame.size.height = height
        }
        slider.frame = sliderFrame
        slider.isHidden = false
        slider.backgroundColor = backgroundColor
        sliderConfig = (position, widthStyle)
    }
    
    fileprivate var scrollView = UIScrollView()
    fileprivate var itemsArray = [UIButton]()
    fileprivate var coverView = UIView()
    fileprivate var slider = UIView()
    fileprivate var totalItemsCount: Int = 0
    fileprivate var titleSources = [String]()
    fileprivate var imageSources: ([UIImage], [UIImage]) = ([], [])
    fileprivate var resourceType: ResourceType = .text
    fileprivate var coverUpDownSpace: CGFloat = 0
    fileprivate var sliderConfig: (SliderPositionStyle, WidthStyle) = (.bottomWithHight(2),.adaptiveSpace(0))
    fileprivate var contentScrollViewWillDragging: Bool = false
    fileprivate var isTapItem: Bool = false
    enum ResourceType {
        case text
        case image
    }
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupContentView()
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupContentView()
    }
    override public func layoutSubviews() {
        super.layoutSubviews()
        updateScrollViewOffset()
    }
    private func setTitleItems(titles: [String], style: WidthStyle) {
        resourceType = .text
        titleSources = titles
        totalItemsCount = titles.count
        switch style {
        case .fixedWidth(let width):
            setupItems(fixedWidth: width)
        case .adaptiveSpace(let space):
            setupItems(fixedWidth: 0, leading: space)
        }
    }
    private func setImageItems(images: [UIImage], selectedImages: [UIImage?]? = nil, fixedWidth: CGFloat) {
        resourceType = .image
        var sImages = [UIImage]()
        if selectedImages == nil {
            sImages = images
        } else {
            for i in 0..<images.count {
                let image = (i < selectedImages!.count && selectedImages![i] != nil) ? selectedImages![i]! : images[i]
                sImages.append(image)
            }
        }
        imageSources = (images, sImages)
        totalItemsCount = images.count
        setupItems(fixedWidth: fixedWidth)
    }
}

extension AppSegmentControl {
    fileprivate func setupContentView() {
        backgroundColor = UIColor.white
        scrollView.frame = bounds
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        addSubview(scrollView)
        scrollView.addSubview(coverView)
        scrollView.addSubview(slider)
        slider.isHidden = true
        coverView.isHidden = true
    }
    
    fileprivate func setupItems(fixedWidth: CGFloat, leading: CGFloat? = nil) {
        itemsArray.forEach { $0.removeFromSuperview() }
        itemsArray.removeAll()
        var contentSizeWidth: CGFloat = 0
        for i in 0..<totalItemsCount {
            var width = fixedWidth
            if let leading = leading {
                let text = titleSources[i] as NSString
                width = text.size(withAttributes: [.font: textFont]).width + leading*2
            }
            let x = contentSizeWidth
            let height = frame.size.height
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: x, y: 0, width: width, height: height)
            button.clipsToBounds = true
            button.tag = i
            button.addTarget(self, action: #selector(selectedButton(sender:)), for: .touchUpInside)
            scrollView.addSubview(button)
            itemsArray.append(button)
            
            switch resourceType {
            case .text:
                button.setTitle(titleSources[i], for: .normal)
                button.setTitleColor(textColor, for: .normal)
                button.titleLabel?.font = textFont
            case .image:
                button.setImage(imageSources.0[i], for: .normal)
                button.setImage(imageSources.1[i], for: .selected)
            }
            contentSizeWidth += width
        }
        scrollView.contentSize = CGSize(width: contentSizeWidth, height: 0)
        let index = min(max(selectedIndex, 0), itemsArray.count-1)
        let selectedButton = itemsArray[index]
        selectedButton.isSelected = true
        updateCoverAndSliderFrame(originFrame: selectedButton.frame, upSpace: coverUpDownSpace)
    }
    @objc private func selectedButton(sender: UIButton) {
        contentScrollViewWillDragging = false
        isTapItem = true
        selectedIndex = sender.tag
    }
}

extension AppSegmentControl {
    fileprivate func updateScrollViewOffset() {
        if itemsArray.count == 0 { return }
        let index = min(max(selectedIndex, 0), itemsArray.count-1)
        delegate?.segmentedControlSelectedIndex(index, animated: isTapItem, segmentedControl: self)
        
        let currentButton = self.itemsArray[index]
        let offset = getScrollViewCorrectOffset(by: currentButton)
        let duration = isTapItem || contentScrollViewWillDragging
        ? 0.3 : 0
        isTapItem = false
        UIView.animate(withDuration: duration, animations: {
            self.itemsArray.forEach({ (button) in
                button.setTitleColor(self.textColor, for: .normal)
                button.isSelected = false
                button.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
            self.updateCoverAndSliderFrame(originFrame: currentButton.frame, upSpace: self.coverUpDownSpace)
            currentButton.setTitleColor(self.textSelectedColor, for: .normal)
            currentButton.isSelected = true
            let scale = self.selectedScale
            currentButton.transform = CGAffineTransform(scaleX: scale, y: scale)
            let animated = duration == 0 ? false:true
            self.scrollView.setContentOffset(offset, animated: animated)
        })
    }
    fileprivate func getScrollViewCorrectOffset(by item: UIButton) -> CGPoint {
        if scrollView.contentSize.width < scrollView.frame.size.width {
            return CGPoint.zero
        }
        var offsetx = item.center.x - frame.size.width/2
        let offsetMax = scrollView.contentSize.width - frame.size.width
        if offsetx < 0 {
            offsetx = 0
        }else if offsetx > offsetMax {
            offsetx = offsetMax
        }
        let offset = CGPoint(x: offsetx, y: 0)
        return offset
    }
}

extension AppSegmentControl {
    fileprivate func updataCoverAndSliderByContentScrollView(_ scrollView: UIScrollView) {
        if !contentScrollViewWillDragging { return }
        let offset = scrollView.contentOffset.x / scrollView.frame.size.width
        let percent = offset-CGFloat(Int(offset))
        let currentIndex = Int(offset)
        var targetIndex = currentIndex
        if percent < 0 && currentIndex > 0 {
            targetIndex = currentIndex-1
        } else if percent > 0 && currentIndex < itemsArray.count-1 {
            targetIndex = currentIndex+1
        } else {
            return
        }
        let currentButton = itemsArray[currentIndex]
        let targentButton = itemsArray[targetIndex]
        currentButton.transform = CGAffineTransform(scaleX: 1, y: 1)
        targentButton.transform = CGAffineTransform(scaleX: 1, y: 1)
        
        let centerXChange = (targentButton.center.x-currentButton.center.x)*abs(percent)
        let widthChange = (targentButton.frame.size.width-currentButton.frame.size.width)*abs(percent)
        var frame = currentButton.frame
        frame.size.width += widthChange
        updateCoverAndSliderFrame(originFrame: frame, upSpace: coverUpDownSpace)
        var center = currentButton.center
        center.x += centerXChange
        coverView.center = center
        
        var sliderCenter = slider.center
        sliderCenter.x = coverView.center.x
        slider.center = sliderCenter
        
        /// scale
        let scale = (selectedScale-1)*abs(percent)
        let targetTx = 1 + scale
        let currentTx = selectedScale - scale
        currentButton.transform = CGAffineTransform(scaleX: currentTx, y: currentTx)
        targentButton.transform = CGAffineTransform(scaleX: targetTx, y: targetTx)
        
        let currentColor = averageColor(fromColor: textSelectedColor, toColor: textColor, percent: abs(percent))
        let targetColor = averageColor(fromColor: textColor, toColor: textSelectedColor, percent: abs(percent))
        currentButton.setTitleColor(currentColor, for: .normal)
        targentButton.setTitleColor(targetColor, for: .normal)
    }
    
    fileprivate func updateCoverAndSliderFrame(originFrame: CGRect, upSpace: CGFloat) {
        var newFrame = originFrame
        newFrame.origin.y = upSpace
        newFrame.size.height -= upSpace*2
        coverView.frame = newFrame
        
        switch sliderConfig.0 {
        case .topWidthHeight(let height):
            newFrame.origin.y = 0
            newFrame.size.height = height
        case .bottomWithHight(let height):
            newFrame.origin.y = originFrame.size.height-height
            newFrame.size.height = height
        }
        switch sliderConfig.1 {
        case .fixedWidth(let width):
            newFrame.size.width = width
        case .adaptiveSpace(let space):
            newFrame.size.width = originFrame.size.width-2*space
        }
        slider.frame = newFrame
        
        var sliderCenter = slider.center
        sliderCenter.x = coverView.center.x
        slider.center = sliderCenter
    }
}

extension AppSegmentControl {
    fileprivate func averageColor(fromColor: UIColor, toColor: UIColor, percent: CGFloat) -> UIColor {
        var fromRed: CGFloat = 0
        var fromGreen: CGFloat = 0
        var fromBlue: CGFloat = 0
        var fromAlpha: CGFloat = 0
        fromColor.getRed(&fromRed, green: &fromGreen, blue: &fromBlue, alpha: &fromAlpha)
        
        var toRed: CGFloat = 0
        var toGreen: CGFloat = 0
        var toBlue: CGFloat = 0
        var toAlpha: CGFloat = 0
        toColor.getRed(&toRed, green: &toGreen, blue: &toBlue, alpha: &toAlpha)
        
        let nowRed = fromRed + (toRed - fromRed) * percent
        let nowGreen = fromGreen + (toGreen - fromGreen) * percent
        let nowBlue = fromBlue + (toBlue - fromBlue) * percent
        let nowAlpha = fromAlpha + (toAlpha - fromAlpha) * percent
        
        return UIColor(red: nowRed, green: nowGreen, blue: nowBlue, alpha: nowAlpha)
    }
}
