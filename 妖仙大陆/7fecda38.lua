





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "rewardHandler_pb"


Pomelo = Pomelo or {}


Pomelo.RewardHandler = {}

local function rewardDeskRequestEncoder(msg)
	local input = rewardHandler_pb.RewardDeskRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function rewardDeskRequestDecoder(stream)
	local res = rewardHandler_pb.RewardDeskResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.RewardHandler.rewardDeskRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.rewardHandler.rewardDeskRequest", option)
	Socket.Request("area.rewardHandler.rewardDeskRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.RewardHandler.lastRewardDeskResponse = res
			Socket.OnRequestEnd("area.rewardHandler.rewardDeskRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.rewardHandler.rewardDeskRequest decode error!!"
			end
			Socket.OnRequestEnd("area.rewardHandler.rewardDeskRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, rewardDeskRequestEncoder, rewardDeskRequestDecoder)
end


local function rewardRequestEncoder(msg)
	local input = rewardHandler_pb.RewardRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function rewardRequestDecoder(stream)
	local res = rewardHandler_pb.RewardResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.RewardHandler.rewardRequest(c2s_playerName,cb,option)
	local msg = {}
	msg.c2s_playerName = c2s_playerName
	Socket.OnRequestStart("area.rewardHandler.rewardRequest", option)
	Socket.Request("area.rewardHandler.rewardRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.RewardHandler.lastRewardResponse = res
			Socket.OnRequestEnd("area.rewardHandler.rewardRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.rewardHandler.rewardRequest decode error!!"
			end
			Socket.OnRequestEnd("area.rewardHandler.rewardRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, rewardRequestEncoder, rewardRequestDecoder)
end


local function checkBountyRequestEncoder(msg)
	local input = rewardHandler_pb.CheckBountyRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function checkBountyRequestDecoder(stream)
	local res = rewardHandler_pb.CheckBountyResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.RewardHandler.checkBountyRequest(c2s_index,cb,option)
	local msg = {}
	msg.c2s_index = c2s_index
	Socket.OnRequestStart("area.rewardHandler.checkBountyRequest", option)
	Socket.Request("area.rewardHandler.checkBountyRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.RewardHandler.lastCheckBountyResponse = res
			Socket.OnRequestEnd("area.rewardHandler.checkBountyRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.rewardHandler.checkBountyRequest decode error!!"
			end
			Socket.OnRequestEnd("area.rewardHandler.checkBountyRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, checkBountyRequestEncoder, checkBountyRequestDecoder)
end


local function getHasFinishRequestEncoder(msg)
	local input = rewardHandler_pb.FinishRewardRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getHasFinishRequestDecoder(stream)
	local res = rewardHandler_pb.FinishRewardResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.RewardHandler.getHasFinishRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.rewardHandler.getHasFinishRequest", option)
	Socket.Request("area.rewardHandler.getHasFinishRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.RewardHandler.lastFinishRewardResponse = res
			Socket.OnRequestEnd("area.rewardHandler.getHasFinishRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.rewardHandler.getHasFinishRequest decode error!!"
			end
			Socket.OnRequestEnd("area.rewardHandler.getHasFinishRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getHasFinishRequestEncoder, getHasFinishRequestDecoder)
end


local function getAwardBountyRequestEncoder(msg)
	local input = rewardHandler_pb.GetAwardBountyRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getAwardBountyRequestDecoder(stream)
	local res = rewardHandler_pb.GetAwardBountyResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.RewardHandler.getAwardBountyRequest(c2s_preyId,c2s_hunterId,c2s_bounty,cb,option)
	local msg = {}
	msg.c2s_preyId = c2s_preyId
	msg.c2s_hunterId = c2s_hunterId
	msg.c2s_bounty = c2s_bounty
	Socket.OnRequestStart("area.rewardHandler.getAwardBountyRequest", option)
	Socket.Request("area.rewardHandler.getAwardBountyRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.RewardHandler.lastGetAwardBountyResponse = res
			Socket.OnRequestEnd("area.rewardHandler.getAwardBountyRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.rewardHandler.getAwardBountyRequest decode error!!"
			end
			Socket.OnRequestEnd("area.rewardHandler.getAwardBountyRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getAwardBountyRequestEncoder, getAwardBountyRequestDecoder)
end





return Pomelo
