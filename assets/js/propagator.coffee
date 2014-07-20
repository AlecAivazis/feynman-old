# this file describes the feynman.svg propagator that connects two points (x1, y1) and (x2, y2)
class Propagator

  style: 'line'
  path: null 
    
  constructor: (@paper, @x1, @y1, @x2, @y2) ->

  # draw/refresh the propagator on the user interface
  draw: =>
    # if a path was previous defined
    if @path
      # remove it
      @path.remove()
    # add a new path connecting the two points
    @element = @paper.circle(300, 150, 20).drag()
    
    
