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
class Items4Cell1: UITableViewCell {

	@IBOutlet var imageProduct: UIImageView!
	@IBOutlet var labelTitle: UILabel!
	@IBOutlet var labelBrandName: UILabel!
	@IBOutlet var labelPrice: UILabel!
	@IBOutlet var labelOriginalPrice: UILabel!
	@IBOutlet var labelItems: UILabel!
	@IBOutlet var buttonAddItem: UIButton!
	@IBOutlet var buttonRemoveItem: UIButton!

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func awakeFromNib() {
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func bindData(index: IndexPath, data: LiveProduct) {
        let url = URL(string: data.productThumbnail ?? "")
        imageProduct.kf.setImage(with: url)
        labelTitle.text = data.productTitle
        labelBrandName.text = data.productCategory
        labelItems.text = "\(0)"
        labelPrice.text = "\(Util.formatNumber(data.productPrice ?? 0))đ"
        labelOriginalPrice.text = "\(Util.formatNumber(data.productOriginPrice ?? 0))đ"
        labelOriginalPrice.isHidden = data.productOriginPrice == nil
	}

	// MARK: - User actions
	//-------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionAddItem(_ sender: UIButton) {

		print(#function)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionRemoveItem(_ sender: UIButton) {

		print(#function)
	}
}
