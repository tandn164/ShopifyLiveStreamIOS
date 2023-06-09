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

//-----------------------------------------------------------------------------------------------------------------------------------------------
class Items1Cell1: UICollectionViewCell {

	@IBOutlet var imageProduct: UIImageView!
	@IBOutlet var labelTitle: UILabel!
	@IBOutlet var labelBrandName: UILabel!
	@IBOutlet var labelPrice: UILabel!
	@IBOutlet var labelOriginalPrice: UILabel!

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func awakeFromNib() {

		super.awakeFromNib()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func bindData(index: Int, data: Product) {
        let url = URL(string: data.image?.src ?? "")
        imageProduct.kf.setImage(with: url, placeholder: UIImage(named: "placeholder"))
        labelTitle.text = data.title
        labelBrandName.text = data.product_type
        labelPrice.text = "\(Util.formatNumber(Int(data.variants?.first?.price ?? "0") ?? 0))đ"
        labelOriginalPrice.text = "\(Util.formatNumber(Int(data.variants?.first?.compare_at_price ?? "0") ?? 0))đ"
        labelOriginalPrice.isHidden = data.variants?.first?.compare_at_price == nil
	}
}
