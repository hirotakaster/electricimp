var http = require('http');
var URLParser = require('url');

// Forwards all ALEXA requests to device cloud.
// URL is obtained from "EI_AGENT_URL" environment variable
exports.handler = function (event, context) {
    var messageId = "1";
    try {
        var url = process.env["EI_AGENT_URL"];

        log("Invocation with ", event);
        log("Target URL", url);

        var parts = URLParser.parse(url);
        var post_data = JSON.stringify(event);

        messageId = event.header.messageId;

        // host to forward
        var post_options = {
            host: parts.hostname,
            auth: parts.auth,
            port: (parts.port || 80),
            path: parts.path,
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Content-Length': post_data.length
            }
        };
        // Initiate the request to the HTTP endpoint
        var req = http.request(post_options, function (res) {
            var body = "";
            // Data may be chunked
            res.on('data', function (chunk) {
                log(`DATA:`, chunk.toString());
                body += chunk;
            });
            res.on('end', function () {
                log("END", body);
                body = JSON.parse(body);
                // When data is done, finish the request
                context.succeed(body);
            });
        });
        req.on('error', function (e) {
            log('problem with request:', e.message);
            context.fail(generateTargetOfflineErr(messageId));
        });
        // send ALEXA request
        req.write(post_data);
        req.end();
    } catch (e) {
        log("General error", e.message);
        context.fail(generateDriverInternalError(messageId));
    }
};

// Network related error, script can't send or receive data
function generateTargetOfflineErr(messageId) {
    return {
        "header": {
            "namespace": "Alexa.ConnectedHome.Control",
            "name": "TargetOfflineError",
            "payloadVersion": "2",
            "messageId": messageId
        },
        "payload": {}
    };
}

// General error not related to network or device interaction
function generateDriverInternalError(messageId) {
    return {
        "header": {
            "namespace": "Alexa.ConnectedHome.Control",
            "name": "DriverInternalError",
            "payloadVersion": "2",
            "messageId": messageId
        },
        "payload": {}
    };
}

function log(title, msg) {
    console.log('*************** ' + title + ' *************');
    console.log(msg);
    console.log('*************** ' + title + ' End*************');
}
