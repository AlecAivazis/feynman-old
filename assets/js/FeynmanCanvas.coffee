# this file handles the instantiation of the default elements as well as the paper based
# event handlers like group selection,
#
# author: alec aivazis

class FeynmanCanvas

  # when a canvas is created
  constructor: (@selector, startingPattern = 'pap') ->
    # create the snap object around the specified selector
    @paper = Snap(selector)
    @diagramGroup = @paper.g().addClass('diagram')
    @paper.anchors = [] 
    @paper.lines = [] 
    @paper.constraints = []
    @zoomLevel = 1

    # default values
    @gridSize = 50
    @title = "An Example Feynman Diagram"
    @minZoom = .5
    @maxZoom = 2
    @deltaZoom = .1
    @hideAnchors = false
    @hideGrid = false

    # register the canvas on the document
    $(document).attr('canvas', this)

    # add the event handlers

    # whenever they click before they can drag
    @paper.mousedown (event) =>
      @mouseDown(event)

    # add event handlers for specific keys (non-modifiers)

    @spacebarPressed = false
    # whenever they press a button
    $(window).keydown (evt) =>
      # if its spacebar 
      if evt.which == 32
        # set the state variable
        @spacebarPressed = true
    # whever they release a button
    $(window).keyup (evt) =>
      # if they released spacebar
      if evt.which == 32
        # clear the state variable
        @spacebarPressed = false
      # if they presed delete or backspace
      if evt.which in [8, 46]
        $(document).trigger('deleteSelectedElement')

      # if they pressed ctrl + z
      if evt.which == 90 and evt.ctrlKey
        # if they actually pressed shift + ctrl + z
        if evt.shiftKey
          # move forward one step in the history
          $(document).trigger('goForwardOneUndo')
        # if they pressed ctrl + z
        else
          # step back in history
          $(document).trigger('goBackOneUndo')
      

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
    @diagramGroup.add element


  refresh: =>
    @zoomIn()
    @zoomOut()


  drawGrid: () =>

    # hide the previous grid
    @removeGrid()
    # create a group for the new grid
    grid = @paper.group().addClass('grid')
    # grab the current transformations of the diagram 
    xform = @diagramGroup.transform().globalMatrix.split()
    scalex = xform.scalex
    scaley = xform.scaley
    x0 = - xform.dx / scalex
    y0 = - xform.dy / scaley

    # get the dimensions of the viewport
    width = $(@paper.node).width() / scalex
    height = $(@paper.node).height() / scaley

    # compute the grid density along the x axis
    xDensity = @gridSize
    # compute the grid density along the x axis
    yDensity = @gridSize

    # the first x-aligned grid line
    xg0 = xDensity * Math.floor(x0/xDensity)
    # the first y-aligned grid line
    yg0 = yDensity * Math.floor(y0/yDensity)

    # go through all visible grid-aligned x coordinates
    for x in [xg0 .. xg0+width] by xDensity
      # draw a horizontal line
      grid.add @paper.path("M #{x} #{yg0} L #{x} #{yg0+height}").addClass('gridLine')
    
    # go through all visible grid-aligned y coordinates
    for y in [yg0 .. yg0+height] by yDensity
      # draw a vertical line
      grid.add @paper.path("M #{xg0} #{y} L #{xg0+width} #{y}").addClass('gridLine')

    # add the grid to the diagram
    @diagramGroup.add grid
    
    # all done
    return
    

  # remove the grid if it exists
  removeGrid: () =>
    # look for the svg container of the grid
    grid = Snap.select('.grid')
    # if there is one
    if grid
      # get rid of it
      grid.remove()


  # refresh the pages representation on the DOM
  draw: () =>
    # if they are fixing the anchors to the grid
    if @gridSize < 1 or @hideGrid
      # hide it
      @removeGrid()
      # if they meant to hide the grid
      if @hideGrid
        # hide the grey background
        $('#canvas').css('background', 'white')
    # otherwise
    else
      # show them the grid
      @drawGrid()
      # with the right color background
      $('#canvas').css('background', '#f5f5f5')
    
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

    # store the current transformation on the viewport
    @originTransform = @diagramGroup.transform().globalMatrix

    # if spacebar is being held then we dont need to do anything
    if @spacebarPressed
      # do nothing else
      return

    # if the user was holding the alt key
    if event.altKey
      # grab the created anchor
      coords = @getMouseEventCoordinates(event)
      # create the anchor at that location
      @newAnchor = new Anchor(@paper, coords.x, coords.y)
      # snap it to the grid and draw
      @newAnchor.snapToGrid()
      # create another anchor off of that one
      @currentAnchor = @newAnchor.split(true)
      # dont do anything else
      # ie create a selection rectangle
      return
    
    # get the event coordinates
    coords = @getMouseEventCoordinates(event)

    # draw a rectangle starting at the x and y
    @selectionRect_element =  @paper.rect().attr
      x: coords.x
      y: coords.y

    # add the rectangle to the diagram
    @addToDiagram @selectionRect_element



  # handle drags on the paper
  # should draw a selection rectangle
  dragMove: (deltaX, deltaY, x_cursor, y_cursor, event) =>

    # if they are holding the spacebar
    if @spacebarPressed
      # create the translation matrix by adding the change in coordinates to the original
      # translation
      translate = new Snap.Matrix().translate(deltaX, deltaY).add @originTransform.clone()
      # apply the transformation
      @diagramGroup.transform(translate)
      # refresh the picture
      @draw()
      # dont do anything else
      return

    # clear the previous selection
    $(document).trigger('clearSelection')

    # scale the lengths by the zoom level
    dx = deltaX / @zoomLevel
    dy = deltaY / @zoomLevel
    # if the user was holding the altKey
    if event.altKey
      # get the event coordinates
      coords = @getMouseEventCoordinates(event)
      # move the created anchor
      @currentAnchor.handleMove(coords.x, coords.y)
      
      return

    # if there hasnt been a  selection rectangle drawn or the user is holding the alt key
    if not @selectionRect_element or event.altKey
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
    @selectionRect_element.addClass('selectionRectangle').transform(transform).attr
      strokeDasharray: '10 '

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

    # get the lines
    lines = _.filter @paper.lines, (line) ->
      midx = (line.anchor1.x + line.anchor2.x)/2
      midy = (line.anchor1.y + line.anchor2.y)/2
      # within this range
      return bound1x <= midx <= bound2x and
             bound1y <= midy <= bound2y

    # get the constraints
    constraints = _.filter @paper.constraints, (constraint) ->
      # within this range
      return bound1x <= constraint.x <= bound2x and
             bound1y <= constraint.y <= bound2y
      

    # add the selectedElement class to each anchor
    _.each _.union(anchors, lines, constraints), (element) ->
      element.makeSelected()


  # after the drag
  dragEnd: (event) =>
    # grab the selection    
    selected = Snap.selectAll('.selectedElement')
    # clear the selection rectangle
    @removeSelectionRect()

    # if i was holding the spacebar
    if @spacebarPressed
      # do nothing else
      return 

    # if the user was holding the alt key
    if event.altKey
      # check for merges for the new 
      merged = @currentAnchor.mergeWithOtherAnchors()
      # if the newly created anchor was merged
      if merged
        # register it with the undo stack
        new UndoEntry false ,
          title: "created vertex at #{@newAnchor.x}, #{@newAnchor.y}"
          data: [@newAnchor, @newAnchor.lines[0]]
          forwards: ->
            # resurrect the anchor
            @data[0].ressurect()
            # ressurect the line
            @data[1].ressurect()
            # draw the anchor
            @data[0].draw()
          backwards: ->
            # remove the anchor
            @data[0].remove()
            # remove the line
            @data[1].remove()

      # otherwise the newly created anchor was not merged
      else
        # check if the anchor was created on a line
        onLine =  @isAnchorOnLine(@currentAnchor)
        # if it was
        if onLine
          # split the line at the given point
          split =  onLine.split(@currentAnchor.x, @currentAnchor.y)
          # merge the anchor with the one created with the split
          splitAnchor = split.anchor.merge(@currentAnchor)
          # save the line created during the split
          splitLine = split.line
          # save a reference to the other anchor
          otherAnchor = if splitLine.anchor2 == splitAnchor then splitLine.anchor1 else splitLine.anchor2
          # register the backwards split with the undo stack
          new UndoEntry false, 
            title: 'added branch to propagator'
            data: 
              originalLine: onLine
              splitAnchor: splitAnchor
              splitLine: splitLine
              otherAnchor: otherAnchor
              newLine: @newAnchor.lines[0]
              newAnchor: @newAnchor
            # forwards action is to recreate the branch
            forwards: ->
              # remove the original line from other anchor
              @data.otherAnchor.removeLine @data.originalLine
              # ressurect the split anchor
              @data.splitAnchor.ressurect()
              @data.splitLine.ressurect()
              # replace otherAnch with split anch in the original line
              @data.originalLine.replaceAnchor @data.otherAnchor, @data.splitAnchor
              # ressurect the new anchor
              @data.newAnchor.ressurect()
              # and the new line
              @data.newLine.ressurect()
              # draw the anchors
              @data.newAnchor.draw()
              @data.splitAnchor.draw()
            # backwards action is to remove the newly created line and anchor
            backwards: ->
              # replace the newly created anchor with the other one in the line
              @data.originalLine.replaceAnchor @data.splitAnchor, otherAnchor
              @data.otherAnchor.addLine @data.originalLine
              # remove the elements created in the split
              @data.splitAnchor.remove()
              @data.splitLine.remove()
              @data.newLine.remove()
              @data.newAnchor.remove()
              # draw the other anchor to update the line
              @data.otherAnchor.draw()

        # otherwise the new anchor was not created on a line
        else
          # grab the line that the initial anchor is on
          onLine = @isAnchorOnLine(@newAnchor)
          # if such a line exists
          if onLine
            # then the user created an anchor that is close enough to snap to a line
            # split the line
            split = onLine.split(@newAnchor.x, @newAnchor.y)
            # merge the new anchor with the one created during the split
            splitAnch = @newAnchor.merge(split.anchor)
            splitLine = split.line
            # save a reference to the other anchor
            if splitLine.anchor1 == splitAnchor
              otherAnchor = splitLine.anchor2
            else
              otherAnchor = splitLine.anchor1

            # register it with the undo stack
            new UndoEntry false,
              title:  'added a branch to propagator'
              data:
                originalLine: onLine
                splitAnchor: splitAnch
                otherLine: splitLine
                otherAnchor: otherAnchor
                newLine: @currentAnchor.lines[0]
                newAnchor: @currentAnchor
              forwards: ->
                # remove the original line from other anchor
                @data.otherAnchor.removeLine @data.originalLine
                # ressurect the split anchor
                @data.splitAnchor.ressurect()
                @data.otherLine.ressurect()
                # replace otherAnch with split anch in the original line
                @data.originalLine.replaceAnchor @data.otherAnchor, @data.splitAnchor
                # ressurect the new anchor
                @data.newAnchor.ressurect()
                # and the new line
                @data.newLine.ressurect()
                # draw the anchors
                @data.newAnchor.draw()
                @data.splitAnchor.draw()
              backwards: ->
                @data.originalLine.replaceAnchor(@data.splitAnchor, @data.otherAnchor)
                @data.otherAnchor.addLine(@data.originalLine)
                @data.splitAnchor.remove()
                @data.otherLine.remove()
                @data.otherAnchor.draw()

                @data.newAnchor.remove()
                @data.newLine.remove()


          # neither the initial or the other anchor are on a line
          else 
            # check if the new anchor is on a constraint
            onConstraint = @isAnchorOnConstraint(@currentAnchor)
            # if such a constraint exists
            if onConstraint
              # add the constraint to the anchor
              @currentAnchor.addConstraint(onConstraint)
              # draw the anchor with the new constraint
              @currentAnchor.draw()
              # register the undo stack
              new UndoEntry false,
                title: 'added branch to circle'
                data:
                  constraint: onConstraint
                  line: @newAnchor.lines[0]
                  constrainedAnchor: @currentAnchor
                  otherAnchor: @newAnchor
                backwards: ->
                  @data.otherAnchor.remove()
                  @data.constrainedAnchor.remove()
                  @data.line.remove()
                forwards: ->
                  @data.otherAnchor.ressurect()
                  @data.constrainedAnchor.ressurect()
                  @data.constrainedAnchor.addConstraint(@data.constraint)
                  @data.line.ressurect()
                  @data.constrainedAnchor.draw()
                  @data.otherAnchor.draw()
                
            # the anchor was not created on a constraint
            else
              # register it with the undo stack
              new UndoEntry false ,
                title: 'created a standalone propagator'
                data: [@newAnchor, @currentAnchor, @newAnchor.lines[0]]
                forwards: ->
                  # ressurect the 2 anchors
                  @data[0].ressurect()
                  @data[1].ressurect()
                # and then the line
                  @data[2].ressurect()
                  # draw the 2 anchors
                  @data[0].draw()
                  @data[1].draw()
                backwards: ->
                  # remove everything
                  @data[2].remove()
                  @data[1].remove()
                  @data[0].remove()
              
      # clear the anchor references
      @currentAnchor = undefined
      @newAnchor = undefined
       
      # do nothing else
      return

    # if theres only one selected event
    if selected.length == 1
      element = @getClassElement(selected[0])
      # then select it
      $(document).trigger 'selectedElement', element
    # there is more than one selected element
    else if selected.length > 1
      # build the object of lists
      elements =
        anchor: []
        line: []
        circle: []

      for element in selected
        # get the element data
        data = @getClassElement(element)
        # add it to the list of elements
        elements[data[1]].push data[0]

      # trigger the selection
      $(document).trigger 'selectedGroup', elements


  # figure out the string type of the class
  getClassElement: (element) =>
    if element.anchor
      return [element.anchor, "anchor"]
    else if element.constraint  
      return [element.constraint, "circle"]
    else if element.line
      return [element.line, "line"]


  # when the mouse is pressed, regardless of drag or not
  mouseDown: (event) =>
    # clear the selection rectangle
    @removeSelectionRect()
    # and clear the selection
    $(document).trigger('clearSelection')


  # check all anchors for possible constraints
  checkAnchorsForConstraint: (constraint) =>
    # keep a list of the anchors we constrained
    constrained = []
    # go over every anchor
    _.each @paper.anchors, (anchor) ->
      # and see if we can constrain it
      onConstraint = $(document).attr('canvas').isAnchorOnConstraint(anchor)
      # if such a constraint exists
      if onConstraint
        # add it to the list
        constrained.push(anchor)

    # once were done return the list 
    return constrained


  # check if a particular anchor falls in a constraint
  isAnchorOnConstraint: (anchor) =>
    # start with a false response
    constraint = false
    # loop over every constraint
    _.each @paper.constraints, (cons) ->
      if cons.isPointInside(anchor.x, anchor.y) and anchor not in cons.anchors
        constraint = cons

    # return the response
    return constraint
      

  # check if a particular anchor falls on any of the lines in the canvas
  # removing any of its children before calculating
  isAnchorOnLine: (anchor) =>
    # start with all of the papers lines
    lines = @paper.lines
    # and a false response
    targetLine = false

    # go over all of anchors children
    _.each anchor.lines, (line) ->
      # remove the line from the local list
      lines = _.without lines, line

    # go over each line
    _.each lines, (line) ->
      # if the anchor falls on the line
      if line.isLocationBetweenAnchors(anchor.x, anchor.y)
        # the anchor is on line so give it to the caller
        targetLine = line

    # return what was found
    return targetLine


  # compute the event coordinates bsaed on a mouse event
  getMouseEventCoordinates: (event) =>
    # compute the coordinates of the event using the offset coordinates if they exists
    if event.offsetX
      x = event.offsetX
    # otherwise compute them 
    else
      x = event.pageX 
    # same for y
    if event.offsetY
      y = event.offsetY
    else
      y = event.pageY 

    # if its firefox
    if navigator.userAgent.toLowerCase().indexOf('firefox') > -1
      # subtract the width of the sidebar from x
      x -= $('#sidebar').width()+40


    return @getCanvasCoordinates(x, y)


  # turn page coordinates into canvas coordinates (ie take into account zoom and pan) 
  getCanvasCoordinates: (x, y) =>
    # grab the current transformation
    transformInfo =  @diagramGroup.transform().globalMatrix.split()
    # apply the transformations to the location we started the drag
    diagramX = (x - transformInfo.dx) / transformInfo.scalex
    diagramY = (y - transformInfo.dy) / transformInfo.scaley

    coords = 
      x: diagramX
      y: diagramY

   
  # draw the sepecified pattern
  drawPattern: (pattern) =>

    # store the current set of anchors for the history
    old = @paper.anchors

    # if they asked for nothing,
    if pattern == ''
      # just drop an anchor to get things going
      new Anchor(@paper, 0, 0)
    
    # if they asked for the particle / antiparticle pattern
    if pattern == 'pap'
      # define the anchors for the particle, anti particle patterns
      a = new Anchor(@paper, 50, 100)
      b = new Anchor(@paper, 150, 200)
      c = new Anchor(@paper, 50, 300)
      d = new Anchor(@paper, 250, 200)
  
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
    # if you are not above maximum zoom level
    if @zoomLevel <= @maxZoom
      # increment the zoom level
      @zoomLevel += @deltaZoom
      # apply
      @applyZoom()


  zoomOut: =>
    # if you are not below the minimum zoom level
    if @zoomLevel >= @minZoom
      # decrement the zoom level
      @zoomLevel -= @deltaZoom
      # apply the zoom level
      @applyZoom()


  applyZoom: =>
    # grab the translation part from the current transformation
    prevInfo = @diagramGroup.transform().globalMatrix.split()
    # create the scaling transformation with any previous translations taken into account
    scale = new Snap.Matrix().translate(prevInfo.dx, prevInfo.dy).scale(@zoomLevel)
    # apply the transformation
    @diagramGroup.transform(scale)
    # update the digram
    @draw()


# when the document is loaded
$(document).ready ->
  # create a canvas out of the appropriate DOM element
  new FeynmanCanvas("#canvas") 


# end of file
