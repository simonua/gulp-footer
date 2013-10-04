//global variables
var es = require('event-stream')
  ,Header = require('./footer');

//Exports
module.exports = function(footer, options) {
  var fm = new Header(footer, options);
  return es.map(fm.mapper.bind(fm));
};
