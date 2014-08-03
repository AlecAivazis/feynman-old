# this file describes the angular app the runs alongside the snap.svg application
# to draw feynman diagrams
#
# author: alec aivazis

# create the angular module 
app = angular.module 'feynman', ['colorpicker.module', 'uiSlider', 'undo']
# define the controller for the properties menu
app.controller 'diagramProperties', ['$scope',  '$rootScope', ($scope, $rootScope) ->

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
      when 'anchor'
        $scope.radius = element.radius
    # load the type independent attributes
    $scope.color = element.color
    $scope.selectedElement = element
    # apply the change since this is technically done in the jquery environment
    $scope.$apply()

  # add event handler for group selection
  $(document).on 'selectedGroup', (event, elements, type) ->
    console.log 'selected group'
    # set the type so we get the right properties menu
    $scope.type = type
    # grab the type specific attributes for the group
    switch type
      when 'anchor'
        $scope.groupRadius = -1
        $scope.groupColor = -1
        $scope.displayColor = "white"

    $scope.selectedGroup = elements
    $scope.listen = true
    $scope.$apply()

  # add event handle for clear selection
  $(document).on 'clearSelection', ->
    $scope.clearSelection()

  # load the canvas atrributes when snap is done loading
  $(document).on 'doneWithInit', ->
    canvas = $(document).attr 'canvas'
    $scope.gridSize = canvas.gridSize
    $scope.snapToGrid = canvas.snapToGrid
    $scope.showDiagramProperties = true
    $rootScope.title = canvas.title
  
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
    $scope.listen = false
    $scope.$apply()

  # update the properties of the appropriate element when we change the selectedElements 
  # the only reason to do this is because snap attributes are not settable with foo.bar = 2

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
      $(document).attr('canvas')['gridSize'] = newVal
      # redraw the canvas
      $(document).attr('canvas').draw()
    
  $scope.$watch 'color', (newVal, oldVal) ->
    if $scope.selectedElement
      $scope.selectedElement.color = newVal
      if $scope.type == 'line'
        $scope.selectedElement.element.attr 'stroke', newVal
      if $scope.type =='anchor'
        $scope.selectedElement.element.attr 'fill', newVal 

  $scope.$watch 'groupColor', (newVal, oldVal) ->
    console.log newVal
    if $scope.selectedGroup
      # if its the default value
      if parseInt(newVal) == -1
        return

      $scope.displayColor = newVal

      console.log 'chaging color'
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

  $scope.$watch 'labelDistance', (newVal, oldVal) ->
    if $scope.selectedElement and $scope.type == 'line'
      $scope.selectedElement.labelDistance = newVal
      $scope.selectedElement.drawLabel()

  $scope.$watch 'selectedElement.fixed', (newVal, oldVal) ->
    if $scope.selectedElement and $scope.type == 'anchor'
      $scope.selectedElement.draw()
    

]
