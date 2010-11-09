$(function(){

// highlight and fade background on named anchors
// requires jquery.color.js http://plugins.jquery.com/project/color
function highlight(elemId){
    var elem = $('[id="'+elemId.substring(1)+'"]');
    elem.css("backgroundColor", "#eeeeaa");
}
   
if (document.location.hash) {
    highlight(document.location.hash);
}

$('a[href*=#]').click(function(){
    var elemId = '#' + $(this).attr('href').split('#')[1];
    highlight(elemId);
});

});
