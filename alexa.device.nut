#require "HTS221.device.lib.nut:2.0.0"
#require "messagemanager.class.nut:1.0.1"

tempSensor <- null;

// 
// Alexa, tell me the  temperature of the  ElectricExplorer
// Alexa, turn on the  ElectricExplorer
// 
local mm = MessageManager();
local agentListener = function(msg, reply) {

    local cmd = msg.data;
    server.log("cmd: " + cmd);

    if ("turnOn" == cmd) {
        server.log("Device: Turning on");
        reply("OK");
    } else if ("turnOff" == cmd) {
        server.log("Device: Turning off");
        reply("OK");
    } else if ("getTemperatureReading" == cmd) {
        local result = tempSensor.read();
        local fal = ((result.temperature - 32) * 5 ) / 9 ;
        server.log("degree : " + result.temperature + ", fal : " + fal );
        reply(fal);
    } else {
        server.log("Device: invalid command " + cmd);
        reply("Failed");
    }
}

local i2c = hardware.i2cNM;
i2c.configure(CLOCK_SPEED_400_KHZ);

tempSensor = HTS221(i2c);
tempSensor.setMode(HTS221_MODE.ONE_SHOT);

mm.on("Control", agentListener);
