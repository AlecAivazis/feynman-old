# this file describes the angular app the runs alongside the snap.svg application
# to draw feynman diagrams
#
# author: alec aivazis

# create the angular module 
app = angular.module 'feynman', [ 'ui.slider', 'undo', 'feynman.colorpicker']
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
      when 'circle'
        $scope.radius = element.radius
      when 'text'
        $scope.text = element.text
    # load the type independent attributes
    $scope.color = element.color
    $scope.selectedElement = element

    # apply the change in angular since this is done in the jquery environment
    $scope.$apply()


  # add event handler for group selection
  $(document).on 'selectedGroup', (event, elements) ->
    $scope.selectedElements = elements
    $scope.$apply()


  # add event handle for clear selection
  $(document).on 'clearSelection', ->
    $scope.clearSelection()


  # when the window resizes
  $(window).resize ->
    # refresh the grid
    refreshCanvas()


  refreshCanvas = ->
    $(document).attr('canvas').refresh()

  # prevent the inputs from triggering other keybindings
  $('input').on 'keyup', (event) ->
    # don't do anything else
    event.stopPropagation()
    # unless its a space
    if event.which == 32
      # then clear the state variable
      $(document).attr('canvas').spacebarPressed = false
    

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
        # compute the offset of the toolbar once
        paletteData.toolbarOffset = $('#toolbar').offset()
        paletteData.placedElement = false

        # save a reference to the element were dragging
        paletteData.draggedElement = $('.ui-draggable-dragging').eq(0)
        # figure out its type
        paletteData.type = paletteData.draggedElement.attr('element')
        # prevent the function from returning anything
        return
      # while the user is dragging
      drag: (event) ->
        # when the element gets outside of the toolbar
        if event.pageX < paletteData.toolbarOffset.left
          # if its the first time we have been past the toolbar
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

                # select the object
                $(document).trigger 'selectedElement', [paletteData.selectedElement, 'text']
              
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
                # select the object
                $(document).trigger 'selectedElement', [paletteData.selectedElement, 'circle']
                
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

          # hide the dragged element past the toolbar
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
          # leave an appropriate undo element
          switch paletteData.type
            # when it is a line 
            when "line", "em", "gluon", "dashed"
              # save references to the two anchors
              anchor1 = paletteData.selectedElement.anchor1
              anchor2 = paletteData.selectedElement.anchor2
              # check the anchors for potential merges
              anchor1Merged = anchor1.checkForMerges()
              anchor2Merged = anchor2.checkForMerges()
              anchor1OnLine = $(document).attr('canvas').isAnchorOnLine(anchor1) 
              anchor2OnLine = $(document).attr('canvas').isAnchorOnLine(anchor2) 

              # if only one of them merged
              if ( anchor1Merged and not anchor2OnLine ) or ( anchor2Merged and not anchor1OnLine )
                # save the references to the meaning elements
                merged = if anchor1Merged then anchor1Merged else anchor2Merged
                line = paletteData.selectedElement
                otherAnchor = if line.anchor1 == merged then line.anchor2 else line.anchor1
                # register the branch with the undo stack
                new UndoEntry false,
                  title: 'added propragator to vertex'
                  data:
                    line: line
                    otherAnchor: otherAnchor
                  backwards: ->
                    @data.otherAnchor.remove()
                    @data.line.remove()
                  forwards: ->
                    @data.otherAnchor.ressurect()
                    @data.line.ressurect()
                    @data.otherAnchor.draw()

              # both merged
              else if anchor1Merged and anchor2Merged 
                # register the line creation with the undo stack
                new UndoEntry false,
                  title: 'added internal propagator'
                  data:
                    line: paletteData.selectedElement
                  forwards: ->
                    @data.line.ressurect()
                    @data.line.draw()
                  backwards: ->
                    @data.line.remove()

              # only one split
              else if (anchor1OnLine and not anchor2Merged) != (anchor2OnLine and not anchor1Merged)
                # split the appropriate line
                split = if anchor1OnLine then anchor1OnLine.split(anchor1.x, anchor1.y) else anchor2OnLine.split(anchor2.x, anchor2.y)

                # merge the split anchor with the appopriate one
                if anchor1OnLine
                  splitAnchor = anchor1.merge(split.anchor)
                else
                  splitAnchor = anchor2.merge(split.anchor)

                # save a reference to the lines
                splitLine = split.line
                newLine = paletteData.selectedElement

                if splitLine.anchor1 == splitAnchor
                  otherAnchor = splitLine.anchor2
                else
                  otherAnchor = splitLine.anchor1

                # register the split with the undo stack
                new UndoEntry false,
                  title: 'added branch to propagator'
                  data:
                    originalLine: split.originalLine
                    splitLine: splitLine
                    splitAnchor: splitAnchor
                    otherAnchor: otherAnchor
                    newLine: newLine
                    newAnchor: if newLine.anchor1 == splitAnchor then newLine.anchor2 else newLine.anchor1
                  backwards: ->
                    @data.originalLine.replaceAnchor(@data.splitAnchor, @data.otherAnchor)
                    @data.otherAnchor.addLine(@data.originalLine)
                    @data.newAnchor.remove()
                    @data.newLine.remove()
                    @data.splitLine.remove()
                    @data.splitAnchor.remove()
                    @data.otherAnchor.draw()
                  forwards: ->
                    @data.originalLine.replaceAnchor(@data.otherAnchor, @data.splitAnchor)
                    @data.otherAnchor.removeLine(@data.originalLine)
                    @data.splitAnchor.ressurect()
                    @data.splitAnchor.addLine(@data.originalLine)
                    @data.splitLine.ressurect()
                    @data.newAnchor.ressurect()
                    @data.newLine.ressurect()
                    @data.newAnchor.draw()
                    @data.splitAnchor.draw()

              # both sides were a split
              else if anchor1OnLine and anchor2OnLine
                # split the line at the anchor
                anchor1split = anchor1OnLine.split(anchor1.x, anchor1.y)
                # merge the anchor with the split
                anchor1.merge(anchor1split.anchor)

                # split the other line
                anchor2split = anchor2OnLine.split(anchor2.x, anchor2.y)
                # merge anchor2 with the split anchor
                anchor2.merge(anchor2split.anchor)

                # register the double split with the undo stack
                new UndoEntry false,
                  title: 'added internal propagator'
                  data:
                    anchor1: anchor1split
                    anchor2: anchor2split
                    line: paletteData.selectedElement
                  backwards: ->
                    @data.anchor1.originalLine.replaceAnchor(@data.anchor1.anchor,
                                                             @data.anchor1.otherAnchor)
                    @data.anchor1.anchor.remove()
                    @data.anchor1.otherAnchor.addLine(@data.anchor1.originalLine)
                    @data.anchor1.otherAnchor.draw()
                    @data.anchor1.line.remove()
                    @data.line.remove()
                    @data.anchor2.originalLine.replaceAnchor(@data.anchor2.anchor,
                                                             @data.anchor2.otherAnchor)
                    @data.anchor2.anchor.remove()
                    @data.anchor2.otherAnchor.addLine(@data.anchor2.originalLine)
                    @data.anchor2.otherAnchor.draw()
                    @data.anchor2.line.remove()
                  forwards: ->
                    @data.anchor1.otherAnchor.removeLine(@data.anchor1.originalLine)
                    @data.anchor1.anchor.ressurect()
                    @data.anchor1.line.ressurect()
                    @data.anchor1.originalLine.replaceAnchor(@data.anchor1.otherAnchor,
                                                             @data.anchor1.anchor)
                    @data.anchor1.anchor.draw()
        
                    @data.anchor2.otherAnchor.removeLine(@data.anchor2.originalLine)
                    @data.anchor2.anchor.ressurect()
                    @data.anchor2.line.ressurect()
                    @data.anchor2.originalLine.replaceAnchor(@data.anchor2.otherAnchor,
                                                             @data.anchor2.anchor)
                    @data.line.ressurect()
                    @data.anchor2.anchor.draw()
                    
              # nothing happened with the line
              else
                # register the element creation with the undo stack
                new UndoEntry false,
                  title: "Added a standalone propagator from the palette"
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
              # check if any anchors needs to be constrained
              constrained = $(document).attr('canvas').checkAnchorsForConstraint(paletteData.selectedElement)
              # if any anchors were there
              if constrained.length > 0
                # go over each of the constrained anchors
                _.each constrained, (anchor) ->
                  # apply the constrain
                  anchor.addConstraint(paletteData.selectedElement)
                  # draw the anchor with the new constrain
                  anchor.draw()
                # register the new constraint with the undo stack
                new UndoEntry false,
                  title: 'created constraint for anchors'
                  data:
                    constraint: paletteData.selectedElement
                    anchors: constrained
                  backwards: ->
                    @data.constraint.remove()
                    # remove the constraint from the anchors
                    _.each @data.anchors, (anchor) ->
                      anchor.removeConstraint()
                      # draw the anchor with the updated constraint
                      anchor.draw()
                  forwards: ->
                    constraint = @data.constraint
                    constraint.draw()
                    # add the constraint to the anchors
                    _.each @data.anchors, (anchor) ->
                      anchor.addConstraint(constraint)
                      # draw the anchor with the new constraint
                      anchor.draw()

              # no anchors need constraining
              else
                # register the free constraint with the undo stack
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

    # deselect the patterns aswell
    _.each Snap.selectAll('.selectedPattern'), (element) ->
      element.removeClass('selectedPattern')
      
    # clear the angular selection
    $scope.selectedElement = false
    $scope.selectedElements = false
    # apply these changes to angular
    $scope.type = undefined
    $scope.$apply()


  # align event element in the selected group align the given direction
  $scope.alignGroup = (direction) ->
    # grab the selected anchors
    selected = $scope.selectedElements.anchor
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

  $(document).on 'deleteSelectedElement', ->
    $scope.deleteSelectedElement()

  # assuming the selected element is a line, delete it and register it with the undo stack
  $scope.deleteSelectedElement = ->
    # get the selected line
    element = Snap.select('.selectedElement')

    # if the element doesn't exist
    if not element
      # dont do anything
      return

    # use the scope variable for the element type
    type = $scope.type
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

    # else if its a constraint
    else if type == 'circle'
      $timeout ->
        # remove the constraint and register it with the undo stack
        new UndoEntry true,
          title: 'removed constraint'
          data:
            constraint: element.constraint
            anchors: element.constraint.anchors
          backwards: ->
            constraint = @data.constraint
            # draw the constraint
            @data.constraint.draw()
            # go to each of the anchors
            _.each @data.anchors, (anchor) ->
              # add the constraint
              anchor.addConstraint(constraint)
              # draw with the new constraint
              anchor.draw()
          forwards: ->
            _.each @data.anchors, (anchor) ->
              # remove the constraint
              anchor.removeConstraint()
              # redraw with the anchor
              anchor.draw()
            @data.constraint.remove()

      , 0
    else if type == 'text'
      $timeout ->
        new UndoEntry true,
          title: 'removed text field'
          data:
            element: element.text
          backwards: ->
            @data.element.draw()
          forwards: ->
            @data.element.remove()
      , 0
    # clear the element selection
    $timeout ->
      $(document).trigger('clearSelection')
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
      if $scope.type in ['line', 'anchor', 'circle']
        $scope.selectedElement.draw()

  $scope.$watch 'groupAnchorColor', (newVal, oldVal) ->
    if $scope.selectedElements.anchor
      # if its the default value
      if parseInt(newVal) == -1
        return

      _.each $scope.selectedElements.anchor, (element) ->
        element.color = newVal
        element.draw()

  $scope.$watch 'groupSize', (newVal, oldVal) ->
    # go over every line
    if $scope.selectedElements.line
      # check that its a valid value
      if parseInt(newVal) == -1
        return
      # go over each of the lines
      _.each $scope.selectedElements.line, (element) ->
        # set the width
        element.width = parseInt(newVal)
        # draw the element
        element.draw()
      
  $scope.$watch 'groupLineColor', (newVal, oldVal) ->
    if $scope.selectedElements.line
      # if its the default value
      if parseInt(newVal) == -1
        return

      _.each $scope.selectedElements.line, (element) ->
        element.color = newVal
        element.draw()

  $scope.$watch 'groupCircleColor', (newVal, oldVal) ->
    if $scope.selectedElements.circle
      # if its the default value
      if parseInt(newVal) == -1
        return

      _.each $scope.selectedElements.circle, (element) ->
        element.color = newVal
        element.draw()

  $scope.$watch 'groupCircleRadius', (newVal, oldVal) ->
    if $scope.selectedElements.circle
      # if its the default value
      if parseInt(newVal) == -1
        return

      _.each $scope.selectedElements.circle, (element) ->
        element.radius = newVal
        element.draw()
        
  $scope.$watch 'radius', (newVal, oldVal) ->
    if $scope.selectedElement and $scope.type in ['anchor' ,'circle']
      $scope.selectedElement.radius = newVal
      $scope.selectedElement.draw()

  $scope.$watch 'selectedElement.text', (newVal, oldVal) ->
    if $scope.selectedElement and $scope.type == 'text'
      $scope.selectedElement.draw()


  $scope.$watch 'groupAnchorRadius', (newVal, oldVal) ->

    if parseFloat(newVal) < 0 or isNaN newVal
      return

    if $scope.selectedElements.anchor
      _.each $scope.selectedElements.anchor, (sAnchor) ->
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
