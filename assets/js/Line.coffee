# this file describes a line object that is drawn between two Anchors

class Line

  element = null

  constructor: (@paper, @anchor1, @anchor2, @style = 'line') ->
    @anchor1.addLine this
    @anchor2.addLine this

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
    # positive slope
    if m > 0
      labelx = midx - x
      labely = midy - y
    else
      labelx = midx + x
      labely = midy + y

    # create the label at the appropriate location
    @createLabel labelx, labely

  # render the label in and add it in the right place
  createLabel: (x, y) =>
    # remove the previous label
    @removeLabel()
    # make the new label
    @labelEle = paper.image "http://latex.codecogs.com/svg.latex?" + @label, x, y

  # align an element along the line connecting the two anchors
  align: (element) =>
    # compute the lengths
    dx = @anchor1.x - @anchor2.x
    dy = @anchor1.y - @anchor2.y
    # figure out the angle that this line needs to take
    angle = Math.atan(dy/dx) * 180/Math.PI
    # we might need to flip the angle
    if dx > 0
      angle += 180

    # perform the rotation
    matrix = new Snap.Matrix().rotate angle, @anchor1.x, @anchor1.y
    element.transform(matrix)

  drawAsLine: =>
    # add the line to the dom
    return @paper.path('M' + @anchor1.x + ',' + @anchor1.y + ' L' + @anchor2.x + ',' + @anchor2.y)

  drawAsGluon: =>

    # the width of one gluon loop
    gluonWidth = 20
    # the ratio of height to width for the loops
    ratio = 1
    gluonHeight = ratio*gluonWidth

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

    @align(element)
    

  drawAsSine: =>
    # define the neccessary paramters
    period = 30
    amplitude = 13
    phase = 0

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
      line = @paper.line().attr
        x1: (i-1) + @anchor1.x
        y1: amplitude * Math.sin(freq * (i - 1 + phase)) + @anchor1.y
        x2: i + @anchor1.x
        y2: amplitude * Math.sin(freq * (i + phase)) + @anchor1.y

      group.add line
    
    @align(group)

  # draw the line on the DOM
  draw: =>
    # clear any previous DOM elements
    @remove()

    # what is drawn changes on the style
    switch @style
      when "line"
        @element = @drawAsLine()
      when "gluon"
        @element = @drawAsGluon()
      when "em"
        @element = @drawAsSine()

    # apply the correct styling
    @element.attr
      stroke: if @stroke then @stroke else 'black'
      strokeWidth: 3.5
      fill: 'none'
      

    # add the click event handler
    @element.node.onclick = =>
      $(document).trigger 'selectedLine', [this]
