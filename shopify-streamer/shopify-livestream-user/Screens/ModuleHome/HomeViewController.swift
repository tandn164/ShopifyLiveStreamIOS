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
import FirebaseAuth

//-----------------------------------------------------------------------------------------------------------------------------------------------
class HomeViewController: BaseViewController {

	@IBOutlet var imageProfile: UIImageView!
	@IBOutlet var buttonProfile: UIButton!
	@IBOutlet var labelTitle: UILabel!
	@IBOutlet var collectionViewSlider: UICollectionView!
	@IBOutlet var pageControl: UIPageControl!
    @IBOutlet weak var categoryCollection: UICollectionView!
    @IBOutlet weak var categoryName: UILabel!
    
    @IBOutlet var collectionViewProducts: UICollectionView!
	@IBOutlet var layoutConstraintProductsHeight: NSLayoutConstraint!

	private var products: [[Product]] = []
    private var categories: [Category] = []
    private var firstLoad: [Bool] = []
    
    private var currentCategory = 0

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        collectionViewSlider.registerCellByNib(Home1Cell1.self)
        collectionViewProducts.registerCellByNib(Items1Cell1.self)
        categoryCollection.registerCellByNib(HomeCategoryCollectionViewCell.self)
        categoryCollection.delegate = self
        categoryCollection.dataSource = self
		loadData()
	}
	// MARK: - Data methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func loadData() {

        let user = DataLocal.getData(forKey: AppKey.userInfo) as? User
        labelTitle.text = user?.storeName
        products.removeAll()
        categories.removeAll()
        firstLoad.removeAll()
        currentCategory = 0
        
        var params = Parameter()
        params.addParam("shop", value: "tannd176865.myshopify.com")
        ListCategoryAPI(params: params).send {[weak self] result, error in
            guard let self = self else {
                return
            }
            
            let dispatchGroup = DispatchGroup()
            var newCategory: [Category] = []
            
            result?.categories.forEach { category in
                guard let id = category.id else {
                    return
                }
                dispatchGroup.enter()
                GetProductByCategoryAPI(expand: "/collections/\(id)").send { result, error in
                    guard let result = result else {
                        newCategory.append(Category(id: category.id,
                                                    title: category.title,
                                                    body_html: category.body_html,
                                                    image: category.image,
                                                    products: nil))
                        dispatchGroup.leave()
                        return
                    }
                    
                    newCategory.append(Category(id: category.id, title: category.title, body_html: category.body_html, image: category.image, products: result.products))
                    dispatchGroup.leave()
                }
            }
            dispatchGroup.notify(queue: .main) {
                self.categories = newCategory
                self.categories.forEach { _ in
                    self.firstLoad.append(true)
                    self.products.append([])
                }
                let dispatchGroup2 = DispatchGroup()
                var newProduct: [Product] = []
                self.categories.first?.products?.forEach({ product in
                    guard let id = product.id else {
                        return
                    }
                    dispatchGroup2.enter()
                    ProductDetailAPI(expand: "/products/\(id)").send { productDetail, error in
                        newProduct.append(Product(id: product.id,
                                                  title: product.title,
                                                  body_html: product.body_html,
                                                  product_type: product.product_type,
                                                  image: product.image,
                                                  variants: productDetail?.product?.variants,
                                                  category: self.categories.first?.title))
                        dispatchGroup2.leave()
                    }
                })
                dispatchGroup2.notify(queue: .main) { [weak self] in
                    guard let self = self else {
                        return
                    }
                    if self.products.count > 0 {
                        self.products[0] = newProduct
                    }
                    if self.firstLoad.count > 0 {
                        self.firstLoad[0] = false
                    }
                    self.refreshCollectionViewProducts()
                }
                self.pageControl.numberOfPages = self.categories.count
                self.refreshCollectionViewSlider()
            }
        }
    }

	// MARK: - Refresh methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func refreshCollectionViewSlider() {

		collectionViewSlider.reloadData()
        categoryCollection.reloadData()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func refreshCollectionViewProducts() {
		collectionViewProducts.reloadData()
        layoutConstraintProductsHeight.constant = collectionViewProducts.collectionViewLayout.collectionViewContentSize.height
        
	}

	// MARK: - User actions
	//-------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionProfile(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            DataLocal.saveData(forKey: AppKey.userInfo, nil)
            let vc = SwitcherViewController()
            if #available(iOS 13.0, *) {
                UIApplication.shared.windows.first?.rootViewController = vc
                UIApplication.shared.windows.first?.makeKeyAndVisible()
            } else {
                UIApplication.shared.keyWindow?.set(rootViewController: vc)
            }
        } catch {
        }
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionSeeAll(_ sender: UIButton) {

		print(#function)
		dismiss(animated: true)
	}
}

