# the base class for elements in the feynman diagram application
# author: alec aivazis

creationCount = 0

class Base

  constructor: ->
    @id = creationCount
    creationCount++
