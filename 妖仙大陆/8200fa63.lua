





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "allyHandler_pb"


Pomelo = Pomelo or {}


Pomelo.AllyHandler = {}

local function getNearbyAllyPlayersRequestEncoder(msg)
	local input = allyHandler_pb.GetNearbyAllyPlayersRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getNearbyAllyPlayersRequestDecoder(stream)
	local res = allyHandler_pb.GetNearbyAllyPlayersResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.AllyHandler.getNearbyAllyPlayersRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.allyHandler.getNearbyAllyPlayersRequest", option)
	Socket.Request("area.allyHandler.getNearbyAllyPlayersRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.AllyHandler.lastGetNearbyAllyPlayersResponse = res
			Socket.OnRequestEnd("area.allyHandler.getNearbyAllyPlayersRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.allyHandler.getNearbyAllyPlayersRequest decode error!!"
			end
			Socket.OnRequestEnd("area.allyHandler.getNearbyAllyPlayersRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getNearbyAllyPlayersRequestEncoder, getNearbyAllyPlayersRequestDecoder)
end


local function allyInviteRequestEncoder(msg)
	local input = allyHandler_pb.AllyInviteRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function allyInviteRequestDecoder(stream)
	local res = allyHandler_pb.AllyInviteResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.AllyHandler.allyInviteRequest(c2s_playerId,cb,option)
	local msg = {}
	msg.c2s_playerId = c2s_playerId
	Socket.OnRequestStart("area.allyHandler.allyInviteRequest", option)
	Socket.Request("area.allyHandler.allyInviteRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.AllyHandler.lastAllyInviteResponse = res
			Socket.OnRequestEnd("area.allyHandler.allyInviteRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.allyHandler.allyInviteRequest decode error!!"
			end
			Socket.OnRequestEnd("area.allyHandler.allyInviteRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, allyInviteRequestEncoder, allyInviteRequestDecoder)
end


local function allyInfoRequestEncoder(msg)
	local input = allyHandler_pb.AllyInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function allyInfoRequestDecoder(stream)
	local res = allyHandler_pb.AllyInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.AllyHandler.allyInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.allyHandler.allyInfoRequest", option)
	Socket.Request("area.allyHandler.allyInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.AllyHandler.lastAllyInfoResponse = res
			Socket.OnRequestEnd("area.allyHandler.allyInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.allyHandler.allyInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.allyHandler.allyInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, allyInfoRequestEncoder, allyInfoRequestDecoder)
end


local function getIntimacyRequestEncoder(msg)
	local input = allyHandler_pb.GetIntimacyRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getIntimacyRequestDecoder(stream)
	local res = allyHandler_pb.GetIntimacyResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.AllyHandler.getIntimacyRequest(c2s_targetId,cb,option)
	local msg = {}
	msg.c2s_targetId = c2s_targetId
	Socket.OnRequestStart("area.allyHandler.getIntimacyRequest", option)
	Socket.Request("area.allyHandler.getIntimacyRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.AllyHandler.lastGetIntimacyResponse = res
			Socket.OnRequestEnd("area.allyHandler.getIntimacyRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.allyHandler.getIntimacyRequest decode error!!"
			end
			Socket.OnRequestEnd("area.allyHandler.getIntimacyRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getIntimacyRequestEncoder, getIntimacyRequestDecoder)
end


local function addIntimacyRequestEncoder(msg)
	local input = allyHandler_pb.AddIntimacyRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function addIntimacyRequestDecoder(stream)
	local res = allyHandler_pb.AddIntimacyResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.AllyHandler.addIntimacyRequest(c2s_targetId,c2s_type,cb,option)
	local msg = {}
	msg.c2s_targetId = c2s_targetId
	msg.c2s_type = c2s_type
	Socket.OnRequestStart("area.allyHandler.addIntimacyRequest", option)
	Socket.Request("area.allyHandler.addIntimacyRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.AllyHandler.lastAddIntimacyResponse = res
			Socket.OnRequestEnd("area.allyHandler.addIntimacyRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.allyHandler.addIntimacyRequest decode error!!"
			end
			Socket.OnRequestEnd("area.allyHandler.addIntimacyRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, addIntimacyRequestEncoder, addIntimacyRequestDecoder)
end


local function transferLeaderRequestEncoder(msg)
	local input = allyHandler_pb.TransferLeaderRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function transferLeaderRequestDecoder(stream)
	local res = allyHandler_pb.TransferLeaderResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.AllyHandler.transferLeaderRequest(c2s_targetId,cb,option)
	local msg = {}
	msg.c2s_targetId = c2s_targetId
	Socket.OnRequestStart("area.allyHandler.transferLeaderRequest", option)
	Socket.Request("area.allyHandler.transferLeaderRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.AllyHandler.lastTransferLeaderResponse = res
			Socket.OnRequestEnd("area.allyHandler.transferLeaderRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.allyHandler.transferLeaderRequest decode error!!"
			end
			Socket.OnRequestEnd("area.allyHandler.transferLeaderRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, transferLeaderRequestEncoder, transferLeaderRequestDecoder)
end


local function kickAllyMemberRequestEncoder(msg)
	local input = allyHandler_pb.KickAllyMemberRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function kickAllyMemberRequestDecoder(stream)
	local res = allyHandler_pb.KickAllyMemberResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.AllyHandler.kickAllyMemberRequest(c2s_targetId,cb,option)
	local msg = {}
	msg.c2s_targetId = c2s_targetId
	Socket.OnRequestStart("area.allyHandler.kickAllyMemberRequest", option)
	Socket.Request("area.allyHandler.kickAllyMemberRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.AllyHandler.lastKickAllyMemberResponse = res
			Socket.OnRequestEnd("area.allyHandler.kickAllyMemberRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.allyHandler.kickAllyMemberRequest decode error!!"
			end
			Socket.OnRequestEnd("area.allyHandler.kickAllyMemberRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, kickAllyMemberRequestEncoder, kickAllyMemberRequestDecoder)
end


local function leaveAllyRequestEncoder(msg)
	local input = allyHandler_pb.LeaveAllyRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function leaveAllyRequestDecoder(stream)
	local res = allyHandler_pb.LeaveAllyResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.AllyHandler.leaveAllyRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.allyHandler.leaveAllyRequest", option)
	Socket.Request("area.allyHandler.leaveAllyRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.AllyHandler.lastLeaveAllyResponse = res
			Socket.OnRequestEnd("area.allyHandler.leaveAllyRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.allyHandler.leaveAllyRequest decode error!!"
			end
			Socket.OnRequestEnd("area.allyHandler.leaveAllyRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, leaveAllyRequestEncoder, leaveAllyRequestDecoder)
end


local function modifyAllyNameRequestEncoder(msg)
	local input = allyHandler_pb.ModifyAllyNameRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function modifyAllyNameRequestDecoder(stream)
	local res = allyHandler_pb.ModifyAllyNameResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.AllyHandler.modifyAllyNameRequest(c2s_name,cb,option)
	local msg = {}
	msg.c2s_name = c2s_name
	Socket.OnRequestStart("area.allyHandler.modifyAllyNameRequest", option)
	Socket.Request("area.allyHandler.modifyAllyNameRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.AllyHandler.lastModifyAllyNameResponse = res
			Socket.OnRequestEnd("area.allyHandler.modifyAllyNameRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.allyHandler.modifyAllyNameRequest decode error!!"
			end
			Socket.OnRequestEnd("area.allyHandler.modifyAllyNameRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, modifyAllyNameRequestEncoder, modifyAllyNameRequestDecoder)
end


local function modifyAllyNoticeRequestEncoder(msg)
	local input = allyHandler_pb.ModifyAllyNoticeRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function modifyAllyNoticeRequestDecoder(stream)
	local res = allyHandler_pb.ModifyAllyNoticeResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.AllyHandler.modifyAllyNoticeRequest(c2s_notice,cb,option)
	local msg = {}
	msg.c2s_notice = c2s_notice
	Socket.OnRequestStart("area.allyHandler.modifyAllyNoticeRequest", option)
	Socket.Request("area.allyHandler.modifyAllyNoticeRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.AllyHandler.lastModifyAllyNoticeResponse = res
			Socket.OnRequestEnd("area.allyHandler.modifyAllyNoticeRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.allyHandler.modifyAllyNoticeRequest decode error!!"
			end
			Socket.OnRequestEnd("area.allyHandler.modifyAllyNoticeRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, modifyAllyNoticeRequestEncoder, modifyAllyNoticeRequestDecoder)
end


local function allyChatRequestEncoder(msg)
	local input = allyHandler_pb.AllyChatRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function allyChatRequestDecoder(stream)
	local res = allyHandler_pb.AllyChatResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.AllyHandler.allyChatRequest(c2s_content,cb,option)
	local msg = {}
	msg.c2s_content = c2s_content
	Socket.OnRequestStart("area.allyHandler.allyChatRequest", option)
	Socket.Request("area.allyHandler.allyChatRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.AllyHandler.lastAllyChatResponse = res
			Socket.OnRequestEnd("area.allyHandler.allyChatRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.allyHandler.allyChatRequest decode error!!"
			end
			Socket.OnRequestEnd("area.allyHandler.allyChatRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, allyChatRequestEncoder, allyChatRequestDecoder)
end


local function getRebateRequestEncoder(msg)
	local input = allyHandler_pb.GetRebateRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getRebateRequestDecoder(stream)
	local res = allyHandler_pb.GetRebateResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.AllyHandler.getRebateRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.allyHandler.getRebateRequest", option)
	Socket.Request("area.allyHandler.getRebateRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.AllyHandler.lastGetRebateResponse = res
			Socket.OnRequestEnd("area.allyHandler.getRebateRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.allyHandler.getRebateRequest decode error!!"
			end
			Socket.OnRequestEnd("area.allyHandler.getRebateRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getRebateRequestEncoder, getRebateRequestDecoder)
end


local function getAllyRankRequestEncoder(msg)
	local input = allyHandler_pb.GetAllyRankRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getAllyRankRequestDecoder(stream)
	local res = allyHandler_pb.GetAllyRankResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.AllyHandler.getAllyRankRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.allyHandler.getAllyRankRequest", option)
	Socket.Request("area.allyHandler.getAllyRankRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.AllyHandler.lastGetAllyRankResponse = res
			Socket.OnRequestEnd("area.allyHandler.getAllyRankRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.allyHandler.getAllyRankRequest decode error!!"
			end
			Socket.OnRequestEnd("area.allyHandler.getAllyRankRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getAllyRankRequestEncoder, getAllyRankRequestDecoder)
end


local function getChatRequestEncoder(msg)
	local input = allyHandler_pb.GetChatRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getChatRequestDecoder(stream)
	local res = allyHandler_pb.GetChatResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.AllyHandler.getChatRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.allyHandler.getChatRequest", option)
	Socket.Request("area.allyHandler.getChatRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.AllyHandler.lastGetChatResponse = res
			Socket.OnRequestEnd("area.allyHandler.getChatRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.allyHandler.getChatRequest decode error!!"
			end
			Socket.OnRequestEnd("area.allyHandler.getChatRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getChatRequestEncoder, getChatRequestDecoder)
end


local function quickCreateTeamRequestEncoder(msg)
	local input = allyHandler_pb.QuickCreateTeamRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function quickCreateTeamRequestDecoder(stream)
	local res = allyHandler_pb.QuickCreateTeamResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.AllyHandler.quickCreateTeamRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.allyHandler.quickCreateTeamRequest", option)
	Socket.Request("area.allyHandler.quickCreateTeamRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.AllyHandler.lastQuickCreateTeamResponse = res
			Socket.OnRequestEnd("area.allyHandler.quickCreateTeamRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.allyHandler.quickCreateTeamRequest decode error!!"
			end
			Socket.OnRequestEnd("area.allyHandler.quickCreateTeamRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, quickCreateTeamRequestEncoder, quickCreateTeamRequestDecoder)
end


local function applyAllyFightRequestEncoder(msg)
	local input = allyHandler_pb.ApplyAllyFightRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function applyAllyFightRequestDecoder(stream)
	local res = allyHandler_pb.ApplyAllyFightResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.AllyHandler.applyAllyFightRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.allyHandler.applyAllyFightRequest", option)
	Socket.Request("area.allyHandler.applyAllyFightRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.AllyHandler.lastApplyAllyFightResponse = res
			Socket.OnRequestEnd("area.allyHandler.applyAllyFightRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.allyHandler.applyAllyFightRequest decode error!!"
			end
			Socket.OnRequestEnd("area.allyHandler.applyAllyFightRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, applyAllyFightRequestEncoder, applyAllyFightRequestDecoder)
end


local function allyFightRequestEncoder(msg)
	local input = allyHandler_pb.AllyFightRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function allyFightRequestDecoder(stream)
	local res = allyHandler_pb.AllyFightResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.AllyHandler.allyFightRequest(c2s_type,c2s_opt,cb,option)
	local msg = {}
	msg.c2s_type = c2s_type
	msg.c2s_opt = c2s_opt
	Socket.OnRequestStart("area.allyHandler.allyFightRequest", option)
	Socket.Request("area.allyHandler.allyFightRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.AllyHandler.lastAllyFightResponse = res
			Socket.OnRequestEnd("area.allyHandler.allyFightRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.allyHandler.allyFightRequest decode error!!"
			end
			Socket.OnRequestEnd("area.allyHandler.allyFightRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, allyFightRequestEncoder, allyFightRequestDecoder)
end


local function allyFightInfoRequestEncoder(msg)
	local input = allyHandler_pb.AllyFightInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function allyFightInfoRequestDecoder(stream)
	local res = allyHandler_pb.AllyFightInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.AllyHandler.allyFightInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.allyHandler.allyFightInfoRequest", option)
	Socket.Request("area.allyHandler.allyFightInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.AllyHandler.lastAllyFightInfoResponse = res
			Socket.OnRequestEnd("area.allyHandler.allyFightInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.allyHandler.allyFightInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.allyHandler.allyFightInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, allyFightInfoRequestEncoder, allyFightInfoRequestDecoder)
end


local function getSingleAllyFightRequestEncoder(msg)
	local input = allyHandler_pb.GetSingleAllyFightRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getSingleAllyFightRequestDecoder(stream)
	local res = allyHandler_pb.GetSingleAllyFightResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.AllyHandler.getSingleAllyFightRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.allyHandler.getSingleAllyFightRequest", option)
	Socket.Request("area.allyHandler.getSingleAllyFightRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.AllyHandler.lastGetSingleAllyFightResponse = res
			Socket.OnRequestEnd("area.allyHandler.getSingleAllyFightRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.allyHandler.getSingleAllyFightRequest decode error!!"
			end
			Socket.OnRequestEnd("area.allyHandler.getSingleAllyFightRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getSingleAllyFightRequestEncoder, getSingleAllyFightRequestDecoder)
end


local function getAllyFightRequestEncoder(msg)
	local input = allyHandler_pb.GetAllyFightRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getAllyFightRequestDecoder(stream)
	local res = allyHandler_pb.GetAllyFightResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.AllyHandler.getAllyFightRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.allyHandler.getAllyFightRequest", option)
	Socket.Request("area.allyHandler.getAllyFightRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.AllyHandler.lastGetAllyFightResponse = res
			Socket.OnRequestEnd("area.allyHandler.getAllyFightRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.allyHandler.getAllyFightRequest decode error!!"
			end
			Socket.OnRequestEnd("area.allyHandler.getAllyFightRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getAllyFightRequestEncoder, getAllyFightRequestDecoder)
end


local function allyChatPushDecoder(stream)
	local res = allyHandler_pb.AllyChatPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.AllyHandler.allyChatPush(cb)
	Socket.On("area.allyPush.allyChatPush", function(res) 
		Pomelo.AllyHandler.lastAllyChatPush = res
		cb(nil,res) 
	end, allyChatPushDecoder) 
end


local function allyRefreshPushDecoder(stream)
	local res = allyHandler_pb.AllyRefreshPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.AllyHandler.allyRefreshPush(cb)
	Socket.On("area.allyPush.allyRefreshPush", function(res) 
		Pomelo.AllyHandler.lastAllyRefreshPush = res
		cb(nil,res) 
	end, allyRefreshPushDecoder) 
end


local function allyFightPushDecoder(stream)
	local res = allyHandler_pb.AllyFightPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.AllyHandler.allyFightPush(cb)
	Socket.On("area.allyPush.allyFightPush", function(res) 
		Pomelo.AllyHandler.lastAllyFightPush = res
		cb(nil,res) 
	end, allyFightPushDecoder) 
end


local function allyJoinPushDecoder(stream)
	local res = allyHandler_pb.AllyJoinPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.AllyHandler.allyJoinPush(cb)
	Socket.On("area.allyPush.allyJoinPush", function(res) 
		Pomelo.AllyHandler.lastAllyJoinPush = res
		cb(nil,res) 
	end, allyJoinPushDecoder) 
end


local function singleAllyFightDataPushDecoder(stream)
	local res = allyHandler_pb.SingleAllyFightDataPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.AllyHandler.singleAllyFightDataPush(cb)
	Socket.On("area.allyPush.singleAllyFightDataPush", function(res) 
		Pomelo.AllyHandler.lastSingleAllyFightDataPush = res
		cb(nil,res) 
	end, singleAllyFightDataPushDecoder) 
end


local function allyFightEndPushDecoder(stream)
	local res = allyHandler_pb.AllyFightEndPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.AllyHandler.allyFightEndPush(cb)
	Socket.On("area.allyPush.allyFightEndPush", function(res) 
		Pomelo.AllyHandler.lastAllyFightEndPush = res
		cb(nil,res) 
	end, allyFightEndPushDecoder) 
end


local function allyTeamPushDecoder(stream)
	local res = allyHandler_pb.AllyTeamPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.AllyHandler.allyTeamPush(cb)
	Socket.On("area.allyPush.allyTeamPush", function(res) 
		Pomelo.AllyHandler.lastAllyTeamPush = res
		cb(nil,res) 
	end, allyTeamPushDecoder) 
end





return Pomelo
