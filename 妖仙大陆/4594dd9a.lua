





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "bagHandler_pb"


Pomelo = Pomelo or {}


Pomelo.BagHandler = {}

local function packUpBagRequestEncoder(msg)
	local input = bagHandler_pb.PackUpBagRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function packUpBagRequestDecoder(stream)
	local res = bagHandler_pb.PackUpBagResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.BagHandler.packUpBagRequest(c2s_type,cb,option)
	local msg = {}
	msg.c2s_type = c2s_type
	Socket.OnRequestStart("area.bagHandler.packUpBagRequest", option)
	Socket.Request("area.bagHandler.packUpBagRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.BagHandler.lastPackUpBagResponse = res
			Socket.OnRequestEnd("area.bagHandler.packUpBagRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.bagHandler.packUpBagRequest decode error!!"
			end
			Socket.OnRequestEnd("area.bagHandler.packUpBagRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, packUpBagRequestEncoder, packUpBagRequestDecoder)
end


local function openBagGridRequestEncoder(msg)
	local input = bagHandler_pb.OpenBagGridRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function openBagGridRequestDecoder(stream)
	local res = bagHandler_pb.OpenBagGridResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.BagHandler.openBagGridRequest(c2s_type,c2s_number,cb,option)
	local msg = {}
	msg.c2s_type = c2s_type
	msg.c2s_number = c2s_number
	Socket.OnRequestStart("area.bagHandler.openBagGridRequest", option)
	Socket.Request("area.bagHandler.openBagGridRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.BagHandler.lastOpenBagGridResponse = res
			Socket.OnRequestEnd("area.bagHandler.openBagGridRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.bagHandler.openBagGridRequest decode error!!"
			end
			Socket.OnRequestEnd("area.bagHandler.openBagGridRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, openBagGridRequestEncoder, openBagGridRequestDecoder)
end


local function transferItemRequestEncoder(msg)
	local input = bagHandler_pb.TransferItemRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function transferItemRequestDecoder(stream)
	local res = bagHandler_pb.TransferItemResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.BagHandler.transferItemRequest(c2s_fromType,c2s_fromIndex,c2s_toType,c2s_num,cb,option)
	local msg = {}
	msg.c2s_fromType = c2s_fromType
	msg.c2s_fromIndex = c2s_fromIndex
	msg.c2s_toType = c2s_toType
	msg.c2s_num = c2s_num
	Socket.OnRequestStart("area.bagHandler.transferItemRequest", option)
	Socket.Request("area.bagHandler.transferItemRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.BagHandler.lastTransferItemResponse = res
			Socket.OnRequestEnd("area.bagHandler.transferItemRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.bagHandler.transferItemRequest decode error!!"
			end
			Socket.OnRequestEnd("area.bagHandler.transferItemRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, transferItemRequestEncoder, transferItemRequestDecoder)
end


local function sellItemRequestEncoder(msg)
	local input = bagHandler_pb.SellItemRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function sellItemRequestDecoder(stream)
	local res = bagHandler_pb.SellItemResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.BagHandler.sellItemRequest(c2s_gridIndex,c2s_num,cb,option)
	local msg = {}
	msg.c2s_gridIndex = c2s_gridIndex
	msg.c2s_num = c2s_num
	Socket.OnRequestStart("area.bagHandler.sellItemRequest", option)
	Socket.Request("area.bagHandler.sellItemRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.BagHandler.lastSellItemResponse = res
			Socket.OnRequestEnd("area.bagHandler.sellItemRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.bagHandler.sellItemRequest decode error!!"
			end
			Socket.OnRequestEnd("area.bagHandler.sellItemRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, sellItemRequestEncoder, sellItemRequestDecoder)
end


local function useItemRequestEncoder(msg)
	local input = bagHandler_pb.UseItemRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function useItemRequestDecoder(stream)
	local res = bagHandler_pb.UseItemResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.BagHandler.useItemRequest(c2s_gridIndex,c2s_num,cb,option)
	local msg = {}
	msg.c2s_gridIndex = c2s_gridIndex
	msg.c2s_num = c2s_num
	Socket.OnRequestStart("area.bagHandler.useItemRequest", option)
	Socket.Request("area.bagHandler.useItemRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.BagHandler.lastUseItemResponse = res
			Socket.OnRequestEnd("area.bagHandler.useItemRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.bagHandler.useItemRequest decode error!!"
			end
			Socket.OnRequestEnd("area.bagHandler.useItemRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, useItemRequestEncoder, useItemRequestDecoder)
end


local function addBagItemTestNotifyEncoder(msg)
	local input = bagHandler_pb.AddBagItemTestNotify()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

function Pomelo.BagHandler.addBagItemTestNotify()
	local msg = nil
	Socket.Notify("area.bagHandler.addBagItemTestNotify", msg, addBagItemTestNotifyEncoder)
end


local function bagItemUpdatePushDecoder(stream)
	local res = bagHandler_pb.BagItemUpdatePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.BagHandler.bagItemUpdatePush(cb)
	Socket.On("area.bagPush.bagItemUpdatePush", function(res) 
		Pomelo.BagHandler.lastBagItemUpdatePush = res
		cb(nil,res) 
	end, bagItemUpdatePushDecoder) 
end


local function bagNewItemPushDecoder(stream)
	local res = bagHandler_pb.BagNewItemPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.BagHandler.bagNewItemPush(cb)
	Socket.On("area.bagPush.bagNewItemPush", function(res) 
		Pomelo.BagHandler.lastBagNewItemPush = res
		cb(nil,res) 
	end, bagNewItemPushDecoder) 
end


local function bagNewEquipPushDecoder(stream)
	local res = bagHandler_pb.BagNewEquipPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.BagHandler.bagNewEquipPush(cb)
	Socket.On("area.bagPush.bagNewEquipPush", function(res) 
		Pomelo.BagHandler.lastBagNewEquipPush = res
		cb(nil,res) 
	end, bagNewEquipPushDecoder) 
end


local function bagGridFullPushDecoder(stream)
	local res = bagHandler_pb.BagGridFullPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.BagHandler.bagGridFullPush(cb)
	Socket.On("area.bagPush.bagGridFullPush", function(res) 
		Pomelo.BagHandler.lastBagGridFullPush = res
		cb(nil,res) 
	end, bagGridFullPushDecoder) 
end


local function bagGridNumPushDecoder(stream)
	local res = bagHandler_pb.BagGridNumPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.BagHandler.bagGridNumPush(cb)
	Socket.On("area.bagPush.bagGridNumPush", function(res) 
		Pomelo.BagHandler.lastBagGridNumPush = res
		cb(nil,res) 
	end, bagGridNumPushDecoder) 
end


local function bagNewItemFromResFubenPushDecoder(stream)
	local res = bagHandler_pb.BagNewItemFromResFubenPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.BagHandler.bagNewItemFromResFubenPush(cb)
	Socket.On("area.bagPush.bagNewItemFromResFubenPush", function(res) 
		Pomelo.BagHandler.lastBagNewItemFromResFubenPush = res
		cb(nil,res) 
	end, bagNewItemFromResFubenPushDecoder) 
end





return Pomelo
