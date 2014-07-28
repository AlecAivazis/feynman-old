# this file handles the instantiation of the default elements as well as the paper based
# event handlers like group selection,
# author: alec aivazis

class FeynmanCanvas

  # when a canvas is created
  constructor: (selector, startingPattern = 'pap') ->
    # create the snap object around the specified selector
    @paper = Snap(selector)
    @paper.anchors = [] 

    # draw the starting pattern
    @drawPattern(startingPattern)

   
  drawPattern: (pattern) =>
    # if they asked for the particle / antiparticle pattern
    if pattern == 'pap'
      # define the anchors for the particle, anti particle patterns
      a = new Anchor(@paper, 50, 25)
      b = new Anchor(@paper, 150, 100)
      c = new Anchor(@paper, 50, 175)
      d = new Anchor(@paper, 300, 100)
  
      # and the lines connecting them
      k = new Line(@paper, a, b)
      l = new Line(@paper, c, b, 'gluon')
      m = new Line(@paper, b, d, 'em')

      a.draw()
      b.draw()
      c.draw()
      d.draw()

    


$(document).ready ->

  canvas = new FeynmanCanvas("#canvas") 

