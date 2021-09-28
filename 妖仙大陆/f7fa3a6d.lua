





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "guildShopHandler_pb"


Pomelo = Pomelo or {}


Pomelo.GuildShopHandler = {}

local function getGuildShopInfoRequestEncoder(msg)
	local input = guildShopHandler_pb.GetGuildShopInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getGuildShopInfoRequestDecoder(stream)
	local res = guildShopHandler_pb.GetGuildShopInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildShopHandler.getGuildShopInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.guildShopHandler.getGuildShopInfoRequest", option)
	Socket.Request("area.guildShopHandler.getGuildShopInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildShopHandler.lastGetGuildShopInfoResponse = res
			Socket.OnRequestEnd("area.guildShopHandler.getGuildShopInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildShopHandler.getGuildShopInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildShopHandler.getGuildShopInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getGuildShopInfoRequestEncoder, getGuildShopInfoRequestDecoder)
end


local function exchangeShopItemRequestEncoder(msg)
	local input = guildShopHandler_pb.ExchangeShopItemRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function exchangeShopItemRequestDecoder(stream)
	local res = guildShopHandler_pb.ExchangeShopItemResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildShopHandler.exchangeShopItemRequest(id,cb,option)
	local msg = {}
	msg.id = id
	Socket.OnRequestStart("area.guildShopHandler.exchangeShopItemRequest", option)
	Socket.Request("area.guildShopHandler.exchangeShopItemRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildShopHandler.lastExchangeShopItemResponse = res
			Socket.OnRequestEnd("area.guildShopHandler.exchangeShopItemRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildShopHandler.exchangeShopItemRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildShopHandler.exchangeShopItemRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, exchangeShopItemRequestEncoder, exchangeShopItemRequestDecoder)
end


local function shopRefreshPushDecoder(stream)
	local res = guildShopHandler_pb.ShopRefreshPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildShopHandler.shopRefreshPush(cb)
	Socket.On("area.guildShopPush.shopRefreshPush", function(res) 
		Pomelo.GuildShopHandler.lastShopRefreshPush = res
		cb(nil,res) 
	end, shopRefreshPushDecoder) 
end





return Pomelo
