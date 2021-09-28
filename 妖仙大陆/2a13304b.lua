





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "vitalityHandler_pb"


Pomelo = Pomelo or {}


Pomelo.VitalityHandler = {}

local function getVitalityListRequestEncoder(msg)
	local input = vitalityHandler_pb.GetVitalityListRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getVitalityListRequestDecoder(stream)
	local res = vitalityHandler_pb.GetVitalityListResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.VitalityHandler.getVitalityListRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.vitalityHandler.getVitalityListRequest", option)
	Socket.Request("area.vitalityHandler.getVitalityListRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.VitalityHandler.lastGetVitalityListResponse = res
			Socket.OnRequestEnd("area.vitalityHandler.getVitalityListRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.vitalityHandler.getVitalityListRequest decode error!!"
			end
			Socket.OnRequestEnd("area.vitalityHandler.getVitalityListRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getVitalityListRequestEncoder, getVitalityListRequestDecoder)
end


local function getVitalityRewardRequestEncoder(msg)
	local input = vitalityHandler_pb.GetVitalityRewardRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getVitalityRewardRequestDecoder(stream)
	local res = vitalityHandler_pb.GetVitalityRewardResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.VitalityHandler.getVitalityRewardRequest(c2s_rewardId,cb,option)
	local msg = {}
	msg.c2s_rewardId = c2s_rewardId
	Socket.OnRequestStart("area.vitalityHandler.getVitalityRewardRequest", option)
	Socket.Request("area.vitalityHandler.getVitalityRewardRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.VitalityHandler.lastGetVitalityRewardResponse = res
			Socket.OnRequestEnd("area.vitalityHandler.getVitalityRewardRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.vitalityHandler.getVitalityRewardRequest decode error!!"
			end
			Socket.OnRequestEnd("area.vitalityHandler.getVitalityRewardRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getVitalityRewardRequestEncoder, getVitalityRewardRequestDecoder)
end


local function getRecommendPlayListRequestEncoder(msg)
	local input = vitalityHandler_pb.GetRecommendPlayListRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getRecommendPlayListRequestDecoder(stream)
	local res = vitalityHandler_pb.GetRecommendPlayListResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.VitalityHandler.getRecommendPlayListRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.vitalityHandler.getRecommendPlayListRequest", option)
	Socket.Request("area.vitalityHandler.getRecommendPlayListRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.VitalityHandler.lastGetRecommendPlayListResponse = res
			Socket.OnRequestEnd("area.vitalityHandler.getRecommendPlayListRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.vitalityHandler.getRecommendPlayListRequest decode error!!"
			end
			Socket.OnRequestEnd("area.vitalityHandler.getRecommendPlayListRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getRecommendPlayListRequestEncoder, getRecommendPlayListRequestDecoder)
end





return Pomelo
