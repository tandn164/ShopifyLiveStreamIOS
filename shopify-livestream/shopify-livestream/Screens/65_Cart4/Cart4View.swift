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
import Kingfisher
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

protocol Cart4ViewDelegate: AnyObject {
    func goToCheckout()
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
class Cart4View: UIViewController {

    @IBOutlet weak var addToCard: UILabel!
    @IBOutlet weak var body: UILabel!
    @IBOutlet var labelItemCount: UILabel!
	@IBOutlet var labelSubTotal: UILabel!
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var quantityLabel: UILabel!
    
    weak var delegate: Cart4ViewDelegate?
    
    var product: LiveProduct?
    var shopToken: String?
    var quantity: Int = 1
    let db = Firestore.firestore()
    

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
        quantityLabel.text = "\(quantity)"
        addToCard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addToCartAction)))
		loadData()
	}

	// MARK: - Data methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func loadData() {
        guard let id = product?.productId, let token = shopToken else {
            return
        }
        DataLocal.shopifyToken = token
        ProductDetailAPI(expand: "/products/\(id)").send { productDetail, error in
            self.labelSubTotal.text = "\(Util.formatNumber(Int(productDetail?.product?.variants[0].price ?? "0") ?? 0))đ"
            self.labelItemCount.text = productDetail?.product?.title
            let url = URL(string: productDetail?.product?.image?.src ?? "")
            self.thumbnail.kf.setImage(with: url)
            self.body.text = productDetail?.product?.body_html
            self.body.numberOfLines = 0
        }
	}

    @objc func addToCartAction() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        if quantity < 1 {
            UIAlertController.show(message: "Please choose at least one product", title: nil)
            return
        }
        let cart = CartModel(shopId: product?.shopId,
                             variantId: product?.variantId,
                             shopName: product?.shopName,
                             productId: product?.productId,
                             productThumbnail: product?.productThumbnail,
                             productTitle: product?.productTitle,
                             productCategory: product?.productCategory,
                             productPrice: product?.productPrice,
                             productOriginPrice: product?.productOriginPrice,
                             userId: uid,
                             quantity: quantity)
        
        db.collection("users").document(uid).updateData([ "cart": FieldValue.arrayUnion([cart.dictionary])])
        UIAlertController.show(message: "Success", title: nil)
        dismiss(animated: true)
    }
    
	@IBAction func actionCancel(_ sender: UIButton) {
		dismiss(animated: true)
	}

	@IBAction func actionCheckout(_ sender: UIButton) {
        dismiss(animated: true) {
            self.delegate?.goToCheckout()
        }
	}
    @IBAction func plusAction(_ sender: UIButton) {
        quantity += 1
        quantityLabel.text = "\(quantity)"
    }
    
    @IBAction func minusAction(_ sender: UIButton) {
        if quantity > 0 {
            quantity -= 1
            quantityLabel.text = "\(quantity)"
        }
    }
}
