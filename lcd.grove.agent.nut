// HTTPのハンドラ
function requestHandler(request, response) {
    try {
        if ("led" in request.query) {
            if (request.query.led == "1" || request.query.led == "0") {
                local ledState = (request.query.led == "0") ? false : true;
                
                // デバイスに送信
                device.send("set.led", ledState);
            }
        }
        response.send(200, "OK");
    } catch (ex) {
        response.send(500, "Internal Server Error: " + ex);
    }
}
// HTTPで受信した時のハンドラ設定
http.onrequest(requestHandler);

