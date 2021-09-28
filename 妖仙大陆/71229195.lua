





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "leaderBoardHandler_pb"


Pomelo = Pomelo or {}


Pomelo.LeaderBoardHandler = {}

local function leaderBoardRequestEncoder(msg)
	local input = leaderBoardHandler_pb.LeaderBoardRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function leaderBoardRequestDecoder(stream)
	local res = leaderBoardHandler_pb.LeaderBoardResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.LeaderBoardHandler.leaderBoardRequest(c2s_kind,c2s_season,cb,option)
	local msg = {}
	msg.c2s_kind = c2s_kind
	msg.c2s_season = c2s_season
	Socket.OnRequestStart("area.leaderBoardHandler.leaderBoardRequest", option)
	Socket.Request("area.leaderBoardHandler.leaderBoardRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.LeaderBoardHandler.lastLeaderBoardResponse = res
			Socket.OnRequestEnd("area.leaderBoardHandler.leaderBoardRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.leaderBoardHandler.leaderBoardRequest decode error!!"
			end
			Socket.OnRequestEnd("area.leaderBoardHandler.leaderBoardRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, leaderBoardRequestEncoder, leaderBoardRequestDecoder)
end


local function guildInfoRequestEncoder(msg)
	local input = leaderBoardHandler_pb.GuildInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function guildInfoRequestDecoder(stream)
	local res = leaderBoardHandler_pb.GuildInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.LeaderBoardHandler.guildInfoRequest(c2s_guildId,cb,option)
	local msg = {}
	msg.c2s_guildId = c2s_guildId
	Socket.OnRequestStart("area.leaderBoardHandler.guildInfoRequest", option)
	Socket.Request("area.leaderBoardHandler.guildInfoRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.LeaderBoardHandler.lastGuildInfoResponse = res
			Socket.OnRequestEnd("area.leaderBoardHandler.guildInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.leaderBoardHandler.guildInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.leaderBoardHandler.guildInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, guildInfoRequestEncoder, guildInfoRequestDecoder)
end


local function worShipRequestEncoder(msg)
	local input = leaderBoardHandler_pb.WorShipRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function worShipRequestDecoder(stream)
	local res = leaderBoardHandler_pb.WorShipResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.LeaderBoardHandler.worShipRequest(c2s_type,cb,option)
	local msg = {}
	msg.c2s_type = c2s_type
	Socket.OnRequestStart("area.leaderBoardHandler.worShipRequest", option)
	Socket.Request("area.leaderBoardHandler.worShipRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.LeaderBoardHandler.lastWorShipResponse = res
			Socket.OnRequestEnd("area.leaderBoardHandler.worShipRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.leaderBoardHandler.worShipRequest decode error!!"
			end
			Socket.OnRequestEnd("area.leaderBoardHandler.worShipRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, worShipRequestEncoder, worShipRequestDecoder)
end


local function worldLevelInfoRequestEncoder(msg)
	local input = leaderBoardHandler_pb.WorldLevelInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function worldLevelInfoRequestDecoder(stream)
	local res = leaderBoardHandler_pb.WorldLevelInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.LeaderBoardHandler.worldLevelInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.leaderBoardHandler.worldLevelInfoRequest", option)
	Socket.Request("area.leaderBoardHandler.worldLevelInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.LeaderBoardHandler.lastWorldLevelInfoResponse = res
			Socket.OnRequestEnd("area.leaderBoardHandler.worldLevelInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.leaderBoardHandler.worldLevelInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.leaderBoardHandler.worldLevelInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, worldLevelInfoRequestEncoder, worldLevelInfoRequestDecoder)
end





return Pomelo
