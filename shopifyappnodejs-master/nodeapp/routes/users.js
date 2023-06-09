var express = require('express');
var router = express.Router();
var Cart = require('../models/cart');
var User = require('../models/user');
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const auth = require("../middleware/auth");
const { formatResponse } = require("../utils/response")

router.get('/', auth, (req, res) => {
  if (req.query.id) {
    User.getUserById(req.query.id, (err, rows) => {
      if (rows.length > 0) {
        res.json(formatResponse(1, { user: rows[0] }))
      } else {
        res.json(formatResponse(0, "User not found"))
      }
    })
  } else {
    res.json(formatResponse(0, "Missing id"))
  }
});

router.post("/login", (req, res) => {

  // Our login logic starts here
  try {
    // Get user input
    const { email, password } = req.query;

    // Validate user input
    if (!(email && password)) {
      res.json(formatResponse(0, "Missing email or password"))
      return
    }
    // Validate if user exist in our database
    User.getUserByEmail(email, async (err, rows) => {
      if (err) {
        res.json(err);
      } else {
        if (rows.length == 0) {
          res.json(formatResponse(0, "User not found"))
        } else {
          let user = rows[0];
          if (user && (await bcrypt.compare(password, user.password))) {
            // Create token
            const token = jwt.sign(
              { user_id: user.id, email },
              process.env.TOKEN_KEY,
              {
                expiresIn: "1000h",
              }
            );
            User.updateToken(user.id, token, (err, rows) => {
              if (err) {
                res.json(formatResponse(0, "Error happened"))
              } else {
                res.json(formatResponse(1, { token: token }))
              }
            })
          }
        }
      }
    })
  } catch (err) {
    res.json(formatResponse(0, "Error happened"))
    console.log(err);
  }
});

router.post("/register", (req, res) => {

  try {
    // Get user input
    const { name, email, password } = req.query;

    // Validate user input
    if (!(email && password && name)) {
      res.json(formatResponse(0, "All input is required"))
      return
    }

    User.getUserByEmail(email, async (err, rows) => {
      if (err) {
        res.json(formatResponse(0, "Error happened"))
      } else {
        if (rows.length > 0) {
          res.json(formatResponse(0, "User Already Exist. Please Login"))
        } else {
          encryptedPassword = await bcrypt.hash(password, 10);

          User.addUser(name, email.toLowerCase(), encryptedPassword, "audience", (err, result) => {
            if (err) {
              res.json(formatResponse(0, "Error happened"))
            } else {
              const token = jwt.sign(
                { user_id: result.insertId, email },
                process.env.TOKEN_KEY,
                {
                  expiresIn: "2h",
                }
              );
              User.updateToken(result.insertId, token, (err, rows) => {
                if (err) {
                  res.json(formatResponse(0, "Error happened"))
                } else {
                  res.json(formatResponse(1, { token: token }))
                }
              })
            }
          })
        }
      }
    });
  } catch (err) {
    res.json(formatResponse(0, "Error happened"))
    console.log(err);
  }
});

router.get('/cart', (req, res) => {
  if (req.query.userId) {
    Cart.getCartByUserId(req.query.userId, (err, rows) => {
      if (err) {
        res.json(formatResponse(0, "Error happened"))
      } else {
        res.json(formatResponse(1, {products: rows}))
      }
    })
  } else {
    res.json(formatResponse(0, "Missing id"))
  }
})

router.post('/cart', (req, res) => {
  console.log(req.body)
  if (req.body.userId) {
    let product = {
      id: req.body.productId,
      title: req.body.productTitle,
      price: req.body.productPrice,
      originPrice: req.body.productOriginPrice,
      category: req.body.productCategory,
      thumb: req.body.productThumbnail
    }
    Cart.addCart(req.body.userId, product, 1, (err, result) => {
      if (err) {
        console.log(err)
        res.json(formatResponse(0, "Error happened"))
      } else {
        res.json(formatResponse(1, "Success")
        )
      }
    })
  } else {
    res.json(formatResponse(0, "Missing id"))
  }
})

router.put('/cart', (req, res) => {
  console.log(req.body)
  if (req.body.userId) {
    Cart.updateCart(req.body.userId, req.body.productId, req.body.quantity, (err, result) => {
      if (err) {
        console.log(err)
        res.json(formatResponse(0, "Error happened"))
      } else {
        res.json(formatResponse(1, "Success")
        )
      }
    })
  } else {
    res.json(formatResponse(0, "Missing id"))
  }
})

router.delete('/cart', (req, res) => {
  if (req.query.userId) {
    Cart.deleteCart(req.query.userId, req.query.productId, (err, result) => {
      if (err) {
        console.log(err)
        res.json(formatResponse(0, "Error happened"))
      } else {
        res.json(formatResponse(1, "Success")
        )
      }
    })
  } else {
    res.json(formatResponse(0, "Missing id"))
  }
})

module.exports = router;
