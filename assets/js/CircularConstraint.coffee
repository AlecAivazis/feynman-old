# this file represents a circular constraint object
# a circular constraint is a map from R2 to R2 that places (x,y) on
# the nearest point to a circle with r = {radius}
#
# author: alec aivazis

class CircularConstraint

  constructor: (@paper, @x, @y, @r) ->
    @paper.constraints.push this
    @anchors = []

  draw: =>
    # if an element already exists on the canvas
    if @element
      # then remove it
      @element.remove()

    # add the circular element to the canvas
    @element = @paper.circle(@x, @y, @r)

    # add it to the diagram group aswell
    $(document).attr('canvas').addToDiagram(@element)

    # add the event handlers
    @element.drag @onDrag, @dragStart, @dragEnd

    # draw each of the anchors
    _.each @anchors, (anchor) ->
      anchor.draw()
      # draw each of the anchors lines
      _.each anchor.lines, (line) ->
        line.draw()


  handleMove: (x, y) =>
    # set the instance variables
    @x = x
    @y = y
    # redraw
    @draw()


  constrain: (x , y) =>
    # compute the distances between the point and the center
    dx = x - @x
    dy = y - @y
    # and the slope of the line joining the two
    m = dy/dx 
    # calculate the distances from the origin
    translate =
      x: Math.sqrt(@r*@r / (1 + (m*m)))
      y: m * Math.sqrt(@r*@r / (1 + (m*m)))
    # apply the right translations in the appropriate quadrant
    if dx > 0 
      x: @x + translate.x
      y: @y + translate.y
    else if dx < 0
      x: @x - translate.x
      y: @y - translate.y
    else
      x: @x
      y: if dy >0 then @y + @r else @y - @r


  isPointInside: (x, y) =>
    dx = x - @x
    dy = y - @y
    return Math.sqrt(dx*dx + dy*dy) < @r


  onDrag: (deltaX, deltaY, x, y, event) =>
    # compute the coordinates with the canvas transforms
    coords = $(document).attr('canvas').getCanvasCoordinates(@origin.x + deltaX, @origin.y + deltaY)
    # move the text to the new coordinates
    @handleMove(coords.x, coords.y)


  dragStart: (x, y, event) =>
    # stop propagation
    event.stopPropagation()
    # save the original location
    @origin =
      x: @x
      y: @y


  dragEnd: =>
    # check that we actually moved somewhere
    if @x != @origin.x and @y != @origin.y
      # register the drag with the undo stack
      new UndoEntry false,
        title: "moved circular constraint"
        data:
          element: this
          origin: @origin
          newLoc:
            x: @x
            y: @y
        forwards: ->
          @data.element.handleMove(@data.newLoc.x, @data.newLoc.y)
        backwards: ->
          @data.element.handleMove(@data.origin.x, @data.origin.y)


  remove: =>
    # if the element exists on the canvas
    if @element
      # remove it
      @element.remove()

    @paper.constraints = _.without @paper.constraints, this
