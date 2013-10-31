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
/*global jQuery */

/**
 * Convert number of seconds into time object
 *
 * @param integer secs Number of seconds to convert
 * @return object
 */
var maper, layer;
function secondsToTime(sec) {
    var hr = Math.floor(sec / 3600);
    var min = Math.floor((sec - (hr * 3600)) / 60);
    sec -= ((hr * 3600) + (min * 60));
    sec += '';
    min += '';
    while (min.length < 2) {
        min = '0' + min;
    }
    while (sec.length < 2) {
        sec = '0' + sec;
    }
    hr = (hr) ? hr + ':' : '';
    return hr + min + ':' + sec;
}

function roundNumber(num, dec) {
    var result = Math.round(num * Math.pow(10, dec)) / Math.pow(10, dec);
    return result;
}

function object2Array(objValue) {
    ar = [];
    i = 0;
    jQuery.each(objValue, function (index, value) {
        if (value != null) {
            ar[i] = [parseInt(index) , roundNumber(value, 2)];
            i++;
        }
    });
    return ar;
}

function splitData(data) {
    var txt = new String(data);
    return txt.split(',');
}
/*
 * Schaltet die Beschreibung der Karte an- und aus.
 * Toggles the description of the map.
 */
function toggleInfo() {
    var state = document.getElementById('description').className;
    if (state == 'hide') {
        // Info anzeigen
        document.getElementById('description').className = '';
        document.getElementById('descriptionToggle').innerHTML = text[1];
    }
    else {
        // Info verstecken
        document.getElementById('description').className = 'hide';
        document.getElementById('descriptionToggle').innerHTML = text[0];
    }
}
function osm_getTileURL(bounds) {
    var res = this.map.getResolution();
    var x = Math.round((bounds.left - this.maxExtent.left) / (res * this.tileSize.w));
    var y = Math.round((this.maxExtent.top - bounds.top) / (res * this.tileSize.h));
    var z = this.map.getZoom();
    var limit = Math.pow(2, z);

    if (y < 0 || y >= limit) {
        return OpenLayers.Util.getImagesLocation() + "404.png";
    } else {
        x = ((x % limit) + limit) % limit;
        return this.url + z + "/" + x + "/" + y + "." + this.type;
    }
}

