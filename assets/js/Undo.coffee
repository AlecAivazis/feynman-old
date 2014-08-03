# this file describes the implementation of a general undo stack in angular
#
# author: alec aivazis

# create the angular module
undo = angular.module 'undo', []

# add a filter to reverse the order of a list
undo.filter 'reverse', ->
  (items) ->
    items.slice().reverse()

undo.controller 'undoCtrl', [ '$scope', ($scope) ->

  # start with an empty queue
  $scope.queue = []
  # and pointing at the zeroth entry
  $scope.current = -1
  
  # listen to the dom for events to add to the que
  #$(document).on 'addEntryToUndo', ( event, title, transparent = true, data,
  $(document).on 'addEntryToUndo', ( event, transparent, entry ) ->  
    # increment the counter
    $scope.current++ 

    # remove all of the undo entries past current
    $scope.queue = $scope.queue.splice(0, $scope.current)

    # add the event to the queue
    $scope.queue.push entry
    # tell angular to refresh 
    $scope.$apply()

    # if they want this to be a wrapper around the intial call the forward
    if transparent
      # call the forward action with the provided data
      entry.forwards()


  # perform the necessary steps to go to a specific event
  $scope.goTo = (id) ->

    # check that were actually doing something
    if id == $scope.current or id < 0
      return
    
    # if we want to go forwards in time
    if id > $scope.current
      # for every step in between me and the target
      while $scope.current < id
        # increment the counter
        $scope.current++
        # grab the entry
        entry = $scope.queue[$scope.current]
        # apply the forward function bringing the DOM up to date with the current number
        entry.forwards()
    # otherwise we want to go backwards in time
    else
      # go every step in between the current one and the guy before our target
      while $scope.current > id
        # grab the undo entry
        entry = $scope.queue[$scope.current]
        # apply the backwards function putting the DOM one step behind the counter
        entry.backwards()
        # decrement the counter
        $scope.current--

]
