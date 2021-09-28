





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "shopMallHandler_pb"


Pomelo = Pomelo or {}


Pomelo.ShopMallHandler = {}

local function getMallTabsRequestEncoder(msg)
	local input = shopMallHandler_pb.GetMallTabsRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getMallTabsRequestDecoder(stream)
	local res = shopMallHandler_pb.GetMallTabsResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ShopMallHandler.getMallTabsRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.shopMallHandler.getMallTabsRequest", option)
	Socket.Request("area.shopMallHandler.getMallTabsRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ShopMallHandler.lastGetMallTabsResponse = res
			Socket.OnRequestEnd("area.shopMallHandler.getMallTabsRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.shopMallHandler.getMallTabsRequest decode error!!"
			end
			Socket.OnRequestEnd("area.shopMallHandler.getMallTabsRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getMallTabsRequestEncoder, getMallTabsRequestDecoder)
end


local function getMallScoreItemListRequestEncoder(msg)
	local input = shopMallHandler_pb.GetMallScoreItemListRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getMallScoreItemListRequestDecoder(stream)
	local res = shopMallHandler_pb.GetMallScoreItemListResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ShopMallHandler.getMallScoreItemListRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.shopMallHandler.getMallScoreItemListRequest", option)
	Socket.Request("area.shopMallHandler.getMallScoreItemListRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ShopMallHandler.lastGetMallScoreItemListResponse = res
			Socket.OnRequestEnd("area.shopMallHandler.getMallScoreItemListRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.shopMallHandler.getMallScoreItemListRequest decode error!!"
			end
			Socket.OnRequestEnd("area.shopMallHandler.getMallScoreItemListRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getMallScoreItemListRequestEncoder, getMallScoreItemListRequestDecoder)
end


local function buyMallItemRequestEncoder(msg)
	local input = shopMallHandler_pb.BuyMallItemRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function buyMallItemRequestDecoder(stream)
	local res = shopMallHandler_pb.BuyMallItemResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ShopMallHandler.buyMallItemRequest(c2s_itemId,c2s_count,c2s_playerId,c2s_bDiamond,cb,option)
	local msg = {}
	msg.c2s_itemId = c2s_itemId
	msg.c2s_count = c2s_count
	msg.c2s_playerId = c2s_playerId
	msg.c2s_bDiamond = c2s_bDiamond
	Socket.OnRequestStart("area.shopMallHandler.buyMallItemRequest", option)
	Socket.Request("area.shopMallHandler.buyMallItemRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ShopMallHandler.lastBuyMallItemResponse = res
			Socket.OnRequestEnd("area.shopMallHandler.buyMallItemRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.shopMallHandler.buyMallItemRequest decode error!!"
			end
			Socket.OnRequestEnd("area.shopMallHandler.buyMallItemRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, buyMallItemRequestEncoder, buyMallItemRequestDecoder)
end


local function getMallItemListRequestEncoder(msg)
	local input = shopMallHandler_pb.GetMallItemListRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getMallItemListRequestDecoder(stream)
	local res = shopMallHandler_pb.GetMallItemListResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ShopMallHandler.getMallItemListRequest(c2s_moneyType,c2s_itemType,cb,option)
	local msg = {}
	msg.c2s_moneyType = c2s_moneyType
	msg.c2s_itemType = c2s_itemType
	Socket.OnRequestStart("area.shopMallHandler.getMallItemListRequest", option)
	Socket.Request("area.shopMallHandler.getMallItemListRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ShopMallHandler.lastGetMallItemListResponse = res
			Socket.OnRequestEnd("area.shopMallHandler.getMallItemListRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.shopMallHandler.getMallItemListRequest decode error!!"
			end
			Socket.OnRequestEnd("area.shopMallHandler.getMallItemListRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getMallItemListRequestEncoder, getMallItemListRequestDecoder)
end


local function buyMallScoreItemRequestEncoder(msg)
	local input = shopMallHandler_pb.BuyMallScoreItemRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function buyMallScoreItemRequestDecoder(stream)
	local res = shopMallHandler_pb.BuyMallScoreItemResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ShopMallHandler.buyMallScoreItemRequest(c2s_itemId,cb,option)
	local msg = {}
	msg.c2s_itemId = c2s_itemId
	Socket.OnRequestStart("area.shopMallHandler.buyMallScoreItemRequest", option)
	Socket.Request("area.shopMallHandler.buyMallScoreItemRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ShopMallHandler.lastBuyMallScoreItemResponse = res
			Socket.OnRequestEnd("area.shopMallHandler.buyMallScoreItemRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.shopMallHandler.buyMallScoreItemRequest decode error!!"
			end
			Socket.OnRequestEnd("area.shopMallHandler.buyMallScoreItemRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, buyMallScoreItemRequestEncoder, buyMallScoreItemRequestDecoder)
end





return Pomelo
