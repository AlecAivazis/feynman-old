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
    @snapToGrid = true
    @gridSize = 75
    @title = "An Example Feynman Diagram"

    # register the canvas on the document
    $(document).attr('canvas', this)

    # add the event handlers

    # whenever they click before they can drag
    @paper.mousedown =>
      @mouseDown()

    # whenever they drag on the paper
    @paper.drag(@dragMove, @dragStart, @dragEnd)

    # draw the starting pattern with an undo to start off the list
    title = "rendered canvas with '" + startingPattern + "' pattern"
    $(document).trigger 'addEventToUndo', [title, true, [this, startingPattern], 
      # the forward action is to draw the starting pattern
      ->
        @data[0].drawPattern(@data[1])
      # the backwards action is to not implemented since this is the first thing done
      , ->
        console.log 'this is the beginning. there is no before me!'
    ]

    $(document).trigger 'doneWithInit'

  mouseDown: () =>
    @removeSelectionRect()
    $(document).trigger('clearSelection')

  drawGrid: () =>

    # hide the previous grid
    @hideGrid()

    # grab the width and height off of the canvas
    width = $(@paper.node).width() 
    height = $(@paper.node).height()

    # get the number of vertical grids lines to make
    nVertical =  Math.round(width/@gridSize)
    nHorizontal = Math.round(height/@gridSize)

    grid = @paper.group().addClass('grid')

    # make a vertical line nVertical times
    for x in [1 .. nVertical]
      line = @paper.line().attr
        x1: x * @gridSize
        x2: x * @gridSize
        y1: 0
        y2: height
      # give it the proper class
      line.addClass('gridLine') 
      # and add it to the grid
      grid.add(line)

    # make a horizontal line nHorizontal times
    for x in [1 .. nHorizontal]
      line = @paper.line().attr
        x1: 0
        x2: width
        y1: x * @gridSize
        y2: x * @gridSize
      # give it the proper class
      line.addClass('gridLine') 
      # and add it to the grid
      grid.add(line)
    

  # remove the grid if it exists
  hideGrid: () =>
    grid = Snap.select('.grid')
    if grid
      grid.remove()

  # refresh the pages representation on the DOM
  draw: () =>
    # if they are fixing the anchors to the grid
    if @gridSize < 1
      # hide it
      @hideGrid()
    # otherwise
    else
      # show them the grid
      @drawGrid()
    
    # draw each of the anchors
    _.each @paper.anchors, (anchor) ->
      anchor.draw()


  dragStart: (x, y, event) =>

    # check if weve already created an element for the rectangle
    if @selectionRect_element
      # if we have then remove it from the dom
      @selectionRect_element.remove()

    # draw a rectangle starting at the x and y
    @selectionRect_element =  @paper.rect().attr
      # use the offset coordinates if they exists
      # otherwise compute them 
      x: if event.offsetX then event.offsetX else event.clientX - $(event.target).offset().left
      y: if event.offsetY then event.offsetY else event.clientY - $(event.target).offset().top

  # handle drags on the paper
  # should draw a selection rectangle
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

  # after the drag
  dragEnd: =>
    # if theres only one selected event
    if Snap.selectAll('.selectedElement').length == 1
      $(document).trigger 'selectedElement', [Snap.select('.selectedElement').anchor , 'anchor']
    
    @removeSelectionRect()
   
  drawPattern: (pattern) =>

    # store the current set of anchors for the history
    old = @paper.anchors
    
    # if they asked for the particle / antiparticle pattern
    if pattern == 'pap'
      # define the anchors for the particle, anti particle patterns
      a = new Anchor(@paper, 150, 75)
      b = new Anchor(@paper, 225, 150)
      c = new Anchor(@paper, 150, 225)
      d = new Anchor(@paper, 375, 150)
  
      # and the lines connecting them
      k = new Line(@paper, a, b)
      l = new Line(@paper, c, b, 'gluon')
      m = new Line(@paper, b, d, 'em')

    
    # draw the anchors
    @draw()
  
  removeSelectionRect: =>
    if @selectionRect_element
      @selectionRect_element.remove()
    @selectionRect_x = null
    @selectionRect_y = null

$(document).ready ->
  new FeynmanCanvas("#canvas") 


