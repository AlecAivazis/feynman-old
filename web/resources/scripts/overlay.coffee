overlay = (content, canClose=true) ->

    $('#overlayGutter').remove()
    
    gutter = $('<div/>').attr
        id: 'overlayGutter'
    
    overlay = $('<div/>').attr
        id: 'overlay'    
    .appendTo(gutter)
    
    overlayContent = $('<span/>').attr
        id: 'overlayContent'    
    .click (event) ->
        event.stopPropagation()
    .html(content).appendTo(overlay)

    gutter.appendTo('body')
    

closeOverlay = ->
    $('#overlayGutter').remove()
    $(document).unbind('keypress')
    
    
# end of file
