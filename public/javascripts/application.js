/*
 * jQuery File Upload Plugin JS Example 4.6
 * https://github.com/blueimp/jQuery-File-Upload
 *
 * Copyright 2010, Sebastian Tschan
 * https://blueimp.net
 *
 * Licensed under the MIT license:
 * http://creativecommons.org/licenses/MIT/
 */

/*jslint unparam: true */
/*global $ */

/**
 * Convert number of seconds into time object
 *
 * @param integer secs Number of seconds to convert
 * @return object
 */
function secondsToTime(sec)
{
	  var hr = Math.floor(sec / 3600);
  	var min = Math.floor((sec - (hr * 3600))/60);
  	sec -= ((hr * 3600) + (min * 60));
  	sec += ''; min += '';
  	while (min.length < 2) {min = '0' + min;}
  	while (sec.length < 2) {sec = '0' + sec;}
  	hr = (hr)?hr+':':'';
  	return hr + min + ':' + sec;
}

function roundNumber(num, dec) {
	var result = Math.round(num*Math.pow(10,dec))/Math.pow(10,dec);
	return result;
}

function object2Array(objValue) {
  ar = [];
  i = 0;
  $.each( objValue, function( index, value ){
      if (value != null) {
        ar[i] = [parseInt( index ) ,roundNumber(value,2)];
        i++;
      }
   });
  return ar;
}
function createMapWithRoute (coordinates, cssId) {
  
  var minLat = 100000;
  var maxLat = 0;
  var minLong = 100000;
  var maxLong = 0;
  
  var points = [];
  var point = [];
  //set up projections
  // World Geodetic System 1984 projection
  var WGS84 = new OpenLayers.Projection("EPSG:4326");
  
  // WGS84 Google Mercator projection
  var WGS84_google_mercator = new OpenLayers.Projection("EPSG:900913");
  
  //Initialize the map
  //creates a new openlayers map in the <div> html element id map
  var map = new OpenLayers.Map (cssId);
  //base layers
  var openstreetmap = new OpenLayers.Layer.OSM();
  var opencyclemap = new OpenLayers.Layer.OSM.CycleMap("CycleMap");
  var wfs_layer = new OpenLayers.Layer.Vector("Blocks", {
     strategies: [new OpenLayers.Strategy.BBOX()],
     projection: WGS84,
     protocol: new OpenLayers.Protocol.WFS({
       version: "1.1.0",
       url: "http://hazardmapping.com/geoserver/wfs",
       featureNS :  "http://www.opengeospatial.net/cite",
       featureType: "testblocks",
     })
   });
  map.addLayers([openstreetmap, opencyclemap, wfs_layer]);
  
  $.each( coordinates, function( intIndex, objValue ){
     
    $.each( objValue, function( index, value ){      
      var txt = new String(value);  
      var t = txt.split(',');
     
      if(minLat > t[0]) {
        minLat = t[0];
      }
      if(maxLat < t[0]) { 
          maxLat = t[0];
      }
      if(minLong > t[1]) {
          minLong = t[1];
      }
      if(maxLong < t[1]) {
          maxLong = t[1];
      }
      point = new OpenLayers.Geometry.Point(t[1],t[0]);
      
      point.transform(
        new OpenLayers.Projection("EPSG:4326"), // transform from WGS 1984
        map.getProjectionObject() // to Spherical Mercator Projection
      );
      points.push(point);
    });
  });
  
  style = { 
            strokeColor: '#2B2B2B',
            strokeOpacity: 1,
            strokeWidth: 2                  
          };
  var mapextent = new OpenLayers.Bounds(minLong,maxLat, maxLong, minLat).transform(WGS84, map.getProjectionObject());        
  map.zoomToExtent(mapextent);        
  lineLayer = new OpenLayers.Layer.Vector("Line Layer");
  lineFeature = new OpenLayers.Feature.Vector(new OpenLayers.Geometry.LineString(points),null,style);
  lineLayer.addFeatures([lineFeature]);
  //console.log(coordinates);
  map.addLayer(lineLayer);
  //map.addLayer(new OpenLayers.Control.Navigation());
  controls = map.getControlsByClass('OpenLayers.Control.Navigation');
  
  for(var i = 0; i<controls.length; ++i)
      controls[i].disableZoomWheel();
}

$(document).ready(function () {
  $("input, textarea, select, button").uniform(); 
  $( "#datepicker" ).datepicker();
});