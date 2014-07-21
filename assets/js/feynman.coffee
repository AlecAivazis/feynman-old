paper =

$(document).ready ->
  initSnap()

initSnap = () ->
  # create the snap document
  paper = Snap 600, 300
  paper.anchors = []

  # anchor a
  a = new Anchor paper, 50, 25
  a.draw()

  # anchor b
  b = new Anchor paper, 150, 100
  b.draw()

  # anchor c
  c = new Anchor paper, 50, 175
  c.draw()

  # line going from a to b
  l = new Line paper, a, b 
  l.draw()

  # another line
  k = new Line paper, c, b
  k.draw()


# create the angular module 
app = angular.module 'feynman', ['colorpicker.module']
# define the controller for the properties menu
app.controller 'elementProperties', ['$scope',  '$rootScope', ($scope, $rootScope) ->
  # when an element is selected in snap the event gets propagated through jquery
  $(document).on 'selectedLine', (event, line) ->

    # load the elements properties into the ui 
    $scope.stroke = line.element.attr 'stroke'
    $scope.label = line.element.attr 'label'
    
    # set the selected element
    $scope.selectedLine = line
    # apply the change since this is technically done in the jquery environment
    $scope.$apply()

# update the properties of the appropriate element when we change the selectedLines 
  # the only reason to do this is because snap attributes are not settable with foo.bar = 2
  $scope.$watch 'stroke', (newVal, oldVal) ->
    if $scope.selectedLine
      $scope.selectedLine.element.attr 'stroke', newVal
  $scope.$watch 'label', (newVal, oldVal) ->
    if $scope.selectLine
      $scope.selectedLine.element.attr 'label', newVal
]

