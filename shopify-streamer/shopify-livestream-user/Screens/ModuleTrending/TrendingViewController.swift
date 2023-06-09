//
//  TrendingViewController.swift
//  ASRApplication
//
//  Created by Đức Tân Nguyễn on 07/06/2021.
//

import UIKit

class TrendingViewController: BaseViewController {
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var segmentedControl: AppSegmentControl!
    
    private var openingOrderView: TrendingView?
    private var closedOrderView: TrendingView?
    private var cancelledOrderView: TrendingView?
    private let segmentTitles = ["Opening Order", "Closed Order", "Cancelled Order"]
    private let screenWidth  = UIScreen.main.bounds.width
    
    var openOrder: [Order] = []
    var closeOrder: [Order] = []
    var cancelledOrder: [Order] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        let user = DataLocal.getData(forKey: AppKey.userInfo) as? User
        labelTitle.text = user?.storeName
        setMenuBar()
        configScrollView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getData()
    }
    
    func getData() {
        GetListOpenOrderAPI().send { orders, error in
            if let error = error {
                UIAlertController.show(message: error.localizedDescription, title: nil)
                return
            } else {
                self.openOrder = orders ?? []
                self.openingOrderView?.setupView(orders: orders ?? [])
            }
        }
        GetListClosedOrderAPI().send { orders, error in
            if let error = error {
                UIAlertController.show(message: error.localizedDescription, title: nil)
                return
            } else {
                self.closeOrder = orders ?? []
                self.closedOrderView?.setupView(orders: orders ?? [])
            }
        }
        GetListCancelOrderAPI().send { orders, error in
            if let error = error {
                UIAlertController.show(message: error.localizedDescription, title: nil)
                return
            } else {
                self.cancelledOrder = orders ?? []
                self.cancelledOrderView?.setupView(orders: orders ?? [])
            }
        }
    }

    func setMenuBar() {
        segmentedControl.textFont = UIFont.boldSystemFont(ofSize: 14)
        segmentedControl.backgroundColor = UIColor.white
        segmentedControl.textColor = UIColor(hex: "999999")
        segmentedControl.textSelectedColor = UIColor.appPrimary
        segmentedControl.bounces = true
        segmentedControl.setTitles(segmentTitles,
                                   style: .fixedWidth(screenWidth/3))
        segmentedControl.delegate = self
        segmentedControl.selectedIndex = 0
    }
    
    private func configScrollView() {
        scrollView.contentSize = CGSize(width: screenWidth * 3.0, height: scrollView.frame.size.height)
        openingOrderView = TrendingView(frame: .zero)
        openingOrderView?.delegate = self
        openingOrderView?.setupView(orders: openOrder)
        closedOrderView = TrendingView(frame: .zero)
        closedOrderView?.delegate = self
        closedOrderView?.setupView(orders: closeOrder)
        cancelledOrderView = TrendingView(frame: .zero)
        cancelledOrderView?.delegate = self
        cancelledOrderView?.setupView(orders: cancelledOrder)
        scrollView.addSubview(openingOrderView!)
        scrollView.addSubview(closedOrderView!)
        scrollView.addSubview(cancelledOrderView!)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        openingOrderView?.frame = CGRect(x: 0,
                                         y: 0,
                                         width: screenWidth,
                                         height: scrollView.frame.height)
        closedOrderView?.frame = CGRect(x: screenWidth,
                                        y: 0,
                                        width: screenWidth,
                                        height: scrollView.frame.height)
        cancelledOrderView?.frame = CGRect(x: 2*screenWidth,
                                           y: 0,
                                           width: screenWidth,
                                           height: scrollView.frame.height)
    }
}

extension TrendingViewController: AppSegmentControlSelectedProtocol {
    func segmentedControlSelectedIndex(_ index: Int, animated: Bool, segmentedControl: AppSegmentControl) {
        let offsetX = CGFloat(index)*scrollView.frame.size.width
        let offsetY = scrollView.contentOffset.y
        let offset = CGPoint(x: offsetX, y: offsetY)
        scrollView.setContentOffset(offset, animated: animated)
    }
}

extension TrendingViewController: TrendingViewDelegate {
    func updateOrder() {
        getData()
    }
}
