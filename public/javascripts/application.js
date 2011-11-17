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
 var maper, layer;
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

function splitData(data) {
	var txt = new String(data);  
  return txt.split(',');
}

function createMapWithRoute (coordinates, cssId, withControl, zoomControl) {
  withControl = typeof(withControl) != 'undefined' ? withControl : true;
  zoomControl = typeof(zoomControl) != 'undefined' ? zoomControl : false;
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
  if (withControl == false) {    
    var map = new OpenLayers.Map (cssId, { controls: [] });
  }
  if (withControl == true) {
    var map = new OpenLayers.Map (cssId);
  }
  map.addControl(new OpenLayers.Control.LayerSwitcher());

  
  var gphy = new OpenLayers.Layer.Google(
        "Google Physical",
        {type: google.maps.MapTypeId.TERRAIN}
    );
  var gmap = new OpenLayers.Layer.Google(
      "Google Streets", // the default
      {numZoomLevels: 20}
  );
  var ghyb = new OpenLayers.Layer.Google(
      "Google Hybrid",
      {type: google.maps.MapTypeId.HYBRID, numZoomLevels: 20}
  );
  var gsat = new OpenLayers.Layer.Google(
      "Google Satellite",
      {type: google.maps.MapTypeId.SATELLITE, numZoomLevels: 22}
  );
  //base layers
  var openstreetmap = new OpenLayers.Layer.OSM();
  var opencyclemap = new OpenLayers.Layer.OSM.CycleMap("CycleMap");


  var wfs_layer = new OpenLayers.Layer.Vector("Blocks", {
     strategies: [new OpenLayers.Strategy.BBOX()],
     projection: WGS84,
     protocol: new OpenLayers.Protocol.WFS({
       version: "1.1.0",
       url: "http://demo.opengeo.org/geoserver/wfs",
       featureNS :  "http://opengeo.org",
       featureType: "restricted",
       geometryName: "the_geom",
       schema: "http://demo.opengeo.org/geoserver/wfs/DescribeFeatureType?version=1.1.0&typename=og:restricted"
     })
   });
  map.addLayers([opencyclemap,gphy,gmap, ghyb, gsat, wfs_layer]);
  
  $.each( coordinates, function( intIndex, objValue ){
     
    $.each( objValue, function( index, value ){      
      var txt = new String(value);  
      var t = txt.split(',');
	    var lat = t[0];	
	    var lon = t[1];
      if(minLat > lat) {
        minLat = lat;
      }
      if(maxLat < lat) { 
          maxLat = lat;
      }
      if(minLong > lon) {
          minLong = lon;
      }
      if(maxLong < lon) {
          maxLong = lon;
      }
      point = new OpenLayers.Geometry.Point(lon,lat);
      
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
  
  if (zoomControl != true) {
    for(var i = 0; i<controls.length; ++i) {
      controls[i].disableZoomWheel();    
    }
  }
     
}

function createChart (data, cssId, unit, min) {
  var datas = data;
  var chartdata = [];
  var value;  
  k = 0;
  $.each( datas, function( intIndex, objValue ){
     $.each( objValue, function( index, value ){
        if (value != null) {
          chartdata[k] = value;
          k++;
        }
     });
  });
  var max = chartdata[k-1][0];
  var min = min;
  $(function() {
      new Highcharts.Chart({
        chart: {
          height: 250,
          renderTo: cssId,

          margin: [10, 20, 30, 60]	
        },
        title: {
          text: '',
          x: -50, //center$maxHeight
          y: 200
        },
        subtitle: {
          text: '',
          x: -20
        },
        credits: {
          enabled: false
        },
        legend: {
          enabled: false
        },
        xAxis: {
          labels: {
            formatter: function() {
                return secondsToTime(this.value);
            },
            style: {
                color: '#000000'
            }
          },
          type: "Time",
          lineWidth: 1,
          max: max
        },

        yAxis: [{ // Primary yAxis
          labels: {
            formatter: function() {
                return this.value + ' ' + unit;
            },
            style: {
                color: '#AA4643'
            }
          },
          title: {
            text: '',
            margin: 80,
            style: {
                color: '#AA4643'
            }
          }, 
          min: min
        }],
        plotOptions: {
          area: {
            fillOpacity: 0.3,
            lineWidth: 1,
            marker: {
              enabled: false,
              states: {
                hover: {
                  enabled: true,
                  radius: 3
                }
              }
            },
            shadow: true,
            states: {
              hover: {
                lineWidth: 1						
              }
            }
          }
        },
        tooltip: {
          formatter: function() {
            return secondsToTime(this.x) +' '+ this.y + ' ' +unit;
          }
        },
        series: [{
          type: 'area',
          data: chartdata
        }]
      });
    });
  
}



$(document).ready(function () {
  
	$("a#bigmap").fancybox({
  		'hideOnContentClick': true,
      'width': '100%',
      'height': '100%'
  	});
     
  	   
  $("#training").validate({
    rules: {
        'training[sport_id]' : { required: true }
    },
    messages: {
        'training[sport_id]' : "You must select a sport type"
    }
  });
  
  $("#course").validate({
    rules: {
        'course[sport_id]' : { required: true },
        'course[name]' : { required: true }
    },
    messages: {
        'course[sport_id]' : "You must select a sport type",
        'course[name]' : "You must select a name"
    }
  });
  
  $('#datepicker').datetimepicker();  
  
  $("li.distance").mouseover(function () {
    $(".comment").dialog();
  });
  $("li.distance").mouseout(function () {
    $(".comment").hide();
  });
  
  $("input, textarea, select, button").uniform(); 
    $( "#datepicker" ).datepicker();
});
