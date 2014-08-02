# this file describes the angular app the runs alongside the snap.svg application
# to draw feynman diagrams
# author: alec aivazis

# create the angular module 
app = angular.module 'feynman', ['colorpicker.module', 'uiSlider', 'undo']
# define the controller for the properties menu
app.controller 'diagramProperties', ['$scope',  '$rootScope', ($scope, $rootScope) ->

  $(document).on 'clearSelection', ->
    $scope.clearSelection()

  $(document).on 'doneWithInit', ->
    canvas = $(document).attr 'canvas'
    $scope.gridSize = canvas.gridSize
    $scope.snapToGrid = canvas.snapToGrid
    # show the UI element for the diagram properties
    $scope.showDiagramProperties = true

    $rootScope.title = canvas.title
  

  # if they change the diagram title then update it on the object
  $rootScope.$watch 'title', (newVal, oldVal) ->
    if $(document).attr 'canvas'
      $(document).attr('canvas').title = newVal

  # if they changes the snapToGrid boolean
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
    
  # when an element is selected in snap the event gets propagated through jquery
  $(document).on 'selectedElement', (event, element, type) ->

    # clear the current selection
    $(document).trigger('clearSelection')

    # load the type of element
    $scope.type = type

    switch type
      when 'line'
        $scope.width = element.width
        $scope.labelDistance = element.labelDistance
      when 'anchor'
        $scope.radius = element.radius

    $scope.color = element.color
    $scope.selectedElement = element
    # apply the change since this is technically done in the jquery environment
    $scope.$apply()

    element.element.addClass('selectedElement')

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
    $scope.$apply()

  # update the properties of the appropriate element when we change the selectedElements 
  # the only reason to do this is because snap attributes are not settable with foo.bar = 2
  $scope.$watch 'color', (newVal, oldVal) ->
    if $scope.selectedElement
      $scope.selectedElement.color = newVal
      if $scope.type == 'line'
        $scope.selectedElement.element.attr 'stroke', newVal
      if $scope.type =='anchor'
        $scope.selectedElement.element.attr 'fill', newVal 

  $scope.$watch 'radius', (newVal, oldVal) ->
    if $scope.selectedElement and $scope.type == 'anchor'
      $scope.selectedElement.radius = newVal
      $scope.selectedElement.draw()

  $scope.$watch 'width', (newVal, oldVal) ->
    if $scope.selectedElement
      $scope.selectedElement.width = newVal
      $scope.selectedElement.draw()

  # if they set the label
  $scope.$watch 'selectedElement.label', (newVal, oldVal) ->
    # we need to tell the element to redraw by hand to incorporate the new label 
    if $scope.selectedElement
      $scope.selectedElement.drawLabel()

  # if they change the line style
  $scope.$watch 'selectedElement.style', (newVal, oldVal) ->
    if $scope.selectedElement
      $scope.selectedElement.draw()

  $scope.$watch 'selectedElement.loopDirection', (newVal, oldVal) ->
    if $scope.selectedElement
      $scope.selectedElement.draw()

  # if they change the line style
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
