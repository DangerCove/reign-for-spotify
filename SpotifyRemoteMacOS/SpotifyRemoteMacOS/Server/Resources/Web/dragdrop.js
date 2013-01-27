function drop(e) {
    ignoreDrag(e);
    var dt = e.originalEvent.dataTransfer;
    var track_uri = JSON.stringify(e.originalEvent.dataTransfer.getData('Text'));
    var valid = false;
    // If the uri starts with http then we need to convert it to a spotify uri rather than a link
    var http_string = 'http';
    var spotify_uri_string = 'spotify:';
    
    // Remove the quotes from the string
    track_uri = track_uri.replace(/['"']/g,'');
    
    if(track_uri.substring(0, http_string.length) == http_string){
        
        // Need to check whether it is a track or a playlist
        if(track_uri.indexOf("user") > 0){
            var user = track_uri.substring(track_uri.indexOf("/user/") + 6, track_uri.indexOf("/playlist/"));
            track_uri = "spotify:user:" + user + ":playlist:" + track_uri.substring(track_uri.lastIndexOf('/') + 1);
        } else {
            track_uri = "spotify:track:" + track_uri.substring(track_uri.lastIndexOf('/') + 1);
        }
        valid = true;
    } else if(track_uri.substring(0, spotify_uri_string.length) == spotify_uri_string){
        valid = true;
    }
    
    if(valid){
        // Play the track as provided
        $.get('/play-track/' + track_uri, function(e){
              // Refresh the page to get the new playing track
              update();
        });
    }
}

function ignoreDrag(e) {
    e.originalEvent.dataTransfer.dropEffect = 'copy';
    e.originalEvent.stopPropagation();
    e.originalEvent.preventDefault();
}

var dropTrackSetup = (function(){
      $('body')
          .bind('dragenter', ignoreDrag)
          .bind('dragover', ignoreDrag)
          .bind('drop', drop);
});
