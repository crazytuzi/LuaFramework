





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "masteryHandler_pb"


Pomelo = Pomelo or {}


Pomelo.MasteryHandler = {}

local function getMasteryInfoRequestEncoder(msg)
	local input = masteryHandler_pb.GetMasteryInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getMasteryInfoRequestDecoder(stream)
	local res = masteryHandler_pb.GetMasteryInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.MasteryHandler.getMasteryInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.masteryHandler.getMasteryInfoRequest", option)
	Socket.Request("area.masteryHandler.getMasteryInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.MasteryHandler.lastGetMasteryInfoResponse = res
			Socket.OnRequestEnd("area.masteryHandler.getMasteryInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.masteryHandler.getMasteryInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.masteryHandler.getMasteryInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getMasteryInfoRequestEncoder, getMasteryInfoRequestDecoder)
end


local function activeMasteryRequestEncoder(msg)
	local input = masteryHandler_pb.ActiveMasteryRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function activeMasteryRequestDecoder(stream)
	local res = masteryHandler_pb.ActiveMasteryResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.MasteryHandler.activeMasteryRequest(c2s_pos,cb,option)
	local msg = {}
	msg.c2s_pos = c2s_pos
	Socket.OnRequestStart("area.masteryHandler.activeMasteryRequest", option)
	Socket.Request("area.masteryHandler.activeMasteryRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.MasteryHandler.lastActiveMasteryResponse = res
			Socket.OnRequestEnd("area.masteryHandler.activeMasteryRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.masteryHandler.activeMasteryRequest decode error!!"
			end
			Socket.OnRequestEnd("area.masteryHandler.activeMasteryRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, activeMasteryRequestEncoder, activeMasteryRequestDecoder)
end


local function getRingRequestEncoder(msg)
	local input = masteryHandler_pb.GetRingRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getRingRequestDecoder(stream)
	local res = masteryHandler_pb.GetRingResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.MasteryHandler.getRingRequest(c2s_ringId,cb,option)
	local msg = {}
	msg.c2s_ringId = c2s_ringId
	Socket.OnRequestStart("area.masteryHandler.getRingRequest", option)
	Socket.Request("area.masteryHandler.getRingRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.MasteryHandler.lastGetRingResponse = res
			Socket.OnRequestEnd("area.masteryHandler.getRingRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.masteryHandler.getRingRequest decode error!!"
			end
			Socket.OnRequestEnd("area.masteryHandler.getRingRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getRingRequestEncoder, getRingRequestDecoder)
end


local function masteryRingRequestEncoder(msg)
	local input = masteryHandler_pb.MasteryRingRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function masteryRingRequestDecoder(stream)
	local res = masteryHandler_pb.MasteryRingResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.MasteryHandler.masteryRingRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.masteryHandler.masteryRingRequest", option)
	Socket.Request("area.masteryHandler.masteryRingRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.MasteryHandler.lastMasteryRingResponse = res
			Socket.OnRequestEnd("area.masteryHandler.masteryRingRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.masteryHandler.masteryRingRequest decode error!!"
			end
			Socket.OnRequestEnd("area.masteryHandler.masteryRingRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, masteryRingRequestEncoder, masteryRingRequestDecoder)
end


local function masteryDeliverRequestEncoder(msg)
	local input = masteryHandler_pb.MasteryDeliverRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function masteryDeliverRequestDecoder(stream)
	local res = masteryHandler_pb.MasteryDeliverResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.MasteryHandler.masteryDeliverRequest(c2s_pos,cb,option)
	local msg = {}
	msg.c2s_pos = c2s_pos
	Socket.OnRequestStart("area.masteryHandler.masteryDeliverRequest", option)
	Socket.Request("area.masteryHandler.masteryDeliverRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.MasteryHandler.lastMasteryDeliverResponse = res
			Socket.OnRequestEnd("area.masteryHandler.masteryDeliverRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.masteryHandler.masteryDeliverRequest decode error!!"
			end
			Socket.OnRequestEnd("area.masteryHandler.masteryDeliverRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, masteryDeliverRequestEncoder, masteryDeliverRequestDecoder)
end





return Pomelo
