





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "tradeHandler_pb"


Pomelo = Pomelo or {}


Pomelo.TradeHandler = {}

local function inviteRequestEncoder(msg)
	local input = tradeHandler_pb.InviteRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function inviteRequestDecoder(stream)
	local res = tradeHandler_pb.InviteResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.TradeHandler.inviteRequest(c2s_playerId,cb,option)
	local msg = {}
	msg.c2s_playerId = c2s_playerId
	Socket.OnRequestStart("area.tradeHandler.inviteRequest", option)
	Socket.Request("area.tradeHandler.inviteRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.TradeHandler.lastInviteResponse = res
			Socket.OnRequestEnd("area.tradeHandler.inviteRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.tradeHandler.inviteRequest decode error!!"
			end
			Socket.OnRequestEnd("area.tradeHandler.inviteRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, inviteRequestEncoder, inviteRequestDecoder)
end


local function addItemRequestEncoder(msg)
	local input = tradeHandler_pb.AddItemRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function addItemRequestDecoder(stream)
	local res = tradeHandler_pb.AddItemResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.TradeHandler.addItemRequest(c2s_diamond,c2s_items,cb,option)
	local msg = {}
	msg.c2s_diamond = c2s_diamond
	msg.c2s_items = c2s_items
	Socket.OnRequestStart("area.tradeHandler.addItemRequest", option)
	Socket.Request("area.tradeHandler.addItemRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.TradeHandler.lastAddItemResponse = res
			Socket.OnRequestEnd("area.tradeHandler.addItemRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.tradeHandler.addItemRequest decode error!!"
			end
			Socket.OnRequestEnd("area.tradeHandler.addItemRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, addItemRequestEncoder, addItemRequestDecoder)
end


local function removeItemRequestEncoder(msg)
	local input = tradeHandler_pb.RemoveItemRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function removeItemRequestDecoder(stream)
	local res = tradeHandler_pb.RemoveItemResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.TradeHandler.removeItemRequest(c2s_indexs,cb,option)
	local msg = {}
	msg.c2s_indexs = c2s_indexs
	Socket.OnRequestStart("area.tradeHandler.removeItemRequest", option)
	Socket.Request("area.tradeHandler.removeItemRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.TradeHandler.lastRemoveItemResponse = res
			Socket.OnRequestEnd("area.tradeHandler.removeItemRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.tradeHandler.removeItemRequest decode error!!"
			end
			Socket.OnRequestEnd("area.tradeHandler.removeItemRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, removeItemRequestEncoder, removeItemRequestDecoder)
end


local function tradeOperateRequestEncoder(msg)
	local input = tradeHandler_pb.TradeOperateRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function tradeOperateRequestDecoder(stream)
	local res = tradeHandler_pb.TradeOperateResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.TradeHandler.tradeOperateRequest(c2s_operate,c2s_diamond,c2s_items,cb,option)
	local msg = {}
	msg.c2s_operate = c2s_operate
	msg.c2s_diamond = c2s_diamond
	msg.c2s_items = c2s_items
	Socket.OnRequestStart("area.tradeHandler.tradeOperateRequest", option)
	Socket.Request("area.tradeHandler.tradeOperateRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.TradeHandler.lastTradeOperateResponse = res
			Socket.OnRequestEnd("area.tradeHandler.tradeOperateRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.tradeHandler.tradeOperateRequest decode error!!"
			end
			Socket.OnRequestEnd("area.tradeHandler.tradeOperateRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, tradeOperateRequestEncoder, tradeOperateRequestDecoder)
end


local function tradeBeginPushDecoder(stream)
	local res = tradeHandler_pb.TradeBeginPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.TradeHandler.tradeBeginPush(cb)
	Socket.On("area.tradePush.tradeBeginPush", function(res) 
		Pomelo.TradeHandler.lastTradeBeginPush = res
		cb(nil,res) 
	end, tradeBeginPushDecoder) 
end


local function tradeItemChangePushDecoder(stream)
	local res = tradeHandler_pb.TradeItemChangePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.TradeHandler.tradeItemChangePush(cb)
	Socket.On("area.tradePush.tradeItemChangePush", function(res) 
		Pomelo.TradeHandler.lastTradeItemChangePush = res
		cb(nil,res) 
	end, tradeItemChangePushDecoder) 
end


local function tradeOperatePushDecoder(stream)
	local res = tradeHandler_pb.TradeOperatePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.TradeHandler.tradeOperatePush(cb)
	Socket.On("area.tradePush.tradeOperatePush", function(res) 
		Pomelo.TradeHandler.lastTradeOperatePush = res
		cb(nil,res) 
	end, tradeOperatePushDecoder) 
end





return Pomelo
