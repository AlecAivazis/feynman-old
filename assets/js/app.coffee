# this file describes the angular app the runs alongside the snap.svg application
# to draw feynman diagrams
#
# author: alec aivazis

# create the angular module 
app = angular.module 'feynman', ['colorpicker.module', 'ui.slider', 'undo']
# define the controller for the properties menu
app.controller 'sidebar', ['$scope',  '$rootScope', '$timeout', ($scope, $rootScope, $timeout) ->

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

    # apply the change in angular since this is done in the jquery environment
    $scope.$apply()
    # orient the tooptip on the selected element
    #$scope.orientTooltip(element, type)


  # align the tooltip element along an element
  $scope.orientTooltip = (element, type) ->
    # compute the coordinates of the event to place the tooltip
    x = $('#sidebar').width()
    y = 0
    switch type
      when 'line'
        # use the midpoint of the line
        x += (element.anchor1.x + element.anchor2.x ) / 2
        y = (element.anchor1.y + element.anchor2.y ) / 2
      when 'anchor'
        # use the anchor's coordinates
        x += element.x
        y = element.y

    # set the off set to position the tooltip
    $("#tooltip").offset
      # place the tooltip slightly below the target coordinates
      top: y+10
      left: x - $('#tooltip').width()/2


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


  # add a listener to reorient thee tooltip when things move
  $(document).on 'orientTooltip', ->
    #$scope.orientTooltip($scope.selectedElement, $scope.type)


  # when the window resizes
  $(window).resize ->
    # refresh the grid
    refreshCanvas()


  refreshCanvas = ->
    $(document).attr('canvas').refresh()
    

  # store an object for the palette data
  paletteData = {}
    
    
  # load the canvas atrributes when snap is done loading
  $(document).on 'doneWithInit', ->
    canvas = $(document).attr 'canvas'
    $scope.gridSize = canvas.gridSize
    $scope.snapToGrid = canvas.snapToGrid
    $scope.showDiagramProperties = true
    $scope.hideAnchors = canvas.hideAnchors
    $scope.hideGrid = canvas.hideGrid
    $rootScope.title = canvas.title

    refreshCanvas()

    # add the drag handlers to the items on the pallet
    $('.paletteItem').draggable
      # use the image as the element that is dragged
      helper: 'clone'
      # at the beginning of the drag
      start: ->
        # compute the offset of the tooltip once
        paletteData.tooltipOffset = $('#tooltip').offset()
        paletteData.placedElement = false

        # save a reference to the element were dragging
        paletteData.draggedElement = $('.ui-draggable-dragging').eq(0)
        # figure out its type
        paletteData.type = paletteData.draggedElement.attr('element')
        # prevent the function from returning anything
        return
      # while the user is dragging
      drag: (event) ->
        # when the element gets outside of the tooltip
        if event.pageX < paletteData.tooltipOffset.left
          # if its the first time we have been past the tooltip
          if not paletteData.placedElement
            # grab the paper object from the canvas
            paper = $(document).attr('canvas').paper
            # compute the offset of the dragged element
            offset = paletteData.draggedElement.offset()
            
            # handle each type independently
            switch paletteData.type
              # when it is a line style
              when "line", "em", "gluon", "dashed"
                # compute the lower left coordinates of the bounding box
                lowerLeft = canvas.getCanvasCoordinates(
                   offset.left - paletteData.draggedElement.width() - $('#sidebar').width(),
                   offset.top + paletteData.draggedElement.height() )
                # make an anchor at the lower left corner
                anchor1 = new Anchor(paper, lowerLeft.x, lowerLeft.y)
                # draw the anchor
                anchor1.draw()

                # compute the upper right coordinates of the bounding box
                upperRight = canvas.getCanvasCoordinates( offset.left - $('#sidebar').width() , offset.top )
                # create an anchor at the upper right coordinates
                anchor2 = new Anchor(paper, upperRight.x, upperRight.y)

                # make a line joining the two anchors with the appropriate style
                line = new Line(paper, anchor1, anchor2, paletteData.type)
              
                # draw the second anchor
                anchor2.draw()

                # select the newly created line
                $(document).trigger 'selectedElement', [line, 'line']
                paletteData.selectedElement = line
                # store the necessary data
                paletteData.anchor1 = anchor1
                paletteData.anchor2 = anchor2
                paletteData.anchor1_origin = lowerLeft
                paletteData.anchor2_origin = upperRight
                paletteData.mouse_origin =
                  x: event.pageX
                  y: event.pageY

              when 'text'
                # compute the coordinates on the canvas
                paletteData.origin = canvas.getCanvasCoordinates(
                     offset.left - $("#sidebar").width() - ( paletteData.draggedElement.width() / 2 ),
                     offset.top + (paletteData.draggedElement.height() / 2 ) )
                # create the text object at the appropriate coordinates
                paletteData.selectedElement = new Text(paper, paletteData.origin.x,
                                                              paletteData.origin.y, 'text!')
                # draw the text field
                paletteData.selectedElement.draw()
              
              when 'circle'
                # compute the coordinates on the canvas
                paletteData.origin = canvas.getCanvasCoordinates(
                     offset.left - $("#sidebar").width() - ( paletteData.draggedElement.width() / 2 ),
                     offset.top + (paletteData.draggedElement.height() / 2 ) )
                paletteData.selectedElement = new CircularConstraint(paper,paletteData.origin.x,
                                                                           paletteData.origin.y,
                                                                           paletteData.draggedElement.height()/2)
                # draw the constraint
                paletteData.selectedElement.draw()
  

            # prevent future drags from creating new elements
            paletteData.placedElement = true

          # move the selected element
          switch paletteData.type
            # when it is a line style
            when "line", "em", "gluon", "dashed"
              # compute the change in mouse coordinates
              dx = (event.pageX - paletteData.mouse_origin.x)/canvas.zoomLevel
              dy = (event.pageY - paletteData.mouse_origin.y)/canvas.zoomLevel
              # move the first anchor by the same amount as the mouse moved
              paletteData.anchor1.handleMove(paletteData.anchor1_origin.x + dx,
                                             paletteData.anchor1_origin.y + dy)
              # move the second anchor by the same amount as the mouse moved
              paletteData.anchor2.handleMove(paletteData.anchor2_origin.x + dx,
                                             paletteData.anchor2_origin.y + dy)
            # when its an element by itself
            when "text", "circle"
              # move the selected element
              mouseCoords = canvas.getCanvasCoordinates(event.pageX - $('#canvas').offset().left , event.pageY)
              paletteData.selectedElement.handleMove(mouseCoords.x, mouseCoords.y)

          # hide the dragged element past the tooltip
          paletteData.draggedElement.hide()

        # the cursor is inside the toolbar
        else
          # if there is a selected element
          if paletteData.selectedElement
            # when its a line
            if paletteData.type in ["line", "em", "gluon", "dashed"]
              # remove the two anchors
              paletteData.selectedElement.anchor1.remove()
              paletteData.selectedElement.anchor2.remove()

            # remove the selected element
            paletteData.selectedElement.remove()
            # clear the palette data associated with the created element
            paletteData.placedElement = false
            paletteData.selectedElement = undefined
            # clear the selection 
            $(document).trigger('clearSelection')

          # show the element from the toolbar
          paletteData.draggedElement.show()
  
          
      # the dragging of an element from the palette has stopped
      stop: (event) ->
        # if we let go with an element selected
        if paletteData.selectedElement
          # if that element can check for merges
          if paletteData.selectedElement.checkForMerges
            # do so
            merges =  paletteData.selectedElement.checkForMerges()
          # if the element merged with something
          if merges
            console.log 'there are merges for the newly created element BEGIN THE UNDO TREE'
          # the element did not merge with anything
          else
            # leave an appropriate undo element
            switch paletteData.type
              # when it is a line 
              when "line", "em", "gluon", "dashed"
                # register the element creation with the undo stack
                new UndoEntry false,
                  title: "Added a standalone #{paletteData.type} propagator from the palette"
                  data:
                    line: paletteData.selectedElement
                    anchor1: paletteData.anchor1
                    anchor2: paletteData.anchor2
                  forwards: ->
                    @data.anchor1.ressurect() 
                    @data.anchor2.ressurect() 
                    @data.line.ressurect()
                    @data.anchor1.draw()
                    @data.anchor2.draw()
                  backwards: ->
                    @data.line.remove()
                    @data.anchor1.remove()
                    @data.anchor2.remove()

              # when its a text field
              when 'text'
                new UndoEntry false,
                  title: 'Added a text field to the canvas'
                  data:
                    element: paletteData.selectedElement
                  forwards: ->
                    @data.element.draw()
                  backwards: ->
                    @data.element.remove()

              # when its a circular constraint
              when "circle"
                new UndoEntry false,
                  title: 'Added a circular constraint to the canvas'
                  data:
                    element: paletteData.selectedElement
                  forwards: ->
                    @data.element.draw()
                  backwards: ->
                    @data.element.remove()
                  
        
        # clear the palette data so the next drag is fresh
        paletteData = {}

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
    # apply these changes to angular
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
