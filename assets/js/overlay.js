function overlay(content){
    
    $('#overlayGutter').remove();
    
    var gutter = $('<div/>').attr({
        id: 'overlayGutter'
    }).click(function(){
        closeOverlay();
    });
    
    var overlay = $('<div/>').attr({
        id: 'overlay'    
    }).appendTo(gutter);
    
    var overlayContent = $('<span/>').attr({
        id: 'overlayContent'    
    }).click(function(event){
            event.stopPropagation();
    }).html(content).appendTo(overlay);

    
    gutter.appendTo('body');
    
    $(document).keypress(function(e){
        if (e.keyCode == 27){
            closeOverlay();
        }
    });
    
}

function closeOverlay(){
    $('#overlayGutter').remove();
    
    $(document).unbind('keypress');
}
    
    
