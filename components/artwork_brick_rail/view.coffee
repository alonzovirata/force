Backbone = require 'backbone'
{ each } = require 'underscore'
User = require '../../models/user.coffee'
initCarousel = require '../merry_go_round/horizontal_nav_mgr.coffee'
ArtworkBrickView = require '../artwork_brick/view.coffee'
template = -> require('./templates/index.jade') arguments...

module.exports = class ArtworkBrickRailView extends Backbone.View
  className: 'abrv-container'
  subViews: []

  initialize: (options) ->
    {
      @$el,
      @title,
      @viewAllUrl,
      @railId,
      @artworks,
      @includeContact = true,
      @hasContext,
      @followAnnotation,
      @user,
      @category
    } = options

  render: ->
    @$el.html template
      artworks: @artworks
      title: @title
      viewAllUrl: @viewAllUrl
      railId: @railId
      includeContact: @includeContact
      hasContext: @hasContext
      followAnnotation: @followAnnotation
      category: @category

    @postRender()
    this

  postRender: ->
    @setupArtworkViews()
    @setupCarousel()

  setupCarousel: ->
    initCarousel @$('.js-my-carousel'),
      imagesLoaded: false
      wrapAround: false
      groupCells: true
    , (carousel) =>
      @trigger 'post-render'
      @carousel = carousel

      # Hide arrows if the cells don't fill the carousel width
      @cellWidth = @$('.js-mgr-cell')
        .map (i, e) -> $(e).outerWidth true
        .get()
        .reduce (prev, curr) -> prev + curr

      unless @cellWidth > @$('.js-my-carousel').width()
        @$('.mgr-navigation').addClass 'is-hidden'

  setupArtworkViews: ->
    if @artworks.length
      @subViews = @artworks.map ({ id }) =>
        $el = @$(".js-artwork-brick[data-id='#{id}']")
        view = new ArtworkBrickView
          el: $el
          id: id
          user: @user

        view.postRender()
        view

    @user.related().savedArtworks
      .check @artworks.map ({ id }) -> id

  remove: ->
    invoke @subViews, 'remove'
    super
