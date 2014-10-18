# this file describes a customizable text field 
#
# author: alec aivazis

class Text

  constructor: (@paper, @x, @y, @text) ->
    
  draw: =>
    # use an image from codecogs public api
    @element = @paper.image("http://latex.codecogs.com/svg.latex?" + @label, x, y)
    # add it to the diagram group
    $(document).attr('canvas').addToDiagram(@element)
    
    
