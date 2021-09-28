





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "soloHandler_pb"


Pomelo = Pomelo or {}


Pomelo.SoloHandler = {}

local function soloInfoRequestEncoder(msg)
	local input = soloHandler_pb.SoloInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function soloInfoRequestDecoder(stream)
	local res = soloHandler_pb.SoloInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.SoloHandler.soloInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.soloHandler.soloInfoRequest", option)
	Socket.Request("area.soloHandler.soloInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.SoloHandler.lastSoloInfoResponse = res
			Socket.OnRequestEnd("area.soloHandler.soloInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.soloHandler.soloInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.soloHandler.soloInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, soloInfoRequestEncoder, soloInfoRequestDecoder)
end


local function rewardInfoRequestEncoder(msg)
	local input = soloHandler_pb.RewardInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function rewardInfoRequestDecoder(stream)
	local res = soloHandler_pb.RewardInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.SoloHandler.rewardInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.soloHandler.rewardInfoRequest", option)
	Socket.Request("area.soloHandler.rewardInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.SoloHandler.lastRewardInfoResponse = res
			Socket.OnRequestEnd("area.soloHandler.rewardInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.soloHandler.rewardInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.soloHandler.rewardInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, rewardInfoRequestEncoder, rewardInfoRequestDecoder)
end


local function drawRankRewardRequestEncoder(msg)
	local input = soloHandler_pb.DrawRankRewardRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function drawRankRewardRequestDecoder(stream)
	local res = soloHandler_pb.DrawRankRewardResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.SoloHandler.drawRankRewardRequest(c2s_rankId,cb,option)
	local msg = {}
	msg.c2s_rankId = c2s_rankId
	Socket.OnRequestStart("area.soloHandler.drawRankRewardRequest", option)
	Socket.Request("area.soloHandler.drawRankRewardRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.SoloHandler.lastDrawRankRewardResponse = res
			Socket.OnRequestEnd("area.soloHandler.drawRankRewardRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.soloHandler.drawRankRewardRequest decode error!!"
			end
			Socket.OnRequestEnd("area.soloHandler.drawRankRewardRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, drawRankRewardRequestEncoder, drawRankRewardRequestDecoder)
end


local function drawDailyRewardRequestEncoder(msg)
	local input = soloHandler_pb.DrawDailyRewardRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function drawDailyRewardRequestDecoder(stream)
	local res = soloHandler_pb.DrawDailyRewardResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.SoloHandler.drawDailyRewardRequest(c2s_index,cb,option)
	local msg = {}
	msg.c2s_index = c2s_index
	Socket.OnRequestStart("area.soloHandler.drawDailyRewardRequest", option)
	Socket.Request("area.soloHandler.drawDailyRewardRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.SoloHandler.lastDrawDailyRewardResponse = res
			Socket.OnRequestEnd("area.soloHandler.drawDailyRewardRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.soloHandler.drawDailyRewardRequest decode error!!"
			end
			Socket.OnRequestEnd("area.soloHandler.drawDailyRewardRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, drawDailyRewardRequestEncoder, drawDailyRewardRequestDecoder)
end


local function joinSoloRequestEncoder(msg)
	local input = soloHandler_pb.JoinSoloRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function joinSoloRequestDecoder(stream)
	local res = soloHandler_pb.JoinSoloResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.SoloHandler.joinSoloRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.soloHandler.joinSoloRequest", option)
	Socket.Request("area.soloHandler.joinSoloRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.SoloHandler.lastJoinSoloResponse = res
			Socket.OnRequestEnd("area.soloHandler.joinSoloRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.soloHandler.joinSoloRequest decode error!!"
			end
			Socket.OnRequestEnd("area.soloHandler.joinSoloRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, joinSoloRequestEncoder, joinSoloRequestDecoder)
end


local function joinSoloBattleRequestEncoder(msg)
	local input = soloHandler_pb.JoinSoloBattleRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function joinSoloBattleRequestDecoder(stream)
	local res = soloHandler_pb.JoinSoloBattleResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.SoloHandler.joinSoloBattleRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.soloHandler.joinSoloBattleRequest", option)
	Socket.Request("area.soloHandler.joinSoloBattleRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.SoloHandler.lastJoinSoloBattleResponse = res
			Socket.OnRequestEnd("area.soloHandler.joinSoloBattleRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.soloHandler.joinSoloBattleRequest decode error!!"
			end
			Socket.OnRequestEnd("area.soloHandler.joinSoloBattleRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, joinSoloBattleRequestEncoder, joinSoloBattleRequestDecoder)
end


local function quitSoloRequestEncoder(msg)
	local input = soloHandler_pb.QuitSoloRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function quitSoloRequestDecoder(stream)
	local res = soloHandler_pb.QuitSoloResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.SoloHandler.quitSoloRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.soloHandler.quitSoloRequest", option)
	Socket.Request("area.soloHandler.quitSoloRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.SoloHandler.lastQuitSoloResponse = res
			Socket.OnRequestEnd("area.soloHandler.quitSoloRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.soloHandler.quitSoloRequest decode error!!"
			end
			Socket.OnRequestEnd("area.soloHandler.quitSoloRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, quitSoloRequestEncoder, quitSoloRequestDecoder)
end


local function queryRewardRequestEncoder(msg)
	local input = soloHandler_pb.QueryRewardRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function queryRewardRequestDecoder(stream)
	local res = soloHandler_pb.QueryRewardResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.SoloHandler.queryRewardRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.soloHandler.queryRewardRequest", option)
	Socket.Request("area.soloHandler.queryRewardRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.SoloHandler.lastQueryRewardResponse = res
			Socket.OnRequestEnd("area.soloHandler.queryRewardRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.soloHandler.queryRewardRequest decode error!!"
			end
			Socket.OnRequestEnd("area.soloHandler.queryRewardRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, queryRewardRequestEncoder, queryRewardRequestDecoder)
end


local function leaveSoloAreaRequestEncoder(msg)
	local input = soloHandler_pb.LeaveSoloAreaRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function leaveSoloAreaRequestDecoder(stream)
	local res = soloHandler_pb.LeaveSoloAreaResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.SoloHandler.leaveSoloAreaRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.soloHandler.leaveSoloAreaRequest", option)
	Socket.Request("area.soloHandler.leaveSoloAreaRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.SoloHandler.lastLeaveSoloAreaResponse = res
			Socket.OnRequestEnd("area.soloHandler.leaveSoloAreaRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.soloHandler.leaveSoloAreaRequest decode error!!"
			end
			Socket.OnRequestEnd("area.soloHandler.leaveSoloAreaRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, leaveSoloAreaRequestEncoder, leaveSoloAreaRequestDecoder)
end


local function newsInfoRequestEncoder(msg)
	local input = soloHandler_pb.NewsInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function newsInfoRequestDecoder(stream)
	local res = soloHandler_pb.NewsInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.SoloHandler.newsInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.soloHandler.newsInfoRequest", option)
	Socket.Request("area.soloHandler.newsInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.SoloHandler.lastNewsInfoResponse = res
			Socket.OnRequestEnd("area.soloHandler.newsInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.soloHandler.newsInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.soloHandler.newsInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, newsInfoRequestEncoder, newsInfoRequestDecoder)
end


local function battleRecordRequestEncoder(msg)
	local input = soloHandler_pb.BattleRecordRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function battleRecordRequestDecoder(stream)
	local res = soloHandler_pb.BattleRecordResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.SoloHandler.battleRecordRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.soloHandler.battleRecordRequest", option)
	Socket.Request("area.soloHandler.battleRecordRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.SoloHandler.lastBattleRecordResponse = res
			Socket.OnRequestEnd("area.soloHandler.battleRecordRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.soloHandler.battleRecordRequest decode error!!"
			end
			Socket.OnRequestEnd("area.soloHandler.battleRecordRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, battleRecordRequestEncoder, battleRecordRequestDecoder)
end


local function getRivalInfoRequestEncoder(msg)
	local input = soloHandler_pb.Void()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getRivalInfoRequestDecoder(stream)
	local res = soloHandler_pb.GetRivalInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.SoloHandler.getRivalInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.soloHandler.getRivalInfoRequest", option)
	Socket.Request("area.soloHandler.getRivalInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.SoloHandler.lastGetRivalInfoResponse = res
			Socket.OnRequestEnd("area.soloHandler.getRivalInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.soloHandler.getRivalInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.soloHandler.getRivalInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getRivalInfoRequestEncoder, getRivalInfoRequestDecoder)
end


local function onSoloMatchedPushDecoder(stream)
	local res = soloHandler_pb.OnSoloMatchedPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.SoloHandler.onSoloMatchedPush(cb)
	Socket.On("area.soloPush.onSoloMatchedPush", function(res) 
		Pomelo.SoloHandler.lastOnSoloMatchedPush = res
		cb(nil,res) 
	end, onSoloMatchedPushDecoder) 
end


local function onNewRewardPushDecoder(stream)
	local res = soloHandler_pb.OnNewRewardPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.SoloHandler.onNewRewardPush(cb)
	Socket.On("area.soloPush.onNewRewardPush", function(res) 
		Pomelo.SoloHandler.lastOnNewRewardPush = res
		cb(nil,res) 
	end, onNewRewardPushDecoder) 
end


local function onFightPointPushDecoder(stream)
	local res = soloHandler_pb.OnFightPointPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.SoloHandler.onFightPointPush(cb)
	Socket.On("area.soloPush.onFightPointPush", function(res) 
		Pomelo.SoloHandler.lastOnFightPointPush = res
		cb(nil,res) 
	end, onFightPointPushDecoder) 
end


local function onRoundEndPushDecoder(stream)
	local res = soloHandler_pb.OnRoundEndPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.SoloHandler.onRoundEndPush(cb)
	Socket.On("area.soloPush.onRoundEndPush", function(res) 
		Pomelo.SoloHandler.lastOnRoundEndPush = res
		cb(nil,res) 
	end, onRoundEndPushDecoder) 
end


local function onGameEndPushDecoder(stream)
	local res = soloHandler_pb.OnGameEndPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.SoloHandler.onGameEndPush(cb)
	Socket.On("area.soloPush.onGameEndPush", function(res) 
		Pomelo.SoloHandler.lastOnGameEndPush = res
		cb(nil,res) 
	end, onGameEndPushDecoder) 
end


local function leftSoloTimePushDecoder(stream)
	local res = soloHandler_pb.LeftSoloTimePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.SoloHandler.leftSoloTimePush(cb)
	Socket.On("area.soloPush.leftSoloTimePush", function(res) 
		Pomelo.SoloHandler.lastLeftSoloTimePush = res
		cb(nil,res) 
	end, leftSoloTimePushDecoder) 
end


local function cancelMatchPushDecoder(stream)
	local res = soloHandler_pb.CancelMatchPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.SoloHandler.cancelMatchPush(cb)
	Socket.On("area.soloPush.cancelMatchPush", function(res) 
		Pomelo.SoloHandler.lastCancelMatchPush = res
		cb(nil,res) 
	end, cancelMatchPushDecoder) 
end





return Pomelo
