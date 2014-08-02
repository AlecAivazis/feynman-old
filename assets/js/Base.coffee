# the base class for elements in the feynman diagram application
# author: alec aivazis

class Base

  constructor: ->
    @id = $('#undoHistory').attr 'current'
