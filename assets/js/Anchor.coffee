# this file describes the anchor class as needed by the online feynman diagram tool
# the anchor acts as the main structural element by providing two ends to connect

class Anchor

  element = null
  
  constructor: (@paper, @x, @y, @radius = 10, @snapRange = 21) ->
    @lines = []
    @paper.anchors.push this

  # add a line to the list of connected elements
  addLine: (element) =>
    @lines.push element

  # update the anchor element on the user interface
  draw: =>
    # if a element was previous defined
    if @element
      # remove it
      @remove()
    # add the circle at the appropriate location with the on move event handler
    @element = @paper.circle(@x, @y, @radius).drag @onMove, @dragStart, @dragEnd

    # when you click on the circle
    @element.node.onclick = (event) ->
      console.log 'clicked on anchor'
      event.stopPropagation()

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
          # if it is then merge the two (me onto him)
          compare.merge anchor

    # clear the target anchor
    @targetAnchor = undefined

  dragStart: (x, y, event) =>
    # if the user is holding alt
    if event.altKey
      # then create a new anchor attached to this one
      @targetAnchor = @split true

    # record the location before the drag
    @origin_x = @x
    @origin_y = @y

  onMove: (dx, dy, mouse_x, mouse_y, event) =>

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

  handleMove: (x, y) =>
    # check that newX falls within the page
    if @radius <= x <= @paper.attr('width') - @radius
      @x = x
    # check that newY falls within the page
    if @radius <= y <= @paper.attr('height') - @radius
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

    return anchor
  
     
