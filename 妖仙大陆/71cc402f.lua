





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "interactHandler_pb"


Pomelo = Pomelo or {}


Pomelo.InteractHandler = {}

local function interactRequestEncoder(msg)
	local input = interactHandler_pb.InteractRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function interactRequestDecoder(stream)
	local res = interactHandler_pb.InteractResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.InteractHandler.interactRequest(c2s_id,c2s_playerId,c2s_playerName,cb,option)
	local msg = {}
	msg.c2s_id = c2s_id
	msg.c2s_playerId = c2s_playerId
	msg.c2s_playerName = c2s_playerName
	Socket.OnRequestStart("area.interactHandler.interactRequest", option)
	Socket.Request("area.interactHandler.interactRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.InteractHandler.lastInteractResponse = res
			Socket.OnRequestEnd("area.interactHandler.interactRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.interactHandler.interactRequest decode error!!"
			end
			Socket.OnRequestEnd("area.interactHandler.interactRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, interactRequestEncoder, interactRequestDecoder)
end


local function interactConfigRequestEncoder(msg)
	local input = interactHandler_pb.InteractConfigRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function interactConfigRequestDecoder(stream)
	local res = interactHandler_pb.InteractConfigResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.InteractHandler.interactConfigRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.interactHandler.interactConfigRequest", option)
	Socket.Request("area.interactHandler.interactConfigRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.InteractHandler.lastInteractConfigResponse = res
			Socket.OnRequestEnd("area.interactHandler.interactConfigRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.interactHandler.interactConfigRequest decode error!!"
			end
			Socket.OnRequestEnd("area.interactHandler.interactConfigRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, interactConfigRequestEncoder, interactConfigRequestDecoder)
end


local function interactTimesRequestEncoder(msg)
	local input = interactHandler_pb.InteractTimesRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function interactTimesRequestDecoder(stream)
	local res = interactHandler_pb.InteractTimesResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.InteractHandler.interactTimesRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.interactHandler.interactTimesRequest", option)
	Socket.Request("area.interactHandler.interactTimesRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.InteractHandler.lastInteractTimesResponse = res
			Socket.OnRequestEnd("area.interactHandler.interactTimesRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.interactHandler.interactTimesRequest decode error!!"
			end
			Socket.OnRequestEnd("area.interactHandler.interactTimesRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, interactTimesRequestEncoder, interactTimesRequestDecoder)
end


local function receiveInteractPushDecoder(stream)
	local res = interactHandler_pb.ReceiveInteractPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.InteractHandler.receiveInteractPush(cb)
	Socket.On("area.interactPush.receiveInteractPush", function(res) 
		Pomelo.InteractHandler.lastReceiveInteractPush = res
		cb(nil,res) 
	end, receiveInteractPushDecoder) 
end





return Pomelo
