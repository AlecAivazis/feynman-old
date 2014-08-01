# this file describes the implementation of a general undo stack in angular

# create the angular module
undo = angular.module 'undo', []

undo.controller 'undoCtrl', [ '$scope', ($scope) ->

  # start with an empty queue
  $scope.queue = []
  # and pointing at the zeroth entry
  $scope.current = -1
  
  # listen to the dom for events to add to the que
  $(document).on 'addEventToUndo', ( event, title, data, transparent = true,
                                     forward, backward ) ->  
    # increment the counter
    $scope.current++ 

    # remove all of the undo entries past current
    $scope.queue = $scope.queue.splice(0, $scope.current)

    # add the event to the queue
    $scope.queue.push
      id: $scope.current
      title: title
      forward: forward
      background: backward

    # tell angular to refresh 
    $scope.$apply()

    # if they want this to be a wrapper around the intial call the forward
    if transparent
      # call the forward action with the provided data
      forward.apply(data: data)

  
]

handleMove = ->
  console.log 'okay'