function createMapWithRoute(coordinates, cssId, withControl, zoomControl) {
    withControl = typeof(withControl) != 'undefined' ? withControl : true;
    zoomControl = typeof(zoomControl) != 'undefined' ? zoomControl : false;
    var minLat = 100000;
    var maxLat = 0;
    var minLong = 100000;
    var maxLong = 0;
    var map;
    var points = [];
    var point = [];
    //set up projections
    // World Geodetic System 1984 projection
    var WGS84 = new OpenLayers.Projection("EPSG:4326");


    map = new OpenLayers.Map(cssId, {
        controls: [
            new OpenLayers.Control.Navigation(),
            new OpenLayers.Control.LayerSwitcher(),
            new OpenLayers.Control.PanZoomBar({zoomStopHeight: 0}),
            new OpenLayers.Control.Attribution(),
            new OpenLayers.Control.MousePosition(),
            new OpenLayers.Control.KeyboardDefaults(),
            new OpenLayers.Control.ScaleLine({geodesic: true})
        ],
        theme: null,
        projection: new OpenLayers.Projection("EPSG:900913"),
        displayProjection: new OpenLayers.Projection("EPSG:4326"),
        units: "m",
        numZoomLevels: 18,
        maxResolution: 156543.0339,
        //maxResolution: "auto",
        maxExtent: new OpenLayers.Bounds(-20037508, -20037508,
            20037508, 20037508.34)
    });


    //base layers
    var hikebike = new OpenLayers.Layer.TMS(
        "Hike & Bike Map",
        "http://toolserver.org/tiles/hikebike/",
        {
            type: 'png', getURL: osm_getTileURL,
            displayOutsideMaxExtent: true, isBaseLayer: true,
            attribution: 'Map Data from <a href="http://www.openstreetmap.org/">OpenStreetMap</a> (<a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-by-SA 2.0</a>)'
        }
    );
    var osm = new OpenLayers.Layer.OSM.Mapnik("Mapnik");
    var cycle = new OpenLayers.Layer.OSM.CycleMap("CycleMap");
    var osma = new OpenLayers.Layer.OSM.Osmarender("Osmarender");


    var contours = new OpenLayers.Layer.TMS(
        "Contours (RGBA)",
        "tiles_contours/",
        {
            type: 'png', getURL: osm_getTileURL,
            displayOutsideMaxExtent: true, isBaseLayer: false,
            transparent: true, opacity: 0.8, "visibility": false
        }
    );
    var contours_8 = new OpenLayers.Layer.TMS(
        "Contours (limited area only)",
        "http://toolserver.org/~cmarqu/opentiles.com/cmarqu/tiles_contours_8/",
        {
            type: 'png', getURL: osm_getTileURL,
            displayOutsideMaxExtent: true, isBaseLayer: false,
            transparent: true, opacity: 0.8, "visibility": false
        }
    );

    var hill = new OpenLayers.Layer.TMS(
        "Hillshading (NASA SRTM3 v2)",
        "http://toolserver.org/~cmarqu/hill/",
        {
            type: 'png', getURL: osm_getTileURL,
            displayOutsideMaxExtent: true, isBaseLayer: false,
            transparent: true, "visibility": true
        }
    );

    var hill2 = new OpenLayers.Layer.TMS(
        "Hillshading (exaggerate)",
        "http://toolserver.org/~cmarqu/hill/",
        {
            type: 'png', getURL: osm_getTileURL,
            displayOutsideMaxExtent: true, isBaseLayer: false,
            transparent: true, "visibility": false
        }
    );

    var lighting_8 = new OpenLayers.Layer.TMS(
        "By Night (lit=yes/no)",
        "http://toolserver.org/tiles/lighting/",
        {
            type: 'png', getURL: osm_getTileURL,
            displayOutsideMaxExtent: true, isBaseLayer: false,
            transparent: true, opacity: 0.72, "visibility": false
        }
    );

    var lighting_residential = new OpenLayers.Layer.TMS(
        "By Night (lit+residential, Thuringia+Saxony)",
        "http://toolserver.org/~cmarqu/opentiles.com/cmarqu/tiles_lighting_residential/",
        {
            type: 'png', getURL: osm_getTileURL,
            displayOutsideMaxExtent: true, isBaseLayer: false,
            transparent: true, opacity: 0.72, "visibility": false
        }
    );

    var lonvia = new OpenLayers.Layer.TMS(
        "Lonvia's Hiking Symbols",
        "http://tile.lonvia.de/hiking/",
        {
            type: 'png', getURL: osm_getTileURL,
            displayOutsideMaxExtent: true, isBaseLayer: false,
            transparent: true, "visibility": false
        }
    );


    //var wfs_layer = new OpenLayers.Layer.Vector("Blocks", {
    //   strategies: [new OpenLayers.Strategy.BBOX()],
    //   projection: WGS84,
    //   protocol: new OpenLayers.Protocol.WFS({
    //     version: "1.1.0",
    //     url: "http://demo.opengeo.org/geoserver/wfs",
    //     featureNS :  "http://opengeo.org",
    //     featureType: "restricted",
    //     geometryName: "the_geom",
    //     schema: "http://demo.opengeo.org/geoserver/wfs/DescribeFeatureType?version=1.1.0&typename=og:restricted"
    //   })
    // });

    map.addLayers([ hikebike, osm, cycle, osma ]);

    map.addLayer(hill);
    map.addLayer(hill2);
    map.addLayer(lighting_8);
    map.addLayer(lonvia);
// hide contour lines from IE since they look very ugly in it
    if (navigator.appName.indexOf("Explorer") != -1) {
    }
    else {
        map.addLayer(contours_8);
    }
    jQuery.each(coordinates, function (intIndex, objValue) {

        jQuery.each(objValue, function (index, value) {
            var txt = new String(value);
            var t = txt.split(',');
            var lat = t[0];
            var lon = t[1];
            if (minLat > lat) {
                minLat = lat;
            }
            if (maxLat < lat) {
                maxLat = lat;
            }
            if (minLong > lon) {
                minLong = lon;
            }
            if (maxLong < lon) {
                maxLong = lon;
            }
            point = new OpenLayers.Geometry.Point(lon, lat);

            point.transform(
                new OpenLayers.Projection("EPSG:4326"), // transform from WGS 1984
                map.getProjectionObject() // to Spherical Mercator Projection
            );
            points.push(point);
        });
    });

    var style = {
        strokeColor: '#2B2B2B',
        strokeOpacity: 1,
        strokeWidth: 2
    };
    var mapextent = new OpenLayers.Bounds(minLong, maxLat, maxLong, minLat).transform(WGS84, map.getProjectionObject());
    map.zoomToExtent(mapextent);
    var lineLayer = new OpenLayers.Layer.Vector("Line Layer");
    var lineFeature = new OpenLayers.Feature.Vector(new OpenLayers.Geometry.LineString(points), null, style);
    lineLayer.addFeatures([lineFeature]);
    //console.log(coordinates);
    map.addLayer(lineLayer);
    //map.addLayer(new OpenLayers.Control.Navigation());
    var controls = map.getControlsByClass('OpenLayers.Control.Navigation');

    if (zoomControl != true) {
        for (var i = 0; i < controls.length; ++i) {
            controls[i].disableZoomWheel();
        }
    }

}
function heartchart(data, avg, maxMeasure, cssId) {
    var datas = data;
    var chartdata = [];
    var value;
    var maxY = 190;
    var k = 0;

    jQuery.each(datas, function (intIndex, objValue) {
        jQuery.each(objValue, function (index, value) {
            if (value != null) {
                chartdata[k] = value;
                k++;
            }
        });
    });
    var max = chartdata[k - 1][0];

    if (maxMeasure > maxY) {
        maxY = maxMeasure;
    }

    jQuery(function () {

        new Highcharts.Chart({
            chart: {
                renderTo: cssId,
                width: '690',
                defaultSeriesType: 'spline',
                margin: [0]
            },
            title: {
                text: ''
            },
            subtitle: {
                text: ''
            },
            credits: {
                enabled: false
            },
            legend: {
                enabled: false
            },
            xAxis: {

                labels: {


                    formatter: function () {
                        return secondsToTime(this.value);
                    },
                    style: {
                        color: '#000000'
                    }
                },
                type: "Time",
                lineWidth: 1
                //max:max
            },
            yAxis: {
                title: {
                    text: ''
                },
                min: 60,
                max: maxY,
                labels: {
                    enabled: false
                },
                minorGridLineWidth: 0,
                gridLineWidth: 0,
                alternateGridColor: null,
                plotBands: [

                    {
                        from: 60,
                        to: 130,
                        color: '#E7F0FE',
                        label: {
                            text: '- 75%',
                            align: 'left',
                            x: 10
                        }
                    },
                    {
                        from: 130,
                        to: 158,
                        color: '#9FCEA2',
                        label: {
                            text: '75% - 85%',
                            align: 'left',
                            x: 10
                        }
                    },
                    {
                        from: 158,
                        to: 164,
                        color: '#CC8C79',
                        label: {
                            text: '85% - 88%',
                            align: 'left',
                            x: 10
                        }
                    }
                    ,
                    {
                        from: 164,
                        to: 190,
                        color: '#BE3155',
                        label: {
                            text: '88% - 95%',
                            align: 'left',
                            x: 10
                        }
                    },
                    {
                        color: 'grey',
                        width: 1,
                        value: avg,
                        label: {
                            text: 'Durchschnitt: ' + avg,
                            align: 'right',
                            x: -10
                        }
                    }
                ]
            },

            tooltip: {
                formatter: function () {
                    return '<b>' + this.y + '</b>';
                }
            },
            plotOptions: {
                spline: {
                    lineWidth: 1,
                    marker: {
                        enabled: false
                    },


                    states: {
                        hover: {
                            marker: {
                                enabled: false,
                                symbol: 'circle',
                                radius: 1,
                                lineWidth: 2
                            }
                        }
                    }
                }
            },
            series: [
                {
                    data: chartdata

                }
            ]
        });
    });
}
function createChart(data, cssId, unit, min) {
    var datas = data;
    var chartdata = [];
    var value;
    k = 0;
    jQuery.each(datas, function (intIndex, objValue) {
        jQuery.each(objValue, function (index, value) {
            if (value != null) {
                chartdata[k] = value;
                k++;
            }
        });
    });
    var max = chartdata[k - 1][0];

    var min = min;
    jQuery(function () {
        new Highcharts.Chart({
            chart: {
                height: 350,
                renderTo: cssId,

                margin: [10, 20, 30, 60]
            },
            title: {
                text: '',
                x: -50, //centerjQuerymaxHeight
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
                    formatter: function () {
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

            yAxis: [
                { // Primary yAxis
                    labels: {
                        formatter: function () {
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
                }
            ],
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
                formatter: function () {
                    return secondsToTime(this.x) + ' ' + this.y + ' ' + unit;
                }
            },
            series: [
                {
                    type: 'area',
                    data: chartdata
                }
            ]
        });
    });

}


jQuery(document).ready(function () {
    var width = jQuery(window).width();
    var height = jQuery(window).height();
    jQuery("#background").width(width);
    jQuery("#background").height(height);
    jQuery(window).resize(function () {
        width = jQuery(window).width();
        height = jQuery(window).height();
        jQuery("#background").width(width);
        jQuery("#background").height(height);
    });

    jQuery("a#bigmap").fancybox({
        'hideOnContentClick': true,
        'width': '100%',
        'height': '100',
        'margin': 0,
        'padding': 0,
        'padding-right': 10
    });


    jQuery("#training").validate({
        rules: {
            'training[sport_id]': { required: true }
        },
        messages: {
            'training[sport_id]': "You must select a sport type"
        }
    });

    jQuery("#course").validate({
        rules: {
            'course[sport_id]': { required: true },
            'course[name]': { required: true }
        },
        messages: {
            'course[sport_id]': "You must select a sport type",
            'course[name]': "You must select a name"
        }
    });

    jQuery('#datepicker').datetimepicker({
        dateFormat: "dd.mm.yy",
        firstDay: 1});

    jQuery("li.distance").mouseover(function () {
        jQuery(".comment").dialog();
    });
    jQuery("li.distance").mouseout(function () {
        jQuery(".comment").hide();
    });

    jQuery("#datepicker").datepicker({
        dateFormat: "dd.mm.yy",
        firstDay: 1});


    jQuery(function() {
        var button  = jQuery('#loginButton');
        var box     = jQuery('#loginBox');
        var form    = jQuery('#loginForm');
        button.removeAttr('href');
        button.mouseup(function(login) {
            box.toggle();
            button.toggleClass('active');
        });
        form.mouseup(function() {
            return false;
        });
        jQuery(this).mouseup(function(login) {
            if(!(jQuery(login.target).parent('#loginButton').length > 0)) {
                button.removeClass('active');
                box.hide();
            }
        });
    });

});
