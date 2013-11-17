var map;
var dist = 0;
var typeMap;
var sports;
var step;
var tracks = {
    track: []
};
function initialize() {

    jQuery('input:radio').click(function() {

        sports = jQuery(this).closest(".radio").text();
        console.log(jQuery.trim(sports));
        if (jQuery.trim(sports) == 'Laufen') {
            typeMap =  'WALKING';
        }
        else {
            typeMap = 'BICYCLING';
        }
    });
    sports = jQuery('input:radio:checked').closest(".radio").text();
    if (jQuery.trim(sports) == 'Laufen') {
        typeMap = 'WALKING';
    }
    else {
        typeMap = 'BICYCLING';
    }
    var markers = [],
        segments = [],
        myOptions = {
            zoom: 12,
            center: new google.maps.LatLng(52.48458353031518, 13.34541249249014,13),
            mapTypeId: google.maps.MapTypeId.ROADMAP,
            disableDoubleClickZoom: true,
            draggableCursor: "crosshair"
        },
        alphas = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split(''),
        alphaIdx = 0,
        map     = new google.maps.Map(document.getElementById("draw_map"), myOptions),
        service = new google.maps.DirectionsService(),
        poly    = new google.maps.Polyline({
            map: map,
            strokeColor: '#00FFFF',
            strokeOpacity: 0.6,
            strokeWeight: 5
        });
    window.resetMarkers = function () {
        for (var i = 0; i < markers.length; i++) {
            markers[i].setMap(null);
        }
        alphaIdx = 0;
        segments = [];
        markers = [];
        poly.setPath([]);
    };

    function getSegmentsPath() {
        tracks = {
            track: []
        };
        var a, i,
            len     = segments.length,
            arr     = [];
            dist    = 0;
        for (i = 0; i < len; i++) {
            a = segments[i];
            if (a && a.routes) {
                arr = arr.concat(a.routes[0].overview_path);
                dist = dist + a.routes[0].legs[0].distance.value;

                tracks.track.push({
                    "start_lat" : a.routes[0].legs[0].start_location.lat(),
                    "start_lng" : a.routes[0].legs[0].start_location.lng(),
                    "stop_lat"  : a.routes[0].legs[0].end_location.lat(),
                    "stop_lng"  : a.routes[0].legs[0].end_location.lng()
                });
            }
        }
        timeCalculator();
        jQuery( "#track_distance").val(dist);
        jQuery( "#track_waypoints").val(JSON.stringify(tracks));
        return arr;
    }

    function save_waypoints()
    {
        var w=[],wp;
        var rleg = ren.directions.routes[0].legs[0];

        data.start = {'lat': rleg.start_location.lat(), 'lng':rleg.start_location.lng()}
        data.end = {'lat': rleg.end_location.lat(), 'lng':rleg.end_location.lng()}
        var wp = rleg.via_waypoints
        for(var i=0;i<wp.length;i++)w[i] = [wp[i].lat(),wp[i].lng()]
        data.waypoints = w;

        var str = JSON.stringify(data)

//        var jax = window.XMLHttpRequest ? new XMLHttpRequest() : new ActiveXObject('Microsoft.XMLHTTP');
//        jax.open('POST','process.php');
//        jax.setRequestHeader('Content-Type','application/x-www-form-urlencoded');
//        jax.send('command=save&mapdata='+str)
//        jax.onreadystatechange = function(){ if(jax.readyState==4) {
//            if(jax.responseText.indexOf('bien')+1)alert('Updated');
//            else alert(jax.responseText)
//        }}
    }
    function addSegment(start, end, segIdx) {
        service.route(
            {
                origin: start,
                destination: end,
                travelMode: google.maps.DirectionsTravelMode[typeMap],
                unitSystem: google.maps.UnitSystem.METRIC
            },
            function (result, status) {
                if (status == google.maps.DirectionsStatus.OK) {
                    //store the entire result, as we may at some time want
                    //other data from it, such as the actual directions
                    segments[segIdx] = result;
                    poly.setPath(getSegmentsPath());
                }
            }
        );
    }

    google.maps.event.addListener(map, "click", function (e) {
        //limiting the number of markers added to no more than 26, as if we have
        //that many we have used up all our alphabetical characters for the icons
        if (alphaIdx > 25) {
            return;
        }
        var evtPos = e.latLng,
            c = alphas[alphaIdx++],
            marker = new google.maps.Marker({
                map: map,
                position: evtPos,
                draggable: true,
                icon: 'http://www.google.com/mapfiles/marker' + c + '.png'
            });
        marker.segmentIndex = markers.length - 1;
        marker.iconChar = c;//just storing this for good measure, may want at some time
        function updateSegments() {
            var start, end, inserts, i,
                idx     = this.segmentIndex,
                segLen  = segments.length, //segLen will always be 1 shorter than markers.length
                myPos   = this.getPosition();
            if (segLen === 0) { //nothing to do, this is the only marker
                return;
            }
            if (idx == -1) { //this is the first marker
                start   = [myPos];
                end     = [markers[1].getPosition()];
                inserts = [0];
            } else if (idx == segLen - 1) { //this is the last marker
                start   = [markers[markers.length - 2].getPosition()];
                end     = [myPos];
                inserts = [idx];
            } else {//there are markers both behind and ahead of this one in the 'markers' array
                start = [markers[idx].getPosition(), myPos];
                end = [myPos, markers[idx + 2].getPosition()];
                inserts = [idx, idx + 1];
            }
            for (i = 0; i < start.length; i++) {
                addSegment(start[i], end[i], inserts[i]);
            }
        }

        /**********************************************************************
         Note that the line below which sets an event listener for the markers
         'drag' event and which is commented out (uncomment it to test,
         but I do not recommend using it in reality) causes us to constantly
         poll google for DirectionsResult objects and may perform poorly at times
         while a marker is being dragged, as the application must wait for a
         directions request to be sent and received from google many many many
         times while the marker is dragged. For these reasons, I personally would
         only use the dragend event listener. Additionally, using the below line can
         very quickly run you up against google maps api services usage limit of
         2500 directions requests per day, as while a marker is being dragged it
         could cause hundreds and hundreds of directions requests to be made! Not good!
         see about usage limits: https://developers.google.com/maps/documentation/directions/#Limits
         ***********************************************************************/

            //google.maps.event.addListener(marker, 'drag', updateSegments);
        google.maps.event.addListener(marker, 'dragend', updateSegments);
        markers.push(marker);
        if (markers.length > 1) {
            addSegment(markers[markers.length - 2].getPosition(), evtPos, marker.segmentIndex);
        }
    });

    function mknull(wert) {
        if (wert<10) return "0" + parseInt(wert); else return parseInt(wert);
    }

    function timeCalculator() {
        var secs        = jQuery('#track_min_per_km').val();
        var secSplits   = secs.split(':');
        var sec         = (secSplits[0] * 60) * 1 + secSplits[1] * 1;
        var km          = dist / 1000;
        var sekunden    = sec * km;
        var stunden     = Math.floor(sekunden / 3600);
        var minuten     = Math.floor((sekunden - stunden * 3600) / 60);
        var gessec      = sekunden - stunden * 3600 - minuten * 60;
        var gesZeit     = mknull(stunden) + ":" + mknull(minuten) + ":" +mknull(gessec);
        jQuery( "#track_duration").val(gesZeit);
    }
}
jQuery(document).ready(function () {
    google.maps.event.addDomListener(window, 'load', initialize);
});


