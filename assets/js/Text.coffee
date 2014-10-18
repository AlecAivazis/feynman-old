# this file describes a customizable text field 
#
# author: alec aivazis

class Text

  constructor: (@paper, @x, @y, @text) ->
    

  draw: =>

    if @element
      @remove()
    
    # use an image from codecogs public api
    @element = @paper.image("http://latex.codecogs.com/svg.latex?#{@text}" , @x, @y)
    # add it to the diagram group
    $(document).attr('canvas').addToDiagram(@element)


  handleMove: (x, y) =>
    # set the instance variables
    @x = x
    @y = y
    # redraw
    @draw()
  
  remove: =>
    # if an element has been created
    if @element  
      # remove the element if it exists
      @element.remove()