// MARK: - UICollectionViewDataSource
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension HomeViewController: UICollectionViewDataSource {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in collectionView: UICollectionView) -> Int {

		return 1
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if (collectionView == collectionViewSlider) {
            return categories.count
        } else if (collectionView == collectionViewProducts) {
            if products.count > 0 {
                return products[currentCategory].count
            } else {
                return 0
            }
        } else if (collectionView == categoryCollection) {
            return categories.count
        } else {
            return 0
        }
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

		if (collectionView == collectionViewSlider) {
            guard let cell = collectionView.dequeueCell(Home1Cell1.self, forIndexPath: indexPath) else {
                return UICollectionViewCell()
            }
            cell.bindData(data: categories[indexPath.item])
			return cell
		}

		if (collectionView == collectionViewProducts) {
            guard let cell = collectionView.dequeueCell(Items1Cell1.self, forIndexPath: indexPath) else {
                return UICollectionViewCell()
            }
			cell.bindData(index: indexPath.item, data: products[currentCategory][indexPath.row])
			return cell
		}

        if (collectionView == categoryCollection) {
            guard let cell = collectionView.dequeueCell(HomeCategoryCollectionViewCell.self, forIndexPath: indexPath) else {
                return UICollectionViewCell()
            }
            cell.bindData(categories[indexPath.item], currentCategory == indexPath.row)
            return cell
        }
        
		return UICollectionViewCell()
	}
}

// MARK: - UICollectionViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension HomeViewController: UICollectionViewDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

		if (collectionView == collectionViewSlider) {
		}
		if (collectionView == collectionViewProducts) {
		}
        if (collectionView == categoryCollection) {
            currentCategory = indexPath.item
            categoryName.text = categories[currentCategory].title
            self.categoryCollection.reloadData()
            if firstLoad[currentCategory] {
                let dispatchGroup2 = DispatchGroup()
                var newProduct: [Product] = []
                self.categories[currentCategory].products?.forEach({ product in
                    guard let id = product.id else {
                        return
                    }
                    dispatchGroup2.enter()
                    ProductDetailAPI(expand: "/products/\(id)").send { [weak self] productDetail, error in
                        newProduct.append(Product(id: product.id,
                                                  title: product.title,
                                                  body_html: product.body_html,
                                                  product_type: product.product_type,
                                                  image: product.image,
                                                  variants: productDetail?.product?.variants,
                                                  category: self?.categories[self?.currentCategory ?? 0].title))
                        dispatchGroup2.leave()
                    }
                })
                dispatchGroup2.notify(queue: .main) {
                    self.products[self.currentCategory] = newProduct
                    self.firstLoad[self.currentCategory] = false
                    self.refreshCollectionViewProducts()
                }
            } else {
                self.refreshCollectionViewProducts()
            }
        }
	}
}

// MARK: - UICollectionViewDelegateFlowLayout
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension HomeViewController: UICollectionViewDelegateFlowLayout {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
		if (collectionView == collectionViewSlider) {
			return collectionView.frame.size
		} else if (collectionView == collectionViewProducts) {
			let width = (collectionView.frame.size.width-15)/2
            return CGSize(width: width, height: width * 1.2)
		} else if (collectionView == categoryCollection) {
            return CGSize(width: 120, height: 50)
        } else {
            return CGSize.zero
        }
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {

		if (collectionView == collectionViewSlider)		{ return 0 }
		if (collectionView == collectionViewProducts)	{ return 15 }
        if (collectionView == categoryCollection)    { return 15 }

		return 0
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {

		if (collectionView == collectionViewSlider)		{ return 0 }
		if (collectionView == collectionViewProducts)	{ return 15 }
        if (collectionView == categoryCollection)    { return 15 }

		return 0
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

		if (collectionView == collectionViewSlider)		{ return UIEdgeInsets.zero }
		if (collectionView == collectionViewProducts)	{ return UIEdgeInsets.zero }

		return UIEdgeInsets.zero
	}
}

// MARK: - UIScrollViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension HomeViewController: UIScrollViewDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

		let visibleRect = CGRect(origin: collectionViewSlider.contentOffset, size: collectionViewSlider.bounds.size)
		let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)

		if let visibleIndexPath = collectionViewSlider.indexPathForItem(at: visiblePoint) {
			pageControl.currentPage = visibleIndexPath.row
		}
	}
}
