





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "five2FiveHandler_pb"


Pomelo = Pomelo or {}


Pomelo.Five2FiveHandler = {}

local function five2FiveRequestEncoder(msg)
	local input = five2FiveHandler_pb.Five2FiveRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function five2FiveRequestDecoder(stream)
	local res = five2FiveHandler_pb.Five2FiveResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.Five2FiveHandler.five2FiveRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("five2five.five2FiveHandler.five2FiveRequest", option)
	Socket.Request("five2five.five2FiveHandler.five2FiveRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.Five2FiveHandler.lastFive2FiveResponse = res
			Socket.OnRequestEnd("five2five.five2FiveHandler.five2FiveRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] five2five.five2FiveHandler.five2FiveRequest decode error!!"
			end
			Socket.OnRequestEnd("five2five.five2FiveHandler.five2FiveRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, five2FiveRequestEncoder, five2FiveRequestDecoder)
end


local function five2FiveLookBtlReportRequestEncoder(msg)
	local input = five2FiveHandler_pb.Five2FiveLookBtlReportRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function five2FiveLookBtlReportRequestDecoder(stream)
	local res = five2FiveHandler_pb.Five2FiveLookBtlReportResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.Five2FiveHandler.five2FiveLookBtlReportRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("five2five.five2FiveHandler.five2FiveLookBtlReportRequest", option)
	Socket.Request("five2five.five2FiveHandler.five2FiveLookBtlReportRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.Five2FiveHandler.lastFive2FiveLookBtlReportResponse = res
			Socket.OnRequestEnd("five2five.five2FiveHandler.five2FiveLookBtlReportRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] five2five.five2FiveHandler.five2FiveLookBtlReportRequest decode error!!"
			end
			Socket.OnRequestEnd("five2five.five2FiveHandler.five2FiveLookBtlReportRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, five2FiveLookBtlReportRequestEncoder, five2FiveLookBtlReportRequestDecoder)
end


local function five2FiveMatchRequestEncoder(msg)
	local input = five2FiveHandler_pb.Five2FiveMatchRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function five2FiveMatchRequestDecoder(stream)
	local res = five2FiveHandler_pb.Five2FiveMatchResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.Five2FiveHandler.five2FiveMatchRequest(matchOrReMatch,cb,option)
	local msg = {}
	msg.matchOrReMatch = matchOrReMatch
	Socket.OnRequestStart("five2five.five2FiveHandler.five2FiveMatchRequest", option)
	Socket.Request("five2five.five2FiveHandler.five2FiveMatchRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.Five2FiveHandler.lastFive2FiveMatchResponse = res
			Socket.OnRequestEnd("five2five.five2FiveHandler.five2FiveMatchRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] five2five.five2FiveHandler.five2FiveMatchRequest decode error!!"
			end
			Socket.OnRequestEnd("five2five.five2FiveHandler.five2FiveMatchRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, five2FiveMatchRequestEncoder, five2FiveMatchRequestDecoder)
end


local function five2FiveRefuseMatchRequestEncoder(msg)
	local input = five2FiveHandler_pb.Five2FiveRefuseMatchRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function five2FiveRefuseMatchRequestDecoder(stream)
	local res = five2FiveHandler_pb.Five2FiveRefuseMatchResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.Five2FiveHandler.five2FiveRefuseMatchRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("five2five.five2FiveHandler.five2FiveRefuseMatchRequest", option)
	Socket.Request("five2five.five2FiveHandler.five2FiveRefuseMatchRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.Five2FiveHandler.lastFive2FiveRefuseMatchResponse = res
			Socket.OnRequestEnd("five2five.five2FiveHandler.five2FiveRefuseMatchRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] five2five.five2FiveHandler.five2FiveRefuseMatchRequest decode error!!"
			end
			Socket.OnRequestEnd("five2five.five2FiveHandler.five2FiveRefuseMatchRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, five2FiveRefuseMatchRequestEncoder, five2FiveRefuseMatchRequestDecoder)
end


local function five2FiveAgreeMatchRequestEncoder(msg)
	local input = five2FiveHandler_pb.Five2FiveAgreeMatchRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function five2FiveAgreeMatchRequestDecoder(stream)
	local res = five2FiveHandler_pb.Five2FiveAgreeMatchResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.Five2FiveHandler.five2FiveAgreeMatchRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("five2five.five2FiveHandler.five2FiveAgreeMatchRequest", option)
	Socket.Request("five2five.five2FiveHandler.five2FiveAgreeMatchRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.Five2FiveHandler.lastFive2FiveAgreeMatchResponse = res
			Socket.OnRequestEnd("five2five.five2FiveHandler.five2FiveAgreeMatchRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] five2five.five2FiveHandler.five2FiveAgreeMatchRequest decode error!!"
			end
			Socket.OnRequestEnd("five2five.five2FiveHandler.five2FiveAgreeMatchRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, five2FiveAgreeMatchRequestEncoder, five2FiveAgreeMatchRequestDecoder)
end


local function five2FiveCancelMatchRequestEncoder(msg)
	local input = five2FiveHandler_pb.Five2FiveCancelMatchRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function five2FiveCancelMatchRequestDecoder(stream)
	local res = five2FiveHandler_pb.Five2FiveCancelMatchResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.Five2FiveHandler.five2FiveCancelMatchRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("five2five.five2FiveHandler.five2FiveCancelMatchRequest", option)
	Socket.Request("five2five.five2FiveHandler.five2FiveCancelMatchRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.Five2FiveHandler.lastFive2FiveCancelMatchResponse = res
			Socket.OnRequestEnd("five2five.five2FiveHandler.five2FiveCancelMatchRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] five2five.five2FiveHandler.five2FiveCancelMatchRequest decode error!!"
			end
			Socket.OnRequestEnd("five2five.five2FiveHandler.five2FiveCancelMatchRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, five2FiveCancelMatchRequestEncoder, five2FiveCancelMatchRequestDecoder)
end


local function five2FiveReadyRequestEncoder(msg)
	local input = five2FiveHandler_pb.Five2FiveReadyRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function five2FiveReadyRequestDecoder(stream)
	local res = five2FiveHandler_pb.Five2FiveReadyResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.Five2FiveHandler.five2FiveReadyRequest(tempTeamId,cb,option)
	local msg = {}
	msg.tempTeamId = tempTeamId
	Socket.OnRequestStart("five2five.five2FiveHandler.five2FiveReadyRequest", option)
	Socket.Request("five2five.five2FiveHandler.five2FiveReadyRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.Five2FiveHandler.lastFive2FiveReadyResponse = res
			Socket.OnRequestEnd("five2five.five2FiveHandler.five2FiveReadyRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] five2five.five2FiveHandler.five2FiveReadyRequest decode error!!"
			end
			Socket.OnRequestEnd("five2five.five2FiveHandler.five2FiveReadyRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, five2FiveReadyRequestEncoder, five2FiveReadyRequestDecoder)
end


local function five2FiveLeaveAreaRequestEncoder(msg)
	local input = five2FiveHandler_pb.Five2FiveLeaveAreaRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function five2FiveLeaveAreaRequestDecoder(stream)
	local res = five2FiveHandler_pb.Five2FiveLeaveAreaResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.Five2FiveHandler.five2FiveLeaveAreaRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("five2five.five2FiveHandler.five2FiveLeaveAreaRequest", option)
	Socket.Request("five2five.five2FiveHandler.five2FiveLeaveAreaRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.Five2FiveHandler.lastFive2FiveLeaveAreaResponse = res
			Socket.OnRequestEnd("five2five.five2FiveHandler.five2FiveLeaveAreaRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] five2five.five2FiveHandler.five2FiveLeaveAreaRequest decode error!!"
			end
			Socket.OnRequestEnd("five2five.five2FiveHandler.five2FiveLeaveAreaRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, five2FiveLeaveAreaRequestEncoder, five2FiveLeaveAreaRequestDecoder)
end


local function five2FiveReciveRewardRequestEncoder(msg)
	local input = five2FiveHandler_pb.Five2FiveReciveRewardRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function five2FiveReciveRewardRequestDecoder(stream)
	local res = five2FiveHandler_pb.Five2FiveReciveRewardResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.Five2FiveHandler.five2FiveReciveRewardRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("five2five.five2FiveHandler.five2FiveReciveRewardRequest", option)
	Socket.Request("five2five.five2FiveHandler.five2FiveReciveRewardRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.Five2FiveHandler.lastFive2FiveReciveRewardResponse = res
			Socket.OnRequestEnd("five2five.five2FiveHandler.five2FiveReciveRewardRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] five2five.five2FiveHandler.five2FiveReciveRewardRequest decode error!!"
			end
			Socket.OnRequestEnd("five2five.five2FiveHandler.five2FiveReciveRewardRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, five2FiveReciveRewardRequestEncoder, five2FiveReciveRewardRequestDecoder)
end


local function five2FiveLookMatchResultRequestEncoder(msg)
	local input = five2FiveHandler_pb.Five2FiveLookMatchResultRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function five2FiveLookMatchResultRequestDecoder(stream)
	local res = five2FiveHandler_pb.Five2FiveLookMatchResultResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.Five2FiveHandler.five2FiveLookMatchResultRequest(instanceId,cb,option)
	local msg = {}
	msg.instanceId = instanceId
	Socket.OnRequestStart("five2five.five2FiveHandler.five2FiveLookMatchResultRequest", option)
	Socket.Request("five2five.five2FiveHandler.five2FiveLookMatchResultRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.Five2FiveHandler.lastFive2FiveLookMatchResultResponse = res
			Socket.OnRequestEnd("five2five.five2FiveHandler.five2FiveLookMatchResultRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] five2five.five2FiveHandler.five2FiveLookMatchResultRequest decode error!!"
			end
			Socket.OnRequestEnd("five2five.five2FiveHandler.five2FiveLookMatchResultRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, five2FiveLookMatchResultRequestEncoder, five2FiveLookMatchResultRequestDecoder)
end


local function five2FiveShardMatchResultRequestEncoder(msg)
	local input = five2FiveHandler_pb.Five2FiveShardMatchResultRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function five2FiveShardMatchResultRequestDecoder(stream)
	local res = five2FiveHandler_pb.Five2FiveShardMatchResultResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.Five2FiveHandler.five2FiveShardMatchResultRequest(instanceId,cb,option)
	local msg = {}
	msg.instanceId = instanceId
	Socket.OnRequestStart("five2five.five2FiveHandler.five2FiveShardMatchResultRequest", option)
	Socket.Request("five2five.five2FiveHandler.five2FiveShardMatchResultRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.Five2FiveHandler.lastFive2FiveShardMatchResultResponse = res
			Socket.OnRequestEnd("five2five.five2FiveHandler.five2FiveShardMatchResultRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] five2five.five2FiveHandler.five2FiveShardMatchResultRequest decode error!!"
			end
			Socket.OnRequestEnd("five2five.five2FiveHandler.five2FiveShardMatchResultRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, five2FiveShardMatchResultRequestEncoder, five2FiveShardMatchResultRequestDecoder)
end


local function five2FiveApplyMatchPushDecoder(stream)
	local res = five2FiveHandler_pb.Five2FiveApplyMatchPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.Five2FiveHandler.five2FiveApplyMatchPush(cb)
	Socket.On("five2five.five2FivePush.five2FiveApplyMatchPush", function(res) 
		Pomelo.Five2FiveHandler.lastFive2FiveApplyMatchPush = res
		cb(nil,res) 
	end, five2FiveApplyMatchPushDecoder) 
end


local function five2FiveMatchMemberInfoPushDecoder(stream)
	local res = five2FiveHandler_pb.Five2FiveMatchMemberInfoPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.Five2FiveHandler.five2FiveMatchMemberInfoPush(cb)
	Socket.On("five2five.five2FivePush.five2FiveMatchMemberInfoPush", function(res) 
		Pomelo.Five2FiveHandler.lastFive2FiveMatchMemberInfoPush = res
		cb(nil,res) 
	end, five2FiveMatchMemberInfoPushDecoder) 
end


local function five2FiveMemberChoicePushDecoder(stream)
	local res = five2FiveHandler_pb.Five2FiveMemberChoicePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.Five2FiveHandler.five2FiveMemberChoicePush(cb)
	Socket.On("five2five.five2FivePush.five2FiveMemberChoicePush", function(res) 
		Pomelo.Five2FiveHandler.lastFive2FiveMemberChoicePush = res
		cb(nil,res) 
	end, five2FiveMemberChoicePushDecoder) 
end


local function five2FiveOnGameEndPushDecoder(stream)
	local res = five2FiveHandler_pb.Five2FiveOnGameEndPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.Five2FiveHandler.five2FiveOnGameEndPush(cb)
	Socket.On("five2five.five2FivePush.five2FiveOnGameEndPush", function(res) 
		Pomelo.Five2FiveHandler.lastFive2FiveOnGameEndPush = res
		cb(nil,res) 
	end, five2FiveOnGameEndPushDecoder) 
end


local function five2FiveOnNewRewardPushDecoder(stream)
	local res = five2FiveHandler_pb.Five2FiveOnNewRewardPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.Five2FiveHandler.five2FiveOnNewRewardPush(cb)
	Socket.On("five2five.five2FivePush.five2FiveOnNewRewardPush", function(res) 
		Pomelo.Five2FiveHandler.lastFive2FiveOnNewRewardPush = res
		cb(nil,res) 
	end, five2FiveOnNewRewardPushDecoder) 
end


local function five2FiveOnNoRewardPushDecoder(stream)
	local res = five2FiveHandler_pb.Five2FiveOnNoRewardPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.Five2FiveHandler.five2FiveOnNoRewardPush(cb)
	Socket.On("five2five.five2FivePush.five2FiveOnNoRewardPush", function(res) 
		Pomelo.Five2FiveHandler.lastFive2FiveOnNoRewardPush = res
		cb(nil,res) 
	end, five2FiveOnNoRewardPushDecoder) 
end


local function five2FiveMatchFailedPushDecoder(stream)
	local res = five2FiveHandler_pb.Five2FiveMatchFailedPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.Five2FiveHandler.five2FiveMatchFailedPush(cb)
	Socket.On("five2five.five2FivePush.five2FiveMatchFailedPush", function(res) 
		Pomelo.Five2FiveHandler.lastFive2FiveMatchFailedPush = res
		cb(nil,res) 
	end, five2FiveMatchFailedPushDecoder) 
end


local function five2FiveLeaderCancelMatchPushDecoder(stream)
	local res = five2FiveHandler_pb.Five2FiveLeaderCancelMatchPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.Five2FiveHandler.five2FiveLeaderCancelMatchPush(cb)
	Socket.On("five2five.five2FivePush.five2FiveLeaderCancelMatchPush", function(res) 
		Pomelo.Five2FiveHandler.lastFive2FiveLeaderCancelMatchPush = res
		cb(nil,res) 
	end, five2FiveLeaderCancelMatchPushDecoder) 
end


local function five2FiveTeamChangePushDecoder(stream)
	local res = five2FiveHandler_pb.Five2FiveTeamChangePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.Five2FiveHandler.five2FiveTeamChangePush(cb)
	Socket.On("five2five.five2FivePush.five2FiveTeamChangePush", function(res) 
		Pomelo.Five2FiveHandler.lastFive2FiveTeamChangePush = res
		cb(nil,res) 
	end, five2FiveTeamChangePushDecoder) 
end


local function five2FiveMatchPoolChangePushDecoder(stream)
	local res = five2FiveHandler_pb.Five2FiveMatchPoolChangePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.Five2FiveHandler.five2FiveMatchPoolChangePush(cb)
	Socket.On("five2five.five2FivePush.five2FiveMatchPoolChangePush", function(res) 
		Pomelo.Five2FiveHandler.lastFive2FiveMatchPoolChangePush = res
		cb(nil,res) 
	end, five2FiveMatchPoolChangePushDecoder) 
end


local function five2FiveApplyMatchResultPushDecoder(stream)
	local res = five2FiveHandler_pb.Five2FiveApplyMatchResultPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.Five2FiveHandler.five2FiveApplyMatchResultPush(cb)
	Socket.On("five2five.five2FivePush.five2FiveApplyMatchResultPush", function(res) 
		Pomelo.Five2FiveHandler.lastFive2FiveApplyMatchResultPush = res
		cb(nil,res) 
	end, five2FiveApplyMatchResultPushDecoder) 
end





return Pomelo
