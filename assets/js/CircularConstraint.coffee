# this file represents a circular constraint object
# a circular constraint is a map from R2 to R2 that places (x,y) on
# the nearest point to a circle with r = {radius}
#
# author: alec aivazis

class CircularConstraint

  constructor: (@paper, @x, @y, @r) ->

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


  handleMove: (x, y) =>
    # set the instance variables
    @x = x
    @y = y
    # redraw
    @draw()


  constrain: (x , y) =>
    x: x
    y: y


  isPointInside: (x, y) =>
    return false


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
    
