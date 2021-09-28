





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "resourceDungeonHandler_pb"


Pomelo = Pomelo or {}


Pomelo.ResourceDungeonHandler = {}

local function queryResourceDugeonInfoRequestEncoder(msg)
	local input = resourceDungeonHandler_pb.QueryResourceDugeonInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function queryResourceDugeonInfoRequestDecoder(stream)
	local res = resourceDungeonHandler_pb.QueryResourceDugeonInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ResourceDungeonHandler.queryResourceDugeonInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.resourceDungeonHandler.queryResourceDugeonInfoRequest", option)
	Socket.Request("area.resourceDungeonHandler.queryResourceDugeonInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ResourceDungeonHandler.lastQueryResourceDugeonInfoResponse = res
			Socket.OnRequestEnd("area.resourceDungeonHandler.queryResourceDugeonInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.resourceDungeonHandler.queryResourceDugeonInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.resourceDungeonHandler.queryResourceDugeonInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, queryResourceDugeonInfoRequestEncoder, queryResourceDugeonInfoRequestDecoder)
end


local function buyTimesRequestEncoder(msg)
	local input = resourceDungeonHandler_pb.BuyTimesRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function buyTimesRequestDecoder(stream)
	local res = resourceDungeonHandler_pb.BuyTimesResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ResourceDungeonHandler.buyTimesRequest(dungeonId,cb,option)
	local msg = {}
	msg.dungeonId = dungeonId
	Socket.OnRequestStart("area.resourceDungeonHandler.buyTimesRequest", option)
	Socket.Request("area.resourceDungeonHandler.buyTimesRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ResourceDungeonHandler.lastBuyTimesResponse = res
			Socket.OnRequestEnd("area.resourceDungeonHandler.buyTimesRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.resourceDungeonHandler.buyTimesRequest decode error!!"
			end
			Socket.OnRequestEnd("area.resourceDungeonHandler.buyTimesRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, buyTimesRequestEncoder, buyTimesRequestDecoder)
end


local function enterResourceDugeonInfoRequestEncoder(msg)
	local input = resourceDungeonHandler_pb.EnterResourceDugeonInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function enterResourceDugeonInfoRequestDecoder(stream)
	local res = resourceDungeonHandler_pb.EnterResourceDugeonInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ResourceDungeonHandler.enterResourceDugeonInfoRequest(dungeonId,cb,option)
	local msg = {}
	msg.dungeonId = dungeonId
	Socket.OnRequestStart("area.resourceDungeonHandler.enterResourceDugeonInfoRequest", option)
	Socket.Request("area.resourceDungeonHandler.enterResourceDugeonInfoRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ResourceDungeonHandler.lastEnterResourceDugeonInfoResponse = res
			Socket.OnRequestEnd("area.resourceDungeonHandler.enterResourceDugeonInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.resourceDungeonHandler.enterResourceDugeonInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.resourceDungeonHandler.enterResourceDugeonInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, enterResourceDugeonInfoRequestEncoder, enterResourceDugeonInfoRequestDecoder)
end


local function receiveDoubleRewardRequestEncoder(msg)
	local input = resourceDungeonHandler_pb.ReceiveDoubleRewardRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function receiveDoubleRewardRequestDecoder(stream)
	local res = resourceDungeonHandler_pb.ReceiveDoubleRewardResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ResourceDungeonHandler.receiveDoubleRewardRequest(dungeonId,cb,option)
	local msg = {}
	msg.dungeonId = dungeonId
	Socket.OnRequestStart("area.resourceDungeonHandler.receiveDoubleRewardRequest", option)
	Socket.Request("area.resourceDungeonHandler.receiveDoubleRewardRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ResourceDungeonHandler.lastReceiveDoubleRewardResponse = res
			Socket.OnRequestEnd("area.resourceDungeonHandler.receiveDoubleRewardRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.resourceDungeonHandler.receiveDoubleRewardRequest decode error!!"
			end
			Socket.OnRequestEnd("area.resourceDungeonHandler.receiveDoubleRewardRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, receiveDoubleRewardRequestEncoder, receiveDoubleRewardRequestDecoder)
end


local function resourceCountDownRequestEncoder(msg)
	local input = resourceDungeonHandler_pb.ResourceCountDownRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function resourceCountDownRequestDecoder(stream)
	local res = resourceDungeonHandler_pb.ResourceCountDownResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ResourceDungeonHandler.resourceCountDownRequest(dungeonId,cb,option)
	local msg = {}
	msg.dungeonId = dungeonId
	Socket.OnRequestStart("area.resourceDungeonHandler.resourceCountDownRequest", option)
	Socket.Request("area.resourceDungeonHandler.resourceCountDownRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ResourceDungeonHandler.lastResourceCountDownResponse = res
			Socket.OnRequestEnd("area.resourceDungeonHandler.resourceCountDownRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.resourceDungeonHandler.resourceCountDownRequest decode error!!"
			end
			Socket.OnRequestEnd("area.resourceDungeonHandler.resourceCountDownRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, resourceCountDownRequestEncoder, resourceCountDownRequestDecoder)
end


local function resourceSweepRequestEncoder(msg)
	local input = resourceDungeonHandler_pb.ResourceSweepRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function resourceSweepRequestDecoder(stream)
	local res = resourceDungeonHandler_pb.ResourceSweepResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ResourceDungeonHandler.resourceSweepRequest(dungeonId,cb,option)
	local msg = {}
	msg.dungeonId = dungeonId
	Socket.OnRequestStart("area.resourceDungeonHandler.resourceSweepRequest", option)
	Socket.Request("area.resourceDungeonHandler.resourceSweepRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ResourceDungeonHandler.lastResourceSweepResponse = res
			Socket.OnRequestEnd("area.resourceDungeonHandler.resourceSweepRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.resourceDungeonHandler.resourceSweepRequest decode error!!"
			end
			Socket.OnRequestEnd("area.resourceDungeonHandler.resourceSweepRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, resourceSweepRequestEncoder, resourceSweepRequestDecoder)
end





return Pomelo
