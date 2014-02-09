// Example specific code; detect the browser platform to activate a different shortcut
var platform = nokia.maps.dom.Page.platform,
    keyModifierString,
    eventKey;
// Differentiate example text and click handler checks depending on platform
if (platform.mac) {
    keyModifierString = "CMD ⌘";
    eventKey = "metaKey";
} else {
    keyModifierString = "CTRL" ;
    eventKey = "ctrlKey";
}

/* We create a UI notecontainer for example description
 * NoteContainer is a UI helper function and not part of the Nokia Maps API
 * See exampleHelpers.js for implementation details 
 */
var noteContainer = new NoteContainer({
    id: "draggableRouteUi",
    parent: document.getElementById("uiContainer"),
    title: "Draggable route",
    content:
        '<p>An existing route can be changed by dragging one of the markers to a different position.</p>' +
            '<p>Once you stop dragging a marker the new route will be automatically calculated and redrawn.</p>' +
            '<ol><li>Add more markers by holding down the "' + keyModifierString + '" key and clicking anywhere on the map.</li>' +
            '<li>Remove a marker by holding down the "' + keyModifierString + '" key and clicking on an existing marker.</li></ol>'
});

/*	Setup authentication app_id and app_code 
 *	WARNING: this is a demo-only key
 *	please register for an Evaluation, Base or Commercial key for use in your app.
 *	Just visit http://developer.here.com/get-started for more details. Thank you!
 */
nokia.Settings.set("app_id", "rgQzd9LLcK1w7pmnsygP");
nokia.Settings.set("app_code", "5kNNYsj2Gq86UBHb83LUgg");
// Use staging environment (remove the line for production environment)
nokia.Settings.set("serviceMode", "cit");


// Get the DOM node to which we will append the map
var mapContainer = document.getElementById("mapContainer");
// Create a map inside the map container DOM node
var map = new nokia.maps.map.Display(mapContainer, {
    // Initial center and zoom level of the map
    center: [52.51, 13.4],
    zoomLevel: 10,
    components: [
        // We add the behavior component to allow panning / zooming of the map
        new nokia.maps.map.component.Behavior()
    ]
});

var waypoints = new nokia.maps.routing.WaypointParameterList(),
    markers = [],
    dragMarker = null,
    polyCounter = 0,
    mode = [{
                type: "fastest",
                transportModes: ["car"],
                options: ""
            }],
    route,
    dragRoutePending = false,
    dragRouteCanceled = false,
    routePolyline,
    dragRoutePolyline,
    arrayIndexOf = function (array, element) {
        for (var i = 0, l = array.length; i < l; i++) {
            if (array[i] == element) {
                return i;
            }
        }
        return -1;
    },
// Zoomlevel - mpp mapping table for route drag request optimization
    mpp = {
        1: 50312,
        2: 25156,
        3: 12578,
        4: 6289,
        5: 3145,
        6: 1572,
        7: 786,
        8: 393,
        9: 197,
        10: 98,
        11: 49,
        12: 25,
        13: 12,
        14: 6,
        15: 3,
        16: 2,
        17: 1,
        18: 1,
        19: 1,
        20: 1,
        21: 1,
        22: 1,
        23: 1
    },
    router = new nokia.maps.routing.Manager(),
    routerDrag = new nokia.maps.routing.Manager(), // This method makes a complete recalculation of the route
    updateRoute = function (oldValue, newValue) {
        if (markers.length > 1) {
            // Build the waypoints out of the current waypoint markers on the map
            waypoints = new nokia.maps.routing.WaypointParameterList();
            for (var i = 0, j = markers.length; i < j; i++) {
                waypoints.addCoordinate(markers[i].coordinate);
            }
            // Recalculate the route
            router.clear();
            router.calculateRoute(waypoints, mode.slice(0)); //pass a copy of the mode
        }
    },
