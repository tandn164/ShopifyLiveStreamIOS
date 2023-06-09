var mysql=require('mysql2');
var connection=mysql.createConnection({
    host: "localhost",
    user: "root",
    password: "anhthu@127",
    database: "shopify_livestream"
});

module.exports=connection;