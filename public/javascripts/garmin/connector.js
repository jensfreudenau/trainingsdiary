/**
 * Created with JetBrains RubyMine.
 * User: jensfreudenau
 * Date: 09.05.13
 * Time: 10:38
 * To change this template use File | Settings | File Templates.
 */
var control;
var display;
var auth;
function load(authm) {
    auth = authm;
    var display = new Garmin.DeviceDisplay("garminDisplay", {
        pathKeyPairsArray: ["http://0.0.0.0:3000", "9efb0ab754c9aebac8db458d98f5a717"],
        showReadDataElement: true,

//        showReadGoogleMap: true,
        showStatusElement: true,

        showProgressBar: true,
        progressBarClass: 'progressBarClass',
        showFindDevicesElement: true,
        showFindDevicesButton: false,
        showDeviceButtonsOnLoad: false,
        showDeviceButtonsOnFound: false,
        autoFindDevices: true,
        showDeviceSelectOnLoad: true,
        autoHideUnusedElements: true,
        showReadDataTypesSelect: false,
        readDataType: Garmin.DeviceControl.FILE_TYPES.tcxDir,
        deviceSelectLabel: "Choose Device <br/>",
        readDataButtonText: "List Activities",
        showCancelReadDataButton: false,
        lookingForDevices: 'Searching for Device <br/><br/> <img src="../javascripts/garmin/device/style/ajax-loader.gif"/>',
        uploadsFinished: "Transfer Complete",
        uploadSelectedActivities: true,
        uploadCompressedData: false,    // Turn on data compression by setting to true.
			uploadMaximum: 1,
        dataFound: "#{tracks} activities found on device",
        showReadDataElementOnDeviceFound: true,

        postActivityHandler: function (aFile, display) {
            postFile(aFile, display, auth);
        }
//            function(activityXml, display) {
//				$('activity').innerHTML += '<pre>'+activityXml.escapeHTML()+'</pre>';
//			}
    });
}

function postFile (aFile, aDisplay, auth) {
    var theContent = aFile;
    new Ajax.Request('/trainings/sort', {
          method:'POST',
//            parameters: form.serialize(),
          parameters: {training_xml: theContent, authenticity_token: auth },
          onSuccess: function(transport) {
            var response = transport.responseText || "no response text";
            alert("Success! \n\n");
              var theStatusCell = aDisplay.currentActivityStatusElement();
              if( theStatusCell ) {
                  theStatusCell.innerHTML = 'Done';
              }

          },
          onFailure: function() { alert('Something went wrong...'); }
        });
}

