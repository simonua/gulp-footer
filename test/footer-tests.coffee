chai = require('chai')
expect = chai.expect
sinonChai = require('sinon-chai')
sinon = require('sinon')
prequire = require('proxyquire')
path = require('path')

#extend chai
chai.use sinonChai

#path to use for gulp-footer
ghPath = "../lib/footer"
ghPath = "../lib-cov/footer" if process.env.CODE_COVERAGE is 'true'

describe "Footer Class", ->

  #global harness setup
  testFile =
    shortened: 'file.ext'
    base: '/path/'
    path: '/path/file.ext'
    contents: new Buffer('content')

  fsStub = {}

  stubRead = (err, data) ->
    fsStub.readFile = sinon.spy (path, options, callback) ->
      setImmediate -> callback(err, data) #async response

  ms =
    render : (text, options) ->
      return text

  stubRender = (response) ->
    ms.render = sinon.stub().returns(response)

  Footer = prequire ghPath,
    'graceful-fs': fsStub
    'mustache' : ms


  #tests
  describe "constructor", ->
    it "will use default options", ->
      #Arrange

      #Act
      h = new Footer()

      #Assert
      expect(h._options).to.deep.equal {}
      expect(h._footer).to.be.null


    it "will use a string as a footer", ->
      #arrange

      #act
      h = new Footer('test')

      #assert
      expect(h._options).to.deep.equal {}
      expect(h._footer).to.deep.equal new Buffer('test')


    it "will take options as a first parameter", ->
      #arrange
      opts =
        file: path.resolve(__dirname, 'footer.txt')

      #act
      h = new Footer(opts)

      #assert
      expect(h._footer).to.be.null
      expect(h._options).to.deep.equal opts


    it "will take a string as a first parameter and options as a second", ->
      #arrange
      opts =
        file: 'footer.txt'

      #act
      h = new Footer('test', opts)

      #assert
      expect(h._footer).to.deep.equal new Buffer('test')
      expect(h._options).to.deep.equal opts



  describe "mapper", ->

    it "will return an error with no options specified", (next) ->
      #arrange
      h = new Footer()

      #act
      h.mapper testFile, (err,file) ->
        #assert
        expect(err).to.be.instanceOf Error
        expect(file).to.be.undefined

        next()


    it "will raise an error from fs.readFile", (next) ->
      #arrange
      expectedError = {}
      stubRead expectedError
      opts =
        file: 'someFile'
      h = new Footer opts

      #act
      h.mapper testFile, (err,file) ->
        #assert
        expect(fsStub.readFile).to.be.calledOnce
        expect(fsStub.readFile).to.be.calledWith opts.file, sinon.match.object, sinon.match.func
        expect(err).to.equal expectedError
        expect(file).to.be.undefined
        expect(h._footer).to.be.null
        next()


    it "will attempt to read a footer from options.file as a path", (next) ->
      #arrange
      expectedResult = 'footer'
      stubRead null, expectedResult
      stubRender expectedResult
      opts =
        file: 'someFile'
      h = new Footer opts

      #act
      h.mapper testFile, (err,file) ->
        #assert
        expect(fsStub.readFile).to.be.calledOnce
        expect(fsStub.readFile).to.be.calledWith opts.file, sinon.match.object, sinon.match.func
        expect(err).to.be.null
        expect(h._footer).to.deep.equal new Buffer('footer')
        next()


    it "will prepend the footer to the file content", (next) ->
      #arrange
      stubRead null, 'footer'
      stubRender 'footer'
      opts =
        file: 'someFile'
      h = new Footer 'footer', opts

      #act
      h.mapper testFile, (err,file) ->
        #assert
        expect(file.contents).to.exist
        expect(file.contents).to.be.instanceOf Buffer
        expect(file.contents).to.deep.equal new Buffer('content\r\nfooter')
        next()


    it "will format the footer via mustache", (next) ->
      #arrange
      stubRead null, 'footer'
      stubRender 'modified-footer'
      opts =
        foo: 'bar'
      h = new Footer 'footer', opts

      #act
      h.mapper testFile, (err,file) ->
        #assert
        expect(ms.render).to.be.calledOnce
        expect(ms.render).to.be.calledWith 'footer', sinon.match.object

        fmtOpts = ms.render.lastCall.args[1]

        expect(fmtOpts.foo).to.equal opts.foo
        expect(fmtOpts.filename).to.equal testFile.shortened
        expect(fmtOpts.now).to.match /^\d\d\d\d\-\d\d\-\d\dT\d\d:\d\d:\d\d(\.\d+)?Z/
        expect(fmtOpts.year).to.equal new Date().getFullYear()

        expect(file.contents).to.deep.equal new Buffer('content\r\nmodified-footer')

        next()
