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


  onDrag: (dx, dy, x, y, event) =>
    console.log 'onDrag'


  dragStart: (x, y, event) =>
    console.log 'drag start'


  dragEnd: =>
    console.log 'drag end'
    