// The function dragRoute makes a recalculation of route part which consists of three following route waypoints
    dragRoute = function (marker, newCoord) {
        // Signalize that we are currently (again) in a drag operation
        dragRouteCanceled = false;

        // If there is no route drag operation in progress at the moment
        if (!dragRoutePending && markers.length > 1) {
            // Signal that there is a drag operation pending now
            dragRoutePending = true;
            // Build the waypoints array out of the markers which reflect the dragged part of the route
            var currentMarkerIdx = arrayIndexOf(markers, marker);

            if (markers.length == 2) {
                if (currentMarkerIdx == 0) {
                    waypoints.coords = [newCoord, markers[1].coordinate];
                } else {
                    waypoints.coords = [markers[0].coordinate, newCoord];
                }
            } else {
                if (markers.length > 2) {
                    if (currentMarkerIdx == 0) {
                        waypoints.coords = [newCoord, markers[1].coordinate];
                    } else
                    if (currentMarkerIdx == (markers.length - 1)) {
                        waypoints.coords = [markers[(currentMarkerIdx - 1)].coordinate, newCoord];
                    } else {
                        waypoints.coords = [markers[(currentMarkerIdx - 1)].coordinate, newCoord, markers[(currentMarkerIdx + 1)].coordinate];
                    }
                }
            }

            // Recalculate the sub part of the route
            routerDrag.clear();

            var currentViewBounds = map.getViewBounds();
            routerDrag._additionalParams["viewbounds"] = "" + currentViewBounds.topLeft.latitude + "," + currentViewBounds.topLeft.longitude + ";" + currentViewBounds.bottomRight.latitude + "," + currentViewBounds.bottomRight.longitude;
            routerDrag._additionalParams["resolution"] = "" + mpp[map.zoomLevel];
            routerDrag.calculateRoute(waypoints, mode.slice(0)); // Pass a copy of the modes
        }
    },
// Handler method to process the server response for the complete route recalculation
    updateRouteHandler = function (obj, prop, newValue) {
        if (newValue == "finished") {
            // Signal that a pending drag operation can be skipped because the recalculation and therefor the drag operation have been finished
            dragRouteCanceled = true;
            dragRoutePending = false;

            // Remove the current route polyline from the map
            if (routePolyline)
                routeLayer.objects.remove(routePolyline);

            // Create the new route polyline
            route = obj.routes[0];
            routePolyline = new nokia.maps.map.Polyline(route.shape, {
                pen: {
                    lineWidth: 6,
                    lineJoin: 'round'
                }
            });

            // Add the listener for the mouse move event on the route
            routePolyline.addListener("mouseenter", function (evt) {
                var coord = map.pixelToGeo((evt.displayX - 8), (evt.displayY - 8));
                routerHoverMarker.set("coordinate", coord);
                routerHoverMarker.set("visibility", true);
            });

            // Add the listener for the mouse leave event on the route
            routePolyline.addListener("mouseleave", function (evt) {
                routerHoverMarker.set("visibility", false);
            });

            // Remove the intermediate drag route polyline if it exist
            if (dragRoutePolyline)
                routeLayer.objects.remove(dragRoutePolyline);

            // Add the new route to the map
            routeLayer.objects.add(routePolyline);
        }
    },
// Handler method to process the server response for the route sub part calculation
    dragRouteHandler = function (obj, prop, newValue) {
        if (newValue == "finished") {
            // Signal that there's no drag route in progress anymore
            dragRoutePending = false;

            // Proceed if the drag route operation hasn't been canceled before
            if (!dragRouteCanceled) {

                // Remove the intermediate drag route polyline if it exist
                if (dragRoutePolyline) {
                    routeLayer.objects.remove(dragRoutePolyline);
                }

                // Create the new route polyline for the sub route
                route = obj.routes[0];
                dragRoutePolyline = new nokia.maps.map.Polyline(route.shape, {
                    pen: {
                        lineWidth: 5,
                        strokeColor: "#00FF0099",
                        lineJoin: 'round'
                    }
                });

                // Add the new drag route to the map
                routeLayer.objects.add(dragRoutePolyline);
            }
        }
    };

// Add the obeservers for the route's calculation state
router.addObserver("state", updateRouteHandler, router);
routerDrag.addObserver("state", dragRouteHandler, routerDrag);
// We need to set some additional properties to make the route draggable
routerDrag._responseattributes = "";
routerDrag._routeattributes = "waypoints";
routerDrag._maneuverattributes = "";
routerDrag._additionalParams = {};
routerDrag._additionalParams["representation"] = "dragNDrop";

// Method which creates a new waypoint marker
var createWaypointMarker = function (geocoord, index) {
    var marker = new nokia.maps.map.StandardMarker(geocoord, {
        draggable: true,
        visibility: false
    });

    // Add a listener for click events on waypoint markers
    marker.addListener("click", function (evt) {
        // Remember the eventKey was determined at the start of the example by querying the running platform
        if (evt[eventKey] === true) {
            // Remove the waypoint marker from the map and recalculate the route
            removeWaypointMarker(evt.currentTarget);
            updateRoute();
            evt.preventDefault();
            evt.stopPropagation();
        }
    });

    // Add a listener for drag events on waypoint markers
    marker.addListener("drag", function (evt) {
        if (Math.abs(evt.deltaX) > 3 || Math.abs(evt.deltaY) > 3) {
            var coord = map.pixelToGeo(evt.displayX, evt.displayY);
            dragRoute(this, coord);
        }
    });
    // Add a listener for dragend events on waypoint markers
    marker.addListener("dragend", function (evt) {
        updateRoute();
    });

    // Add the marker to the markers array according to the passed index
    if (typeof index == "number") {
        markers.splice(index, 0, marker);
    } else {
        markers.push(marker);
        index = markers.length;
    }

    // Correct the markers' text after maker insertion
    for (var i = (index - 1); i < markers.length; i++) {
        markers[i].set("text", "" + (i + 1));
    }

    // Add marker to the markerLayer, to make it visible on the map
    markerLayer.objects.add(marker);

    return marker;
};

