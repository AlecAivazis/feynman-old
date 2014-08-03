# this file describes the anchor class as needed by the online feynman diagram tool
# the anchor acts as the main structural element by providing two ends to connect
#
# author: alec aivazis

class Anchor

  element = null
  
  constructor: (@paper, @x, @y, @radius = 5, @snapRange = 21) ->
    @lines = []
    @paper.anchors.push this

    # default values
    @color = 'black'
    @fixed = false

  # add a line to the list of connected elements
  addLine: (lines) =>
    # if they gave us an array
    if lines.length 
      for line in lines
        @lines.push line
    else
      @lines.push lines

  # update the anchor element on the user interface
  draw: =>
    # default status is not selected
    isSelected = false
    
    # if a element was previously defined
    if @element
      # and its selected
      if @element.hasClass('selectedElement')
        isSelected = true

      # remove it
      @element.remove()


    # add the circle at the appropriate location with the on move event handler
    @element = @paper.circle(@x, @y, @radius).attr
      fill: if @color then @color else 'black'

    @element.anchor = this

    # add the fixed class if necessary
    if @fixed
      @element.addClass('fixed')
    # if it was previously selected
    if isSelected
      # add the appropriate class
      @element.addClass('selectedElement')

    # set the drag handlers
    @element.drag @onMove, @dragStart, @dragEnd

    # when you click on the circle
    @element.node.onclick = =>
      event.stopPropagation()
      $(document).trigger 'selectedElement', [this, 'anchor']

    # update the associated lines
    _.each @lines, (line) ->
      line.draw()

  checkForMerges: (targetAnchor = this)=>
    # check if there is any anchor that it within snapRange of me
    _.each @paper.anchors, (compare) =>
      # make sure we dont compare us with ourselves
      if compare == targetAnchor
        return

      # compute the distance between me and the other anchor
      dx = targetAnchor.x - compare.x
      dy = targetAnchor.y - compare.y

      # check if the other anchor is within snap range
      if @snapRange * @snapRange > dx*dx + dy*dy
        # grab the line before we merge
        lines = targetAnchor.lines
        # if it is then merge the two
        targetAnchor.merge compare
        # if the newAnchor is defined and we're merging it
        if @newAnchor
          # regsiter it with the undo stack
          new UndoEntry false,
            title: 'added internal propagator'
            data: [lines[0], this]
            # the forwards action is to show the line that was created
            forwards: ->
              @data[0].ressurect()
              @data[1].draw()
            # the backwards action is the hide that line
            backwards: ->
              @data[0].remove()

          # take away the newAnchor definition
          @newAnchor = undefined
        # there was no new anchor defined 
        else
          # we are merging a pre-existing anchor - register it with the undo stack
          new UndoEntry false,
            title: 'merged two vertices together'
            data: [targetAnchor, compare, lines, @origin_x, @origin_y]
            # the forwards action is to merge target anchor with compare
            forwards: ->
              @data[0].merge @data[1]
            # the backwards action is to remove all of targetAnchors lines from compare
            # and ressurect targetAnchor
            backwards: ->
              @data[1].removeLine(@data[2])
              
              # bring back the anchor 
              @data[0].ressurect()
              # add the lines back to it
              @data[0].addLine(@data[2])
              # go to each line
              _.each @data[2], (line) =>
                # change the anchor assignment back to targetAnchor
                line.replaceAnchor(@data[1], @data[0])

              # move the anchor back to its original place (ignoring the grid)
              @data[0].handleMove(@data[3], @data[4], false)

              

        # return that we merged elements
        return true
    return false
      
  # at the end of the drag
  dragEnd: (x, y, event) =>
    # if we were making a new anchor
    if @newAnchor
      # then we are dragging it so target the new Anchor
      targetAnchor = @newAnchor
    # otherwise
    else
      # we are dragging this so target me
      targetAnchor = this

    # check for merges around the targetAnchor that will look to create elements from me
    # grab the line before we potentially remove it
    line = targetAnchor.lines[0]
    # this is a check for internal line construction with targetAnchor
    if @checkForMerges(targetAnchor)
      return

    # if i am supposed to be a new anchor
    if @newAnchor == targetAnchor
      # add the entry in the undo stack
      new UndoEntry false,
        title: 'created vertex at ' + targetAnchor.x + ',' +  targetAnchor.y
        data: [@paper, this, targetAnchor, line]
        forwards: ->
          # resurrect the anchor
          @data[2].ressurect()
          # resurrect the line
          @data[3].ressurect()
          # draw the anchor/line
          @data[2].draw()
          @data[3].draw()
          
        backwards: ->
          # remove the anchor
          @data[2].remove()
          # remove the line
          @data[3].remove()
          
  
    selected = Snap.selectAll('.selectedElement')

    # make sure there is an element selected
    if selected.length == 0
      return


    # if there is only one anchor selected
    if selected.length == 1

      # check that we actually moved it
      if @x == @origin_x and @y == @origin_y
        return
        
      # register the move with the undo stack but do not waste the time performing it again
      new UndoEntry false,
        title: 'moved vertex to ' + @x + ', ' + @y 
        data: [@paper, targetAnchor, targetAnchor.x, targetAnchor.y,
                                     targetAnchor.origin_x, targetAnchor.origin_y]
        # the forward action is to move to the current location
        forwards: ->
          @data[1].handleMove(@data[2], @data[3])
        # the backwards action is to move to the origin as defined when the drag started
        backwards: ->
          @data[1].handleMove(@data[4], @data[5])
        
    # there is more than one selected element
    else
      # build the position data for the group of elements
      anchor_data = []
      # go over every selected element
      for element in selected
        # grab its anchor
        anchor = element.anchor

        # check that we actually went somewhere
        if anchor.x == anchor.origin_x and anchor.y == anchor.origin_y
          return

        # save the important data
        anchor_data.push
          anchor: anchor
          x: anchor.x
          y: anchor.y
          origin_x: anchor.origin_x
          origin_y: anchor.origin_y

      # register the move with the undo stack but do not waste the time performing it again
      new UndoEntry false,
        title: 'moved group of anchors'
        data: [anchor_data]
        # the forward action is to move the group to its current location
        forwards: ->
          _.each @data[0], (element) ->
            element.anchor.handleMove element.x, element.y
        # the backwards action is to move the group to the origin as defined when the drag started
        backwards: ->
          _.each @data[0], (element) ->
            element.anchor.handleMove element.origin_x, element.origin_y

    # clear the target anchor
    @newAnchor = undefined

    # draw any labels that need to be
    _.each _.compact(@lines), (line)->
      line.drawLabel()

  dragStart: (x, y, event) =>
    # check if there are multiple selected
    event.stopPropagation()

    # select this event

    # record the location before the drag
    @origin_x = @x
    @origin_y = @y

    # if the user is holding alt
    if event.altKey
      # clear the selection so we can eventually select the new anchor
      $(document).trigger 'clearSelection', ->
      # then create a new anchor attached to this one
      @newAnchor = @split true
      # and do nothing ele
      return
      
    # user is not holding alt
    # go to each line
    _.each @lines, (line) ->
      # and tell it to hide its label
      line.removeLabel()
    
    # if im currently selected and there's more than one
    if @element.hasClass('selectedElement') and Snap.selectAll('.selectedElement').length > 1
      # flag this move as a group
      @moveAsGroup = true
      # set the origin for each anchor
      _.each Snap.selectAll('.selectedElement'), (anchor) ->
        anchor.anchor.origin_x = anchor.anchor.x
        anchor.anchor.origin_y = anchor.anchor.y
    # otherwise we are moving a single anchor
    else
      # so select it
      $(document).trigger 'selectedElement', [this, 'anchor']

  onMove: (dx, dy, mouse_x, mouse_y, event) =>

    event.stopPropagation()

    if @moveAsGroup
      _.each Snap.selectAll('.selectedElement'), (element) ->
        anchor = element.anchor
        anchor.handleMove anchor.origin_x + dx, anchor.origin_y + dy

      return

    # compute the new location
    x = @origin_x + dx
    y = @origin_y + dy

    # if they are holding down the alt key
    if event.altKey
      # if a new anchor was created at the beginning
      if @newAnchor
        @newAnchor.handleMove x, y
      # the user pressed alt in the middle of the drag
      else
        @newAnchor = @split true
      
    # default case
    else
      @handleMove x, y

  # merge with another anchor by replacing all of my references with other
  merge: (other) =>
    # if were told to merge something with itself then our job is done
    if this == other
      return

    # go over all of the lines of the anchor
    _.each @lines, (line) =>
      # if the replaced anchor was anchor1 for this line
      if line.anchor1 == this
        # become anchor1
        line.anchor1 = other
      # if the replaced anchor was anchor2
      if line.anchor2 == this
        # assume the position
        line.anchor2 = other

      # add the line to their list
      other.addLine line

    # remove me from the DOM 
    @remove()
    # update all of their lines
    other.draw()

  remove: =>
    @element.remove()
    # remove this element from the papers list
    @paper.anchors =  _.without @paper.anchors, this
    @lines = []

  ressurect: =>
    @paper.anchors.push this
    @lines = []

  removeLine: (lines) =>
    # if they gave us a list
    if lines.length
      for line in lines
        @lines =  _.without @lines, line
    else
      @lines =  _.without @lines, lines

  # move in a single direction
  translate:  (attr, value, useGrid = true) =>
    if attr == 'x'
      @handleMove(value, @y, useGrid) 
    else if attr == 'y'
      @handleMove(@x, value, useGrid) 

  handleMove: (x, y, useGrid = true) =>

    # if its fixed
    if @fixed
      # dont do anything
      return
       
    # grab the document's feynman canvas
    gridSize = $(document).attr('canvas').gridSize
    # if they want to snap everything to a grid
    if gridSize > 0 and useGrid
      # find the nearest point on the grid
      x = Math.round(x/gridSize)*gridSize
      y = Math.round(y/gridSize)*gridSize

    # check that newX falls within the page
    if @radius <= x <= $(@paper.node).width() - @radius
      @x = x
    # check that newY falls within the page
    if @radius <= y <= $(@paper.node).height() - @radius
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

    # return the new anchor
    return anchor
  
     
