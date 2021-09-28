





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "crossServerHandler_pb"


Pomelo = Pomelo or {}


Pomelo.CrossServerHandler = {}

local function treasureOpenPushDecoder(stream)
	local res = crossServerHandler_pb.TreasureOpenPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.CrossServerHandler.treasureOpenPush(cb)
	Socket.On("area.crossServerPush.treasureOpenPush", function(res) 
		Pomelo.CrossServerHandler.lastTreasureOpenPush = res
		cb(nil,res) 
	end, treasureOpenPushDecoder) 
end





return Pomelo
