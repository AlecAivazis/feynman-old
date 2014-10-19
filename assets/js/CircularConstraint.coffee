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

    @element.attr
      fill: 'transparent'
      stroke: 'black'
      strokeWidth: 2

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
    zoom = $(document).attr('canvas').zoomLevel
    # if the alt key was held
    if event.altKey 
      @targetAnchor.handleMove(@origin.x + deltaX/zoom, @origin.y + deltaY/zoom)
    # nothing was held down
    else
      # move the text to the new coordinates
      @handleMove(@origin.x + deltaX/zoom, @origin.y + deltaY/zoom)


  dragStart: (x, y, event) =>
    # stop propagation
    event.stopPropagation()
    # save the original location
    @origin =
      x: @x
      y: @y

    # check if the alt key was held down
    if event.altKey
      coords = $(document).attr('canvas').getCanvasCoordinates(x - $("#canvas").offset().left, y)
      # create an anchor at the coordiantes
      @newAnchor = new Anchor(@paper, coords.x, coords.y)
      # constrain the anchor to the constraint
      @newAnchor.addConstraint(this)
      # draw the anchor with the new constraint
      @newAnchor.draw()
      # make a second anchor connected to this one
      @targetAnchor = @newAnchor.split(true)
      # set the origin
      @origin =
        x: coords.x
        y: coords.y
      


  dragEnd: =>
    # check that we actually moved somewhere
    if @x != @origin.x and @y != @origin.y
      # check if we are targetting an anchor
      if @targetAnchor
        # check for merges with other anchors
        merged = @targetAnchor.checkForMerges()
        # if such a merge happened
        if merged
          line = @targetAnchor.lines[0]
          # register it with the undo stack
          new UndoEntry false,
            title: 'created internal branch off of circular constraint'
            data:
              constraint: this
              otherAnchor: if line.anchor1 == merged then line.anchor2 else line.anchor1
              line: @targetAnchor.lines[0]
              newAnchor: merged
            backwards: ->
              @data.otherAnchor.remove()
              @data.line.remove()
            
            forwards: ->
              @data.otherAnchor.ressurect()
              @data.line.ressurect()
              @data.otherAnchor.addConstraint(@data.constraint)
              @data.otherAnchor.draw()
          
        # no such merge happened
        else
          # check if the target anchor is on a line or constraint
          onLine = $(document).attr('canvas').isAnchorOnLine(@targetAnchor)
          onConstraint = $(document).attr('canvas').isAnchorOnConstraint(@targetAnchor)
          # if there is such a line
          if onLine
            console.log 'branched off of circle on to line!'
            # split the line at the anchor's location
            split = onLine.split(@targetAnchor.x, @targetAnchor.y)
            # merge the newly created anchor with the one we created earlier
            splitAnchor = split.anchor.merge(@targetAnchor)
            # save references to the other elements
            splitLine = split.line
            otherAnchor = if splitLine.anchor2 == splitAnchor then splitLine.anchor1 else splitLine.anchor2
            newLine = @targetAnchor.lines[0]
            # regsiter the line split with the undo stack
            new UndoEntry false,
              title: 'added a constrained branch'
              data:
                constraint: this
                constrainedAnchor: if newLine.anchor1 == splitAnchor then newLine.anchor2 else newLine.anchor1
                splitLine: splitLine
                otherAnchor: otherAnchor
                originalLine: onLine
                splitAnchor: splitAnchor
                newLine: newLine 
              backwards: ->
                @data.originalLine.replaceAnchor(@data.splitAnchor, @data.otherAnchor)
                @data.otherAnchor.addLine(@data.originalLine)
                @data.newLine.remove()
                @data.constrainedAnchor.remove()
                @data.splitAnchor.remove()
                @data.splitLine.remove()
                @data.otherAnchor.draw()
              forwards: ->
                @data.originalLine.replaceAnchor(@data.otherAnchor, @data.splitAnchor)
                @data.splitAnchor.addLine(@data.originalLine)
                @data.splitLine.ressurect()
                @data.constrainedAnchor.ressurect()
                @data.constrainedAnchor.addConstraint(@data.constraint)
                @data.newLine.ressurect()
                @data.splitAnchor.draw()
                @data.constrainedAnchor.draw()
            
          # if there is such a constraint
          else if onConstraint
            # add the new constraint to the anchor
            @targetAnchor.addConstraint(onConstraint)
            # draw the anchor with the new constraint
            @targetAnchor.draw()
            # grab a reference to the created line
            newLine = @targetAnchor.lines[0]
            # register the internal line with the undo stack
            new UndoEntry false,
              title: 'created internal propagator'
              data:
                constraint1: this
                constraint2: onConstraint
                anchor1: if newLine.anchor1 == @targetAnchor then newLine.anchor2 else newLine.anchor1
                anchor2: @targetAnchor
                line: newLine
              backwards: ->
                @data.anchor1.remove()
                @data.anchor2.remove()
                @data.line.remove()
              forwards: ->
                @data.anchor1.ressurect()
                @data.anchor1.addConstraint(@data.constraint1)
                @data.anchor1.draw()
                @data.anchor2.ressurect()
                @data.anchor2.addConstraint(@data.constraint2)
                @data.anchor2.draw()
                @data.line.ressurect()
                @data.line.draw()

          else
            # register the free branch with the undo stack
            new UndoEntry false,
            title: 'added branch to circular constraint'
            data:
              constraint: this
              line: @targetAnchor.lines[0]
              newAnchor: @targetAnchor
              otherAnchor: if @targetAnchor.lines[0].anchor2 == @targetAnchor then  @targetAnchor.lines[0].anchor1 else @targetAnchor.lines[0].anchor2
            backwards: ->
              @data.newAnchor.remove()
              @data.line.remove()
              @data.otherAnchor.removeConstraint()
              @data.otherAnchor.remove()
            forwards: ->
              @data.otherAnchor.ressurect()
              @data.otherAnchor.addConstraint(@data.constraint)
              @data.newAnchor.ressurect()
              @data.line.ressurect()
              @data.otherAnchor.draw()
              @data.newAnchor.draw()


        # clear the anchor reference
        @targetAnchor = undefined
        return
      
      # see if any anchors need to be constrained
      constrained = $(document).attr('canvas').checkAnchorsForConstraint(this)
      constraint = this
      # if there are anchors that we constrained
      if constrained.length > 0
        # go over each of them
        _.each constrained, (anchor) ->
          # add the constraint
          anchor.addConstraint(constraint)
          # draw with the updated constraint
          anchor.draw()
        # register the move and constrain with the undo stack
        new UndoEntry false,
          title: 'moved circular constraint on top of anchors'
          data:
            anchors: constrained
            constraint: constraint
            origin: @origin
            newLoc:
              x: @x
              y: @y
          backwards: ->
            constraint = @data.constraint
            # go over each anchor
            _.each @data.anchors, (anchor) ->
              # remove the constraint
              anchor.removeConstraint(constraint)
              # draw without the constraint
              anchor.draw()
            # move the constraint back to the origin
            @data.constraint.handleMove(@data.origin.x, @data.origin.y)
          forwards: ->
            constraint = @data.constraint
            # move to the new location
            @data.constraint.handleMove(@data.newLoc.x, @data.newLoc.y)
            # go over each of the anchors
            _.each @data.anchors, (anchor) ->
              # apply the constraint
              anchor.addConstraint(constraint)
              # draw with the new constraint
              anchor.draw()
            

      else
        # register the drag with the undo stack
        new UndoEntry false,
          title: "moved circular constraint"
          data:
            constraint: this
            origin: @origin
            newLoc:
              x: @x
              y: @y
          forwards: ->
            @data.constraint.handleMove(@data.newLoc.x, @data.newLoc.y)
          backwards: ->
            @data.constraint.handleMove(@data.origin.x, @data.origin.y)


  remove: =>
    # if the element exists on the canvas
    if @element
      # remove it
      @element.remove()

    @paper.constraints = _.without @paper.constraints, this