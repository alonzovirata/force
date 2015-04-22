sinon = require 'sinon'
moment = require 'moment'
Auction = require '../../models/auction'

describe 'Auction', ->
  describe '#calculateAuctionState', ->
    before ->
      # moment#unix returns seconds
      # sinon#useFakeTimers accepts milliseconds
      now = moment([2010, 0, 15]).unix() * 1000
      @clock = sinon.useFakeTimers now
      @auction = new Auction

    after ->
      @clock.restore()

    it 'returns with the correct state (closed)', ->
      start = moment().subtract(1, 'minutes').format()
      end = moment().subtract(3, 'minutes').format()
      @auction.calculateAuctionState(start, end).should.equal 'closed'

    it 'returns with the correct state (preview)', ->
      start = moment().add(1, 'minutes').format()
      end = moment().add(3, 'minutes').format()
      @auction.calculateAuctionState(start, end).should.equal 'preview'

    it 'returns with the correct state (open)', ->
      start = moment().subtract(1, 'minutes').format()
      end = moment().add(3, 'minutes').format()
      @auction.calculateAuctionState(start, end).should.equal 'open'

    it 'accomdates offsets', ->
      start = moment().subtract(1, 'seconds').format()
      end = moment().add(1, 'seconds').format()
      @auction.calculateAuctionState(start, end, 0).should.equal 'open'
      @auction.calculateAuctionState(start, end, -999).should.equal 'open'
      @auction.calculateAuctionState(start, end, -1000).should.equal 'closed'

  describe '#parse', ->
    beforeEach ->
      @clock = sinon.useFakeTimers()
      @auction = new Auction
        auction_state: 'open' # An incorrect state 'returned from the server'
        start_at: moment().subtract(1, 'minutes').format()
        end_at: moment().subtract(3, 'minutes').format()
      , parse: true

    afterEach ->
      @clock.restore()

    it 'corrects the state', ->
      @auction.get('auction_state').should.equal 'closed'