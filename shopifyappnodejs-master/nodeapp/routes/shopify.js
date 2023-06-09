var express = require('express');
var router = express.Router();
var url = require('url');
var verifyCall = require('../tools/verify');
var request = require('request-promise');

//upload image section
var multer = require('multer');
var storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, './public/uploads');
    },
    filename: function (req, file, cb) {



        cb(null, file.originalname);
    }
});
const imageFilter = function (req, file, cb) {
    if (!file.originalname.match(/\.(jpg|png|gif|PNG|JPG|jpeg|JPEG)$/)) {
        return cb(new Error('Only image files are allowed.'), false);
    }
    cb(null, true);
};
var limit = { fileSize: 8000000 };

var upload = multer({ storage: storage, limits: limit, fileFilter: imageFilter }).array('file', 50);
//end upload image section

router.get('/install', function (req, res, next) {
    var shop = req.query.shop;
    var appId = process.env.appId;

    var appSecret = process.env.appSecret;
    var appScope = process.env.appScope;
    var appDomain = process.env.appDomain;

    //build the url
    var installUrl = `https://${shop}/admin/oauth/authorize?client_id=${appId}&scope=${appScope}&redirect_uri=https://${appDomain}/shopify/auth`;
    // var installUrl = `https://tannd176865.myshopify.com/admin/oauth/install_custom_app?client_id=ca55bfa331d5dad3456dd37aa9aed3ba&signature=eyJfcmFpbHMiOnsibWVzc2FnZSI6ImV5SmxlSEJwY21WelgyRjBJam94TmpVNU1ERXpOall6TENKd1pYSnRZVzVsYm5SZlpHOXRZV2x1SWpvaWRHRnVibVF4TnpZNE5qVXViWGx6YUc5d2FXWjVMbU52YlNJc0ltTnNhV1Z1ZEY5cFpDSTZJbU5oTlRWaVptRXpNekZrTldSaFpETTBOVFprWkRNM1lXRTVZV1ZrTTJKaElpd2ljSFZ5Y0c5elpTSTZJbU4xYzNSdmJWOWhjSEFpZlE9PSIsImV4cCI6IjIwMjItMDgtMDRUMTM6MDc6NDMuODMzWiIsInB1ciI6bnVsbH19--ee27b68294487debacd179a9e914a3314f33f888&redirect_uri=https://${appDomain}/shopify/auth`
    //Do I have the token already for this store?
    //Check database
    //For tutorial ONLY - check .env variable value
    if (process.env.appStoreTokenTest?.length > 0) {
        res.redirect('/shopify/app?shop=' + shop);
    } else {
        //go here if you don't have the token yet
        res.redirect(installUrl);
    }

});

router.get('/auth', function (req, res, next) {
    let securityPass = false;
    let appId = process.env.appId;
    let appSecret = process.env.appSecret;
    let shop = req.query.shop;
    let code = req.query.code;


    const regex = /^[a-z\d_.-]+[.]myshopify[.]com$/;

    if (shop.match(regex)) {
        console.log('regex is ok');
        securityPass = true;
    } else {
        //exit
        securityPass = false;
    }

    // 1. Parse the string URL to object
    let urlObj = url.parse(req.url);
    // 2. Get the 'query string' portion
    let query = urlObj.search.slice(1);
    if (verifyCall.verify(query)) {
        //get token
        console.log('get token');
        securityPass = true;
    } else {
        //exit
        securityPass = false;
    }

    if (securityPass && regex) {

        //Exchange temporary code for a permanent access token
        let accessTokenRequestUrl = 'https://' + shop + '/admin/oauth/access_token';
        let accessTokenPayload = {
            client_id: appId,
            client_secret: appSecret,
            code,
        };

        request.post(accessTokenRequestUrl, { json: accessTokenPayload })
            .then((accessTokenResponse) => {
                let accessToken = accessTokenResponse.access_token;
                console.log('shop token ' + accessToken);

                res.redirect('/shopify/app?token=' + accessToken);
            })
            .catch((error) => {
                res.status(error.statusCode).send(error.error.error_description);
            });
    }
    else {
        res.redirect('/installerror');
    }

});


router.get('/app', function (req, res, next) {
    let url =`https://tannn.free.beeceptor.com?token=${req.query.token}`
    
    res.render('app', { url: url });
});
router.post('/app/create-product', function (req, res) {

    //this is what we need to post
    // POST /admin/products.json
    // {
    //   "product": {
    //     "title": "Burton Custom Freestyle 151",
    //     "body_html": "<strong>Good snowboard!</strong>",
    //     "vendor": "Burton",
    //     "product_type": "Snowboard",
    //     "tags": "Barnes & Noble, John's Fav, &quot;Big Air&quot;"
    //   }
    // }



    let new_product = {
        product: {
            title: req.body.title,
            body_html: req.body.body_html,
            vendor: req.body.vendor,
            product_type: req.body.product_type,
            tags: req.body.tags
        }
    };
    console.log(req.query.shop);
    let url = 'https://' + req.query.shop + '/admin/products.json';

    let options = {
        method: 'POST',
        uri: url,
        json: true,
        resolveWithFullResponse: true,//added this to view status code
        headers: {
            'X-Shopify-Access-Token': process.env.appStoreTokenTest,
            'content-type': 'application/json'
        },
        body: new_product//pass new product object - NEW - request-promise problably updated
    };

    request.post(options)
        .then(function (response) {
            console.log(response.body);
            if (response.statusCode == 201) {
                res.json(true);
            } else {
                res.json(false);
            }

        })
        .catch(function (err) {
            console.log(err);
            res.json(false);
        });


});

