





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "teamHandler_pb"


Pomelo = Pomelo or {}


Pomelo.TeamHandler = {}

local function gotoTeamTargetRequestEncoder(msg)
	local input = teamHandler_pb.GotoTeamTargetRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function gotoTeamTargetRequestDecoder(stream)
	local res = teamHandler_pb.GotoTeamTargetResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.TeamHandler.gotoTeamTargetRequest(targetId,difficulty,cb,option)
	local msg = {}
	msg.targetId = targetId
	msg.difficulty = difficulty
	Socket.OnRequestStart("area.teamHandler.gotoTeamTargetRequest", option)
	Socket.Request("area.teamHandler.gotoTeamTargetRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.TeamHandler.lastGotoTeamTargetResponse = res
			Socket.OnRequestEnd("area.teamHandler.gotoTeamTargetRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.teamHandler.gotoTeamTargetRequest decode error!!"
			end
			Socket.OnRequestEnd("area.teamHandler.gotoTeamTargetRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, gotoTeamTargetRequestEncoder, gotoTeamTargetRequestDecoder)
end


local function summonRequestEncoder(msg)
	local input = teamHandler_pb.SummonRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function summonRequestDecoder(stream)
	local res = teamHandler_pb.SummonResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.TeamHandler.summonRequest(c2s_teamMemberId,cb,option)
	local msg = {}
	msg.c2s_teamMemberId = c2s_teamMemberId
	Socket.OnRequestStart("area.teamHandler.summonRequest", option)
	Socket.Request("area.teamHandler.summonRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.TeamHandler.lastSummonResponse = res
			Socket.OnRequestEnd("area.teamHandler.summonRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.teamHandler.summonRequest decode error!!"
			end
			Socket.OnRequestEnd("area.teamHandler.summonRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, summonRequestEncoder, summonRequestDecoder)
end


local function summonConfirmRequestEncoder(msg)
	local input = teamHandler_pb.SummonConfirmRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function summonConfirmRequestDecoder(stream)
	local res = teamHandler_pb.SummonConfirmResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.TeamHandler.summonConfirmRequest(c2s_id,s2c_operate,cb,option)
	local msg = {}
	msg.c2s_id = c2s_id
	msg.s2c_operate = s2c_operate
	Socket.OnRequestStart("area.teamHandler.summonConfirmRequest", option)
	Socket.Request("area.teamHandler.summonConfirmRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.TeamHandler.lastSummonConfirmResponse = res
			Socket.OnRequestEnd("area.teamHandler.summonConfirmRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.teamHandler.summonConfirmRequest decode error!!"
			end
			Socket.OnRequestEnd("area.teamHandler.summonConfirmRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, summonConfirmRequestEncoder, summonConfirmRequestDecoder)
end


local function autoJoinTeamRequestEncoder(msg)
	local input = teamHandler_pb.AutoJoinTeamRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function autoJoinTeamRequestDecoder(stream)
	local res = teamHandler_pb.AutoJoinTeamResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.TeamHandler.autoJoinTeamRequest(c2s_targetId,c2s_difficulty,cb,option)
	local msg = {}
	msg.c2s_targetId = c2s_targetId
	msg.c2s_difficulty = c2s_difficulty
	Socket.OnRequestStart("area.teamHandler.autoJoinTeamRequest", option)
	Socket.Request("area.teamHandler.autoJoinTeamRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.TeamHandler.lastAutoJoinTeamResponse = res
			Socket.OnRequestEnd("area.teamHandler.autoJoinTeamRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.teamHandler.autoJoinTeamRequest decode error!!"
			end
			Socket.OnRequestEnd("area.teamHandler.autoJoinTeamRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, autoJoinTeamRequestEncoder, autoJoinTeamRequestDecoder)
end


local function joinTeamRequestEncoder(msg)
	local input = teamHandler_pb.JoinTeamRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function joinTeamRequestDecoder(stream)
	local res = teamHandler_pb.JoinTeamResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.TeamHandler.joinTeamRequest(c2s_teamId,cb,option)
	local msg = {}
	msg.c2s_teamId = c2s_teamId
	Socket.OnRequestStart("area.teamHandler.joinTeamRequest", option)
	Socket.Request("area.teamHandler.joinTeamRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.TeamHandler.lastJoinTeamResponse = res
			Socket.OnRequestEnd("area.teamHandler.joinTeamRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.teamHandler.joinTeamRequest decode error!!"
			end
			Socket.OnRequestEnd("area.teamHandler.joinTeamRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, joinTeamRequestEncoder, joinTeamRequestDecoder)
end


local function getAppliedPlayersRequestEncoder(msg)
	local input = teamHandler_pb.GetAppliedPlayersRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getAppliedPlayersRequestDecoder(stream)
	local res = teamHandler_pb.GetAppliedPlayersResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.TeamHandler.getAppliedPlayersRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.teamHandler.getAppliedPlayersRequest", option)
	Socket.Request("area.teamHandler.getAppliedPlayersRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.TeamHandler.lastGetAppliedPlayersResponse = res
			Socket.OnRequestEnd("area.teamHandler.getAppliedPlayersRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.teamHandler.getAppliedPlayersRequest decode error!!"
			end
			Socket.OnRequestEnd("area.teamHandler.getAppliedPlayersRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getAppliedPlayersRequestEncoder, getAppliedPlayersRequestDecoder)
end


local function getPlayersByTypeRequestEncoder(msg)
	local input = teamHandler_pb.GetPlayersByTypeRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getPlayersByTypeRequestDecoder(stream)
	local res = teamHandler_pb.GetPlayersByTypeResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.TeamHandler.getPlayersByTypeRequest(c2s_type,cb,option)
	local msg = {}
	msg.c2s_type = c2s_type
	Socket.OnRequestStart("area.teamHandler.getPlayersByTypeRequest", option)
	Socket.Request("area.teamHandler.getPlayersByTypeRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.TeamHandler.lastGetPlayersByTypeResponse = res
			Socket.OnRequestEnd("area.teamHandler.getPlayersByTypeRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.teamHandler.getPlayersByTypeRequest decode error!!"
			end
			Socket.OnRequestEnd("area.teamHandler.getPlayersByTypeRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getPlayersByTypeRequestEncoder, getPlayersByTypeRequestDecoder)
end


local function queryTeamByTargetRequestEncoder(msg)
	local input = teamHandler_pb.QueryTeamByTargetRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function queryTeamByTargetRequestDecoder(stream)
	local res = teamHandler_pb.QueryTeamByTargetResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.TeamHandler.queryTeamByTargetRequest(c2s_targetId,c2s_difficulty,cb,option)
	local msg = {}
	msg.c2s_targetId = c2s_targetId
	msg.c2s_difficulty = c2s_difficulty
	Socket.OnRequestStart("area.teamHandler.queryTeamByTargetRequest", option)
	Socket.Request("area.teamHandler.queryTeamByTargetRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.TeamHandler.lastQueryTeamByTargetResponse = res
			Socket.OnRequestEnd("area.teamHandler.queryTeamByTargetRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.teamHandler.queryTeamByTargetRequest decode error!!"
			end
			Socket.OnRequestEnd("area.teamHandler.queryTeamByTargetRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, queryTeamByTargetRequestEncoder, queryTeamByTargetRequestDecoder)
end


local function setTeamTargetRequestEncoder(msg)
	local input = teamHandler_pb.SetTeamTargetRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function setTeamTargetRequestDecoder(stream)
	local res = teamHandler_pb.SetTeamTargetResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.TeamHandler.setTeamTargetRequest(c2s_targetId,c2s_difficulty,c2s_minLevel,c2s_maxLevel,c2s_isAutoTeam,c2s_isAutoStart,cb,option)
	local msg = {}
	msg.c2s_targetId = c2s_targetId
	msg.c2s_difficulty = c2s_difficulty
	msg.c2s_minLevel = c2s_minLevel
	msg.c2s_maxLevel = c2s_maxLevel
	msg.c2s_isAutoTeam = c2s_isAutoTeam
	msg.c2s_isAutoStart = c2s_isAutoStart
	Socket.OnRequestStart("area.teamHandler.setTeamTargetRequest", option)
	Socket.Request("area.teamHandler.setTeamTargetRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.TeamHandler.lastSetTeamTargetResponse = res
			Socket.OnRequestEnd("area.teamHandler.setTeamTargetRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.teamHandler.setTeamTargetRequest decode error!!"
			end
			Socket.OnRequestEnd("area.teamHandler.setTeamTargetRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, setTeamTargetRequestEncoder, setTeamTargetRequestDecoder)
end


local function createTeamRequestEncoder(msg)
	local input = teamHandler_pb.CreateTeamRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function createTeamRequestDecoder(stream)
	local res = teamHandler_pb.CreateTeamResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.TeamHandler.createTeamRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.teamHandler.createTeamRequest", option)
	Socket.Request("area.teamHandler.createTeamRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.TeamHandler.lastCreateTeamResponse = res
			Socket.OnRequestEnd("area.teamHandler.createTeamRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.teamHandler.createTeamRequest decode error!!"
			end
			Socket.OnRequestEnd("area.teamHandler.createTeamRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, createTeamRequestEncoder, createTeamRequestDecoder)
end


local function followLeaderRequestEncoder(msg)
	local input = teamHandler_pb.FollowLeaderRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function followLeaderRequestDecoder(stream)
	local res = teamHandler_pb.FollowLeaderResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.TeamHandler.followLeaderRequest(follow,cb,option)
	local msg = {}
	msg.follow = follow
	Socket.OnRequestStart("area.teamHandler.followLeaderRequest", option)
	Socket.Request("area.teamHandler.followLeaderRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.TeamHandler.lastFollowLeaderResponse = res
			Socket.OnRequestEnd("area.teamHandler.followLeaderRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.teamHandler.followLeaderRequest decode error!!"
			end
			Socket.OnRequestEnd("area.teamHandler.followLeaderRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, followLeaderRequestEncoder, followLeaderRequestDecoder)
end


local function formTeamRequestEncoder(msg)
	local input = teamHandler_pb.FormTeamRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function formTeamRequestDecoder(stream)
	local res = teamHandler_pb.FormTeamResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.TeamHandler.formTeamRequest(c2s_playerId,cb,option)
	local msg = {}
	msg.c2s_playerId = c2s_playerId
	Socket.OnRequestStart("area.teamHandler.formTeamRequest", option)
	Socket.Request("area.teamHandler.formTeamRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.TeamHandler.lastFormTeamResponse = res
			Socket.OnRequestEnd("area.teamHandler.formTeamRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.teamHandler.formTeamRequest decode error!!"
			end
			Socket.OnRequestEnd("area.teamHandler.formTeamRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, formTeamRequestEncoder, formTeamRequestDecoder)
end


local function getTeamMembersRequestEncoder(msg)
	local input = teamHandler_pb.GetTeamMembersRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getTeamMembersRequestDecoder(stream)
	local res = teamHandler_pb.GetTeamMembersResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.TeamHandler.getTeamMembersRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.teamHandler.getTeamMembersRequest", option)
	Socket.Request("area.teamHandler.getTeamMembersRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.TeamHandler.lastGetTeamMembersResponse = res
			Socket.OnRequestEnd("area.teamHandler.getTeamMembersRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.teamHandler.getTeamMembersRequest decode error!!"
			end
			Socket.OnRequestEnd("area.teamHandler.getTeamMembersRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getTeamMembersRequestEncoder, getTeamMembersRequestDecoder)
end


local function getNearbyPlayersRequestEncoder(msg)
	local input = teamHandler_pb.GetNearbyPlayersRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getNearbyPlayersRequestDecoder(stream)
	local res = teamHandler_pb.GetNearbyPlayersResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.TeamHandler.getNearbyPlayersRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.teamHandler.getNearbyPlayersRequest", option)
	Socket.Request("area.teamHandler.getNearbyPlayersRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.TeamHandler.lastGetNearbyPlayersResponse = res
			Socket.OnRequestEnd("area.teamHandler.getNearbyPlayersRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.teamHandler.getNearbyPlayersRequest decode error!!"
			end
			Socket.OnRequestEnd("area.teamHandler.getNearbyPlayersRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getNearbyPlayersRequestEncoder, getNearbyPlayersRequestDecoder)
end


local function getNearTeamsRequestEncoder(msg)
	local input = teamHandler_pb.GetNearTeamsRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getNearTeamsRequestDecoder(stream)
	local res = teamHandler_pb.GetNearTeamsResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.TeamHandler.getNearTeamsRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.teamHandler.getNearTeamsRequest", option)
	Socket.Request("area.teamHandler.getNearTeamsRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.TeamHandler.lastGetNearTeamsResponse = res
			Socket.OnRequestEnd("area.teamHandler.getNearTeamsRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.teamHandler.getNearTeamsRequest decode error!!"
			end
			Socket.OnRequestEnd("area.teamHandler.getNearTeamsRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getNearTeamsRequestEncoder, getNearTeamsRequestDecoder)
end


local function changeTeamLeaderRequestEncoder(msg)
	local input = teamHandler_pb.ChangeTeamLeaderRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function changeTeamLeaderRequestDecoder(stream)
	local res = teamHandler_pb.ChangeTeamLeaderResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.TeamHandler.changeTeamLeaderRequest(c2s_playerId,cb,option)
	local msg = {}
	msg.c2s_playerId = c2s_playerId
	Socket.OnRequestStart("area.teamHandler.changeTeamLeaderRequest", option)
	Socket.Request("area.teamHandler.changeTeamLeaderRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.TeamHandler.lastChangeTeamLeaderResponse = res
			Socket.OnRequestEnd("area.teamHandler.changeTeamLeaderRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.teamHandler.changeTeamLeaderRequest decode error!!"
			end
			Socket.OnRequestEnd("area.teamHandler.changeTeamLeaderRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, changeTeamLeaderRequestEncoder, changeTeamLeaderRequestDecoder)
end


local function kickOutTeamRequestEncoder(msg)
	local input = teamHandler_pb.KickOutTeamRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function kickOutTeamRequestDecoder(stream)
	local res = teamHandler_pb.KickOutTeamResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.TeamHandler.kickOutTeamRequest(c2s_playerId,cb,option)
	local msg = {}
	msg.c2s_playerId = c2s_playerId
	Socket.OnRequestStart("area.teamHandler.kickOutTeamRequest", option)
	Socket.Request("area.teamHandler.kickOutTeamRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.TeamHandler.lastKickOutTeamResponse = res
			Socket.OnRequestEnd("area.teamHandler.kickOutTeamRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.teamHandler.kickOutTeamRequest decode error!!"
			end
			Socket.OnRequestEnd("area.teamHandler.kickOutTeamRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, kickOutTeamRequestEncoder, kickOutTeamRequestDecoder)
end


local function leaveTeamRequestEncoder(msg)
	local input = teamHandler_pb.LeaveTeamRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function leaveTeamRequestDecoder(stream)
	local res = teamHandler_pb.LeaveTeamResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.TeamHandler.leaveTeamRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.teamHandler.leaveTeamRequest", option)
	Socket.Request("area.teamHandler.leaveTeamRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.TeamHandler.lastLeaveTeamResponse = res
			Socket.OnRequestEnd("area.teamHandler.leaveTeamRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.teamHandler.leaveTeamRequest decode error!!"
			end
			Socket.OnRequestEnd("area.teamHandler.leaveTeamRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, leaveTeamRequestEncoder, leaveTeamRequestDecoder)
end


local function setAutoAcceptTeamRequestEncoder(msg)
	local input = teamHandler_pb.SetAutoAcceptTeamRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function setAutoAcceptTeamRequestDecoder(stream)
	local res = teamHandler_pb.SetAutoAcceptTeamResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.TeamHandler.setAutoAcceptTeamRequest(c2s_isAccept,cb,option)
	local msg = {}
	msg.c2s_isAccept = c2s_isAccept
	Socket.OnRequestStart("area.teamHandler.setAutoAcceptTeamRequest", option)
	Socket.Request("area.teamHandler.setAutoAcceptTeamRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.TeamHandler.lastSetAutoAcceptTeamResponse = res
			Socket.OnRequestEnd("area.teamHandler.setAutoAcceptTeamRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.teamHandler.setAutoAcceptTeamRequest decode error!!"
			end
			Socket.OnRequestEnd("area.teamHandler.setAutoAcceptTeamRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, setAutoAcceptTeamRequestEncoder, setAutoAcceptTeamRequestDecoder)
end


local function cancelAutoRequestEncoder(msg)
	local input = teamHandler_pb.CancelAutoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function cancelAutoRequestDecoder(stream)
	local res = teamHandler_pb.CancelAutoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.TeamHandler.cancelAutoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.teamHandler.cancelAutoRequest", option)
	Socket.Request("area.teamHandler.cancelAutoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.TeamHandler.lastCancelAutoResponse = res
			Socket.OnRequestEnd("area.teamHandler.cancelAutoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.teamHandler.cancelAutoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.teamHandler.cancelAutoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, cancelAutoRequestEncoder, cancelAutoRequestDecoder)
end


local function acrossMatchRequestEncoder(msg)
	local input = teamHandler_pb.AcrossMatchRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function acrossMatchRequestDecoder(stream)
	local res = teamHandler_pb.AcrossMatchResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.TeamHandler.acrossMatchRequest(targetId,difficulty,cb,option)
	local msg = {}
	msg.targetId = targetId
	msg.difficulty = difficulty
	Socket.OnRequestStart("area.teamHandler.acrossMatchRequest", option)
	Socket.Request("area.teamHandler.acrossMatchRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.TeamHandler.lastAcrossMatchResponse = res
			Socket.OnRequestEnd("area.teamHandler.acrossMatchRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.teamHandler.acrossMatchRequest decode error!!"
			end
			Socket.OnRequestEnd("area.teamHandler.acrossMatchRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, acrossMatchRequestEncoder, acrossMatchRequestDecoder)
end


local function leaveAcrossMatchRequestEncoder(msg)
	local input = teamHandler_pb.LeaveAcrossMatchRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function leaveAcrossMatchRequestDecoder(stream)
	local res = teamHandler_pb.LeaveAcrossMatchResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.TeamHandler.leaveAcrossMatchRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.teamHandler.leaveAcrossMatchRequest", option)
	Socket.Request("area.teamHandler.leaveAcrossMatchRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.TeamHandler.lastLeaveAcrossMatchResponse = res
			Socket.OnRequestEnd("area.teamHandler.leaveAcrossMatchRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.teamHandler.leaveAcrossMatchRequest decode error!!"
			end
			Socket.OnRequestEnd("area.teamHandler.leaveAcrossMatchRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, leaveAcrossMatchRequestEncoder, leaveAcrossMatchRequestDecoder)
end


local function onSummonTeamPushDecoder(stream)
	local res = teamHandler_pb.OnSummonTeamPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.TeamHandler.onSummonTeamPush(cb)
	Socket.On("area.teamPush.onSummonTeamPush", function(res) 
		Pomelo.TeamHandler.lastOnSummonTeamPush = res
		cb(nil,res) 
	end, onSummonTeamPushDecoder) 
end


local function onTeamUpdatePushDecoder(stream)
	local res = teamHandler_pb.OnTeamUpdatePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.TeamHandler.onTeamUpdatePush(cb)
	Socket.On("area.teamPush.onTeamUpdatePush", function(res) 
		Pomelo.TeamHandler.lastOnTeamUpdatePush = res
		cb(nil,res) 
	end, onTeamUpdatePushDecoder) 
end


local function onTeamMemberUpdatePushDecoder(stream)
	local res = teamHandler_pb.OnTeamMemberUpdatePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.TeamHandler.onTeamMemberUpdatePush(cb)
	Socket.On("area.teamPush.onTeamMemberUpdatePush", function(res) 
		Pomelo.TeamHandler.lastOnTeamMemberUpdatePush = res
		cb(nil,res) 
	end, onTeamMemberUpdatePushDecoder) 
end


local function onTeamTargetPushDecoder(stream)
	local res = teamHandler_pb.OnTeamTargetPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.TeamHandler.onTeamTargetPush(cb)
	Socket.On("area.teamPush.onTeamTargetPush", function(res) 
		Pomelo.TeamHandler.lastOnTeamTargetPush = res
		cb(nil,res) 
	end, onTeamTargetPushDecoder) 
end


local function onAcrossTeamInfoPushDecoder(stream)
	local res = teamHandler_pb.OnAcrossTeamInfoPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.TeamHandler.onAcrossTeamInfoPush(cb)
	Socket.On("area.teamPush.onAcrossTeamInfoPush", function(res) 
		Pomelo.TeamHandler.lastOnAcrossTeamInfoPush = res
		cb(nil,res) 
	end, onAcrossTeamInfoPushDecoder) 
end


local function onTeamMumberHurtPushDecoder(stream)
	local res = teamHandler_pb.OnTeamMumberHurtPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.TeamHandler.onTeamMumberHurtPush(cb)
	Socket.On("area.teamPush.onTeamMumberHurtPush", function(res) 
		Pomelo.TeamHandler.lastOnTeamMumberHurtPush = res
		cb(nil,res) 
	end, onTeamMumberHurtPushDecoder) 
end





return Pomelo
