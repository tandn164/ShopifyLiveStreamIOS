var express = require('express');
var router = express.Router();
var url = require('url');
var verifyCall = require('../tools/verify');
const cors = require('cors');
const {RtcTokenBuilder, RtcRole} = require('agora-access-token');

// Agora token
const PORT = process.env.PORT || 8080;
const nocache = (_, resp, next) => {
  resp.header('Cache-Control', 'private, no-cache, no-store, must-revalidate');
  resp.header('Expires', '-1');
  resp.header('Pragma', 'no-cache');
  next();
}

var rtcToken = "";

const ping = (req, resp) => {
  resp.send({message: 'pong'});
}

const generateRTCToken = (req, resp) => {
  // set response header
  resp.header('Access-Control-Allow-Origin', '*');
  // get channel name
  console.log(req.query)
  const channelName = req.query.channel;
  if (!channelName) {
    return resp.status(500).json({ 'error': 'channel is required' });
  }
  // get uid
  let uid = req.query.UID;
  console.log(uid)
  if(!uid || uid === '') {
    return resp.status(500).json({ 'error': 'uid is required' });
  }
  console.log(req.query.role)
  // get role
  let role;
  if (req.query.role === 'publisher') {
    role = RtcRole.PUBLISHER;
  } else if (req.query.role === 'audience') {
    role = RtcRole.SUBSCRIBER
  } else {
    return resp.status(500).json({ 'error': 'role is incorrect' });
  }
  // get the expire time
  let expireTime = req.query.expiry;
  if (!expireTime || expireTime === '') {
    expireTime = 3600;
  } else {
    expireTime = parseInt(expireTime, 10);
  }
  // calculate privilege expire time
  const currentTime = Math.floor(Date.now() / 1000);
  const privilegeExpireTime = currentTime + expireTime;
  // build the token
  let token;

  if (req.query.tokenType === 'userAccount') {
    token = RtcTokenBuilder.buildTokenWithAccount(process.env.agoraID, process.env.agoraCert, channelName, uid, role, privilegeExpireTime);
  } else if (req.query.tokenType === 'uid') {
    token = RtcTokenBuilder.buildTokenWithUid(process.env.agoraID, process.env.agoraCert, channelName, uid, role, privilegeExpireTime);
    console.log(token);
  } else {
    return resp.status(500).json({ 'error': 'token type is invalid' });
  }
  // return the token
  rtcToken = token;
  return resp.json({ 'rtcToken': token });
}

const getRTCToken = (req, resp) => {
    return resp.json({ 'rtcToken': rtcToken });
}

router.options('*', cors());
router.get('/ping', nocache, ping)
router.get('/', nocache , generateRTCToken);
router.get('/token', nocache, getRTCToken)

module.exports = router;