router.post('/app/file-upload', function (req, res, next) {

    try {
        upload(req, res, function (err) {

            if (err) {
                if (err.code == 'LIMIT_FILE_SIZE') {
                    console.log(err);
                    res.status(413).json({ error: err.message });
                } else {
                    console.log(err);
                    res.status(413).json({ error: err.message });
                }
            } else {
                //upload to Shopify
                console.log(req.query.filename);


                let url = 'https://' + req.query.shop + '/admin/products/' + req.query.id + '.json';

                let update_product = {
                    product: {
                        id: req.query.id,
                        images: [
                            {
                                src: 'https://' + process.env.appDomain + '/uploads/' + req.query.filename
                            }
                        ]
                    }
                };

                let options = {
                    method: 'PUT',
                    uri: url,
                    json: true,
                    resolveWithFullResponse: true,//added this to view status code
                    headers: {
                        'X-Shopify-Access-Token': process.env.appStoreTokenTest,
                        'content-type': 'application/json'
                    },
                    body: update_product
                };

                request.put(options)
                    .then(function (response) {
                        console.log(response.body);
                        if (response.statusCode == 200) {
                            res.send({ message: 'uploaded' });
                        } else {
                            res.send({ message: 'fail to upload' });
                        }

                    })
                    .catch(function (err) {
                        console.log(err);
                        res.send({ message: 'error' });
                    });

            }

        });
    } catch (error) {
        console.log(error);
    }


});

router.post('/app/delete', function (req, res) {

    let url = 'https://' + req.query.shop + '/admin/products/' + req.query.id + '.json';

    let options = {
        method: 'DELETE',
        uri: url,
        resolveWithFullResponse: true,//added this to view status code
        headers: {
            'X-Shopify-Access-Token': process.env.appStoreTokenTest,
            'content-type': 'application/json'
        }
    };

    request.delete(options)
        .then(function (response) {
            console.log(response.body);
            if (response.statusCode == 200) {
                res.json(true);
            } else {
                res.json(false);
            }

        })
        .catch(function (err) {
            console.log(err);
            res.json(false);
        });
});

router.get('/app/products', function (req, res, next) {

    let url = 'https://' + req.query.shop + '/admin/products.json';

    let options = {
        method: 'GET',
        uri: url,
        json: true,
        headers: {
            'X-Shopify-Access-Token': process.env.appStoreTokenTest,
            'content-type': 'application/json'
        }
    };

    request(options)
        .then(function (parsedBody) {
            console.log(parsedBody);
            res.json(parsedBody);
        })
        .catch(function (err) {
            console.log(err);
            res.json(err);
        });


});

router.post('/app/orders', function (req, res, next) {

    let url = 'https://' + req.query.shop + '/admin/orders.json';
    let new_order = {
        order: {
            line_items: [
                {
                  "variant_id": 43030533275905,
                  "quantity": 1
                }
              ],
        }
    };
    let options = {
        method: 'POST',
        uri: url,
        json: true,
        headers: {
            'X-Shopify-Access-Token': process.env.appStoreTokenTest,
            'content-type': 'application/json'
        },
        body: new_order
    };

    request(options)
        .then(function (parsedBody) {
            console.log(parsedBody);
            res.json(parsedBody);
        })
        .catch(function (err) {
            console.log(err);
            res.json(err);
        });


});

router.post('/app/variants', function (req, res, next) {

    let url = 'https://' + req.query.shop + '/admin/variants.json';
    let new_variant = {
        variant: {
            product_id: 7747046539521,
            options: "Yellow",
            price: "1.00"
        }
    };
    let options = {
        method: 'POST',
        uri: url,
        json: true,
        headers: {
            'X-Shopify-Access-Token': process.env.appStoreTokenTest,
            'content-type': 'application/json'
        },
        body: new_variant
    };

    request(options)
        .then(function (parsedBody) {
            console.log(parsedBody);
            res.json(parsedBody);
        })
        .catch(function (err) {
            console.log(err);
            res.json(err);
        });
});

router.post('/app/create_collection', function (req, res) {

    let url = 'https://' + req.query.shop + '/admin/custom_collections.json';
    let new_collection = {
        custom_collection: {
            title: req.query.title,
            body_html: req.query.body_html
        }
    };

    let options = {
        method: 'POST',
        uri: url,
        json: true,
        resolveWithFullResponse: true,//added this to view status code
        headers: {
            'X-Shopify-Access-Token': process.env.appStoreTokenTest,
            'content-type': 'application/json'
        },
        body: new_collection
    };

    request.post(options)
        .then(function (response) {
            console.log(response.statusCode);
            if (response.statusCode >= 200 && response.statusCode < 300) {
                res.json(true);
            } else {
                res.json(false);
            }

        })
        .catch(function (err) {
            console.log(err);
            res.json(false);
        });
});

module.exports = router;