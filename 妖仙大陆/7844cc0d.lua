





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "fleeHandler_pb"


Pomelo = Pomelo or {}


Pomelo.FleeHandler = {}

local function fleeInfoRequestEncoder(msg)
	local input = fleeHandler_pb.FleeInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function fleeInfoRequestDecoder(stream)
	local res = fleeHandler_pb.FleeInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FleeHandler.fleeInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.fleeHandler.fleeInfoRequest", option)
	Socket.Request("area.fleeHandler.fleeInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FleeHandler.lastFleeInfoResponse = res
			Socket.OnRequestEnd("area.fleeHandler.fleeInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.fleeHandler.fleeInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.fleeHandler.fleeInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, fleeInfoRequestEncoder, fleeInfoRequestDecoder)
end


local function getRewardRequestEncoder(msg)
	local input = fleeHandler_pb.GetRewardRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getRewardRequestDecoder(stream)
	local res = fleeHandler_pb.GetRewardResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FleeHandler.getRewardRequest(gradeId,cb,option)
	local msg = {}
	msg.gradeId = gradeId
	Socket.OnRequestStart("area.fleeHandler.getRewardRequest", option)
	Socket.Request("area.fleeHandler.getRewardRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FleeHandler.lastGetRewardResponse = res
			Socket.OnRequestEnd("area.fleeHandler.getRewardRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.fleeHandler.getRewardRequest decode error!!"
			end
			Socket.OnRequestEnd("area.fleeHandler.getRewardRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getRewardRequestEncoder, getRewardRequestDecoder)
end


local function fleeLookBtlReportRequestEncoder(msg)
	local input = fleeHandler_pb.FleeLookBtlReportRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function fleeLookBtlReportRequestDecoder(stream)
	local res = fleeHandler_pb.FleeLookBtlReportResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FleeHandler.fleeLookBtlReportRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.fleeHandler.fleeLookBtlReportRequest", option)
	Socket.Request("area.fleeHandler.fleeLookBtlReportRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FleeHandler.lastFleeLookBtlReportResponse = res
			Socket.OnRequestEnd("area.fleeHandler.fleeLookBtlReportRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.fleeHandler.fleeLookBtlReportRequest decode error!!"
			end
			Socket.OnRequestEnd("area.fleeHandler.fleeLookBtlReportRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, fleeLookBtlReportRequestEncoder, fleeLookBtlReportRequestDecoder)
end


local function enterFleeRequestEncoder(msg)
	local input = fleeHandler_pb.EnterFleeRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function enterFleeRequestDecoder(stream)
	local res = fleeHandler_pb.EnterFleeResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FleeHandler.enterFleeRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.fleeHandler.enterFleeRequest", option)
	Socket.Request("area.fleeHandler.enterFleeRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FleeHandler.lastEnterFleeResponse = res
			Socket.OnRequestEnd("area.fleeHandler.enterFleeRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.fleeHandler.enterFleeRequest decode error!!"
			end
			Socket.OnRequestEnd("area.fleeHandler.enterFleeRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, enterFleeRequestEncoder, enterFleeRequestDecoder)
end


local function cancelMatchRequestEncoder(msg)
	local input = fleeHandler_pb.CancelMatchRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function cancelMatchRequestDecoder(stream)
	local res = fleeHandler_pb.CancelMatchResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FleeHandler.cancelMatchRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.fleeHandler.cancelMatchRequest", option)
	Socket.Request("area.fleeHandler.cancelMatchRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FleeHandler.lastCancelMatchResponse = res
			Socket.OnRequestEnd("area.fleeHandler.cancelMatchRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.fleeHandler.cancelMatchRequest decode error!!"
			end
			Socket.OnRequestEnd("area.fleeHandler.cancelMatchRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, cancelMatchRequestEncoder, cancelMatchRequestDecoder)
end


local function onFleeDeathPushDecoder(stream)
	local res = fleeHandler_pb.OnFleeDeathPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FleeHandler.onFleeDeathPush(cb)
	Socket.On("area.fleePush.onFleeDeathPush", function(res) 
		Pomelo.FleeHandler.lastOnFleeDeathPush = res
		cb(nil,res) 
	end, onFleeDeathPushDecoder) 
end


local function onFleeEndPushDecoder(stream)
	local res = fleeHandler_pb.OnFleeEndPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FleeHandler.onFleeEndPush(cb)
	Socket.On("area.fleePush.onFleeEndPush", function(res) 
		Pomelo.FleeHandler.lastOnFleeEndPush = res
		cb(nil,res) 
	end, onFleeEndPushDecoder) 
end





return Pomelo
