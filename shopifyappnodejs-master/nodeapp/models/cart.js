var db = require('../config/dbconnection');

var Cart={
	getCartByUserId:function(id,callback){
		return db.query("select * from cart where user_id=?",[id],callback);
	},
	addCart:function(userId, product, quantity, callback){
		return db.query("Insert into cart(user_id,product_id,quantity,product_title,product_price,product_originPrice,product_category,product_thumb) values(?,?,?,?,?,?,?,?)",[userId,product.id,quantity,product.title,product.price,product.originPrice,product.category, product.thumb],callback);
	},
	deleteCart:function(userId, productId, callback){
		return db.query("delete from cart where user_id=? and product_id=?",[userId, productId],callback);
	},
	updateCart:function(userId,productId, quantity,callback){
		return db.query("update cart set quantity=? where user_id=? and product_id=?",[quantity,userId,productId],callback);
	}
};

module.exports=Cart;