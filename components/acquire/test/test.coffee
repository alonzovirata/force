benv = require 'benv'
Backbone = require 'backbone'
acquireArtwork = require('../view.coffee').acquireArtwork
sinon = require 'sinon'

describe 'AcquireArtwork Component', ->

  before (done) ->
    benv.setup =>
      benv.expose { $: benv.require 'jquery' }
      Backbone.$ = $
      done()

  after ->
    benv.teardown()

  describe '#acquireArtwork', ->

    beforeEach ->
      sinon.stub Backbone, 'sync'
      @target = { removeClass: -> }
      @editionSetId = null
      @artwork = new Backbone.Model(id: 'artwork-id')
      sinon.stub location, 'reload'
      sinon.stub location, 'assign'

    afterEach ->
      Backbone.sync.restore()
      location.reload.restore()
      location.assign.restore()

    it 'redirects to correct order resume url', ->
      acquireArtwork(@artwork, @target, @editionSetId)
      Backbone.sync.args[0][2].success
        id: 'order-id'
        token: 'order-token'
      location.assign.args[0][0].should.containEql '/order/order-id/resume?token=order-token'
