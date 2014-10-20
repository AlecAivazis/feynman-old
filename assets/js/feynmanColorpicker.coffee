# this file describes a color picker directive 
#
# author: alec aivazis

angular.module 'feynman.colorpicker', ['colorpicker.module']

.directive 'colorPicker', ->
  restrict: 'EA'
  replace: 'true'
  scope:
    model: '='
  template:'<div><div class="colorContainer"><div style="background: {{model}}"> &nbsp; </div></div><input class="colorInput" colorpicker="hex" type="text" ng-model="model" name="color"></div></div>'
