function overlay(content){
    
    $('#overlayGutter').remove();
    
    var gutter = $('<div/>').attr({
        id: 'overlayGutter'
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
    
}

function closeOverlay(){
    $('#overlayGutter').remove();
    
    $(document).unbind('keypress');
}
    
    
// end of file
