





local Socket = require "Xmds.Pomelo.LuaGateSocket"
require "base64"


Pomelo = Pomelo or {}


Pomelo.GateSocket = {}

local function serverStatePushDecoder(stream)
	local res = loginHandler_pb.ServerStatePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GateSocket.serverStatePush(cb)
	Socket.On("login.loginPush.serverStatePush", function(res) 
		Pomelo.GateSocket.lastServerStatePush = res
		cb(nil,res) 
	end, serverStatePushDecoder) 
end





return Pomelo
