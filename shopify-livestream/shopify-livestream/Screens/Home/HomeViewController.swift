//
// Copyright (c) 2021 Related Code - https://relatedcode.com
//
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class HomeViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var topViewStream: [Room] = []
    var hotStream: [Room] = []
    var listFollowedStore: [Room] = []
    var allStream: [Room] = []
    let db = Firestore.firestore()
    let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
		super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        tableView.registerCellByNib(LiveByCategoryTableViewCell.self)
        tableView.delegate = self
        tableView.dataSource = self

        refreshControl.addTarget(self, action: #selector(loadData), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        loadData()
	}

	@objc func loadData() {
        db.collection("rooms").whereField("endTime", isEqualTo: 0).getDocuments() { (querySnapshot, err) in
            if let err = err {
                UIAlertController.show(message: err.localizedDescription, title: nil)
            } else {
                self.allStream = []
                self.listFollowedStore = []
                self.hotStream = []
                self.topViewStream = []
                let group = DispatchGroup()
                for document in querySnapshot!.documents {
                    let newRoom = Room(dictionary: document.data())
                    self.allStream.append(newRoom)
                    if let name = newRoom.roomOwnerId, !name.isEmpty {
                        group.enter()
                        self.db.collection("users").document(name).getDocument { document, error in
                            let user = User(dictionary: document?.data() ?? [:])
                            newRoom.actorName = user.storeName
                            group.leave()
                        }
                    }
                }
                group.notify(queue: .main) {
                    let favoriteAvalaible = self.allStream.filter { room in
                        room.favorite?.count ?? 0 > 0
                    }
                    self.hotStream = Array(favoriteAvalaible.sorted(by: { room1, room2 in
                        return room1.favorite?.count ?? 0 > room2.favorite?.count ?? 0
                    }).prefix(3))
                    
                    self.topViewStream = Array(self.allStream.sorted(by: { room1, room2 in
                        return room1.viewer?.count ?? 0 > room2.viewer?.count ?? 0
                    }).prefix(3))
                    
                    if self.refreshControl.isRefreshing {
                        self.refreshControl.endRefreshing()
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueCell(LiveByCategoryTableViewCell.self, forIndexPath: indexPath) else {
            return UITableViewCell()
        }

        if indexPath.row == 0 {
            cell.initData(title: "Top Views", lives: topViewStream)
        } else if indexPath.row == 1 {
            cell.initData(title: "Hot Views", lives: hotStream)
        } else {
            cell.initData(title: "Followed Store", lives: listFollowedStore)
        }
        return cell
    }
}