// Method which removes waypoint markers from the map
var removeWaypointMarker = function (marker) {
    var index = arrayIndexOf(markers, marker);

    markers.splice(index, 1);
    markerLayer.objects.remove(marker);

    // Correct the markers' text after maker insertion
    for (var i = index; i < markers.length; i++) {
        markers[i].set("text", "" + (i + 1));
    }

    // Remove the route if there aren't more than 1 marker left
    if (markers.length < 2) {
        // remove the current route polyline from the map
        if (routePolyline)
            routeLayer.objects.remove(routePolyline);
    }
};

// Create a layer for the route shape objects
var routeLayer = new nokia.maps.map.Container();
map.objects.add(routeLayer);

var routeHoverContext = new nokia.maps.gfx.Graphics();
routeHoverContext.beginImage(18, 18);
routeHoverContext.set("fillColor", "#FFF2");
routeHoverContext.set("strokeColor", "#000");
routeHoverContext.set("lineWidth", 2);
routeHoverContext.drawEllipse(1, 1, 14, 14);
routeHoverContext.fill();
routeHoverContext.stroke();

var routerHoverMarker = new nokia.maps.map.Marker({
    latitude: 50,
    longitude: 50
}, {
    icon: new nokia.maps.gfx.GraphicsImage(routeHoverContext.getIDL()),
    visibility: false,
    anchor: new nokia.maps.util.Point(0, 0),
    draggable: true
});
routeLayer.objects.add(routerHoverMarker);

// Add the listener for the mouse move event on the route
routeLayer.addListener("mousemove", function (evt) {
    var coord = map.pixelToGeo((evt.displayX - 8), (evt.displayY - 8));
    routerHoverMarker.set("coordinate", coord);
});

// Add the listener for the dragstart event on the route
routerHoverMarker.addListener("dragstart", function (evt) {
    var coord = map.pixelToGeo(evt.displayX, evt.displayY), nearestIndex = routePolyline.getNearestIndex(coord), shape = routePolyline.path.asArray(), currentWaypoint = route.waypoints[0].mappedPosition, currentWaypointIdx = 0, i;

    // Find the route's waypoint which comes before the point affected by the dragstart operation
    for (i = 0; i <= ((nearestIndex + 1) * 3); i += 3) {
        if (currentWaypoint.latitude == shape[i] &&
            currentWaypoint.longitude == shape[i + 1]) {
            currentWaypoint = route.waypoints[++currentWaypointIdx].mappedPosition;
        }
    }

    // Create a new marker at the drag start position and add it to the markers array at the correct position
    dragMarker = createWaypointMarker(coord, currentWaypointIdx);
});

// Add the listener for the drag event on the route
routerHoverMarker.addListener("drag", function (evt) {
    if (Math.abs(evt.deltaX) > 3 || Math.abs(evt.deltaY) > 3) {
        var coord = map.pixelToGeo(evt.displayX, evt.displayY);

        // Drag the route
        dragRoute(dragMarker, coord);
    }
});

// Add the listener for the dragend event on the route
routerHoverMarker.addListener("dragend", function (evt) {
    var coord = map.pixelToGeo(evt.displayX, evt.displayY);

    // Finalize the new created drag marker
    dragMarker.set("coordinate", coord);
    dragMarker.set("visibility", true);
    // Update the whole route
    updateRoute();
});

// Create a layer for the waypoint markers
var markerLayer = new nokia.maps.map.Container();
map.objects.add(markerLayer);

// Add a listener for click events on the map for adding markers and triggering the route recalculation
map.addListener("click", function (evt) {
    // Remember the eventKey was determined at the start of the example by querying the running platform
    if (evt[eventKey] === true) {
        var coord = map.pixelToGeo(evt.displayX, evt.displayY),
            marker = createWaypointMarker(coord);

        marker.set("visibility", true);
        updateRoute();
        evt.preventDefault();
    }
});

var start = createWaypointMarker({
    latitude: 52.5173,
    longitude: 13.3767
});

var destination = createWaypointMarker({
    latitude: 52.3984,
    longitude: 13.0529
});

// Trigger the example after the map emmits the "displayready" event.
map.addListener("displayready", function () {
    updateRoute();
    start.set("visibility", true);
    destination.set("visibility", true);
}, false);
		