const moment = require('moment');

function formatMessage(username, text) {
  return {
    username,
    text,
    time: moment().format('h:mm a')
  };
}

function formatProduct(id, title, thumbnail) {
  return {
    id,
    title,
    thumbnail
  };
}

function formatInvitation(userId) {
  return {
    userId
  };
}

module.exports = {
  formatMessage,
  formatProduct,
  formatInvitation
}