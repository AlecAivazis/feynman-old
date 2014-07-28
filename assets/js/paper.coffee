# this file handles the instantiation of the default elements as well as the paper based
# event handlers like group selection,
# author: alec aivazis

paper =

$(document).ready ->

  # create the snap document
  paper = Snap '#canvas' 
  paper.anchors = []

  # define the anchors for the default view

  a = new Anchor(paper, 50, 25)
  b = new Anchor(paper, 150, 100)
  c = new Anchor(paper, 50, 175)
  d = new Anchor(paper, 300, 100)

  # and the lines connecting them

  k = new Line(paper, a, b)
  l = new Line(paper, c, b, 'gluon')
  m = new Line(paper, b, d, 'em')

  a.draw()
  b.draw()
  c.draw()
  d.draw()

  # on every click regardless of drag or not
  paper.mousedown ->
    # clear all of the selected elements
    console.log 'clicked on the paper'

