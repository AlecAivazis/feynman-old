paper =

$(document).ready ->

  # create the snap document
  paper = Snap '#canvas' 
  paper.anchors = []

  # define the anchors for the default view

  a = new Anchor paper, 50, 25
  b = new Anchor paper, 150, 100
  c = new Anchor paper, 50, 175
  d = new Anchor paper, 300, 100

  # and the lines connecting them

  k = new Line paper, a, b 
  l = new Line paper, c, b, 'gluon'
  m = new Line paper, b, d, 'em'

  a.draw()
  b.draw()
  c.draw()
  d.draw()

# create the angular module 
app = angular.module 'feynman', ['colorpicker.module']
# define the controller for the properties menu
app.controller 'elementProperties', ['$scope',  '$rootScope', ($scope, $rootScope) ->
  # when an element is selected in snap the event gets propagated through jquery
  $(document).on 'selectedLine', (event, line) ->

    # load the elements properties into the ui 
    $scope.stroke = line.element.attr 'stroke'
    
    # set the selected element
    $scope.selectedLine = line
    # apply the change since this is technically done in the jquery environment
    $scope.$apply()

  # update the properties of the appropriate element when we change the selectedLines 
  # the only reason to do this is because snap attributes are not settable with foo.bar = 2
  $scope.$watch 'stroke', (newVal, oldVal) ->
    if $scope.selectedLine
      $scope.selectedLine.stroke = newVal
      $scope.selectedLine.element.attr 'stroke', newVal

  # if they set the label
  $scope.$watch 'selectedLine.label', (newVal, oldVal) ->
    # we need to tell the element to redraw by hand to incorporate the new label 
    if $scope.selectedLine
      $scope.selectedLine.drawLabel()

  # if they change the line style
  $scope.$watch 'selectedLine.style', (newVal, oldVal) ->
    if $scope.selectedLine
      $scope.selectedLine.draw()

  # if they change the line style
  $scope.$watch 'selectedLine.labelPosition', (newVal, oldVal) ->
    if $scope.selectedLine
      $scope.selectedLine.drawLabel()
    

]

