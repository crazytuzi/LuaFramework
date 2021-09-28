





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "itemHandler_pb"


Pomelo = Pomelo or {}


Pomelo.ItemHandler = {}

local function getAllEquipDetailsRequestEncoder(msg)
	local input = itemHandler_pb.GetAllEquipDetailsRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getAllEquipDetailsRequestDecoder(stream)
	local res = itemHandler_pb.GetAllEquipDetailsResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ItemHandler.getAllEquipDetailsRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.itemHandler.getAllEquipDetailsRequest", option)
	Socket.Request("area.itemHandler.getAllEquipDetailsRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ItemHandler.lastGetAllEquipDetailsResponse = res
			Socket.OnRequestEnd("area.itemHandler.getAllEquipDetailsRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.itemHandler.getAllEquipDetailsRequest decode error!!"
			end
			Socket.OnRequestEnd("area.itemHandler.getAllEquipDetailsRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getAllEquipDetailsRequestEncoder, getAllEquipDetailsRequestDecoder)
end


local function getCombineFormulaRequestEncoder(msg)
	local input = itemHandler_pb.GetCombineFormulaRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getCombineFormulaRequestDecoder(stream)
	local res = itemHandler_pb.GetCombineFormulaResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ItemHandler.getCombineFormulaRequest(c2s_destID,cb,option)
	local msg = {}
	msg.c2s_destID = c2s_destID
	Socket.OnRequestStart("area.itemHandler.getCombineFormulaRequest", option)
	Socket.Request("area.itemHandler.getCombineFormulaRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ItemHandler.lastGetCombineFormulaResponse = res
			Socket.OnRequestEnd("area.itemHandler.getCombineFormulaRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.itemHandler.getCombineFormulaRequest decode error!!"
			end
			Socket.OnRequestEnd("area.itemHandler.getCombineFormulaRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getCombineFormulaRequestEncoder, getCombineFormulaRequestDecoder)
end


local function combineRequestEncoder(msg)
	local input = itemHandler_pb.CombineRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function combineRequestDecoder(stream)
	local res = itemHandler_pb.CombineResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ItemHandler.combineRequest(c2s_destID,c2s_num,c2s_gridIndex,cb,option)
	local msg = {}
	msg.c2s_destID = c2s_destID
	msg.c2s_num = c2s_num
	msg.c2s_gridIndex = c2s_gridIndex
	Socket.OnRequestStart("area.itemHandler.combineRequest", option)
	Socket.Request("area.itemHandler.combineRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ItemHandler.lastCombineResponse = res
			Socket.OnRequestEnd("area.itemHandler.combineRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.itemHandler.combineRequest decode error!!"
			end
			Socket.OnRequestEnd("area.itemHandler.combineRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, combineRequestEncoder, combineRequestDecoder)
end


local function queryItemStatusUpdateNotifyEncoder(msg)
	local input = itemHandler_pb.QueryItemStatusUpdateNotify()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

function Pomelo.ItemHandler.queryItemStatusUpdateNotify(index)
	local msg = {}
	msg.index = index
	Socket.Notify("area.itemHandler.queryItemStatusUpdateNotify", msg, queryItemStatusUpdateNotifyEncoder)
end


local function fishItemPushDecoder(stream)
	local res = itemHandler_pb.FishItemPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ItemHandler.fishItemPush(cb)
	Socket.On("area.itemPush.fishItemPush", function(res) 
		Pomelo.ItemHandler.lastFishItemPush = res
		cb(nil,res) 
	end, fishItemPushDecoder) 
end


local function countItemChangePushDecoder(stream)
	local res = itemHandler_pb.CountItemChangePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ItemHandler.countItemChangePush(cb)
	Socket.On("area.itemPush.countItemChangePush", function(res) 
		Pomelo.ItemHandler.lastCountItemChangePush = res
		cb(nil,res) 
	end, countItemChangePushDecoder) 
end


local function itemDetailPushDecoder(stream)
	local res = itemHandler_pb.ItemDetailPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ItemHandler.itemDetailPush(cb)
	Socket.On("area.itemPush.itemDetailPush", function(res) 
		Pomelo.ItemHandler.lastItemDetailPush = res
		cb(nil,res) 
	end, itemDetailPushDecoder) 
end


local function rewardItemPushDecoder(stream)
	local res = itemHandler_pb.RewardItemPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ItemHandler.rewardItemPush(cb)
	Socket.On("area.itemPush.rewardItemPush", function(res) 
		Pomelo.ItemHandler.lastRewardItemPush = res
		cb(nil,res) 
	end, rewardItemPushDecoder) 
end





return Pomelo
