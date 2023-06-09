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
class Categories4Cell1: UITableViewCell {

	@IBOutlet var imageCategory: UIImageView!
	@IBOutlet var labelCategory: UILabel!
	@IBOutlet var labelItems: UILabel!

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func bindData(index: IndexPath, data: Category) {
        let url = URL(string: data.image?.src ?? "")
        imageCategory.kf.setImage(with: url)
        labelCategory.text = data.title
        labelItems.text = data.body_html
	}
}
