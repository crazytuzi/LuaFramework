





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "activityRevelryHandler_pb"


Pomelo = Pomelo or {}


Pomelo.ActivityRevelryHandler = {}

local function revelryGetColumnRequestEncoder(msg)
	local input = activityRevelryHandler_pb.RevelryGetColumnRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function revelryGetColumnRequestDecoder(stream)
	local res = activityRevelryHandler_pb.RevelryGetColumnResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ActivityRevelryHandler.revelryGetColumnRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("revelry.activityRevelryHandler.revelryGetColumnRequest", option)
	Socket.Request("revelry.activityRevelryHandler.revelryGetColumnRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ActivityRevelryHandler.lastRevelryGetColumnResponse = res
			Socket.OnRequestEnd("revelry.activityRevelryHandler.revelryGetColumnRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] revelry.activityRevelryHandler.revelryGetColumnRequest decode error!!"
			end
			Socket.OnRequestEnd("revelry.activityRevelryHandler.revelryGetColumnRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, revelryGetColumnRequestEncoder, revelryGetColumnRequestDecoder)
end


local function revelryGetRankInfoRequestEncoder(msg)
	local input = activityRevelryHandler_pb.RevelryGetRankInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function revelryGetRankInfoRequestDecoder(stream)
	local res = activityRevelryHandler_pb.RevelryGetRankInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ActivityRevelryHandler.revelryGetRankInfoRequest(id,cb,option)
	local msg = {}
	msg.id = id
	Socket.OnRequestStart("revelry.activityRevelryHandler.revelryGetRankInfoRequest", option)
	Socket.Request("revelry.activityRevelryHandler.revelryGetRankInfoRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ActivityRevelryHandler.lastRevelryGetRankInfoResponse = res
			Socket.OnRequestEnd("revelry.activityRevelryHandler.revelryGetRankInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] revelry.activityRevelryHandler.revelryGetRankInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("revelry.activityRevelryHandler.revelryGetRankInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, revelryGetRankInfoRequestEncoder, revelryGetRankInfoRequestDecoder)
end


local function revelryExchangeRequestEncoder(msg)
	local input = activityRevelryHandler_pb.RevelryExchangeRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function revelryExchangeRequestDecoder(stream)
	local res = activityRevelryHandler_pb.RevelryExchangeResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ActivityRevelryHandler.revelryExchangeRequest(id,num,cb,option)
	local msg = {}
	msg.id = id
	msg.num = num
	Socket.OnRequestStart("revelry.activityRevelryHandler.revelryExchangeRequest", option)
	Socket.Request("revelry.activityRevelryHandler.revelryExchangeRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ActivityRevelryHandler.lastRevelryExchangeResponse = res
			Socket.OnRequestEnd("revelry.activityRevelryHandler.revelryExchangeRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] revelry.activityRevelryHandler.revelryExchangeRequest decode error!!"
			end
			Socket.OnRequestEnd("revelry.activityRevelryHandler.revelryExchangeRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, revelryExchangeRequestEncoder, revelryExchangeRequestDecoder)
end


local function revelryRechargeGetColumnRequestEncoder(msg)
	local input = activityRevelryHandler_pb.RevelryRechargeGetColumnRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function revelryRechargeGetColumnRequestDecoder(stream)
	local res = activityRevelryHandler_pb.RevelryRechargeGetColumnResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ActivityRevelryHandler.revelryRechargeGetColumnRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("revelry.activityRevelryHandler.revelryRechargeGetColumnRequest", option)
	Socket.Request("revelry.activityRevelryHandler.revelryRechargeGetColumnRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ActivityRevelryHandler.lastRevelryRechargeGetColumnResponse = res
			Socket.OnRequestEnd("revelry.activityRevelryHandler.revelryRechargeGetColumnRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] revelry.activityRevelryHandler.revelryRechargeGetColumnRequest decode error!!"
			end
			Socket.OnRequestEnd("revelry.activityRevelryHandler.revelryRechargeGetColumnRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, revelryRechargeGetColumnRequestEncoder, revelryRechargeGetColumnRequestDecoder)
end


local function revelryRechargeGetInfoRequestEncoder(msg)
	local input = activityRevelryHandler_pb.RevelryRechargeGetInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function revelryRechargeGetInfoRequestDecoder(stream)
	local res = activityRevelryHandler_pb.RevelryRechargeGetInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ActivityRevelryHandler.revelryRechargeGetInfoRequest(day,cb,option)
	local msg = {}
	msg.day = day
	Socket.OnRequestStart("revelry.activityRevelryHandler.revelryRechargeGetInfoRequest", option)
	Socket.Request("revelry.activityRevelryHandler.revelryRechargeGetInfoRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ActivityRevelryHandler.lastRevelryRechargeGetInfoResponse = res
			Socket.OnRequestEnd("revelry.activityRevelryHandler.revelryRechargeGetInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] revelry.activityRevelryHandler.revelryRechargeGetInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("revelry.activityRevelryHandler.revelryRechargeGetInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, revelryRechargeGetInfoRequestEncoder, revelryRechargeGetInfoRequestDecoder)
end


local function revelryRechargeAwardRequestEncoder(msg)
	local input = activityRevelryHandler_pb.RevelryRechargeAwardRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function revelryRechargeAwardRequestDecoder(stream)
	local res = activityRevelryHandler_pb.RevelryRechargeAwardResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ActivityRevelryHandler.revelryRechargeAwardRequest(id,cb,option)
	local msg = {}
	msg.id = id
	Socket.OnRequestStart("revelry.activityRevelryHandler.revelryRechargeAwardRequest", option)
	Socket.Request("revelry.activityRevelryHandler.revelryRechargeAwardRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ActivityRevelryHandler.lastRevelryRechargeAwardResponse = res
			Socket.OnRequestEnd("revelry.activityRevelryHandler.revelryRechargeAwardRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] revelry.activityRevelryHandler.revelryRechargeAwardRequest decode error!!"
			end
			Socket.OnRequestEnd("revelry.activityRevelryHandler.revelryRechargeAwardRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, revelryRechargeAwardRequestEncoder, revelryRechargeAwardRequestDecoder)
end





return Pomelo
