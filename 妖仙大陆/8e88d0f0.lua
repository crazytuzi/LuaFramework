





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "payGiftHandler_pb"


Pomelo = Pomelo or {}


Pomelo.PayGiftHandler = {}

local function firstPayGiftInfoRequestEncoder(msg)
	local input = payGiftHandler_pb.FirstPayGiftInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function firstPayGiftInfoRequestDecoder(stream)
	local res = payGiftHandler_pb.FirstPayGiftInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PayGiftHandler.firstPayGiftInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.payGiftHandler.firstPayGiftInfoRequest", option)
	Socket.Request("area.payGiftHandler.firstPayGiftInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PayGiftHandler.lastFirstPayGiftInfoResponse = res
			Socket.OnRequestEnd("area.payGiftHandler.firstPayGiftInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.payGiftHandler.firstPayGiftInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.payGiftHandler.firstPayGiftInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, firstPayGiftInfoRequestEncoder, firstPayGiftInfoRequestDecoder)
end


local function getFirstPayGiftRequestEncoder(msg)
	local input = payGiftHandler_pb.GetFirstPayGiftRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getFirstPayGiftRequestDecoder(stream)
	local res = payGiftHandler_pb.GetFirstPayGiftResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PayGiftHandler.getFirstPayGiftRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.payGiftHandler.getFirstPayGiftRequest", option)
	Socket.Request("area.payGiftHandler.getFirstPayGiftRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PayGiftHandler.lastGetFirstPayGiftResponse = res
			Socket.OnRequestEnd("area.payGiftHandler.getFirstPayGiftRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.payGiftHandler.getFirstPayGiftRequest decode error!!"
			end
			Socket.OnRequestEnd("area.payGiftHandler.getFirstPayGiftRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getFirstPayGiftRequestEncoder, getFirstPayGiftRequestDecoder)
end


local function dailyPayGiftInfoRequestEncoder(msg)
	local input = payGiftHandler_pb.DailyPayGiftInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function dailyPayGiftInfoRequestDecoder(stream)
	local res = payGiftHandler_pb.DailyPayGiftInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PayGiftHandler.dailyPayGiftInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.payGiftHandler.dailyPayGiftInfoRequest", option)
	Socket.Request("area.payGiftHandler.dailyPayGiftInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PayGiftHandler.lastDailyPayGiftInfoResponse = res
			Socket.OnRequestEnd("area.payGiftHandler.dailyPayGiftInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.payGiftHandler.dailyPayGiftInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.payGiftHandler.dailyPayGiftInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, dailyPayGiftInfoRequestEncoder, dailyPayGiftInfoRequestDecoder)
end


local function getDailyPayGiftRequestEncoder(msg)
	local input = payGiftHandler_pb.GetDailyPayGiftRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getDailyPayGiftRequestDecoder(stream)
	local res = payGiftHandler_pb.GetDailyPayGiftResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PayGiftHandler.getDailyPayGiftRequest(c2s_giftId,cb,option)
	local msg = {}
	msg.c2s_giftId = c2s_giftId
	Socket.OnRequestStart("area.payGiftHandler.getDailyPayGiftRequest", option)
	Socket.Request("area.payGiftHandler.getDailyPayGiftRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PayGiftHandler.lastGetDailyPayGiftResponse = res
			Socket.OnRequestEnd("area.payGiftHandler.getDailyPayGiftRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.payGiftHandler.getDailyPayGiftRequest decode error!!"
			end
			Socket.OnRequestEnd("area.payGiftHandler.getDailyPayGiftRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getDailyPayGiftRequestEncoder, getDailyPayGiftRequestDecoder)
end





return Pomelo
