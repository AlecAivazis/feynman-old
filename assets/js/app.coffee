# this file describes the angular app the runs alongside the snap.svg application
# to draw feynman diagrams
#
# author: alec aivazis

# create the angular module 
app = angular.module 'feynman', ['colorpicker.module', 'ui.slider', 'undo']
# define the controller for the properties menu
app.controller 'diagramProperties', ['$scope',  '$rootScope', '$timeout', ($scope, $rootScope, $timeout) ->

  # add event handler for element selection
  $(document).on 'selectedElement', (event, element, type) ->

    # clear the previous selection
    $(document).trigger('clearSelection')
    # and add the class to the selected element
    element.element.addClass('selectedElement')

    # load the type of element
    $scope.type = type
    # load type specific attributes
    switch type
      when 'line'
        $scope.width = element.width
        $scope.labelDistance = element.labelDistance
        $scope.labelLocation = element.labelLocation
      when 'anchor'
        $scope.radius = element.radius
    # load the type independent attributes
    $scope.color = element.color
    $scope.selectedElement = element
    # apply the change since this is technically done in the jquery environment
    $scope.$apply()

  # add event handler for group selection
  $(document).on 'selectedGroup', (event, elements, type) ->
    # set the type so we get the right properties menu
    $scope.type = type
    # grab the type specific attributes for the group
    switch type
      when 'anchor'
        $scope.groupRadius = -1
        $scope.groupColor = -1
        $scope.displayColor = "white"

    $scope.selectedGroup = elements
    $scope.$apply()

  # add event handle for clear selection
  $(document).on 'clearSelection', ->
    $scope.clearSelection()


  # when the window resizes
  $(window).resize ->
    # refresh the grid
    $(document).attr('canvas').refresh()


  # load the canvas atrributes when snap is done loading
  $(document).on 'doneWithInit', ->
    canvas = $(document).attr 'canvas'
    $scope.gridSize = canvas.gridSize
    $scope.snapToGrid = canvas.snapToGrid
    $scope.showDiagramProperties = true
    $scope.hideAnchors = canvas.hideAnchors
    $scope.hideGrid = canvas.hideGrid
    $rootScope.title = canvas.title
    resizeCanvas()
  
  # clear the selection
  $scope.clearSelection = ->
  
    # find every selected element
    _.each Snap.selectAll('.selectedElement'), (element) ->
      # only for anchors (ignore lines)
      if element.anchor
        # clear the group move flag
        element.anchor.moveAsGroup = false
      # and deselect it
      element.removeClass('selectedElement')
      
    # clear the angular selection
    $scope.selectedElement = false
    $scope.selectedGroup = false
    $scope.$apply()

  # align event element in the selected group align the given direction
  $scope.alignGroup = (direction) ->
    # grab the selected anchors
    selected = (element.anchor for element in Snap.selectAll('.selectedElement').items)
    # get the appropraite attribute given the direction
    if direction == 'vertical'
      attr = 'x'
    else if direction == 'horizontal'
      attr = 'y'

    # compute the sum over the appropriate attribute and its average
    sum = _.reduce selected, (runningTotal, element) ->
      return runningTotal + parseFloat(element[attr])
    , 0
    avg = sum / selected.length

    # store the origin so we can move back
    translate_data = []
    for element in selected
      translate_data.push
        element: element
        x: element.x
        y: element.y

    # perform the alignment in its own apply block
    $timeout ->
      new UndoEntry true,
        title: 'aligned vertices ' + direction + 'ly'
        data: [translate_data, attr, avg]
        forwards: ->
          _.each @data[0], (anchor) =>
            anchor.element.translate(@data[1], @data[2], false)
        backwards: ->
          _.each @data[0], (anchor) =>
            anchor.element.handleMove(anchor.x, anchor.y, false)
    , 0

  # assuming the selected element is a line, delete it and register it with the undo stack
  $scope.deleteSelectedElement = (type) ->
    # get the selected line
    element = Snap.select('.selectedElement')
    # if the element is a line
    if type == 'line'
      # remove the line and register it with the undo stack
      $timeout ->
        new UndoEntry true,
          title: 'removed line'
          data: [element.line]
          forwards: ->
            @data[0].remove()
          backwards: ->
            @data[0].ressurect().draw()
      , 0
    # if they asked for an anchor
    else if type == 'anchor'
      # remove the anchor and register it with the undo stack
      $timeout ->
        new UndoEntry true,
          title: 'removed anchor'
          data: [element.anchor, element.anchor.lines]
          forwards: ->
            # remove the anchor
            @data[0].remove()
            # and the lines associated with the anchor
            _.each @data[1], (line) ->
              line.remove()
          backwards: ->
            # ressurect the anchor
            @data[0].ressurect()
            # all of the lines
            _.each @data[1], (line) ->
              line.ressurect()
            # draw the anchor
            @data[0].draw()
      , 0


  # update the properties of the appropriate element when we change the selectedElements 
  # the only reason to do this is because some attributes are not settable with foo.bar = 2
  # or we need to call the appropriate draw after the variable is reset

  $rootScope.$watch 'title', (newVal, oldVal) ->
    if $(document).attr 'canvas'
      $(document).attr('canvas').title = newVal

  $scope.$watch 'snapToGrid', (newVal, oldVal) ->
    # grab the canvas
    canvas = $(document).attr 'canvas'
    # if it exists
    if $(document).attr 'canvas'
      # change the value of the object
      $(document).attr('canvas')['snapToGrid'] = newVal
      # redraw the canvas
      $(document).attr('canvas').draw()

  $scope.$watch 'gridSize', (newVal, oldVal) ->
    # grab the canvas
    canvas = $(document).attr 'canvas'
    # if it exists
    if $(document).attr 'canvas'
      # change the value of the object
      $(document).attr('canvas').gridSize = parseInt(newVal)
      # redraw the canvas
      $(document).attr('canvas').draw()

  $scope.$watch 'hideAnchors', (newVal, oldVal) ->
    if $(document).attr 'canvas'
      $(document).attr('canvas').hideAnchors = newVal
      $(document).attr('canvas').draw()
    
  $scope.$watch 'hideGrid', (newVal, oldVal) ->
    if $(document).attr 'canvas'
      $(document).attr('canvas').hideGrid = newVal
      $(document).attr('canvas').draw()

  $scope.$watch 'color', (newVal, oldVal) ->
    if $scope.selectedElement
      $scope.selectedElement.color = newVal
      if $scope.type == 'line'
        $scope.selectedElement.draw()
      if $scope.type =='anchor'
        $scope.selectedElement.draw()

  $scope.$watch 'groupColor', (newVal, oldVal) ->
    if $scope.selectedGroup
      # if its the default value
      if parseInt(newVal) == -1
        return

      $scope.displayColor = newVal

      _.each $scope.selectedGroup, (element) ->
        if $scope.type == 'anchor'
          element.color = newVal
        element.draw()
        
  $scope.$watch 'radius', (newVal, oldVal) ->
    if $scope.selectedElement and $scope.type == 'anchor'
      $scope.selectedElement.radius = newVal
      $scope.selectedElement.draw()

  $scope.$watch 'groupRadius', (newVal, oldVal) ->

    if parseFloat(newVal) < 0 or isNaN newVal
      return

    if $scope.selectedGroup and $scope.type == 'anchor'
      _.each $scope.selectedGroup, (sAnchor) ->
        sAnchor.radius = newVal
        sAnchor.draw()

  $scope.$watch 'width', (newVal, oldVal) ->
    if $scope.selectedElement
      $scope.selectedElement.width = newVal
      $scope.selectedElement.draw()

  $scope.$watch 'selectedElement.label', (newVal, oldVal) ->
    # we need to tell the element to redraw by hand to incorporate the new label 
    if $scope.selectedElement
      $scope.selectedElement.drawLabel()

  $scope.$watch 'selectedElement.style', (newVal, oldVal) ->
    if $scope.selectedElement
      $scope.selectedElement.draw()

  $scope.$watch 'selectedElement.loopDirection', (newVal, oldVal) ->
    if $scope.selectedElement
      $scope.selectedElement.draw()

  $scope.$watch 'selectedElement.labelPosition', (newVal, oldVal) ->
    if $scope.selectedElement and $scope.type == 'line'
      $scope.selectedElement.drawLabel()

  $scope.$watch 'selectedElement.drawArrow', (newVal, oldVal) ->
    if $scope.selectedElement and $scope.type == 'line'
      $scope.selectedElement.draw()

  $scope.$watch 'selectedElement.flipArrow', (newVal, oldVal) ->
    if $scope.selectedElement and $scope.type == 'line'
      $scope.selectedElement.draw()

  $scope.$watch 'selectedElement.drawEndCaps', (newVal, oldVal) ->
    if $scope.selectedElement
      $scope.selectedElement.draw()

  $scope.$watch 'labelDistance', (newVal, oldVal) ->
    if $scope.selectedElement and $scope.type == 'line'
      $scope.selectedElement.labelDistance = newVal
      $scope.selectedElement.drawLabel()

  $scope.$watch 'labelLocation', (newVal, oldVal) ->
    if $scope.selectedElement and $scope.type == 'line'
      $scope.selectedElement.labelLocation = parseFloat(newVal)
      $scope.selectedElement.drawLabel()

  $scope.$watch 'selectedElement.fixed', (newVal, oldVal) ->
    if $scope.selectedElement and $scope.type == 'anchor'
      $scope.selectedElement.draw()
    

]
