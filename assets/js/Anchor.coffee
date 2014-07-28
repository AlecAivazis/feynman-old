# this file describes the anchor class as needed by the online feynman diagram tool
# the anchor acts as the main structural element by providing two ends to connect

class Anchor

  element = null
  
  constructor: (@paper, @x, @y, @radius = 10, @snapRange = 21) ->
    @lines = []
    @paper.anchors.push this

    # default values
    @color = 'black'
    @fixed = false

  # add a line to the list of connected elements
  addLine: (element) =>
    @lines.push element

  # update the anchor element on the user interface
  draw: =>

    # default status is not selected
    isSelected = false
    
    # if a element was previously defined
    if @element
      # and im selected
      if @element.hasClass('selectedElement')
        if not @fixed
          isSelected = true

      # remove it
      @element.remove()

    # add the circle at the appropriate location with the on move event handler
    @element = @paper.circle(@x, @y, @radius).attr
      fill: if @color then @color else 'black'

    @element.anchor = this

    if isSelected
      @element.addClass('selectedElement')
    if @fixed
      @element.addClass('fixed')

    @element.drag @onMove, @dragStart, @dragEnd

    # when you click on the circle
    @element.node.onclick = =>
      event.stopPropagation()
      $(document).trigger 'selectedElement', [this, 'anchor']

    # update the associated lines
    _.each @lines, (line) ->
      line.draw()
      
  # at the end of the drag
  dragEnd: (x, y, event) =>
    # for each anchor
    _.each @paper.anchors, (anchor) =>
      # check if there is any anchor that it within snapRange of me
      _.each @paper.anchors, (compare) =>
        # compute the distance between me and the other anchor
        dx = anchor.x - compare.x
        dy = anchor.y - compare.y
  
        # check if the other anchor is within snap range
        if @snapRange * @snapRange > dx*dx + dy*dy
          # if it is then merge the two
          compare.merge anchor

    # clear the target anchor
    @targetAnchor = undefined

    # draw any labels that need to be
    _.each _.compact(@lines), (line)->
      line.drawLabel()

  dragStart: (x, y, event) =>
    # check if there are multiple selected
    event.stopPropagation()

    # select this event

    # record the location before the drag
    @origin_x = @x
    @origin_y = @y

    # if the user is holding alt
    if event.altKey
      # then create a new anchor attached to this one
      @targetAnchor = @split true
      # and do nothing ele
      return
      
    # user is not holding alt
    # go to each line
    _.each @lines, (line) ->
      # and tell it to hide its label
      line.removeLabel()
    
    # if im currently selected and there's more than one
    if @element.hasClass('selectedElement') and Snap.selectAll('.selectedElement').length > 1
      # flag this move as a group
      @moveAsGroup = true
      # set the origin for each anchor
      _.each Snap.selectAll('.selectedElement'), (anchor) ->
        anchor.anchor.originX = anchor.anchor.x
        anchor.anchor.originY = anchor.anchor.y
    # otherwise we are moving a single anchor
    else
      # so select it
      $(document).trigger 'selectedElement', [this, 'anchor']

  onMove: (dx, dy, mouse_x, mouse_y, event) =>

    event.stopPropagation()

    if @moveAsGroup
      _.each Snap.selectAll('.selectedElement'), (element) ->
        anchor = element.anchor
        anchor.handleMove anchor.originX + dx, anchor.originY + dy

      return

    # compute the new location
    x = @origin_x + dx
    y = @origin_y + dy

    # if they are holding down the alt key
    if event.altKey
      # if a new anchor was created at the beginning
      if @targetAnchor
        @targetAnchor.handleMove x, y
      # the user pressed alt in the middle of the drag
      else
        @targetAnchor = @split true
      
    # default case
    else
      @handleMove x, y

  # merge with another anchor 
  merge: (other) =>
    # if were told to merge something with itself then our job is done
    if this == other
      return

    # go over all of the lines of the anchor
    _.each other.lines, (line) =>
      # if the replaced anchor was anchor1 for this line
      if line.anchor1 == other
        # become anchor1
        line.anchor1 = this
      # if the replaced anchor was anchor2
      if line.anchor2 == other
        # assume the position
        line.anchor2 = this

      # add the line to my list
      @addLine line

    # remove the other anchor from the DOM
    other.remove()
    # update all of my lines
    @draw()

  remove: =>
    @element.remove()
    # remove this element from the papers list
    @paper.anchors =  _.without @paper.anchors, this

  handleMove: (x, y) =>

    # check that newX falls within the page
    if @radius <= x <= $(@paper.node).width() - @radius
      @x = x
    # check that newY falls within the page
    if @radius <= y <= $(@paper.node).height() - @radius
      @y = y
    # update the ui element
    @draw()


  split: (connected) =>
    # create a new Anchor at this location
    anchor = new Anchor @paper, @x, @y
    anchor.draw()

    # if they wanted them to be connected
    if connected
      # create a line attached to the two anchors
      line = new Line @paper, this, anchor
      line.draw()

    # return the new anchor
    return anchor
  
     
