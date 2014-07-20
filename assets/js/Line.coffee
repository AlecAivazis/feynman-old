# this file describes a line object that is drawn between two Anchors

class Line

  element = null

  constructor: (@paper, @anchor1, @anchor2) ->
    @anchor1.addLine this
    @anchor2.addLine this

  draw: =>

    # if this line has already been drawn
    if @element
      # remove it
      @element.remove()

    # add the line to the dom
    @element = @paper.path('M' + @anchor1.x + ',' + @anchor1.y + ' L' + @anchor2.x + ',' + @anchor2.y).attr
      stroke: 'black'
      strokeWidth: 3

    # add the click event handler
    @element.node.onclick = ->
      console.log 'you clicked on a line'
