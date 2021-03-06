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
var host;
var key_garminCon;

function load(authm) {
    if (window.location.hostname == '0.0.0.0') {
        host = "http://0.0.0.0:3000";
        key_garminCon  = "9efb0ab754c9aebac8db458d98f5a717";
    }
    else {
        host = "http://www.trainingsdiary.com";
        key_garminCon  = "536b56b9c19941fcda1d7aa92955738e";
    }
    auth = authm;
    var display = new Garmin.DeviceDisplay("garminDisplay", {
        pathKeyPairsArray: [host, key_garminCon],
        showReadDataElement: true,
        showProgressBar: true,

//        showReadGoogleMap: true,
        showStatusElement: true,
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
        lookingForDevices: 'Searching for Device <br/><br/> <img src="/assets/ajax-loader.gif"/>',
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
    new Ajax.Request('/trainings/presave', {
          method:'POST',
//            parameters: form.serialize(),
          parameters: {training_xml: theContent, authenticity_token: auth },
          onSuccess: function(transport) {
            var response = transport.responseText || "no response text";

              var theStatusCell = aDisplay.currentActivityStatusElement();
              if( theStatusCell ) {
                  theStatusCell.innerHTML = 'Done';
              }

          },
          onFailure: function() { alert('Something went wrong...'); }
        });
}

