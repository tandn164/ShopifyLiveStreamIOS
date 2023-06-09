var express = require('express');
var router = express.Router();
var url = require('url');
var verifyCall = require('../tools/verify');
//var config = require('../config/config.json'); //testing
/* GET home page. */
router.get('/', function (req, res, next) {
	var shop = "tannd176865.myshopify.com"
	var appId = process.env.appId;
    var appScope = process.env.appScope;
    var appDomain = process.env.appDomain;
    var url = `https://${shop}/admin/oauth/authorize?client_id=${appId}&scope=${appScope}&redirect_uri=https://${appDomain}/shopify/auth`;
	res.render('index', { url: url });
});

module.exports = router;
