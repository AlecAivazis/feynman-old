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
    # if theres no label defined
    if not @label
      return
    # remove the previous label
    @removeLabel()

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

  createLabel: (x, y) =>
    # remove the previous label
    @removeLabel()
    # make the new label
    @labelEle = @paper.text x, y, @label
    # compute the width of the label
    width =  @labelEle.getBBox().width
    # remove the old label
    @labelEle.remove()
    # recenter the label based on the width
    @labelEle = @paper.text (x - width/2), y, @label


  draw: =>
    # clear any previous DOM elements
    @remove()
    # add the line to the dom
    @element = @paper.path('M' + @anchor1.x + ',' + @anchor1.y + ' L' + @anchor2.x + ',' + @anchor2.y)

    # with the right attributes
    @element.attr
      stroke: if @stroke then @stroke else 'black'
      strokeWidth: 5

    # add the click event handler
    @element.node.onclick = =>
      $(document).trigger 'selectedLine', [this]
