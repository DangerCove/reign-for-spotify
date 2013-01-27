/* plugins.js */
window.log = function f(){ log.history = log.history || []; log.history.push(arguments); if(this.console) { var args = arguments, newarr; args.callee = args.callee.caller; newarr = [].slice.call(args); if (typeof console.log === 'object') log.apply.call(console.log, console, newarr); else console.log.apply(console, newarr);}};
(function(a){function b(){}for(var c="assert,count,debug,dir,dirxml,error,exception,group,groupCollapsed,groupEnd,info,log,markTimeline,profile,profileEnd,time,timeEnd,trace,warn".split(","),d;!!(d=c.pop());){a[d]=a[d]||b;}})
(function(){try{console.log();return window.console;}catch(a){return (window.console={});}}());

/* Author: Danger Cove

*/

var updateTimeout,
    timeout = 30000,
    currentState,
    currentTime,
    duration,
    allowForce,
    secondTimeout,
    secondTimeoutTime = 1000;

function everySecond(){
    if(currentTime != undefined && currentState == 'playing'){
        // Need to update the current time
        if(currentTime / duration <= 1){
            $('#playtime_slider').slider( "option", "value", currentTime / duration * 100);
            setTimeDisplay('#currtime', currentTime);
            currentTime++;
        } else {
            update();
        }
    }
    clearTimeout(secondTimeout);
    secondTimeout = setTimeout(everySecond, secondTimeoutTime);
}

function deduplicate(songlist){
    var deduplist = new Array();
    
    track = new Object();
    track.name = songlist[0].name;
    track.artistname = songlist[0].artists[0].name;
    track.albumname = songlist[0].album.name;
    track.href = songlist[0].href
    
    deduplist[0] = track;
    
    for(i = 1; i < songlist.length; i++){
        track = new Object();
        track.name = songlist[i].name;
        track.artistname = songlist[i].artists[0].name;
        track.albumname = songlist[i].album.name;
        track.href = songlist[i].href
        
       var dup = false;
        
        for(j = 0; j < deduplist.length; j++){
            if(deduplist[j].name.toLowerCase() == track.name.toLowerCase() && deduplist[j].artistname.toLowerCase() == track.artistname.toLowerCase() && deduplist[j].albumname.toLowerCase() == track.albumname.toLowerCase()){
                dup = true;
                break;
            }
        }
        if(!dup){
            deduplist.push(track);
        }
    }
    
    return deduplist;
}

function setTimeDisplay(container, seconds){
    var minutes = Math.floor(seconds / 60);
    seconds = seconds % 60;
    if(isNaN(minutes) || isNaN(seconds)){
        $(container).text("0:00");
    } else {
        $(container).text(minutes + ":" + (seconds < 10 ? '0' : '') + seconds);
    }
}

function update() {
  $.getJSON('/status', function(data) {
    $('#controls').removeClass();
    currentState = data.state;
    currentTime = data.position;
    duration = data.duration;
            
    setTimeDisplay('#totaltime', duration);
    setTimeDisplay('#currtime', currentTime);
            
    allowForce = data['allow_force'];
    switch(currentState) {
      case "playing":
        $('#playpause').attr('class', 'pause');
        break;
      default:
        $('#playpause').attr('class', 'play');
        break;
    }

    switch(data.shuffle){
        case true:
            $('#shuffle').attr('class','shuffleon');
        break;
        default:
            $('#shuffle').attr('class','shuffleoff');
        break;
    }
    
    if(currentState == 'off' || allowForce == false) {
      $('#controls').attr('class', 'off');
      $('#playtime_slider').slider('disable');
    }
    $('.track_cover').attr('src', data.cover);
    $('.now_playing').text(data['now_playing']);
    $('.now_playing').attr('href', data.url);
            
    clearTimeout(updateTimeout);
    updateTimeout = setTimeout(update, timeout);
  });
}

var displayTrackList = (function(track_list){
    // We have a track list returned, so display it
                        $('#searchlist').css({'display': 'block', 'height': $('body').height()});
                        $('#searchlist .listbox').css({'height':$('body').height() - $('#searchlist .title').height()});
                        $('#songlist').empty();
                        $('#searchlist').animate({'top': 0});
                        // TODO: Show a spinner
                        var song_list = $('<ul></ul>');
                        // Display the list
                        for(i = 0; i < track_list.length; i++){
                            song_list.append('<li><a onclick="play_search_track(this.id)" id="'+track_list[i].href+'"><span class="search_title">'+track_list[i].name+'</span><br /><span class="search_artist">' + track_list[i].artistname + ' - ' + track_list[i].albumname + '</span></a></li>');
                        }
                        $('#songlist').append(song_list);
                        // Todo: Hide the spinner




});

var play_search_track = function(id){
    $.get('/play-track/' + id);
    $('#searchlist').animate({'top':$('body').height()}, 500, null, function(){
                             $('#searchlist').css({'display':'none'});
                           update();
                             }

                             );
}

$(document).ready(function() {
  // Set up the play time slider
  $('#playtime_slider').slider();
  $('#playtime_slider').on( "slidestop", function( event, ui ) {
    $.get('updatetime/' + Math.floor(ui.value / 100 * duration), function(data){
      update();
    });
  });
                  
  $('#controls a').click(function(e) {
    e.preventDefault();
    if(!allowForce) {
      alert("Sorry, the owner has disabled remote commands.");
    } else {
      if(currentState != 'off') {
        $.get($(this).attr('href'), function(data) {
          //window.location.reload();
          update();
        });
      }
    }
  });
                  $('#closesearchbutton').click(function(e) {
                                                     e.preventDefault();
                                                $('#searchlist').animate({'top':$('body').height()}, 500, null, function(){
                                                                                                                                                              $('#searchlist').css({'display':'none'});
                                                                                                              }

                                                                         );
                                                });
  $('#searchlist').css({'height': $('body').height(), 'top': $('body').height()});
  $('#search_song').submit( function(e) {
    e.preventDefault();
    var search_term = $('#search_keywords').val();
                           if(search_term.length == 0){
                           alert("Please provide a search term");
                           return;
                           }

    $.ajax({
      url: 'http://ws.spotify.com/search/1/track.json?q=' + escape(search_term),
      dataType: 'json',
      success: function(data) {
           
        if(data.tracks && data.tracks.length > 1) {
            // We have more than one track, so display a list of them
           displayTrackList(deduplicate(data.tracks));
        } else if (data.tracks && data.tracks.length > 0) {
           // We only have one track returned. It was probably a hit, so play it
          var song = data.tracks[0];
          if(song) {
                track_uri = track.href;
            $.get('/play-track/' + track_uri);
            update();
          }
        } else {
          alert("Didn't find anything for: " + search_term);
        }
      }
    });
  });

  update();
  updateTimeout = setTimeout(update, timeout);
  everySecond();
  secondTimeout = setTimeout(everySecond, secondTimeoutTime);
  dropTrackSetup();
});
