# this file describes a line object that is drawn between two Anchors

class Line

  element = null

  constructor: (@paper, @anchor1, @anchor2, @style = 'line') ->
    @anchor1.addLine this
    @anchor2.addLine this

    # default values

    @labelPosition = 'top'
    @width = 3.6
    @stroke = 'black'
    @loopDirection = 1

  # safely remove any elements on the DOM associated with this line
  remove: =>
    # if this line has already been drawn
    if @element
      # remove it
      @element.remove()
    # remove the label
    @removeLabel

  removeLabel: =>
    # if this line has a label
    if @labelEle
      @labelEle.remove()

  # calculate the location for the label and then draw it
  drawLabel: =>

    # remove the previous label
    @removeLabel()

    # if theres no label defined
    if not @label
      # do nothing
      return

    # the distance to be from the line
    r = 30
      
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
    @createLabel labelx, labely

  # render the label in and add it in the right place
  createLabel: (x, y) =>
    # remove the previous label
    @removeLabel()
    # make the new label
    @labelEle = paper.image "http://latex.codecogs.com/svg.latex?" + @label, x, y

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
    if dx > 0
      angle += 180

    # create the alignment matrix by scaling it to match the width
    # and then rotating it along the line joining the two anchors
    alignment = new Snap.Matrix().scale(length/width, 1, @anchor1.x, @anchor1.y)
                                 .rotate(angle, @anchor1.x, @anchor1.y)

    # apply the transform and return the element
    element.transform(alignment)

  drawAsLine: =>
    # add the line to the dom
    return @paper.path('M' + @anchor1.x + ',' + @anchor1.y + ' L' + @anchor2.x + ',' + @anchor2.y)

  # draw  
  drawAsDashedLine: =>
    element = @drawAsLine().attr
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

    # clear any previous DOM elements
    @remove()
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
      stroke: @stroke
      strokeWidth: @width
      fill: 'none'
      

    # add the click event handler
    @element.node.onclick = =>
      $(document).trigger 'selectedLine', [this]
