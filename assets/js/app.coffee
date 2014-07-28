# this file describes the angular app the runs alongside the snap.svg application
# to draw feynman diagrams
# author: alec aivazis

# create the angular module 
app = angular.module 'feynman', ['colorpicker.module', 'uiSlider']
# define the controller for the properties menu
app.controller 'elementProperties', ['$scope',  '$rootScope', ($scope, $rootScope) ->
  # when an element is selected in snap the event gets propagated through jquery
  $(document).on 'selectedElement', (event, element, type) ->

    $scope.type = type

    switch type
      when 'line'
        # load the elements properties into the ui 
        $scope.color = element.color
        # fucking ui-slider
        $scope.width = element.width
      when 'anchor'
        $scope.radius = element.element.attr 'r'
        $scope.color = element.color

    $scope.selectedElement = element
    # apply the change since this is technically done in the jquery environment
    $scope.$apply()

  # update the properties of the appropriate element when we change the selectedElements 
  # the only reason to do this is because snap attributes are not settable with foo.bar = 2
  $scope.$watch 'color', (newVal, oldVal) ->
    if $scope.selectedElement
      console.log 'changing an acutal color'
      $scope.selectedElement.color = newVal
      if $scope.type == 'line'
        $scope.selectedElement.element.attr 'stroke', newVal
      if $scope.type =='anchor'
        console.log 'changing fill color'
        $scope.selectedElement.element.attr 'fill', newVal 

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
    if $scope.selectedElement
      $scope.selectedElement.drawLabel()
    

]
