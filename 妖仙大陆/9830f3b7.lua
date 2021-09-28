





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "farmHandler_pb"


Pomelo = Pomelo or {}


Pomelo.FarmHandler = {}

local function myFarmInfoRequestEncoder(msg)
	local input = farmHandler_pb.MyFarmInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function myFarmInfoRequestDecoder(stream)
	local res = farmHandler_pb.MyFarmInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FarmHandler.myFarmInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("farm.farmHandler.myFarmInfoRequest", option)
	Socket.Request("farm.farmHandler.myFarmInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FarmHandler.lastMyFarmInfoResponse = res
			Socket.OnRequestEnd("farm.farmHandler.myFarmInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] farm.farmHandler.myFarmInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("farm.farmHandler.myFarmInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, myFarmInfoRequestEncoder, myFarmInfoRequestDecoder)
end


local function friendFarmInfoRequestEncoder(msg)
	local input = farmHandler_pb.FriendFarmInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function friendFarmInfoRequestDecoder(stream)
	local res = farmHandler_pb.FriendFarmInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FarmHandler.friendFarmInfoRequest(playerId,cb,option)
	local msg = {}
	msg.playerId = playerId
	Socket.OnRequestStart("farm.farmHandler.friendFarmInfoRequest", option)
	Socket.Request("farm.farmHandler.friendFarmInfoRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FarmHandler.lastFriendFarmInfoResponse = res
			Socket.OnRequestEnd("farm.farmHandler.friendFarmInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] farm.farmHandler.friendFarmInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("farm.farmHandler.friendFarmInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, friendFarmInfoRequestEncoder, friendFarmInfoRequestDecoder)
end


local function friendLsRequestEncoder(msg)
	local input = farmHandler_pb.FriendLsRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function friendLsRequestDecoder(stream)
	local res = farmHandler_pb.FriendLsResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FarmHandler.friendLsRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("farm.farmHandler.friendLsRequest", option)
	Socket.Request("farm.farmHandler.friendLsRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FarmHandler.lastFriendLsResponse = res
			Socket.OnRequestEnd("farm.farmHandler.friendLsRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] farm.farmHandler.friendLsRequest decode error!!"
			end
			Socket.OnRequestEnd("farm.farmHandler.friendLsRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, friendLsRequestEncoder, friendLsRequestDecoder)
end


local function openRequestEncoder(msg)
	local input = farmHandler_pb.OpenRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function openRequestDecoder(stream)
	local res = farmHandler_pb.OpenResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FarmHandler.openRequest(blockId,cb,option)
	local msg = {}
	msg.blockId = blockId
	Socket.OnRequestStart("farm.farmHandler.openRequest", option)
	Socket.Request("farm.farmHandler.openRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FarmHandler.lastOpenResponse = res
			Socket.OnRequestEnd("farm.farmHandler.openRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] farm.farmHandler.openRequest decode error!!"
			end
			Socket.OnRequestEnd("farm.farmHandler.openRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, openRequestEncoder, openRequestDecoder)
end


local function sowRequestEncoder(msg)
	local input = farmHandler_pb.SowRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function sowRequestDecoder(stream)
	local res = farmHandler_pb.SowResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FarmHandler.sowRequest(blockId,seedCode,cb,option)
	local msg = {}
	msg.blockId = blockId
	msg.seedCode = seedCode
	Socket.OnRequestStart("farm.farmHandler.sowRequest", option)
	Socket.Request("farm.farmHandler.sowRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FarmHandler.lastSowResponse = res
			Socket.OnRequestEnd("farm.farmHandler.sowRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] farm.farmHandler.sowRequest decode error!!"
			end
			Socket.OnRequestEnd("farm.farmHandler.sowRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, sowRequestEncoder, sowRequestDecoder)
end


local function cultivateFriendRequestEncoder(msg)
	local input = farmHandler_pb.CultivateFriendRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function cultivateFriendRequestDecoder(stream)
	local res = farmHandler_pb.CultivateFriendResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FarmHandler.cultivateFriendRequest(blockId,cultivateType,friendId,cb,option)
	local msg = {}
	msg.blockId = blockId
	msg.cultivateType = cultivateType
	msg.friendId = friendId
	Socket.OnRequestStart("farm.farmHandler.cultivateFriendRequest", option)
	Socket.Request("farm.farmHandler.cultivateFriendRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FarmHandler.lastCultivateFriendResponse = res
			Socket.OnRequestEnd("farm.farmHandler.cultivateFriendRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] farm.farmHandler.cultivateFriendRequest decode error!!"
			end
			Socket.OnRequestEnd("farm.farmHandler.cultivateFriendRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, cultivateFriendRequestEncoder, cultivateFriendRequestDecoder)
end


local function cultivateSelfRequestEncoder(msg)
	local input = farmHandler_pb.CultivateSelfRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function cultivateSelfRequestDecoder(stream)
	local res = farmHandler_pb.CultivateSelfResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FarmHandler.cultivateSelfRequest(blockId,cultivateType,cb,option)
	local msg = {}
	msg.blockId = blockId
	msg.cultivateType = cultivateType
	Socket.OnRequestStart("farm.farmHandler.cultivateSelfRequest", option)
	Socket.Request("farm.farmHandler.cultivateSelfRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FarmHandler.lastCultivateSelfResponse = res
			Socket.OnRequestEnd("farm.farmHandler.cultivateSelfRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] farm.farmHandler.cultivateSelfRequest decode error!!"
			end
			Socket.OnRequestEnd("farm.farmHandler.cultivateSelfRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, cultivateSelfRequestEncoder, cultivateSelfRequestDecoder)
end


local function stealRequestEncoder(msg)
	local input = farmHandler_pb.StealRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function stealRequestDecoder(stream)
	local res = farmHandler_pb.StealResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FarmHandler.stealRequest(blockId,friendId,cb,option)
	local msg = {}
	msg.blockId = blockId
	msg.friendId = friendId
	Socket.OnRequestStart("farm.farmHandler.stealRequest", option)
	Socket.Request("farm.farmHandler.stealRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FarmHandler.lastStealResponse = res
			Socket.OnRequestEnd("farm.farmHandler.stealRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] farm.farmHandler.stealRequest decode error!!"
			end
			Socket.OnRequestEnd("farm.farmHandler.stealRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, stealRequestEncoder, stealRequestDecoder)
end


local function harvestRequestEncoder(msg)
	local input = farmHandler_pb.HarvestRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function harvestRequestDecoder(stream)
	local res = farmHandler_pb.HarvestResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FarmHandler.harvestRequest(blockId,cb,option)
	local msg = {}
	msg.blockId = blockId
	Socket.OnRequestStart("farm.farmHandler.harvestRequest", option)
	Socket.Request("farm.farmHandler.harvestRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FarmHandler.lastHarvestResponse = res
			Socket.OnRequestEnd("farm.farmHandler.harvestRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] farm.farmHandler.harvestRequest decode error!!"
			end
			Socket.OnRequestEnd("farm.farmHandler.harvestRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, harvestRequestEncoder, harvestRequestDecoder)
end


local function getShopInfoRequestEncoder(msg)
	local input = farmHandler_pb.GetShopInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getShopInfoRequestDecoder(stream)
	local res = farmHandler_pb.GetShopInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FarmHandler.getShopInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("farm.farmHandler.getShopInfoRequest", option)
	Socket.Request("farm.farmHandler.getShopInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FarmHandler.lastGetShopInfoResponse = res
			Socket.OnRequestEnd("farm.farmHandler.getShopInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] farm.farmHandler.getShopInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("farm.farmHandler.getShopInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getShopInfoRequestEncoder, getShopInfoRequestDecoder)
end


local function changeShopItemRequestEncoder(msg)
	local input = farmHandler_pb.ChangeShopItemRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function changeShopItemRequestDecoder(stream)
	local res = farmHandler_pb.ChangeShopItemResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FarmHandler.changeShopItemRequest(itemId,cb,option)
	local msg = {}
	msg.itemId = itemId
	Socket.OnRequestStart("farm.farmHandler.changeShopItemRequest", option)
	Socket.Request("farm.farmHandler.changeShopItemRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FarmHandler.lastChangeShopItemResponse = res
			Socket.OnRequestEnd("farm.farmHandler.changeShopItemRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] farm.farmHandler.changeShopItemRequest decode error!!"
			end
			Socket.OnRequestEnd("farm.farmHandler.changeShopItemRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, changeShopItemRequestEncoder, changeShopItemRequestDecoder)
end





return Pomelo
