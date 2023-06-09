//
// Copyright (c) 2021 Related Code - https://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

protocol SearchDelegate: AnyObject {
    func showProduct(with product: Product?)
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
class Search1View: UIViewController {

	@IBOutlet var tableView: UITableView!
	@IBOutlet var searchBar: UISearchBar!

	private var categories: [Category] = []
    private var products: [Product] = []
    private var showResult: Bool = false

    weak var delegate: SearchDelegate?
    
	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
		title = "Search"

		navigationController?.navigationBar.prefersLargeTitles = true
		navigationItem.largeTitleDisplayMode = .always

		searchBar.layer.borderWidth = 1
		searchBar.layer.borderColor = UIColor.systemBackground.cgColor

		tableView.tableHeaderView = searchBar
        tableView.registerCellByNib(Categories4Cell1.self)
        tableView.registerCellByNib(Items10Cell2.self)
        
		loadData()
	}

	// MARK: - Data methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func loadData() {
		categories.removeAll()
        var params = Parameter()
        params.addParam("shop", value: "tannd176865.myshopify.com")
        ListCategoryAPI(params: params).send {[weak self] result, error in
            self?.categories.append(contentsOf: result?.categories ?? [])
            self?.refreshTableView()
        }
	}

	// MARK: - Refresh methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func refreshTableView() {

		tableView.reloadData()
	}
}

// MARK: - UITableViewDataSource
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Search1View: UITableViewDataSource {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return showResult ? products.count : categories.count
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if showResult {
            guard let cell = tableView.dequeueCell(Items10Cell2.self, forIndexPath: indexPath) else {
                return UITableViewCell()
            }
            cell.bindData(index: indexPath, data: products[indexPath.row])
            return cell
        } else {
            guard let cell = tableView.dequeueCell(Categories4Cell1.self, forIndexPath: indexPath) else {
                return UITableViewCell()
            }
            cell.bindData(index: indexPath, data: categories[indexPath.row])
            return cell
        }
	}
}

// MARK: - UITableViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Search1View: UITableViewDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if showResult {
            dismiss(animated: true) { [weak self] in
                guard let self = self else {
                    return
                }
                self.delegate?.showProduct(with: self.products[indexPath.row])
            }
        } else {
            guard let id = categories[indexPath.row].id, let category = categories[indexPath.row].title else {
                return
            }
            GetProductByCategoryAPI(expand: "/collections/\(id)").send { [weak self] result, error in
                guard let self = self,
                      let result = result else {
                    return
                }
                self.showResult.toggle()
                let dispatchGroup = DispatchGroup()
                
                result.products.forEach { product in
                    guard let id = product.id else {
                        return
                    }
                    dispatchGroup.enter()
                    ProductDetailAPI(expand: "/products/\(id)").send { productDetail, error in
                        
                        self.products.append(Product(id: productDetail?.product?.id,
                                                     title: productDetail?.product?.title,
                                                     body_html: productDetail?.product?.body_html,
                                                     product_type: productDetail?.product?.product_type,
                                                     image: productDetail?.product?.image,
                                                     variants: productDetail?.product?.variants,
                                                     category: category))
                        dispatchGroup.leave()
                    }
                }
                dispatchGroup.notify(queue: .main) {
                    self.tableView.reloadData()
                }
            }
        }
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return showResult ? 85 : 150
	}
}

// MARK: - UISearchControllerDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Search1View: UISearchControllerDelegate {

}
