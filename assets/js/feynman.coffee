$(document).ready ->

  # create the snap document
  paper = Snap 700, 600
  paper.anchors = []

  # anchor a
  a = new Anchor paper, 50, 50
  a.draw()

  # anchor b
  b = new Anchor paper, 150, 150
  b.draw()

  # anchor c
  c = new Anchor paper, 50, 250
  c.draw()

  # line going from a to b
  l = new Line paper, a, b 
  l.draw()

  # another line
  k = new Line paper, c, b
  k.draw()
