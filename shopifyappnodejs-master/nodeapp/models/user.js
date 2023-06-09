var db = require('../config/dbconnection');

var User = {
	getUserById : function(id, callback) {
		return db.query("select * from user where id=?",[id],callback);
	},
	addUser: function(name, email, password, role, callback) {
		return db.query("Insert into user(name,email,password,role) values(?,?,?,?)",[
            name,
            email,
            password,
            role
        ], callback);
	},
	updateToken : function(id,token,callback) {
		return db.query("update user set token=? where id=?",[
            token,
            id
        ], callback);
	},
    getUserByEmail : function(email, callback) {
		return db.query("select * from user where email=?",[email],callback);
	},
};

module.exports = User;