





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "saleHandler_pb"


Pomelo = Pomelo or {}


Pomelo.SaleHandler = {}

local function buyPageRequestEncoder(msg)
	local input = saleHandler_pb.BuyPageRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function buyPageRequestDecoder(stream)
	local res = saleHandler_pb.BuyPageResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.SaleHandler.buyPageRequest(c2s_sellIndex,cb,option)
	local msg = {}
	msg.c2s_sellIndex = c2s_sellIndex
	Socket.OnRequestStart("area.saleHandler.buyPageRequest", option)
	Socket.Request("area.saleHandler.buyPageRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.SaleHandler.lastBuyPageResponse = res
			Socket.OnRequestEnd("area.saleHandler.buyPageRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.saleHandler.buyPageRequest decode error!!"
			end
			Socket.OnRequestEnd("area.saleHandler.buyPageRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, buyPageRequestEncoder, buyPageRequestDecoder)
end


local function buyItemRequestEncoder(msg)
	local input = saleHandler_pb.BuyItemRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function buyItemRequestDecoder(stream)
	local res = saleHandler_pb.BuyItemResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.SaleHandler.buyItemRequest(c2s_typeId,c2s_itemId,c2s_num,cb,option)
	local msg = {}
	msg.c2s_typeId = c2s_typeId
	msg.c2s_itemId = c2s_itemId
	msg.c2s_num = c2s_num
	Socket.OnRequestStart("area.saleHandler.buyItemRequest", option)
	Socket.Request("area.saleHandler.buyItemRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.SaleHandler.lastBuyItemResponse = res
			Socket.OnRequestEnd("area.saleHandler.buyItemRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.saleHandler.buyItemRequest decode error!!"
			end
			Socket.OnRequestEnd("area.saleHandler.buyItemRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, buyItemRequestEncoder, buyItemRequestDecoder)
end


local function autoBuyItemByCodeRequestEncoder(msg)
	local input = saleHandler_pb.AutoBuyItemByCodeRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function autoBuyItemByCodeRequestDecoder(stream)
	local res = saleHandler_pb.AutoBuyItemByCodeResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.SaleHandler.autoBuyItemByCodeRequest(c2s_typeId,c2s_itemCode,c2s_num,cb,option)
	local msg = {}
	msg.c2s_typeId = c2s_typeId
	msg.c2s_itemCode = c2s_itemCode
	msg.c2s_num = c2s_num
	Socket.OnRequestStart("area.saleHandler.autoBuyItemByCodeRequest", option)
	Socket.Request("area.saleHandler.autoBuyItemByCodeRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.SaleHandler.lastAutoBuyItemByCodeResponse = res
			Socket.OnRequestEnd("area.saleHandler.autoBuyItemByCodeRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.saleHandler.autoBuyItemByCodeRequest decode error!!"
			end
			Socket.OnRequestEnd("area.saleHandler.autoBuyItemByCodeRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, autoBuyItemByCodeRequestEncoder, autoBuyItemByCodeRequestDecoder)
end


local function sellItemsRequestEncoder(msg)
	local input = saleHandler_pb.SellItemsRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function sellItemsRequestDecoder(stream)
	local res = saleHandler_pb.SellItemsResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.SaleHandler.sellItemsRequest(c2s_sellGrids,cb,option)
	local msg = {}
	msg.c2s_sellGrids = c2s_sellGrids
	Socket.OnRequestStart("area.saleHandler.sellItemsRequest", option)
	Socket.Request("area.saleHandler.sellItemsRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.SaleHandler.lastSellItemsResponse = res
			Socket.OnRequestEnd("area.saleHandler.sellItemsRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.saleHandler.sellItemsRequest decode error!!"
			end
			Socket.OnRequestEnd("area.saleHandler.sellItemsRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, sellItemsRequestEncoder, sellItemsRequestDecoder)
end


local function rebuyItemRequestEncoder(msg)
	local input = saleHandler_pb.RebuyItemRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function rebuyItemRequestDecoder(stream)
	local res = saleHandler_pb.RebuyItemResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.SaleHandler.rebuyItemRequest(c2s_gridIndex,c2s_num,cb,option)
	local msg = {}
	msg.c2s_gridIndex = c2s_gridIndex
	msg.c2s_num = c2s_num
	Socket.OnRequestStart("area.saleHandler.rebuyItemRequest", option)
	Socket.Request("area.saleHandler.rebuyItemRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.SaleHandler.lastRebuyItemResponse = res
			Socket.OnRequestEnd("area.saleHandler.rebuyItemRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.saleHandler.rebuyItemRequest decode error!!"
			end
			Socket.OnRequestEnd("area.saleHandler.rebuyItemRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, rebuyItemRequestEncoder, rebuyItemRequestDecoder)
end





return Pomelo
