# this file describes the anchor class as needed by the online feynman diagram tool
# the anchor acts as the main structural element by providing two ends to connect

class Anchor

  element = null
  
  constructor: (@paper, @x_raw, @y_raw, @radius = 5, @snapRange = 21) ->
    @lines = []
    @paper.anchors.push this

    # default values
    @color = 'black'
    @fixed = false
    @x = @x_raw
    @y = @y_raw

  # add a line to the list of connected elements
  addLine: (element) =>
    @lines.push element

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

    # grab the document's feynman canvas
    gridSize = $(document).attr('canvas').gridSize
    # if they want to snap everything to a grid
    if gridSize > 0
      # find the nearest point on the grid
      @x = Math.round(@x_raw/gridSize)*gridSize
      @y = Math.round(@y_raw/gridSize)*gridSize
    # were not snapping to the grid
    else
      # use the raw coordinates
      @x = @x_raw
      @y = @y_raw

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
        line = targetAnchor.lines[0]
        # if it is then merge the two
        targetAnchor.merge compare
        # if the newAnchor is defined and we're merging it
        if @newAnchor
          # grab the line that we just created
      
          new UndoEntry false,
            title: 'added internal propagator'
            data: [@paper, this, compare, line], 
            forwards: ->
              @line.ressurect()
              @data[1].draw()
            backwards: ->
              if not @line
                @line = @data[3]
              @line.remove()

          # take away the newAnchor definition
          @newAnchor = undefined
          # now that the we are gone we are done
          return true
    return false
      
  # at the end of the drag
  dragEnd: (x, y, event) =>

    if @newAnchor
      console.log 'created new element only?'
      targetAnchor = @newAnchor
    else
      targetAnchor = this

    # check for merges around the targetAnchor that will look to create elements from me
    # grab the line before we potentially remove it
    line = targetAnchor.lines[0]
    console.log line
    # this is a check for internal lines 
    if @checkForMerges(targetAnchor)
      return

    # if i am supposed to be a new anchor
    if @newAnchor == targetAnchor
      console.log 'making new anchor'
      # add the entry in the undo stack
      new UndoEntry false,
        title: 'created anchor at ' + targetAnchor.x + ',' +  targetAnchor.y
        data: [@paper, this, targetAnchor, line]
        forwards: ->
          # set and create the anchor
          @anchor.ressurect()
          # set and create the line
          @line.ressurect()
          # draw the anchor/line
          @anchor.draw()
          
        backwards: ->
          # if this is the first time we've gone back
          if not @anchor
            # set the anchor variable
            @anchor = @data[2]
          # remove the anchor 
          @anchor.remove()
          # same for line
          if not @line
            @line = @data[3]
          @line.remove()
          
  
    selected = Snap.selectAll('.selectedElement')

    # make sure there is an element selected
    if selected.length == 0
      return

    # if there is only one anchor selected
    if selected.length == 1
      # register the move with the undo stack but do not waste the time performing it again
      new UndoEntry false,
        title: 'moved anchor to ' + @x + ', ' + @y 
        data: [@paper, targetAnchor, @x, @y, @origin_x, @origin_y]
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

  # merge with another anchor 
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

  removeLine: (line) =>
    @lines =  _.without @lines, line


  handleMove: (x, y) =>

    # if its fixed
    if @fixed
      # dont do anything
      return

    # check that newX falls within the page
    if @radius <= x <= $(@paper.node).width() - @radius
      @x_raw = x
    # check that newY falls within the page
    if @radius <= y <= $(@paper.node).height() - @radius
      @y_raw = y
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
  
     
