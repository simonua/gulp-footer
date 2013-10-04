chai = require('chai')
expect = chai.expect
sinonChai = require('sinon-chai')
sinon = require('sinon')
prequire = require('proxyquire')
path = require('path')

#extend chai
chai.use sinonChai

#path to use for gulp-footer
ghPath = "../lib/gulp-footer"
ghPath = "../lib-cov/gulp-footer" if process.env.CODE_COVERAGE is 'true'

expected = {}  #result for event-stream .map
expectedBind = -> #result for footer .mapper.bind
footerConstructor = sinon.spy() #track footer constructor call
esMap = sinon.stub().returns(expected) #stub event-stream .map
footerStub = #footer instance for testing
  mapper :
    bind : sinon.stub().returns expectedBind

GulpFooter = prequire ghPath,
  './footer': (text,options) ->
    footerConstructor.call(null, arguments)
    return footerStub
  'event-stream':
    map: esMap


describe "gulp-footer module", ->
  footerText = "path"
  options =
    option:"test"
  result = GulpFooter footerText, options

  it "should expose a function", ->
    expect(GulpFooter).to.be.instanceOf(Function)
    expect(footerConstructor).to.have.been.calledOnce

  it "should pass footerText argument to Footer constructor", ->
    expect(footerConstructor.getCall(0).args[0][0]).to.equal footerText

  it "should pass options argument to Footer constructor", ->
    expect(footerConstructor.getCall(0).args[0][1]).to.equal options

  it "should bind the footerStub to the mapper method", ->
    expect(footerStub.mapper.bind).to.have.been.calledOnce
    expect(footerStub.mapper.bind).to.have.been.calledWith footerStub

  it "should pass the instance's mapper method to the event-stream map method", ->
    expect(esMap.calledOnce).to.be.true
    expect(esMap).to.have.been.calledWith expectedBind

  it "should return the results from event-stream map method", ->
    expect(result).to.equal expected
