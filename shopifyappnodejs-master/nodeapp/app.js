// Initialize Firebase
var express = require('express');
var path = require('path');
const http = require('http');
const socketio = require('socket.io');
var favicon = require('serve-favicon');
var logger = require('morgan');
var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser');

var index = require('./routes/index');
var users = require('./routes/users');
var agora = require('./routes/agoraToken');
var shopify = require('./routes/shopify');
var serveIndex = require('serve-index');

const {formatMessage, formatProduct, formatInvitation} = require('./utils/messages');
const {
  userJoin,
  getCurrentUser,
  userLeave,
  getRoomUsers
} = require('./utils/users');

require('dotenv').config();
var app = express();
const server = http.createServer(app);
const io = socketio(server);

// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'hbs');

// uncomment after placing your favicon in /public
//app.use(favicon(path.join(__dirname, 'public', 'favicon.ico')));
app.use(logger('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

// Socket io
// Run when client connects
const botName = 'Bot';

io.on('connection', socket => {
  console.log("New socket connection: " + socket.id)

  socket.on('joinRoom', ({ username, room, userId, agoraId }) => {

    const user = userJoin(socket.id, username, room, userId, agoraId);
    if (user == null || user.room == null) {
      return
    }
    socket.join(user.room);

    // Welcome current user
    socket.emit('message', formatMessage(botName, 'Welcome to Stream!'));

    // Broadcast when a user connects
    socket.broadcast
      .to(user.room)
      .emit(
        'message',
        formatMessage(botName, `${user.username} has joined the chat`)
      );


    // Send users and room info
    io.to(user.room).emit('roomUsers', {
      room: user.room,
      users: getRoomUsers(user.room)
    });
  });

  // Listen for chatMessage
  socket.on('chatMessage', ({msg}) => {
    const user = getCurrentUser(socket.id);
    if (user == null || user.room == null) {
      return
    }

    io.to(user.room).emit('message', formatMessage(user.username, msg));
  });

  // Listen for invitation
  socket.on('inviteUser', ({userId}) => {
    const user = getCurrentUser(socket.id);
    if (user == null || user.room == null) {
      return
    }

    io.to(user.room).emit('invite', formatInvitation(userId));
  });

  // Listen for invitation
  socket.on('kickUser', ({userId}) => {
    const user = getCurrentUser(socket.id);
    if (user == null || user.room == null) {
      return
    }

    io.to(user.room).emit('kick', formatInvitation(userId));
  });

  // Listen for invitation
  socket.on('endStream', () => {
    const user = getCurrentUser(socket.id);
    if (user == null || user.room == null) {
      return
    }
    io.to(user.room).emit('end');
  });

  // Listen for showProduct
  socket.on('showProduct', ({shopId, variantId, shopName, productId, productTitle, productThumbnail, productPrice, productOriginPrice, productCategory}) => {

    const user = getCurrentUser(socket.id);
    if (user == null || user.room == null) {
      return
    }
    let product = {
      shopId: shopId,
      variantId: variantId,
      shopName: shopName,
      product_Id: productId,
      product_title: productTitle,
      product_thumb: productThumbnail,
      product_price: productPrice,
      product_originPrice: productOriginPrice,
      product_category: productCategory
    }
    io.to(user.room).emit('product', product)
  })

  socket.on('removeProduct', ({productId}) => {

    const user = getCurrentUser(socket.id);
    if (user == null || user.room == null) {
      return
    }
    let product = {
      product_Id: productId
    }
    io.to(user.room).emit('remove_product', product)
  })

  // Runs when client disconnects
  socket.on('disconnect', () => {
    const user = userLeave(socket.id);
if (user == null || user.room == null) {
      return
    }
    if (user) {
      io.to(user.room).emit(
        'message',
        formatMessage(botName, `${user.username} has left the chat`)
      );

      // Send users and room info
      io.to(user.room).emit('roomUsers', {
        room: user.room,
        users: getRoomUsers(user.room)
      });
    }
  });
});

server.listen(3001, () => console.log(`Server running on port 3001`));

app.use('/', index);
app.use('/users', users);
app.use('/shopify', shopify);
app.use('/rtc', agora);

// catch 404 and forward to error handler
app.use(function (req, res, next) {
  var err = new Error('Not Found');
  err.status = 404;
  next(err);
});

// error handler
app.use(function (err, req, res, next) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  // render the error page
  res.status(err.status || 500);
  res.render('error');
});

app.use('/.well-known', express.static('.well-known'), serveIndex('.well-known'));

module.exports = app;
