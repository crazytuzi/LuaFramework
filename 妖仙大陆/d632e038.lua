





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "exchangeHandler_pb"


Pomelo = Pomelo or {}


Pomelo.ExchangeHandler = {}

local function getExchangeLabelRequestEncoder(msg)
	local input = exchangeHandler_pb.GetExchangeLabelRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getExchangeLabelRequestDecoder(stream)
	local res = exchangeHandler_pb.GetExchangeLabelResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ExchangeHandler.getExchangeLabelRequest(c2s_npcId,cb,option)
	local msg = {}
	msg.c2s_npcId = c2s_npcId
	Socket.OnRequestStart("area.exchangeHandler.getExchangeLabelRequest", option)
	Socket.Request("area.exchangeHandler.getExchangeLabelRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ExchangeHandler.lastGetExchangeLabelResponse = res
			Socket.OnRequestEnd("area.exchangeHandler.getExchangeLabelRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.exchangeHandler.getExchangeLabelRequest decode error!!"
			end
			Socket.OnRequestEnd("area.exchangeHandler.getExchangeLabelRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getExchangeLabelRequestEncoder, getExchangeLabelRequestDecoder)
end


local function getExchangeListRequestEncoder(msg)
	local input = exchangeHandler_pb.GetExchangeListRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getExchangeListRequestDecoder(stream)
	local res = exchangeHandler_pb.GetExchangeListResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ExchangeHandler.getExchangeListRequest(c2s_npcId,c2s_typeId,cb,option)
	local msg = {}
	msg.c2s_npcId = c2s_npcId
	msg.c2s_typeId = c2s_typeId
	Socket.OnRequestStart("area.exchangeHandler.getExchangeListRequest", option)
	Socket.Request("area.exchangeHandler.getExchangeListRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ExchangeHandler.lastGetExchangeListResponse = res
			Socket.OnRequestEnd("area.exchangeHandler.getExchangeListRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.exchangeHandler.getExchangeListRequest decode error!!"
			end
			Socket.OnRequestEnd("area.exchangeHandler.getExchangeListRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getExchangeListRequestEncoder, getExchangeListRequestDecoder)
end


local function exchangeItemRequestEncoder(msg)
	local input = exchangeHandler_pb.ExchangeItemRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function exchangeItemRequestDecoder(stream)
	local res = exchangeHandler_pb.ExchangeItemResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ExchangeHandler.exchangeItemRequest(c2s_typeId,c2s_itemId,c2s_num,c2s_npcId,cb,option)
	local msg = {}
	msg.c2s_typeId = c2s_typeId
	msg.c2s_itemId = c2s_itemId
	msg.c2s_num = c2s_num
	msg.c2s_npcId = c2s_npcId
	Socket.OnRequestStart("area.exchangeHandler.exchangeItemRequest", option)
	Socket.Request("area.exchangeHandler.exchangeItemRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ExchangeHandler.lastExchangeItemResponse = res
			Socket.OnRequestEnd("area.exchangeHandler.exchangeItemRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.exchangeHandler.exchangeItemRequest decode error!!"
			end
			Socket.OnRequestEnd("area.exchangeHandler.exchangeItemRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, exchangeItemRequestEncoder, exchangeItemRequestDecoder)
end


local function allyFightExchangeRequestEncoder(msg)
	local input = exchangeHandler_pb.AllyFightExchangeRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function allyFightExchangeRequestDecoder(stream)
	local res = exchangeHandler_pb.AllyFightExchangeResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ExchangeHandler.allyFightExchangeRequest(c2s_npcId,c2s_typeId,cb,option)
	local msg = {}
	msg.c2s_npcId = c2s_npcId
	msg.c2s_typeId = c2s_typeId
	Socket.OnRequestStart("area.exchangeHandler.allyFightExchangeRequest", option)
	Socket.Request("area.exchangeHandler.allyFightExchangeRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ExchangeHandler.lastAllyFightExchangeResponse = res
			Socket.OnRequestEnd("area.exchangeHandler.allyFightExchangeRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.exchangeHandler.allyFightExchangeRequest decode error!!"
			end
			Socket.OnRequestEnd("area.exchangeHandler.allyFightExchangeRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, allyFightExchangeRequestEncoder, allyFightExchangeRequestDecoder)
end





return Pomelo
