//
//  LiveStreamButton.swift
//  FammiActor
//

import UIKit

protocol AppViewProtocol {
    var contentView: UIView! { get }
    func commonInit(for customViewName: String)
}

extension AppViewProtocol where Self: UIView {
    func commonInit(for customViewName: String) {
        Bundle.main.loadNibNamed(customViewName, owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}


class LiveStreamButton: UIView, AppViewProtocol {
    @IBOutlet weak var contentView: UIView!

    @IBOutlet weak var liveStreamLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit(for: "LiveStreamButton")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit(for: "LiveStreamButton")
    }
    
    //MARK: Actions
    @IBAction func onLiveClicked(_ sender: UIButton) {
    }
}
