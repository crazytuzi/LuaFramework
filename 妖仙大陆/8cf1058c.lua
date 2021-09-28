





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "daoYouHandler_pb"


Pomelo = Pomelo or {}


Pomelo.DaoYouHandler = {}

local function daoYouRequestEncoder(msg)
	local input = daoYouHandler_pb.DaoYouRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function daoYouRequestDecoder(stream)
	local res = daoYouHandler_pb.DaoYouResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.DaoYouHandler.daoYouRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("daoyou.daoYouHandler.daoYouRequest", option)
	Socket.Request("daoyou.daoYouHandler.daoYouRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.DaoYouHandler.lastDaoYouResponse = res
			Socket.OnRequestEnd("daoyou.daoYouHandler.daoYouRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] daoyou.daoYouHandler.daoYouRequest decode error!!"
			end
			Socket.OnRequestEnd("daoyou.daoYouHandler.daoYouRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, daoYouRequestEncoder, daoYouRequestDecoder)
end


local function daoYouInviteDaoYouRequestEncoder(msg)
	local input = daoYouHandler_pb.DaoYouInviteDaoYouRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function daoYouInviteDaoYouRequestDecoder(stream)
	local res = daoYouHandler_pb.DaoYouInviteDaoYouResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.DaoYouHandler.daoYouInviteDaoYouRequest(playerId,cb,option)
	local msg = {}
	msg.playerId = playerId
	Socket.OnRequestStart("daoyou.daoYouHandler.daoYouInviteDaoYouRequest", option)
	Socket.Request("daoyou.daoYouHandler.daoYouInviteDaoYouRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.DaoYouHandler.lastDaoYouInviteDaoYouResponse = res
			Socket.OnRequestEnd("daoyou.daoYouHandler.daoYouInviteDaoYouRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] daoyou.daoYouHandler.daoYouInviteDaoYouRequest decode error!!"
			end
			Socket.OnRequestEnd("daoyou.daoYouHandler.daoYouInviteDaoYouRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, daoYouInviteDaoYouRequestEncoder, daoYouInviteDaoYouRequestDecoder)
end


local function daoYouFastInviteDaoYouRequestEncoder(msg)
	local input = daoYouHandler_pb.DaoYouFastInviteDaoYouRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function daoYouFastInviteDaoYouRequestDecoder(stream)
	local res = daoYouHandler_pb.DaoYouFastInviteDaoYouResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.DaoYouHandler.daoYouFastInviteDaoYouRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("daoyou.daoYouHandler.daoYouFastInviteDaoYouRequest", option)
	Socket.Request("daoyou.daoYouHandler.daoYouFastInviteDaoYouRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.DaoYouHandler.lastDaoYouFastInviteDaoYouResponse = res
			Socket.OnRequestEnd("daoyou.daoYouHandler.daoYouFastInviteDaoYouRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] daoyou.daoYouHandler.daoYouFastInviteDaoYouRequest decode error!!"
			end
			Socket.OnRequestEnd("daoyou.daoYouHandler.daoYouFastInviteDaoYouRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, daoYouFastInviteDaoYouRequestEncoder, daoYouFastInviteDaoYouRequestDecoder)
end


local function daoYouEditTeamNameRequestEncoder(msg)
	local input = daoYouHandler_pb.DaoYouEditTeamNameRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function daoYouEditTeamNameRequestDecoder(stream)
	local res = daoYouHandler_pb.DaoYouEditTeamNameResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.DaoYouHandler.daoYouEditTeamNameRequest(teamName,cb,option)
	local msg = {}
	msg.teamName = teamName
	Socket.OnRequestStart("daoyou.daoYouHandler.daoYouEditTeamNameRequest", option)
	Socket.Request("daoyou.daoYouHandler.daoYouEditTeamNameRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.DaoYouHandler.lastDaoYouEditTeamNameResponse = res
			Socket.OnRequestEnd("daoyou.daoYouHandler.daoYouEditTeamNameRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] daoyou.daoYouHandler.daoYouEditTeamNameRequest decode error!!"
			end
			Socket.OnRequestEnd("daoyou.daoYouHandler.daoYouEditTeamNameRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, daoYouEditTeamNameRequestEncoder, daoYouEditTeamNameRequestDecoder)
end


local function daoYouLeaveMessageRequestEncoder(msg)
	local input = daoYouHandler_pb.DaoYouLeaveMessageRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function daoYouLeaveMessageRequestDecoder(stream)
	local res = daoYouHandler_pb.DaoYouLeaveMessageResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.DaoYouHandler.daoYouLeaveMessageRequest(message,cb,option)
	local msg = {}
	msg.message = message
	Socket.OnRequestStart("daoyou.daoYouHandler.daoYouLeaveMessageRequest", option)
	Socket.Request("daoyou.daoYouHandler.daoYouLeaveMessageRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.DaoYouHandler.lastDaoYouLeaveMessageResponse = res
			Socket.OnRequestEnd("daoyou.daoYouHandler.daoYouLeaveMessageRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] daoyou.daoYouHandler.daoYouLeaveMessageRequest decode error!!"
			end
			Socket.OnRequestEnd("daoyou.daoYouHandler.daoYouLeaveMessageRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, daoYouLeaveMessageRequestEncoder, daoYouLeaveMessageRequestDecoder)
end


local function daoYouNoticeRequestEncoder(msg)
	local input = daoYouHandler_pb.DaoYouNoticeRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function daoYouNoticeRequestDecoder(stream)
	local res = daoYouHandler_pb.DaoYouNoticeResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.DaoYouHandler.daoYouNoticeRequest(notice,cb,option)
	local msg = {}
	msg.notice = notice
	Socket.OnRequestStart("daoyou.daoYouHandler.daoYouNoticeRequest", option)
	Socket.Request("daoyou.daoYouHandler.daoYouNoticeRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.DaoYouHandler.lastDaoYouNoticeResponse = res
			Socket.OnRequestEnd("daoyou.daoYouHandler.daoYouNoticeRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] daoyou.daoYouHandler.daoYouNoticeRequest decode error!!"
			end
			Socket.OnRequestEnd("daoyou.daoYouHandler.daoYouNoticeRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, daoYouNoticeRequestEncoder, daoYouNoticeRequestDecoder)
end


local function daoYouKickTeamRequestEncoder(msg)
	local input = daoYouHandler_pb.DaoYouKickTeamRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function daoYouKickTeamRequestDecoder(stream)
	local res = daoYouHandler_pb.DaoYouKickTeamResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.DaoYouHandler.daoYouKickTeamRequest(playerId,cb,option)
	local msg = {}
	msg.playerId = playerId
	Socket.OnRequestStart("daoyou.daoYouHandler.daoYouKickTeamRequest", option)
	Socket.Request("daoyou.daoYouHandler.daoYouKickTeamRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.DaoYouHandler.lastDaoYouKickTeamResponse = res
			Socket.OnRequestEnd("daoyou.daoYouHandler.daoYouKickTeamRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] daoyou.daoYouHandler.daoYouKickTeamRequest decode error!!"
			end
			Socket.OnRequestEnd("daoyou.daoYouHandler.daoYouKickTeamRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, daoYouKickTeamRequestEncoder, daoYouKickTeamRequestDecoder)
end


local function daoYouTransferAdminRequestEncoder(msg)
	local input = daoYouHandler_pb.DaoYouTransferAdminRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function daoYouTransferAdminRequestDecoder(stream)
	local res = daoYouHandler_pb.DaoYouTransferAdminResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.DaoYouHandler.daoYouTransferAdminRequest(playerId,cb,option)
	local msg = {}
	msg.playerId = playerId
	Socket.OnRequestStart("daoyou.daoYouHandler.daoYouTransferAdminRequest", option)
	Socket.Request("daoyou.daoYouHandler.daoYouTransferAdminRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.DaoYouHandler.lastDaoYouTransferAdminResponse = res
			Socket.OnRequestEnd("daoyou.daoYouHandler.daoYouTransferAdminRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] daoyou.daoYouHandler.daoYouTransferAdminRequest decode error!!"
			end
			Socket.OnRequestEnd("daoyou.daoYouHandler.daoYouTransferAdminRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, daoYouTransferAdminRequestEncoder, daoYouTransferAdminRequestDecoder)
end


local function daoYouQuitTeamRequestEncoder(msg)
	local input = daoYouHandler_pb.DaoYouQuitTeamRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function daoYouQuitTeamRequestDecoder(stream)
	local res = daoYouHandler_pb.DaoYouQuitTeamResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.DaoYouHandler.daoYouQuitTeamRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("daoyou.daoYouHandler.daoYouQuitTeamRequest", option)
	Socket.Request("daoyou.daoYouHandler.daoYouQuitTeamRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.DaoYouHandler.lastDaoYouQuitTeamResponse = res
			Socket.OnRequestEnd("daoyou.daoYouHandler.daoYouQuitTeamRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] daoyou.daoYouHandler.daoYouQuitTeamRequest decode error!!"
			end
			Socket.OnRequestEnd("daoyou.daoYouHandler.daoYouQuitTeamRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, daoYouQuitTeamRequestEncoder, daoYouQuitTeamRequestDecoder)
end


local function daoYouRebateRequestEncoder(msg)
	local input = daoYouHandler_pb.DaoYouRebateRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function daoYouRebateRequestDecoder(stream)
	local res = daoYouHandler_pb.DaoYouRebateResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.DaoYouHandler.daoYouRebateRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("daoyou.daoYouHandler.daoYouRebateRequest", option)
	Socket.Request("daoyou.daoYouHandler.daoYouRebateRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.DaoYouHandler.lastDaoYouRebateResponse = res
			Socket.OnRequestEnd("daoyou.daoYouHandler.daoYouRebateRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] daoyou.daoYouHandler.daoYouRebateRequest decode error!!"
			end
			Socket.OnRequestEnd("daoyou.daoYouHandler.daoYouRebateRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, daoYouRebateRequestEncoder, daoYouRebateRequestDecoder)
end





return Pomelo
