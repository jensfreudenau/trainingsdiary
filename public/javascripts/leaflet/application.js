var map, route, fromMarker, toMarker, prevMarker, distance = {}, track = [];
var tracks = {
    track: []
};
var markers = {};
map = L.map('draw_map').setView([52.48458353031518, 13.34541249249014], 15);
L.tileLayer('http://{s}.tile.cloudmade.com/68ee3ca235dd4e4f973298bc343e9b73/997/256/{z}/{x}/{y}.png', {
    maxZoom: 10,
    attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://cloudmade.com">CloudMade</a>'
}).addTo(map);

function writeDistance() {
    var finalDistance = 0;
    jQuery.each(distance, function( index, value ) {
        finalDistance = finalDistance + value;
    });
    var secs        = jQuery('#track_min_per_km').val();
    var secSplits   = secs.split(':');
    var sec         = (secSplits[0] * 60) * 1 + secSplits[1] * 1;
    var km          = finalDistance / 1000;
    var sekunden    = sec * km;
    var stunden     = Math.floor(sekunden / 3600);
    var minuten     = Math.floor((sekunden - stunden * 3600) / 60);
    var gessec      = sekunden - stunden * 3600 - minuten * 60;
    var gesZeit     = mknull(stunden) + ":" + mknull(minuten) + ":" +mknull(gessec);

    jQuery('#track_duration').val(gesZeit);
    jQuery( "#track_distance").val(km);
    jQuery( "#track_waypoints").val(JSON.stringify(tracks));
}

function mknull(wert) {
    if (wert<10) return "0" + parseInt(wert); else return parseInt(wert);
}

function clear_polyline() {
    map.removeLayer(route);
    map.removeLayer(toMarker);
    delete distance[route._leaflet_id];
    delete tracks[route._leaflet_id];
}

function getRoute(response, changes) {
    var point, points = [];
    for (var i = 0; i < response.route_geometry.length; i++) {
        point = new L.LatLng(response.route_geometry[i][0], response.route_geometry[i][1]);
        points.push(point);

    }
    if (changes == 1) {
        clear_polyline();
    }
    route = new L.Polyline(points, {
        weight: 3,
        opacity: 0.5,
        smoothFactor: 1
    }).addTo(map);


    tracks.track.push({
        "start_lat" : prevMarker.getLatLng().lat,
        "start_lng" : prevMarker.getLatLng().lng,
        "stop_lat"  : toMarker.getLatLng().lat,
        "stop_lng"  : toMarker.getLatLng().lng
    });


    distance[route._leaflet_id] = response.route_summary['total_distance'];
    writeDistance();
}



function removeMarker(e) {
    map.removeLayer(markers[e.target._leaflet_id]);
    map.removeLayer(route);
    delete distance[route._leaflet_id];
    delete tracks[route._leaflet_id];
    fromMarker = prevMarker;
    writeDistance();

}
function onMapClick(e) {
    var lng = e.latlng.lng;
    var lat = e.latlng.lat;
    toMarker = new L.Marker(new L.LatLng(parseFloat(lat), parseFloat(lng)), {draggable: true}).on('click', removeMarker);
    toMarker.addTo(map);
    markers[toMarker._leaflet_id] = toMarker;
    if (fromMarker !== undefined) {
        jQuery.ajax({
            url: 'http://routes.cloudmade.com/68ee3ca235dd4e4f973298bc343e9b73/api/0.3/' + fromMarker.getLatLng().lat + ',' + fromMarker.getLatLng().lng + ',' + e.latlng.lat + ',' + e.latlng.lng + '/foot.js',
            dataType: "jsonp",
            success: function (json) {
                getRoute(json, 0)
            },
            error: function (e) {
                console.log(e);
            }
        });
        toMarker.on('dragend', function (e) {
            var coords = e.target._latlng;
            toMarker = new L.Marker(new L.LatLng(parseFloat(coords.lat), parseFloat(coords.lng)), {draggable: true}).addTo(map);
            jQuery.ajax({
                url: 'http://routes.cloudmade.com/68ee3ca235dd4e4f973298bc343e9b73/api/0.3/' + prevMarker.getLatLng().lat + ',' + prevMarker.getLatLng().lng + ',' + coords.lat + ',' + coords.lng + '/foot.js',
                dataType: "jsonp",
                success: function (json) {
                    getRoute(json, 1)
                },
                error: function (e) {
                    console.log(e);
                }
            });
        });
    }
    prevMarker = fromMarker;
    fromMarker = toMarker;
}
map.on('click', onMapClick);
var basemap = L.tileLayer('http://{s}.tile.cloudmade.com/68ee3ca235dd4e4f973298bc343e9b73/99474/256/{z}/{x}/{y}.png', { maxZoom: 18 }).addTo(map);

function drawRoute(waypoints, min_per_km) {
    secs = min_per_km;
    jQuery.each(waypoints['track'], function( index, value ) {
        console.log(value);
        toMarker = new L.Marker(new L.LatLng(parseFloat(value.start_lat), parseFloat(value.start_lng)), {draggable: true}).addTo(map);
        jQuery.ajax({
            url: 'http://routes.cloudmade.com/68ee3ca235dd4e4f973298bc343e9b73/api/0.3/' + value.start_lat + ',' + value.start_lng + ',' + value.stop_lat + ',' + value.stop_lng + '/foot.js',
            dataType: "jsonp",
            success: function (json) {
                getRoute(json, 0)
            },
            error: function (e) {
                console.log(e);
            }
        });
        fromMarker = toMarker;
        prevMarker = fromMarker;
    });
}



