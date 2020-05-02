var app = require('express')();
var http = require('http').Server(app);
var io = require('socket.io')(http);
var port = 3004;
const { exec } = require('child_process');

io.on('connection', function(socket) {
	console.log("Connected!")

	socket.on('SEND_COMMAND', function(command) {
		console.log("SEND_COMMAND")
		exec(command, (err, stdout, stderr) => {
			var out = stdout || stderr || err;
			socket.emit('RECIVE_COMMAND_OUTPUT', {
				commandReq: command,
				data: out
			});
		});
	});
});

http.listen(port, function() {
	console.log('listening on *:' + port);
});
