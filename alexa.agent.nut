#require "AlexaSmartHomeSkill.agent.nut:1.0.0"
#require "messagemanager.class.nut:1.0.1"

local smartToasterInfo = {
    "actions": [
        "turnOn"
        "turnOff",
        "getTemperatureReading"
    ],
    "additionalApplianceDetails": {
        "extraDetail1": "pin1",
    },
    "friendlyDescription": "Electric Imp004m Explorer",
    "friendlyName": "Machine",
    "manufacturerName": "Mars Industrial",
    "modelName": "ElectricExplorer 1.0",
    "version": "1.0"
};

local mm = MessageManager();
local mmHandlers = {
    "onReply" :
        function(msg, response) {
            local action  = msg.metadata.action;
            local session = msg.metadata.session;

            local responseCallback = action == "turnOn"
                ? session.sendTurnOnConfirm.bindenv(session)
                : session.sendTurnOffConfirm.bindenv(session);

            if (action == "getTemperatureReading") {
                server.log("request : getTemperatureReading");
                session.sendGetTempReadingResponse(response);
            } else {
                local err;
                if ("OK" == response) {
                    err = responseCallback();
                } else {
                    err = session.driverInternalError();
                }
                if (null != err) {
                    server.error("Unable to send response: " + err);
                }
            }
        }.bindenv(this)
}

// Callback executed upon Alexa request
local actionCallback = function(session, applianceId, action, param) {
    server.log("Got action " + action + " for " + applianceId);
    mm.send("Control", action, mmHandlers, null, {
            "action" : action,
            "session": session
        });
}.bindenv(this);


local alexa = AlexaSmartHomeSkill();
alexa.registerAppliance("Device", smartToasterInfo, actionCallback);
