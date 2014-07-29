# this file handles the instantiation of the default elements as well as the paper based
# event handlers like group selection,
# author: alec aivazis

class FeynmanCanvas

  
  # when a canvas is created
  constructor: (selector, startingPattern = 'pap') ->
    # create the snap object around the specified selector
    @paper = Snap(selector)
    @paper.anchors = [] 

    # default values
    @snapToGrid = false
    @gridSize = 15
    @title = "An Example Feynman Diagram"

    # register the canvas on the document
    $(document).attr('canvas', this)

    # add the event handlers

    # whenever they click before they can drag
    @paper.mousedown =>
      @mouseDown()

    # whenever they drag on the paper
    @paper.drag(@dragMove, @dragStart, @dragEnd)

    # draw the starting pattern
    @drawPattern(startingPattern)

    $(document).trigger 'doneWithInit'

  mouseDown: () =>
    @removeSelectionRect()
    $(document).trigger('clearSelection')

  draw: () =>
    console.log @snapToGrid
    console.log @gridSize


  dragStart: (x, y, event) =>

    # check if weve already created an element for the rectangle
    if @selectionRect_element
      # if we have then remove it from the dom
      @selectionRect_element.remove()

    console.log event
  
    # draw a rectangle starting at the x and y
    @selectionRect_element =  @paper.rect().attr
      x: if event.offsetX then event.offsetX else event.clientX - $(event.target).offset().left
      y: if event.offsetY then event.offsetY else event.clientY - $(event.target).offset().top

  dragMove: (dx, dy, x_cursor, y_cursor) =>
    $(document).trigger('clearSelection')

    # if there hasnt been a  selection rectangle drawn
    if not @selectionRect_element
      # dont do anything
      return

    # otherwise, change its width and height
    @selectionRect_element.attr
      width: Math.abs(dx)
      height: Math.abs(dy)

    # create the appropriate translation 
    if dx >= 0
      if dy <= 0
        transform = new Snap.Matrix().translate(0, dy)
      else
        transform = new Snap.Matrix().translate(0,0)
    else
      transform = new Snap.Matrix().translate(dx, 0)
      if dy <= 0
        transform.translate(0, dy)

    # apply the transformation and style the rectangle
    @selectionRect_element.transform(transform).attr
      stroke: 'red'
      strokeWidth: 1.5
      fill: 'none'

    # turn the strings into floats
    bound1x = parseInt(@selectionRect_element.attr('x'))
    dx = parseFloat(dx)
    
    # create the inner bounds that these represent
    if bound1x < bound1x + dx
      bound2x = bound1x + dx
    else
      bound2x = bound1x
      bound1x = bound1x + dx

    bound1y = parseInt(@selectionRect_element.attr('y'))
    dy = parseFloat(dy)

    # get the inner bounds
    if bound1y < bound1y + dy
      bound2y = bound1y + dy
    else
      bound2y = bound1y
      bound1y = bound1y + dy

    # get the anchors within this range
    anchors = _.filter @paper.anchors, (anchor) ->
      return bound1x <= anchor.x <= bound2x and
             bound1y <= anchor.y <= bound2y and
             not anchor.fixed

    _.each anchors, (anchor) ->
      anchor.element.addClass('selectedElement')

  dragEnd: =>
    @removeSelectionRect()

   
  drawPattern: (pattern) =>
    # if they asked for the particle / antiparticle pattern
    if pattern == 'pap'
      # define the anchors for the particle, anti particle patterns
      a = new Anchor(@paper, 50, 25)
      b = new Anchor(@paper, 150, 100)
      c = new Anchor(@paper, 50, 175)
      d = new Anchor(@paper, 300, 100)
  
      # and the lines connecting them
      k = new Line(@paper, a, b)
      l = new Line(@paper, c, b, 'gluon')
      m = new Line(@paper, b, d, 'em')

      a.draw()
      b.draw()
      c.draw()
      d.draw()


  removeSelectionRect: =>
    if @selectionRect_element
      @selectionRect_element.remove()
    @selectionRect_x = null
    @selectionRect_y = null

$(document).ready ->
  new FeynmanCanvas("#canvas") 


