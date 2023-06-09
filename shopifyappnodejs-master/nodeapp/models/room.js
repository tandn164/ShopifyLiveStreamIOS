var db = require('../config/dbconnection');

var Room = {
	getAllRoom : function(callback) {
		return db.query("Select * from room",callback);
	},
	getRoomById : function(id, callback) {
		return db.query("select * from room where id=?",[id],callback);
	},
	addRoom : function(room, callback) {
		return db.query("Insert into room(name,rtc_token,start_time,publisher_id) values(?,?,?,?)",[
            room.name,
            room.rtc_token,
            room.start_time,
            room.publisher_id
        ], callback);
	},
	deleteRoom : function(id, callback) {
		return db.query("delete from room where id=?",[id],callback);
	},
	updateRoomEndtime : function(id,end_time,callback) {
		return db.query("update room set end_time=? where id=?",[
            end_time,
            id
        ], callback);
	}
};

module.exports = Room;