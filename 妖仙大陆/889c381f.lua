





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "vipHandler_pb"


Pomelo = Pomelo or {}


Pomelo.VipHandler = {}

local function vipInfoRequestEncoder(msg)
	local input = vipHandler_pb.VipRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function vipInfoRequestDecoder(stream)
	local res = vipHandler_pb.VipResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.VipHandler.vipInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.vipHandler.vipInfoRequest", option)
	Socket.Request("area.vipHandler.vipInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.VipHandler.lastVipResponse = res
			Socket.OnRequestEnd("area.vipHandler.vipInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.vipHandler.vipInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.vipHandler.vipInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, vipInfoRequestEncoder, vipInfoRequestDecoder)
end


local function getEveryDayGiftRequestEncoder(msg)
	local input = vipHandler_pb.GetEveryDayGiftRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getEveryDayGiftRequestDecoder(stream)
	local res = vipHandler_pb.GetEveryDayGiftResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.VipHandler.getEveryDayGiftRequest(c2s_type,cb,option)
	local msg = {}
	msg.c2s_type = c2s_type
	Socket.OnRequestStart("area.vipHandler.getEveryDayGiftRequest", option)
	Socket.Request("area.vipHandler.getEveryDayGiftRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.VipHandler.lastGetEveryDayGiftResponse = res
			Socket.OnRequestEnd("area.vipHandler.getEveryDayGiftRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.vipHandler.getEveryDayGiftRequest decode error!!"
			end
			Socket.OnRequestEnd("area.vipHandler.getEveryDayGiftRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getEveryDayGiftRequestEncoder, getEveryDayGiftRequestDecoder)
end


local function buyEveryDayGiftRequestEncoder(msg)
	local input = vipHandler_pb.BuyEveryDayGiftRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function buyEveryDayGiftRequestDecoder(stream)
	local res = vipHandler_pb.BuyEveryDayGiftResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.VipHandler.buyEveryDayGiftRequest(c2s_vipLevel,cb,option)
	local msg = {}
	msg.c2s_vipLevel = c2s_vipLevel
	Socket.OnRequestStart("area.vipHandler.buyEveryDayGiftRequest", option)
	Socket.Request("area.vipHandler.buyEveryDayGiftRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.VipHandler.lastBuyEveryDayGiftResponse = res
			Socket.OnRequestEnd("area.vipHandler.buyEveryDayGiftRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.vipHandler.buyEveryDayGiftRequest decode error!!"
			end
			Socket.OnRequestEnd("area.vipHandler.buyEveryDayGiftRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, buyEveryDayGiftRequestEncoder, buyEveryDayGiftRequestDecoder)
end


local function buyVipCardRequestEncoder(msg)
	local input = vipHandler_pb.BuyVipCardRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function buyVipCardRequestDecoder(stream)
	local res = vipHandler_pb.BuyVipCardResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.VipHandler.buyVipCardRequest(c2s_typeId,c2s_itemId,c2s_type,cb,option)
	local msg = {}
	msg.c2s_typeId = c2s_typeId
	msg.c2s_itemId = c2s_itemId
	msg.c2s_type = c2s_type
	Socket.OnRequestStart("area.vipHandler.buyVipCardRequest", option)
	Socket.Request("area.vipHandler.buyVipCardRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.VipHandler.lastBuyVipCardResponse = res
			Socket.OnRequestEnd("area.vipHandler.buyVipCardRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.vipHandler.buyVipCardRequest decode error!!"
			end
			Socket.OnRequestEnd("area.vipHandler.buyVipCardRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, buyVipCardRequestEncoder, buyVipCardRequestDecoder)
end





return Pomelo
