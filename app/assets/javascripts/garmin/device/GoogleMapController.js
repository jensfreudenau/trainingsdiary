if (Garmin == undefined) var Garmin = {};
/** Copyright &copy; 2007-2010 Garmin Ltd. or its subsidiaries.
 *
 * Licensed under the Apache License, Version 2.0 (the 'License')
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * @fileoverview Garmin.MapController Overlays tracks and waypoint data on Google maps.
 * @version 1.9
 */
/**
 * Accepts Garmin.Series objects and draws them on a Google Map.
 *
 * @class Garmin.MapController
 * @constructor
 * @param (String) mapString id of element to place map in
 */

Garmin.MapController = function (mapString) {
}; //just here for jsdoc
Garmin.MapController = Class.create();
Garmin.MapController.prototype = {

    initialize: function (mapString) {
        this.mapElement = jQuery(mapString);
        this.mapElement = 'readMap';
        this.usePositionMarker = true;
        this.polylines = new Array();
        this.markers = new Array();
        this.tracks = new Array();
        this.markerIndex = 0;
        this.point = [];
        this.timeToCheck = false;
        try {
            //this.map = new google.maps.Map( this.mapElement  );
            OpenLayers.ImgPath = "/assets/";
//	        this.map.addControl(new GSmallMapControl());
//			this.map.addControl(new GMapTypeControl());
//        	new GKeyboardHandler(this.map);
            this.map = new OpenLayers.Map(this.mapElement, {
                theme: null,
                projection: new OpenLayers.Projection("EPSG:900913"),
                displayProjection: new OpenLayers.Projection("EPSG:4326"),
                units: "m",
                numZoomLevels: 18,
                maxResolution: 156543.0339,
                //maxResolution: "auto",
                maxExtent: new OpenLayers.Bounds(-20037508, -20037508, 20037508, 20037508.34)
            });
            //this.map = new OpenLayers.Map('readMap');
            var osm = new OpenLayers.Layer.WMS("OpenLayers WMS", "http://vmap0.tiles.osgeo.org/wms/vmap0", {layers: 'basic'});
            var hikebike = new OpenLayers.Layer.TMS(
                "Hike & Bike Map",
                "http://toolserver.org/tiles/hikebike/",
                {
                    type: 'png',
                    getURL: osm_getTileURL,
                    displayOutsideMaxExtent: true,
                    isBaseLayer: true,
                    attribution: 'Map Data from <a href="http://www.openstreetmap.org/">OpenStreetMap</a> (<a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-by-SA 2.0</a>)'
                }
            );
//            var osm = new OpenLayers.Layer.OSM();
            this.map.addLayers([hikebike]);
            var contours_8 = new OpenLayers.Layer.TMS(
                "Contours (limited area only)",
                "http://toolserver.org/~cmarqu/opentiles.com/cmarqu/tiles_contours_8/",
                {
                    type: 'png', getURL: osm_getTileURL,
                    displayOutsideMaxExtent: true, isBaseLayer: false,
                    transparent: true, opacity: 0.8, "visibility": false
                }
            );

            if (navigator.appName.indexOf("Explorer") != -1) {}
            else {
                this.map.addLayer(contours_8);
            }
            this.map.addControl(new OpenLayers.Control.LayerSwitcher());
//            this.map.zoomToMaxExtent();
            var zoom = this.map.getZoomForResolution(76.43702827453613);
            this.map.setCenter(new OpenLayers.LonLat(-71.147, 42.472).transform(
                new OpenLayers.Projection("EPSG:4326"),new OpenLayers.Projection("EPSG:900913")
            ), zoom);
        } catch (e) {
            alert("WARNING: application will not function properly.  Error: " + e);
        }
        //window.onUnload = "GUnload()";
    },
    /** Set the center point and zoom level of the map.
     * @param (Number) Latitude of the center point
     * @param (Number) Longitude of the center point
     * @param (Number) Zoom level
     */
    centerAndScale: function (lat, lon, scale) {
        scale = (scale == null ? 13 : scale);
        this.map.setCenter(new GLatLng(lat, lon), scale);
    },
    /** Draw track on map.
     * @param (Garmin.Track) The track to draw
     * @param (String) Color in RGB Hex format, default: "#ff0000"
     */
    drawTrack: function (series, color) {
        color = (color == null ? "#ff0000" : color);
        var minLat = 100000;
        var maxLat = 0;
        var minLong = 100000;
        var maxLong = 0;
        var points = [];
        var WGS84 = new OpenLayers.Projection("EPSG:4326");
        OpenLayers.ImgPath = "/assets/";
        var drawAt = Math.ceil(series.getSamplesLength()/300);
        var drawnPoints = new Array();

        try {
            // create up to 300 points
            for(var h = 0; h < series.getSamplesLength(); h += drawAt) {
                drawnPoints.push(this.createNearestValidLocationPoint(series, h, -1));
            }
            // create the end point
            drawnPoints.push(this.createNearestValidLocationPoint(series, series.getSamplesLength()-1, -1));
        } catch( e ) {
            alert("GoogleMapControl.drawTrack: " + e.message);
        }

        jQuery.each(drawnPoints, function (index, value) {
            var lat = value.lon;
            var lon = value.lat;
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
            point.transform(WGS84,new OpenLayers.Projection("EPSG:900913"));
            points.push(point);
        });
        var style = {
            strokeColor: color,
            strokeOpacity: 1,
            strokeWidth: 2
        };
        var mapextent = new OpenLayers.Bounds(minLong, maxLat, maxLong, minLat).transform(WGS84,new OpenLayers.Projection("EPSG:900913"));
        this.map.zoomToExtent(mapextent);
        try{
            var sample = series.getSample(0);
            var d = sample.getTime();
        }
        catch (e){
            console.log(e);
        }
        var num = this.map.getNumLayers();
        for (var i = num - 1; i >= 0; i--) {
            if(i>1) {
                this.map.layers[i].destroy();
            }
        }
        var lineLayer = new OpenLayers.Layer.Vector(d.getXsdString());

        var lineFeature = new OpenLayers.Feature.Vector(new OpenLayers.Geometry.LineString(points), null, style);
        lineLayer.removeFeatures(lineLayer.features[0]);

        lineLayer.addFeatures([lineFeature]);
        this.map.addLayer(lineLayer);
    },
    /**Creates a GLatLng for the sample in the series closest to the index with a valid location (lat and lon).
     * @param series - The series to search through.
     * @param index - The index to start searching from.
     * @param incDirection - The direction to travel for the search.
     * @return A GLatLng of the nearest valid location sample found.
     */
    createNearestValidLocationPoint: function (series, index, incDirection) {
        var sample = series.findNearestValidLocationSample(index, -1);
        if (sample != null) {
            var sampleLat = sample.getMeasurement(Garmin.Sample.MEASUREMENT_KEYS.latitude).getValue();
            var sampleLon = sample.getMeasurement(Garmin.Sample.MEASUREMENT_KEYS.longitude).getValue();
            return new OpenLayers.LonLat(sampleLat, sampleLon);
        } else {
            throw new Error("No valid location point in series.");
        }
    },
    /** Draw waypoint on map.
     * @param (Garmin.Series) series containing a waypoint to add to the map
     */
    drawWaypoint: function (series) {
        var sample = series.getSample(0);
        this.centerAndScale(sample.getLatitude(), sample.getLongitude(), 15);
        this.addMarker(sample.getLatitude(), sample.getLongitude());
    },
    /** Calculates minimum bounding box for an set of points.
     * @param (Array) The array of points to find a zoom level for
     */
    findAZoomLevel: function (points) {
        var bounds = new GLatLngBounds(points[0], points[0]);
        for (var i = 1; i < points.length - 1; i += 3) {
            bounds.extend(points[i]);
        }
        return bounds;
    },
    /** Check the new dimensions of the map, and determine the bounds of the tracks
     * Then set the map to zoom to that bound level
     * @private
     */
    sizeAndSetOnBounds: function () {
        this.map.checkResize();
        this.setOnBounds(this.bounds);
    },
    /** Set the bounding box on the map.
     * @param (GLatLngBounds) bounding box for the
     */
    setOnBounds: function (bounds) {
        this.map.setCenter(this.bounds.getCenter(), this.map.getBoundsZoomLevel(this.bounds));
    },
    /** Add an icon to a point.
     * @param {Number} latitude of marker
     * @param {Number} longitude of marker
     */
    addMarker: function (latitude, longitude) {
        this.addMarkerWithIcon(latitude, longitude, Garmin.MapIcons.getRedIcon());
    },
    /** Adds a marker to the point with the icon specified
     * @param {Number} latitude of marker
     * @param {Number} longitude of marker
     * @param (GIcon) icon to add at the point
     */
    addMarkerWithIcon: function (latitude, longitude, icon) {
        var gMarker = new GMarker(new GLatLng(latitude, longitude), icon);
        this.markers.push(gMarker);
        this.map.addOverlay(gMarker);
    },
    /** Add start and finish markers to a track
     * @param (Garmin.Series) The series to add markers to
     */
    addStartFinishMarkers: function (series) {
        var firstSample = series.getFirstValidLocationSample();
        var lastSample = series.getLastValidLocationSample();
        this.addMarkerWithIcon(firstSample.getLatitude(), firstSample.getLongitude(), Garmin.MapIcons.getGreenIcon());
        this.addMarkerWithIcon(lastSample.getLatitude(), lastSample.getLongitude(), Garmin.MapIcons.getRedIcon());
    },
    /** String representation of map.
     * @return (String)
     */
    toString: function () {
        return "Google Based Map Controller, managing " + this.tracks.length + " track(s)";
    }
};
/** Icons used to mark waypoints and POIs on Google maps.
 *
 * @class Garmin.MapIcons
 * @constructor
 */
Garmin.MapIcons = function () {
}; //just here for jsdoc
Garmin.MapIcons = {
    getRedIcon: function () {
        var icon = new GIcon();
        icon.image = "http://developer.garmin.com/img/marker_red.png";
        return Garmin.MapIcons._applyShadowAndStuff(icon);
    },
    getGreenIcon: function () {
        var icon = new GIcon();
        icon.image = "http://developer.garmin.com/img/marker_green.png";
        return Garmin.MapIcons._applyShadowAndStuff(icon);
    },
    _applyShadowAndStuff: function (icon) {
        icon.iconSize = new GSize(12, 20);
        icon.shadow = "http://developer.garmin.com/img/marker_shadow.png";
        icon.shadowSize = new GSize(22, 20);
        icon.iconAnchor = new GPoint(6, 20);
        icon.infoWindowAnchor = new GPoint(5, 1);
        return icon;
    }
}