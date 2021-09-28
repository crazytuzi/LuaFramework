





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "guildHandler_pb"


Pomelo = Pomelo or {}


Pomelo.GuildHandler = {}

local function createGuildRequestEncoder(msg)
	local input = guildHandler_pb.CreateGuildRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function createGuildRequestDecoder(stream)
	local res = guildHandler_pb.CreateGuildResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildHandler.createGuildRequest(c2s_icon,c2s_name,c2s_qqGroup,cb,option)
	local msg = {}
	msg.c2s_icon = c2s_icon
	msg.c2s_name = c2s_name
	msg.c2s_qqGroup = c2s_qqGroup
	Socket.OnRequestStart("area.guildHandler.createGuildRequest", option)
	Socket.Request("area.guildHandler.createGuildRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildHandler.lastCreateGuildResponse = res
			Socket.OnRequestEnd("area.guildHandler.createGuildRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildHandler.createGuildRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildHandler.createGuildRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, createGuildRequestEncoder, createGuildRequestDecoder)
end


local function getGuildListRequestEncoder(msg)
	local input = guildHandler_pb.GetGuildListRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getGuildListRequestDecoder(stream)
	local res = guildHandler_pb.GetGuildListResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildHandler.getGuildListRequest(c2s_name,cb,option)
	local msg = {}
	msg.c2s_name = c2s_name
	Socket.OnRequestStart("area.guildHandler.getGuildListRequest", option)
	Socket.Request("area.guildHandler.getGuildListRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildHandler.lastGetGuildListResponse = res
			Socket.OnRequestEnd("area.guildHandler.getGuildListRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildHandler.getGuildListRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildHandler.getGuildListRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getGuildListRequestEncoder, getGuildListRequestDecoder)
end


local function joinGuildRequestEncoder(msg)
	local input = guildHandler_pb.JoinGuildRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function joinGuildRequestDecoder(stream)
	local res = guildHandler_pb.JoinGuildResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildHandler.joinGuildRequest(c2s_guildId,cb,option)
	local msg = {}
	msg.c2s_guildId = c2s_guildId
	Socket.OnRequestStart("area.guildHandler.joinGuildRequest", option)
	Socket.Request("area.guildHandler.joinGuildRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildHandler.lastJoinGuildResponse = res
			Socket.OnRequestEnd("area.guildHandler.joinGuildRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildHandler.joinGuildRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildHandler.joinGuildRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, joinGuildRequestEncoder, joinGuildRequestDecoder)
end


local function joinGuildOfPlayerRequestEncoder(msg)
	local input = guildHandler_pb.JoinGuildOfPlayerRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function joinGuildOfPlayerRequestDecoder(stream)
	local res = guildHandler_pb.JoinGuildOfPlayerResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildHandler.joinGuildOfPlayerRequest(c2s_playerId,cb,option)
	local msg = {}
	msg.c2s_playerId = c2s_playerId
	Socket.OnRequestStart("area.guildHandler.joinGuildOfPlayerRequest", option)
	Socket.Request("area.guildHandler.joinGuildOfPlayerRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildHandler.lastJoinGuildOfPlayerResponse = res
			Socket.OnRequestEnd("area.guildHandler.joinGuildOfPlayerRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildHandler.joinGuildOfPlayerRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildHandler.joinGuildOfPlayerRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, joinGuildOfPlayerRequestEncoder, joinGuildOfPlayerRequestDecoder)
end


local function invitePlayerJoinMyGuildRequestEncoder(msg)
	local input = guildHandler_pb.InvitePlayerJoinMyGuildRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function invitePlayerJoinMyGuildRequestDecoder(stream)
	local res = guildHandler_pb.InvitePlayerJoinMyGuildResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildHandler.invitePlayerJoinMyGuildRequest(c2s_playerId,cb,option)
	local msg = {}
	msg.c2s_playerId = c2s_playerId
	Socket.OnRequestStart("area.guildHandler.invitePlayerJoinMyGuildRequest", option)
	Socket.Request("area.guildHandler.invitePlayerJoinMyGuildRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildHandler.lastInvitePlayerJoinMyGuildResponse = res
			Socket.OnRequestEnd("area.guildHandler.invitePlayerJoinMyGuildRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildHandler.invitePlayerJoinMyGuildRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildHandler.invitePlayerJoinMyGuildRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, invitePlayerJoinMyGuildRequestEncoder, invitePlayerJoinMyGuildRequestDecoder)
end


local function agreeOrRefuseInviteRequestEncoder(msg)
	local input = guildHandler_pb.AgreeOrRefuseInviteRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function agreeOrRefuseInviteRequestDecoder(stream)
	local res = guildHandler_pb.AgreeOrRefuseInviteResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildHandler.agreeOrRefuseInviteRequest(c2s_isAgree,c2s_inviteId,c2s_guildId,cb,option)
	local msg = {}
	msg.c2s_isAgree = c2s_isAgree
	msg.c2s_inviteId = c2s_inviteId
	msg.c2s_guildId = c2s_guildId
	Socket.OnRequestStart("area.guildHandler.agreeOrRefuseInviteRequest", option)
	Socket.Request("area.guildHandler.agreeOrRefuseInviteRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildHandler.lastAgreeOrRefuseInviteResponse = res
			Socket.OnRequestEnd("area.guildHandler.agreeOrRefuseInviteRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildHandler.agreeOrRefuseInviteRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildHandler.agreeOrRefuseInviteRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, agreeOrRefuseInviteRequestEncoder, agreeOrRefuseInviteRequestDecoder)
end


local function dealApplyRequestEncoder(msg)
	local input = guildHandler_pb.DealApplyRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function dealApplyRequestDecoder(stream)
	local res = guildHandler_pb.DealApplyResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildHandler.dealApplyRequest(c2s_applyId,c2s_operate,cb,option)
	local msg = {}
	msg.c2s_applyId = c2s_applyId
	msg.c2s_operate = c2s_operate
	Socket.OnRequestStart("area.guildHandler.dealApplyRequest", option)
	Socket.Request("area.guildHandler.dealApplyRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildHandler.lastDealApplyResponse = res
			Socket.OnRequestEnd("area.guildHandler.dealApplyRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildHandler.dealApplyRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildHandler.dealApplyRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, dealApplyRequestEncoder, dealApplyRequestDecoder)
end


local function getMyGuildInfoRequestEncoder(msg)
	local input = guildHandler_pb.GetMyGuildInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getMyGuildInfoRequestDecoder(stream)
	local res = guildHandler_pb.GetMyGuildInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildHandler.getMyGuildInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.guildHandler.getMyGuildInfoRequest", option)
	Socket.Request("area.guildHandler.getMyGuildInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildHandler.lastGetMyGuildInfoResponse = res
			Socket.OnRequestEnd("area.guildHandler.getMyGuildInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildHandler.getMyGuildInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildHandler.getMyGuildInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getMyGuildInfoRequestEncoder, getMyGuildInfoRequestDecoder)
end


local function getMyGuildMembersRequestEncoder(msg)
	local input = guildHandler_pb.GetMyGuildMembersRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getMyGuildMembersRequestDecoder(stream)
	local res = guildHandler_pb.GetMyGuildMembersResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildHandler.getMyGuildMembersRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.guildHandler.getMyGuildMembersRequest", option)
	Socket.Request("area.guildHandler.getMyGuildMembersRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildHandler.lastGetMyGuildMembersResponse = res
			Socket.OnRequestEnd("area.guildHandler.getMyGuildMembersRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildHandler.getMyGuildMembersRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildHandler.getMyGuildMembersRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getMyGuildMembersRequestEncoder, getMyGuildMembersRequestDecoder)
end


local function getApplyListRequestEncoder(msg)
	local input = guildHandler_pb.GetApplyListRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getApplyListRequestDecoder(stream)
	local res = guildHandler_pb.GetApplyListResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildHandler.getApplyListRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.guildHandler.getApplyListRequest", option)
	Socket.Request("area.guildHandler.getApplyListRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildHandler.lastGetApplyListResponse = res
			Socket.OnRequestEnd("area.guildHandler.getApplyListRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildHandler.getApplyListRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildHandler.getApplyListRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getApplyListRequestEncoder, getApplyListRequestDecoder)
end


local function setGuildInfoRequestEncoder(msg)
	local input = guildHandler_pb.SetGuildInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function setGuildInfoRequestDecoder(stream)
	local res = guildHandler_pb.SetGuildInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildHandler.setGuildInfoRequest(entryLevel,guildMode,entryUpLevel,cb,option)
	local msg = {}
	msg.entryLevel = entryLevel
	msg.guildMode = guildMode
	msg.entryUpLevel = entryUpLevel
	Socket.OnRequestStart("area.guildHandler.setGuildInfoRequest", option)
	Socket.Request("area.guildHandler.setGuildInfoRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildHandler.lastSetGuildInfoResponse = res
			Socket.OnRequestEnd("area.guildHandler.setGuildInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildHandler.setGuildInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildHandler.setGuildInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, setGuildInfoRequestEncoder, setGuildInfoRequestDecoder)
end


local function setGuildQQGroupRequestEncoder(msg)
	local input = guildHandler_pb.SetGuildQQGroupRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function setGuildQQGroupRequestDecoder(stream)
	local res = guildHandler_pb.SetGuildQQGroupResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildHandler.setGuildQQGroupRequest(qqGroup,cb,option)
	local msg = {}
	msg.qqGroup = qqGroup
	Socket.OnRequestStart("area.guildHandler.setGuildQQGroupRequest", option)
	Socket.Request("area.guildHandler.setGuildQQGroupRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildHandler.lastSetGuildQQGroupResponse = res
			Socket.OnRequestEnd("area.guildHandler.setGuildQQGroupRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildHandler.setGuildQQGroupRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildHandler.setGuildQQGroupRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, setGuildQQGroupRequestEncoder, setGuildQQGroupRequestDecoder)
end


local function exitGuildRequestEncoder(msg)
	local input = guildHandler_pb.ExitGuildRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function exitGuildRequestDecoder(stream)
	local res = guildHandler_pb.ExitGuildResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildHandler.exitGuildRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.guildHandler.exitGuildRequest", option)
	Socket.Request("area.guildHandler.exitGuildRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildHandler.lastExitGuildResponse = res
			Socket.OnRequestEnd("area.guildHandler.exitGuildRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildHandler.exitGuildRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildHandler.exitGuildRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, exitGuildRequestEncoder, exitGuildRequestDecoder)
end


local function kickMemberRequestEncoder(msg)
	local input = guildHandler_pb.KickMemberRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function kickMemberRequestDecoder(stream)
	local res = guildHandler_pb.KickMemberResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildHandler.kickMemberRequest(memberId,cb,option)
	local msg = {}
	msg.memberId = memberId
	Socket.OnRequestStart("area.guildHandler.kickMemberRequest", option)
	Socket.Request("area.guildHandler.kickMemberRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildHandler.lastKickMemberResponse = res
			Socket.OnRequestEnd("area.guildHandler.kickMemberRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildHandler.kickMemberRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildHandler.kickMemberRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, kickMemberRequestEncoder, kickMemberRequestDecoder)
end


local function upgradeGuildLevelRequestEncoder(msg)
	local input = guildHandler_pb.UpgradeGuildLevelRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function upgradeGuildLevelRequestDecoder(stream)
	local res = guildHandler_pb.UpgradeGuildLevelResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildHandler.upgradeGuildLevelRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.guildHandler.upgradeGuildLevelRequest", option)
	Socket.Request("area.guildHandler.upgradeGuildLevelRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildHandler.lastUpgradeGuildLevelResponse = res
			Socket.OnRequestEnd("area.guildHandler.upgradeGuildLevelRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildHandler.upgradeGuildLevelRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildHandler.upgradeGuildLevelRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, upgradeGuildLevelRequestEncoder, upgradeGuildLevelRequestDecoder)
end


local function changeGuildNoticeRequestEncoder(msg)
	local input = guildHandler_pb.ChangeGuildNoticeRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function changeGuildNoticeRequestDecoder(stream)
	local res = guildHandler_pb.ChangeGuildNoticeResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildHandler.changeGuildNoticeRequest(notice,cb,option)
	local msg = {}
	msg.notice = notice
	Socket.OnRequestStart("area.guildHandler.changeGuildNoticeRequest", option)
	Socket.Request("area.guildHandler.changeGuildNoticeRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildHandler.lastChangeGuildNoticeResponse = res
			Socket.OnRequestEnd("area.guildHandler.changeGuildNoticeRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildHandler.changeGuildNoticeRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildHandler.changeGuildNoticeRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, changeGuildNoticeRequestEncoder, changeGuildNoticeRequestDecoder)
end


local function changeGuildNameRequestEncoder(msg)
	local input = guildHandler_pb.ChangeGuildNameRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function changeGuildNameRequestDecoder(stream)
	local res = guildHandler_pb.ChangeGuildNameResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildHandler.changeGuildNameRequest(name,cb,option)
	local msg = {}
	msg.name = name
	Socket.OnRequestStart("area.guildHandler.changeGuildNameRequest", option)
	Socket.Request("area.guildHandler.changeGuildNameRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildHandler.lastChangeGuildNameResponse = res
			Socket.OnRequestEnd("area.guildHandler.changeGuildNameRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildHandler.changeGuildNameRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildHandler.changeGuildNameRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, changeGuildNameRequestEncoder, changeGuildNameRequestDecoder)
end


local function changeOfficeNameRequestEncoder(msg)
	local input = guildHandler_pb.ChangeOfficeNameRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function changeOfficeNameRequestDecoder(stream)
	local res = guildHandler_pb.ChangeOfficeNameResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildHandler.changeOfficeNameRequest(officeNames,cb,option)
	local msg = {}
	msg.officeNames = officeNames
	Socket.OnRequestStart("area.guildHandler.changeOfficeNameRequest", option)
	Socket.Request("area.guildHandler.changeOfficeNameRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildHandler.lastChangeOfficeNameResponse = res
			Socket.OnRequestEnd("area.guildHandler.changeOfficeNameRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildHandler.changeOfficeNameRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildHandler.changeOfficeNameRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, changeOfficeNameRequestEncoder, changeOfficeNameRequestDecoder)
end


local function contributeToGuildRequestEncoder(msg)
	local input = guildHandler_pb.ContributeToGuildRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function contributeToGuildRequestDecoder(stream)
	local res = guildHandler_pb.ContributeToGuildResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildHandler.contributeToGuildRequest(type,times,cb,option)
	local msg = {}
	msg.type = type
	msg.times = times
	Socket.OnRequestStart("area.guildHandler.contributeToGuildRequest", option)
	Socket.Request("area.guildHandler.contributeToGuildRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildHandler.lastContributeToGuildResponse = res
			Socket.OnRequestEnd("area.guildHandler.contributeToGuildRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildHandler.contributeToGuildRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildHandler.contributeToGuildRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, contributeToGuildRequestEncoder, contributeToGuildRequestDecoder)
end


local function setMemberJobRequestEncoder(msg)
	local input = guildHandler_pb.SetMemberJobRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function setMemberJobRequestDecoder(stream)
	local res = guildHandler_pb.SetMemberJobResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildHandler.setMemberJobRequest(memberId,job,cb,option)
	local msg = {}
	msg.memberId = memberId
	msg.job = job
	Socket.OnRequestStart("area.guildHandler.setMemberJobRequest", option)
	Socket.Request("area.guildHandler.setMemberJobRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildHandler.lastSetMemberJobResponse = res
			Socket.OnRequestEnd("area.guildHandler.setMemberJobRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildHandler.setMemberJobRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildHandler.setMemberJobRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, setMemberJobRequestEncoder, setMemberJobRequestDecoder)
end


local function transferPresidentRequestEncoder(msg)
	local input = guildHandler_pb.TransferPresidentRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function transferPresidentRequestDecoder(stream)
	local res = guildHandler_pb.TransferPresidentResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildHandler.transferPresidentRequest(memberId,cb,option)
	local msg = {}
	msg.memberId = memberId
	Socket.OnRequestStart("area.guildHandler.transferPresidentRequest", option)
	Socket.Request("area.guildHandler.transferPresidentRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildHandler.lastTransferPresidentResponse = res
			Socket.OnRequestEnd("area.guildHandler.transferPresidentRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildHandler.transferPresidentRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildHandler.transferPresidentRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, transferPresidentRequestEncoder, transferPresidentRequestDecoder)
end


local function getGuildRecordRequestEncoder(msg)
	local input = guildHandler_pb.GetGuildRecordRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getGuildRecordRequestDecoder(stream)
	local res = guildHandler_pb.GetGuildRecordResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildHandler.getGuildRecordRequest(page,cb,option)
	local msg = {}
	msg.page = page
	Socket.OnRequestStart("area.guildHandler.getGuildRecordRequest", option)
	Socket.Request("area.guildHandler.getGuildRecordRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildHandler.lastGetGuildRecordResponse = res
			Socket.OnRequestEnd("area.guildHandler.getGuildRecordRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildHandler.getGuildRecordRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildHandler.getGuildRecordRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getGuildRecordRequestEncoder, getGuildRecordRequestDecoder)
end


local function impeachGuildPresidentRequestEncoder(msg)
	local input = guildHandler_pb.ImpeachGuildPresidentRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function impeachGuildPresidentRequestDecoder(stream)
	local res = guildHandler_pb.ImpeachGuildPresidentResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildHandler.impeachGuildPresidentRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.guildHandler.impeachGuildPresidentRequest", option)
	Socket.Request("area.guildHandler.impeachGuildPresidentRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildHandler.lastImpeachGuildPresidentResponse = res
			Socket.OnRequestEnd("area.guildHandler.impeachGuildPresidentRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildHandler.impeachGuildPresidentRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildHandler.impeachGuildPresidentRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, impeachGuildPresidentRequestEncoder, impeachGuildPresidentRequestDecoder)
end


local function getGuildMoneyRequestEncoder(msg)
	local input = guildHandler_pb.GetGuildMoneyRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getGuildMoneyRequestDecoder(stream)
	local res = guildHandler_pb.GetGuildMoneyResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildHandler.getGuildMoneyRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.guildHandler.getGuildMoneyRequest", option)
	Socket.Request("area.guildHandler.getGuildMoneyRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildHandler.lastGetGuildMoneyResponse = res
			Socket.OnRequestEnd("area.guildHandler.getGuildMoneyRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildHandler.getGuildMoneyRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildHandler.getGuildMoneyRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getGuildMoneyRequestEncoder, getGuildMoneyRequestDecoder)
end


local function joinGuildDungeonRequestEncoder(msg)
	local input = guildHandler_pb.JoinGuildDungeonRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function joinGuildDungeonRequestDecoder(stream)
	local res = guildHandler_pb.JoinGuildDungeonResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildHandler.joinGuildDungeonRequest(c2s_type,cb,option)
	local msg = {}
	msg.c2s_type = c2s_type
	Socket.OnRequestStart("area.guildHandler.joinGuildDungeonRequest", option)
	Socket.Request("area.guildHandler.joinGuildDungeonRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildHandler.lastJoinGuildDungeonResponse = res
			Socket.OnRequestEnd("area.guildHandler.joinGuildDungeonRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildHandler.joinGuildDungeonRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildHandler.joinGuildDungeonRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, joinGuildDungeonRequestEncoder, joinGuildDungeonRequestDecoder)
end


local function leaveGuildDungeonRequestEncoder(msg)
	local input = guildHandler_pb.LeaveGuildDungeonRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function leaveGuildDungeonRequestDecoder(stream)
	local res = guildHandler_pb.LeaveGuildDungeonResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildHandler.leaveGuildDungeonRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.guildHandler.leaveGuildDungeonRequest", option)
	Socket.Request("area.guildHandler.leaveGuildDungeonRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildHandler.lastLeaveGuildDungeonResponse = res
			Socket.OnRequestEnd("area.guildHandler.leaveGuildDungeonRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildHandler.leaveGuildDungeonRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildHandler.leaveGuildDungeonRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, leaveGuildDungeonRequestEncoder, leaveGuildDungeonRequestDecoder)
end


local function guildRefreshPushDecoder(stream)
	local res = guildHandler_pb.GuildRefreshPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildHandler.guildRefreshPush(cb)
	Socket.On("area.guildPush.guildRefreshPush", function(res) 
		Pomelo.GuildHandler.lastGuildRefreshPush = res
		cb(nil,res) 
	end, guildRefreshPushDecoder) 
end


local function guildInvitePushDecoder(stream)
	local res = guildHandler_pb.GuildInvitePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildHandler.guildInvitePush(cb)
	Socket.On("area.guildPush.guildInvitePush", function(res) 
		Pomelo.GuildHandler.lastGuildInvitePush = res
		cb(nil,res) 
	end, guildInvitePushDecoder) 
end


local function onDungeonEndPushDecoder(stream)
	local res = guildHandler_pb.OnDungeonEndPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildHandler.onDungeonEndPush(cb)
	Socket.On("area.guildPush.onDungeonEndPush", function(res) 
		Pomelo.GuildHandler.lastOnDungeonEndPush = res
		cb(nil,res) 
	end, onDungeonEndPushDecoder) 
end


local function guildDungeonOpenPushDecoder(stream)
	local res = guildHandler_pb.GuildDungeonOpenPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildHandler.guildDungeonOpenPush(cb)
	Socket.On("area.guildPush.guildDungeonOpenPush", function(res) 
		Pomelo.GuildHandler.lastGuildDungeonOpenPush = res
		cb(nil,res) 
	end, guildDungeonOpenPushDecoder) 
end


local function guildDungeonPassPushDecoder(stream)
	local res = guildHandler_pb.GuildDungeonPassPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildHandler.guildDungeonPassPush(cb)
	Socket.On("area.guildPush.guildDungeonPassPush", function(res) 
		Pomelo.GuildHandler.lastGuildDungeonPassPush = res
		cb(nil,res) 
	end, guildDungeonPassPushDecoder) 
end


local function guildDungeonPlayerNumPushDecoder(stream)
	local res = guildHandler_pb.GuildDungeonPlayerNumPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildHandler.guildDungeonPlayerNumPush(cb)
	Socket.On("area.guildPush.guildDungeonPlayerNumPush", function(res) 
		Pomelo.GuildHandler.lastGuildDungeonPlayerNumPush = res
		cb(nil,res) 
	end, guildDungeonPlayerNumPushDecoder) 
end





return Pomelo
