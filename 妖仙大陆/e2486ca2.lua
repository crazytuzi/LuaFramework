





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "sevenGoalHandler_pb"


Pomelo = Pomelo or {}


Pomelo.SevenGoalHandler = {}

local function getSevenGoalRequestEncoder(msg)
	local input = sevenGoalHandler_pb.GetSevenGoalRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getSevenGoalRequestDecoder(stream)
	local res = sevenGoalHandler_pb.GetSevenGoalResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.SevenGoalHandler.getSevenGoalRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("sevengoal.sevenGoalHandler.getSevenGoalRequest", option)
	Socket.Request("sevengoal.sevenGoalHandler.getSevenGoalRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.SevenGoalHandler.lastGetSevenGoalResponse = res
			Socket.OnRequestEnd("sevengoal.sevenGoalHandler.getSevenGoalRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] sevengoal.sevenGoalHandler.getSevenGoalRequest decode error!!"
			end
			Socket.OnRequestEnd("sevengoal.sevenGoalHandler.getSevenGoalRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getSevenGoalRequestEncoder, getSevenGoalRequestDecoder)
end


local function fetchAwardRequestEncoder(msg)
	local input = sevenGoalHandler_pb.FetchAwardRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function fetchAwardRequestDecoder(stream)
	local res = sevenGoalHandler_pb.FetchAwardResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.SevenGoalHandler.fetchAwardRequest(id,cb,option)
	local msg = {}
	msg.id = id
	Socket.OnRequestStart("sevengoal.sevenGoalHandler.fetchAwardRequest", option)
	Socket.Request("sevengoal.sevenGoalHandler.fetchAwardRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.SevenGoalHandler.lastFetchAwardResponse = res
			Socket.OnRequestEnd("sevengoal.sevenGoalHandler.fetchAwardRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] sevengoal.sevenGoalHandler.fetchAwardRequest decode error!!"
			end
			Socket.OnRequestEnd("sevengoal.sevenGoalHandler.fetchAwardRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, fetchAwardRequestEncoder, fetchAwardRequestDecoder)
end





return Pomelo
