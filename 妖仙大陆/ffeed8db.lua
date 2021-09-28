





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "functionHandler_pb"


Pomelo = Pomelo or {}


Pomelo.FunctionHandler = {}

local function functionGoToPushDecoder(stream)
	local res = functionHandler_pb.FunctionGoToPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FunctionHandler.functionGoToPush(cb)
	Socket.On("area.functionPush.functionGoToPush", function(res) 
		Pomelo.FunctionHandler.lastFunctionGoToPush = res
		cb(nil,res) 
	end, functionGoToPushDecoder) 
end


local function taskGuideFuncPushDecoder(stream)
	local res = functionHandler_pb.TaskGuideFuncPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FunctionHandler.taskGuideFuncPush(cb)
	Socket.On("area.functionPush.taskGuideFuncPush", function(res) 
		Pomelo.FunctionHandler.lastTaskGuideFuncPush = res
		cb(nil,res) 
	end, taskGuideFuncPushDecoder) 
end





return Pomelo
