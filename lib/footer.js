//global variables
var es = require('event-stream')
  ,fs = require('graceful-fs')
  ,path = require('path')
  ,clone = require('clone')
  ,extend = require('xtend')
  ,Mustache = require('mustache')
  ,EventEmitter = require('events').EventEmitter;
;

module.exports = Footer;
Footer.prototype.mapper = mapper;
Footer.prototype._getFooterText = getFooterText;
Footer.prototype._startRead = startRead;

//Module constructor
function Footer(footerText, options) {
  //passed in options directly, no footerText
  //shift params out
  if (typeof footerText !== "string" && typeof options === "undefined") {
    options = footerText;
    footerText = null;
  }

  this._footer = footerText ? new Buffer(footerText) : null;
  this._options = extend({}, clone(options));
  this._emitter = null;

  return this;
}


//Footer.prototype.mapper - EventStream mapper function for adding a footer to a file
function mapper(file, cb) {
  //get footerText
  var h = this;

  this._getFooterText(function(err,footerText) {
    //unable to get footer text
    if (err) return cb(err);

    //add filename, now and year to the options for formatting
    var fmtOptions = extend({}, h._options, {
      filename:file.shortened
      , now:new Date().toISOString()
      , year: new Date().getFullYear()
    });

    var newFile = clone(file);
    var footerText = Mustache.render(footerText.toString('utf8'), fmtOptions)
    newFile.contents = Buffer.concat([
      new Buffer(newFile.contents)
      ,new Buffer('\r\n')
      ,new Buffer(footerText)
    ]);
    return cb(null,newFile);
  });
}


//Footer.prototype._getFooterText - gets the footer text for the module instance
function getFooterText(callback) {
  //already have the footer text, use it
  if (this._footer) return callback(null, this._footer);

  //has options for a file
  if (this._options && this._options.file) {
    //init read process, bind events for callback
    return (this._emitter || this._startRead()).on('error', callback.bind(this)).on('text', callback.bind(this,null));
  }

  return callback(new Error("No footerText or file option specified."));
}

//Footer.prototype._startRead()
function startRead() {

  var h = this;
  fs.readFile(this._options.file, {encoding:'utf8'}, function(err, contents) {
    //cleanup emitter
    var em = h._emitter; //reference to original emitter
    h._emitter = null; //cleanup object handler

    //error reading file
    if (err) return em.emit('error', err);

    //read file, assign value to buffer, and emit the text event
    h._footer = new Buffer(contents); //save reference
    em.emit('text', h._footer); //emit text event
  });

  return h._emitter = new EventEmitter();
}