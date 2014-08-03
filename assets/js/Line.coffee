# this file describes a line object that is drawn between two Anchors
#
# author: alec aivazis

class Line

  element = null

  constructor: (@paper, @anchor1, @anchor2, @style = 'line') ->
    @anchor1.addLine this
    @anchor2.addLine this

    # default values
    @labelPosition = 'top'
    @width = 2
    @color = 'black'
    @loopDirection = 1
    @labelDistance = 30


  ressurect: =>
    @anchor1.addLine this
    @anchor2.addLine this
    return this

  # remove all references to this element
  remove: =>
    # hide this element
    @hide()
    # remove both of the references
    @anchor1.removeLine this
    @anchor2.removeLine this

  # safely remove any elements on the DOM associated with this line
  hide: =>
    # if this line has already been drawn
    if @element
      # remove it
      @element.remove()
    # remove the label
    @removeLabel

  # remove this lines label from the DOM
  removeLabel: =>
    # if this line has a label
    if @labelEle
      @labelEle.remove()

  # delete all references to this object
  delete: =>
    @anchor1.removeLine this
    @anchor2.removeLine this
    @remove()


  # calculate the location for the label and then draw it
  drawLabel: =>

    # remove the previous label
    @removeLabel()

    # if theres no label defined
    if not @label
      # do nothing
      return

    # the distance to be from the line
    r = @labelDistance
      
    # calculate the midpoint
    midx = (@anchor1.x + @anchor2.x ) / 2
    midy = (@anchor1.y + @anchor2.y ) / 2

    # find the slope of the perpendicular line 
    # m' = -1/m
    m = -(@anchor1.x - @anchor2.x)/(@anchor1.y - @anchor2.y)

    # the points that are perpedicular to the line a distance r away satisfy
    # y = mx
    # x^2 + y^2 = r

    x = Math.sqrt(r*r / (1 + (m*m)))
    y = m*x

    # add these values to the mid point for the appropriate center of the label
    # CAREFUL: these signs take into account the possible minus sign from midx/y calculation
    if m > 0
      if @labelPosition == 'top'
        labelx = midx - x
        labely = midy - y
      else
        labelx = midx + x
        labely = midy + y
    if m < 0
      if @labelPosition == 'top'
        labelx = midx + x
        labely = midy + y
      else
        labelx = midx - x
        labely = midy - y

    # if we hit an infinity in y
    if isNaN labely
      if @labelPosition == 'top'
        labely = midy - r
      else
        labely = midy + r

    # create the label at the appropriate location
    @createLabel(labelx, labely)

  # render the label in and add it in the right place
  createLabel: (x, y) =>
    # remove the previous label
    @removeLabel()
    # make the new label
    if @label
      @labelEle = @paper.image("http://latex.codecogs.com/svg.latex?" + @label, x, y)

  # align an element along the line connecting the two anchors
  # assumes the element is horizontal before align for the purposes for scaling
  align: (element) =>

    # figure out the width of the element
    width = element.getBBox().width

    # compute the lengths between the anchors
    dx = @anchor1.x - @anchor2.x
    dy = @anchor1.y - @anchor2.y
    length = Math.sqrt(dx*dx + dy*dy)

    # figure out the angle that this line needs to take
    angle = Math.atan(dy/dx) * 180/Math.PI
    # we might need to flip the angle
    if dx >= 0
      angle += 180

    # create the alignment matrix by scaling it to match the width
    # and then rotating it along the line joining the two anchors
    alignment = new Snap.Matrix().scale(length/width, 1, @anchor1.x, @anchor1.y)
                                 .rotate(angle, @anchor1.x, @anchor1.y)

    # apply the transform and return the element
    element.transform(alignment)

  replaceAnchor: (replaced, replaces) =>
    if @anchor1 == replaced
      @anchor1 = replaces
    else if @anchor2 == replaced
      @anchor2 = replaces
    

  drawAsLine: =>
    # add the line to the dom
    @paper.path('M' + @anchor1.x + ',' + @anchor1.y + ' L' + @anchor2.x + ',' + @anchor2.y)

  # draw  
  drawAsDashedLine: =>
    @drawAsLine().attr
      strokeDasharray: '10 '

  drawAsGluon: =>
    # the width of one gluon loop
    gluonWidth = 20
    # the ratio of height to width for the loops
    ratio = 1
    gluonHeight = ratio*gluonWidth * parseInt(@loopDirection)

    # compute the length of the line
    dx = @anchor1.x - @anchor2.x
    dy = @anchor1.y - @anchor2.y
    length = Math.sqrt dx*dx + dy*dy

    # current x loc for path generation
    x = @anchor1.x
    y = @anchor1.y 

    # start the path at the first anchor
    pathString = 'M' + x + ',' + y
    # figure out how many gluon loops to draw
    numLoops = Math.round length/gluonWidth
    # make a gluon loop numLoops times
    for i in [1..numLoops]
      # increment x
      x += gluonWidth
      #  add the curve
      pathString += 'C ' + x + ',' + y + ' '
      pathString +=  x  + ',' + (y - gluonHeight) + ' '
      pathString += (x - (gluonWidth/2)) + ',' + (y - gluonHeight) + ' '
      # stop gluonWidth away from where we started and mirror the curve
      pathString += 'S ' + (x - gluonWidth) + ',' + y + ' ' + x + ',' + y + ' '

    # add the svg element
    element = @paper.path(pathString)
    # align along the line created by the anchors
    @align(element)
    

  drawAsSine: =>
    # the length of the pattern
    period = 30
    # the height of the pattern
    amplitude = 13
    # compute frequency from period
    freq = 2 * Math.PI / period

    # compute the length of the line
    dx = @anchor1.x - @anchor2.x
    dy = @anchor1.y - @anchor2.y
    length = Math.sqrt dx*dx + dy*dy

    # find the closest whole number of full periods
    nCycles = Math.round length/period

    # create a group that houses all of the line elements
    group = @paper.g()

    for i in [0... nCycles * period]
      group.add @paper.line().attr
        x1: (i-1) + @anchor1.x
        y1: amplitude * Math.sin(freq * (i - 1 )) + @anchor1.y
        x2: i + @anchor1.x
        y2: amplitude * Math.sin(freq * i) + @anchor1.y
    # align along the line created by the anchors
    @align(group)

  # draw the line on the DOM
  draw: =>

    # if this element was previously selected
    if @element and @element.hasClass('selectedElement')
      isSelected = true

    # clear any previous DOM elements
    @hide()
    # what is drawn changes on the style
    switch @style
      when "line"
        @element = @drawAsLine()
      when "dashed"
        @element = @drawAsDashedLine()
      when "gluon"
        @element = @drawAsGluon()
      when "em"
        @element = @drawAsSine()


    # apply the correct styling
    @element.attr
      stroke: @color
      strokeWidth: @width
      fill: 'none'

    if isSelected
      @element.addClass('selectedElement')


    # on drag move
    @element.drag @onDrag, @dragStart, @dragEnd

    # add the click event handler
    @element.node.onclick = (event)=>
      event.stopPropagation()
      $(document).trigger 'selectedElement', [this, 'line']

  # when you start dragging a line
  dragStart: (x , y, event) =>
    event.stopPropagation()
    # deselect the previous selection
    $(document).trigger 'clearSelection'

    # not sure why you need this, should investigate
    @newAnchor = undefined

    # check if the alt key is being pressed
    if event.altKey

      # split the line at those coordinates
      splitx = if event.offsetX then event.offsetX else event.clientX - $(event.target).offset().left
      splity = if event.offsetY then event.offsetY else event.clientY - $(event.target).offset().top

      # if we haven't already made a new one this drag
      # create a node off of this one
      @newAnchor = @split(splitx, splity, true)
      @newAnchor.origin_x = splitx
      @newAnchor.origin_y = splity

      # do nothing else
      return

    # go set the origins for both anchors
    @anchor1.origin_x = @anchor1.x
    @anchor1.origin_y = @anchor1.y
    @anchor2.origin_x = @anchor2.x
    @anchor2.origin_y = @anchor2.y

    # select this element
    $(document).trigger 'selectedElement', [this, 'line']

  onDrag: (dx, dy, x, y, event) =>
    event.stopPropagation()
    # if we made a new anchor with this mode
    if @newAnchor
      @newAnchor.handleMove(@newAnchor.origin_x + dx, @newAnchor.origin_y + dy)
      return

    @anchor1.handleMove(@anchor1.origin_x + dx, @anchor1.origin_y + dy)
    @anchor2.handleMove(@anchor2.origin_x + dx, @anchor2.origin_y + dy)

  dragEnd: =>
    # check if we made a new anchor this drag
    if @newAnchor
      # find the old anchors for the undo stack

      # since the anchor we created only has one line
      newLine = @newAnchor.lines[0]
      # we can figure out the split anchor
      splitAnch = if newLine == @newAnchor then newLine.anchor2 else newLine.anchor1
      # the other line is the only line left if you remove me from the lines of the split anchor
      otherLine = _.without(splitAnch.lines, this)[0]
      # get the anchor from otherLine that isn't the splitAnch
      otherAnch = if otherLine.anchor1 == splitAnch then otherLine.anchor2 else otherLine.anchor1
      # get the anchor that is connected to this
      thisAnch = if this.anchor1 == splitAnch then this.anchor2 else this.anchor1

      # regsiter the creation of the branch with the undo stack
      new UndoEntry false,
        title: 'added branch to propagator'
        data: [@newAnchor, newLine, splitAnch, otherLine, otherAnch, this, thisAnch]
        # the forwards action is to fake the branch by bringing back the old elements
        forwards: ->
          # remove this from the other anchor
          @data[4].removeLine @data[5]
          # ressurect the newAnchor
          @data[0].ressurect()
          # ressurect the splitAnchor
          @data[2].ressurect()
          # while were at it replace other anchor with split anch in me
          @data[5].replaceAnchor @data[4], @data[2]
          # ressurect the newLine
          @data[1].ressurect()
          # ressurect this
          @data[5].ressurect()
          # ressurect the other anchorr
          @data[4].ressurect()
          # ressurect the other line
          @data[3].ressurect()
          # draw the anchors
          @data[0].draw()
          @data[2].draw()
          @data[4].draw()
        # the backwards removes everything and makes this back to what it was
        backwards: ->
          # remove the intermediate elements
          @data[0].remove()
          @data[1].remove()
          @data[2].remove()
          @data[3].remove()
          # before removing the midAnch, lets replace it with the otherAnch
          @data[5].replaceAnchor @data[2], @data[4]
          @data[4].addLine @data[5]
          @data[4].draw()
          
    @newAnchor = undefined


  # create an anchor at the given coordinates and 
  split: (x, y, createNode = false) =>
    # create the new elements
    anch = new Anchor(@paper, x, y)
    # arbitrarily set my anchor1 so we need a line from anchor1 to the new anchor
    l = new Line(@paper, anch, @anchor1)
    # arbitrarily set my anchor1 to the new anchor
    @anchor1.removeLine this
    @anchor1.draw()
    @anchor1 = anch
    anch.addLine this
    # redraw me and the new anchor
    anch.draw()
    @draw()
    # if they told us to create a node off of the new one
    if createNode
      # split the created node with a line between
      return anch.split(true)

    
    
  
