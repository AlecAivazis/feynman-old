# this file handles the instantiation of the default elements as well as the paper based
# event handlers like group selection,
#
# author: alec aivazis

class FeynmanCanvas

  # when a canvas is created
  constructor: (@selector, startingPattern = 'pap') ->
    # create the snap object around the specified selector
    @paper = Snap(selector)
    @diagram_group = @paper.g().addClass('diagram')
    @paper.anchors = [] 
    @zoomLevel = 1

    # default values
    @gridSize = 50
    @title = "An Example Feynman Diagram"
    @minZoom = .5
    @maxZoom = 2
    @deltaZoom = .1

    # register the canvas on the document
    $(document).attr('canvas', this)

    # add the event handlers

    # whenever they click before they can drag
    @paper.mousedown (event) =>
      # clear the selection rectangle
      @removeSelectionRect()
      # and clear the selection
      $(document).trigger('clearSelection')

    # add event handlers for specific keys (non-modifiers)

    @spacebar_pressed = false
    # whenever they press a button
    $(window).keydown (evt) =>
      # if its spacebar 
      if evt.which == 32
        evt.preventDefault()
        # set the state variable
        @spacebar_pressed = true
    # whever they release a button
    $(window).keyup (evt) =>
      # if they released spacebar
      if evt.which == 32
        # clear the state variable
        @spacebar_pressed = false

    # whenever the scroll over the paper
    $(@paper.node).on 'mousewheel', (event) =>
      # prevent the browser from scrolling
      event.preventDefault()
      event.stopPropagation()
      # if we scrolled up
      if event.originalEvent.wheelDelta / 120 > 0
        # so zoom in
        @zoomIn()
      # otherwise we scrolled down
      else
        # so zoom out
        @zoomOut()
      
    # whenever they drag on the paper
    @paper.drag(@dragMove, @dragStart, @dragEnd)

    # render the canvas with the starting pattern and register it as item 0 in the history
    new UndoEntry true,
      title: "rendered canvas with '" + startingPattern + "' pattern"
      data: [this, startingPattern]
      # the forward action is to move to the current location
      forwards: ->
        @data[0].drawPattern(@data[1])
      # the backwards action is to move to the origin as defined when the drag started
      backwards: ->
        console.log 'this is the beginning. there is no before me!'

    # tell the angular app to load the canvas properties
    $(document).trigger 'doneWithInit'


  addToDiagram: (element) ->
    @diagram_group.add element


  drawGrid: () =>

    # hide the previous grid
    @hideGrid()

    # scale the width and height off of the canvas so there is still canvas when you zoom
    width = $(@paper.node).width()*10
    height = $(@paper.node).height()*10

    # get the number of vertical grids lines to make
    nVertical =  Math.round(width/@gridSize)
    nHorizontal = Math.round(height/@gridSize)

    grid = @paper.group().addClass('grid')
    @diagram_group.add grid

    # make a vertical line nVertical times
    for x in [1 .. nVertical]
      line = @paper.line().attr
        x1: (x-(nVertical/2)) * @gridSize
        x2: (x-(nVertical/2)) * @gridSize
        y1: -nHorizontal/2 * @gridSize
        y2: nHorizontal/2 * @gridSize
      # give it the proper class
      line.addClass('gridLine') 
      # and add it to the grid
      grid.add(line)

    # make a horizontal line nHorizontal times
    for y in [1 .. nHorizontal]
      line = @paper.line().attr
        x1: -nVertical/2 * @gridSize
        x2: width + (nVertical/2 * @gridSize)
        y1: (y - (nHorizontal/2)) * @gridSize
        y2: (y - (nHorizontal/2)) * @gridSize
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
      _.each anchor.lines, (line) ->
        line.drawLabel()


  dragStart: (x, y, event) =>
    # check if weve already created an element for the rectangle
    if @selectionRect_element
      # if we have then remove it from the dom
      @selectionRect_element.remove()

    # use the offset coordinates if they exists
    # otherwise compute them 
    if event.offsetX
      x = event.offsetX
    else
      x = event.pageX 
    if event.offsetY
      y = event.offsetY
    else
      y = event.pageY 

    # store the current transformation on the viewport
    @originTransform = @diagram_group.transform().globalMatrix

    # if spacebar is being held then we dont need to do anything
    if @spacebar_pressed
      # do nothing else
      return
    # grab the current transformation
    transformInfo = @originTransform.split()
    # apply the transformations to the location we started the drag
    diagramX = (x - transformInfo.dx) / transformInfo.scalex
    diagramY = (y - transformInfo.dy) / transformInfo.scaley

    # draw a rectangle starting at the x and y
    @selectionRect_element =  @paper.rect().attr
      x: diagramX
      y: diagramY

    # add the rectangle to the diagram
    @addToDiagram @selectionRect_element


  # handle drags on the paper
  # should draw a selection rectangle
  dragMove: (deltaX, deltaY, x_cursor, y_cursor, event) =>

    # if they are holding the spacebar
    if @spacebar_pressed
      # create the translation matrix by adding the change in coordinates to the original
      # translation
      translate = new Snap.Matrix().translate(deltaX, deltaY).add @originTransform.clone()
      # apply the transformation
      @diagram_group.transform(translate)
      # dont do anything else
      return

    # clear the previous selection
    $(document).trigger('clearSelection')

    # scale the lengths by the zoom level
    dx = deltaX / @zoomLevel
    dy = deltaY / @zoomLevel

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

    $(document).attr('canvas').addToDiagram @selectionRect_element

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

    # get the anchors
    anchors = _.filter @paper.anchors, (anchor) ->
      # within this range
      return bound1x <= anchor.x <= bound2x and
             bound1y <= anchor.y <= bound2y and
             # ignore the fixed anchors
             not anchor.fixed

    # add the selectedElement class to each anchor
    _.each anchors, (anchor) ->
      anchor.element.addClass('selectedElement')


  # after the drag
  dragEnd: =>
    # grab the selection    
    selected = Snap.selectAll('.selectedElement')
    # clear the selection rectangle
    @removeSelectionRect()
    # if i was holding the spacebar
    if @spacebar_pressed
      # do nothing else
      return 
    # if theres only one selected event
    if selected.length == 1
      # then select it
      $(document).trigger 'selectedElement', [Snap.select('.selectedElement').anchor , 'anchor']
    # there is more than one selected element
    else if selected.length > 1
      # select each element in the group
      $(document).trigger 'selectedGroup', [item.anchor for item in selected.items, 'anchor']


   
  # draw the sepecified pattern
  drawPattern: (pattern) =>

    # store the current set of anchors for the history
    old = @paper.anchors
    
    # if they asked for the particle / antiparticle pattern
    if pattern == 'pap'
      # define the anchors for the particle, anti particle patterns
      a = new Anchor(@paper, 150, 75)
      b = new Anchor(@paper, 225, 150)
      c = new Anchor(@paper, 150, 250)
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


  zoomIn: =>
    # if your not below the min
    if @zoomLevel <= @maxZoom
      # increment the zoom level
      @zoomLevel += @deltaZoom
      # apply the zoom level
      @applyZoom()


  zoomOut: =>
    # if your not below the min
    if @zoomLevel >= @minZoom
      # increment the zoom level
      @zoomLevel -= @deltaZoom
      # apply the zoom level
      @applyZoom()


  applyZoom: =>
    # grab the translation part from the current transformation
    prevInfo = @diagram_group.transform().globalMatrix.split()
    # create the scaling transformation with any previous translations taken into account
    scale = new Snap.Matrix().scale(@zoomLevel).translate(prevInfo.dx, prevInfo.dy)
    # apply the transformation
    @diagram_group.transform(scale)
    # update the digram
    @draw()


# when the document is loaded
$(document).ready ->
  # create a canvas out of the appropriate DOM element
  new FeynmanCanvas("#canvas") 


