# this file describes a customizable text field 
#
# author: alec aivazis

class Text

  constructor: (@paper, @x, @y, @text) ->
    

  draw: =>

    if @element
      @remove()
    
    # use an image from codecogs public api
    @element = @paper.image("http://latex.codecogs.com/svg.latex?#{@text}" , @x, @y)
    # add it to the diagram group
    $(document).attr('canvas').addToDiagram(@element)

    # add the event handlers
    @element.drag @onDrag, @dragStart, @onDragEnd


  handleMove: (x, y) =>
    # set the instance variables
    @x = x
    @y = y
    # redraw
    @draw()

  
  remove: =>
    # if an element has been created
    if @element  
      # remove the element if it exists
      @element.remove()

    # clear the element reference
    @element = undefined


  dragStart: (x, y, event) =>
    # stop propagation
    event.stopPropagation()
    # save the original location
    @origin =
      x: @x
      y: @y


  onDrag: (deltaX, deltaY, x, y, event) =>
    # compute the coordinates with the canvas transforms
    coords = $(document).attr('canvas').getCanvasCoordinates(@origin.x + deltaX, @origin.y + deltaY)
    # move the text to the new coordinates
    @handleMove(coords.x, coords.y)


  onDragEnd: =>
    # check that we actually moved somewhere
    if @x != @origin.x and @y != @origin.y
      # register the drag with the undo stack
      new UndoEntry false,
        title: "moved text" 
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
        
          




