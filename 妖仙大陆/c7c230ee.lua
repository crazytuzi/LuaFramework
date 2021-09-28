





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "onlineGiftHandler_pb"


Pomelo = Pomelo or {}


Pomelo.OnlineGiftHandler = {}

local function getGiftInfoRequestEncoder(msg)
	local input = onlineGiftHandler_pb.GetGiftInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getGiftInfoRequestDecoder(stream)
	local res = onlineGiftHandler_pb.GetGiftInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.OnlineGiftHandler.getGiftInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.onlineGiftHandler.getGiftInfoRequest", option)
	Socket.Request("area.onlineGiftHandler.getGiftInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.OnlineGiftHandler.lastGetGiftInfoResponse = res
			Socket.OnRequestEnd("area.onlineGiftHandler.getGiftInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.onlineGiftHandler.getGiftInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.onlineGiftHandler.getGiftInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getGiftInfoRequestEncoder, getGiftInfoRequestDecoder)
end


local function getOnlineTimeRequestEncoder(msg)
	local input = onlineGiftHandler_pb.GetOnlineTimeRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getOnlineTimeRequestDecoder(stream)
	local res = onlineGiftHandler_pb.GetOnlineTimeResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.OnlineGiftHandler.getOnlineTimeRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.onlineGiftHandler.getOnlineTimeRequest", option)
	Socket.Request("area.onlineGiftHandler.getOnlineTimeRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.OnlineGiftHandler.lastGetOnlineTimeResponse = res
			Socket.OnRequestEnd("area.onlineGiftHandler.getOnlineTimeRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.onlineGiftHandler.getOnlineTimeRequest decode error!!"
			end
			Socket.OnRequestEnd("area.onlineGiftHandler.getOnlineTimeRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getOnlineTimeRequestEncoder, getOnlineTimeRequestDecoder)
end


local function receiveGiftRequestEncoder(msg)
	local input = onlineGiftHandler_pb.ReceiveGiftRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function receiveGiftRequestDecoder(stream)
	local res = onlineGiftHandler_pb.ReceiveGiftResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.OnlineGiftHandler.receiveGiftRequest(c2s_id,cb,option)
	local msg = {}
	msg.c2s_id = c2s_id
	Socket.OnRequestStart("area.onlineGiftHandler.receiveGiftRequest", option)
	Socket.Request("area.onlineGiftHandler.receiveGiftRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.OnlineGiftHandler.lastReceiveGiftResponse = res
			Socket.OnRequestEnd("area.onlineGiftHandler.receiveGiftRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.onlineGiftHandler.receiveGiftRequest decode error!!"
			end
			Socket.OnRequestEnd("area.onlineGiftHandler.receiveGiftRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, receiveGiftRequestEncoder, receiveGiftRequestDecoder)
end


local function giftInfoPushDecoder(stream)
	local res = onlineGiftHandler_pb.GiftInfoPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.OnlineGiftHandler.giftInfoPush(cb)
	Socket.On("area.onlineGiftPush.giftInfoPush", function(res) 
		Pomelo.OnlineGiftHandler.lastGiftInfoPush = res
		cb(nil,res) 
	end, giftInfoPushDecoder) 
end





return Pomelo
