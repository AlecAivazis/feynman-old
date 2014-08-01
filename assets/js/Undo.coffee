# this file describes the implementation of a general undo stack in angular

# create the angular module
undo = angular.module 'undo', []

undo.controller 'undoCtrl', [ '$scope', ($scope) ->

  # start with an empty queue
  $scope.queue = []
  # and pointing at the zeroth entry
  $scope.current = -1
  
  # listen to the dom for events to add to the que
  $(document).on 'addEventToUndo', ( event, title, transparent = true, data,
                                     forward, backward ) ->  
    # increment the counter
    $scope.current++ 

    # remove all of the undo entries past current
    $scope.queue = $scope.queue.splice(0, $scope.current)

    # add the event to the queue
    $scope.queue.push
      id: $scope.current
      title: title
      data: data
      forward: forward
      backward: backward

    # tell angular to refresh 
    $scope.$apply()

    # if they want this to be a wrapper around the intial call the forward
    if transparent
      # call the forward action with the provided data
      forward.apply(data: data)


  # perform the necessary steps to go to a specific event
  $scope.goTo = (id) ->

    console.log 'going to ' , id
    console.log 'current: ', $scope.current

    # check that were actually doing something
    if id == $scope.current
      console.log 'you have no where to go'
      return
    
    # if we want to go forwards in time
    if id > $scope.current
      # for every step in between me and the target
      while $scope.current < id
        # increment the counter
        $scope.current++
        # grab the entry
        entry = $scope.queue[$scope.current]
        # apply the forward function
        entry.forward.apply(data: entry.data)
        console.log $scope.current
    # otherwise we want to go backwards in time
    else
      # go every step in between the current one and the guy before our target
      while $scope.current > id
        # grab the undo entry
        entry = $scope.queue[$scope.current]
        # apply the backwards function
        entry.backward.apply(data: entry.data)
        # decrement the counter
        $scope.current--
        console.log $scope.current
      


  
]

handleMove = ->
  console.log 'okay'
