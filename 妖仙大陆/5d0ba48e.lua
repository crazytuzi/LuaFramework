





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "guildFortHandler_pb"


Pomelo = Pomelo or {}


Pomelo.GuildFortHandler = {}

local function getGuildAreaListRequestEncoder(msg)
	local input = guildFortHandler_pb.GetGuildAreaListRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getGuildAreaListRequestDecoder(stream)
	local res = guildFortHandler_pb.GetGuildAreaListResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildFortHandler.getGuildAreaListRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.guildFortHandler.getGuildAreaListRequest", option)
	Socket.Request("area.guildFortHandler.getGuildAreaListRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildFortHandler.lastGetGuildAreaListResponse = res
			Socket.OnRequestEnd("area.guildFortHandler.getGuildAreaListRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildFortHandler.getGuildAreaListRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildFortHandler.getGuildAreaListRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getGuildAreaListRequestEncoder, getGuildAreaListRequestDecoder)
end


local function getGuildAreaDetailRequestEncoder(msg)
	local input = guildFortHandler_pb.GetGuildAreaDetailRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getGuildAreaDetailRequestDecoder(stream)
	local res = guildFortHandler_pb.GetGuildAreaDetailResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildFortHandler.getGuildAreaDetailRequest(areaId,cb,option)
	local msg = {}
	msg.areaId = areaId
	Socket.OnRequestStart("area.guildFortHandler.getGuildAreaDetailRequest", option)
	Socket.Request("area.guildFortHandler.getGuildAreaDetailRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildFortHandler.lastGetGuildAreaDetailResponse = res
			Socket.OnRequestEnd("area.guildFortHandler.getGuildAreaDetailRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildFortHandler.getGuildAreaDetailRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildFortHandler.getGuildAreaDetailRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getGuildAreaDetailRequestEncoder, getGuildAreaDetailRequestDecoder)
end


local function getGuildAreaApplyListRequestEncoder(msg)
	local input = guildFortHandler_pb.GetGuildAreaApplyListRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getGuildAreaApplyListRequestDecoder(stream)
	local res = guildFortHandler_pb.GetGuildAreaApplyListResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildFortHandler.getGuildAreaApplyListRequest(areaId,cb,option)
	local msg = {}
	msg.areaId = areaId
	Socket.OnRequestStart("area.guildFortHandler.getGuildAreaApplyListRequest", option)
	Socket.Request("area.guildFortHandler.getGuildAreaApplyListRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildFortHandler.lastGetGuildAreaApplyListResponse = res
			Socket.OnRequestEnd("area.guildFortHandler.getGuildAreaApplyListRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildFortHandler.getGuildAreaApplyListRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildFortHandler.getGuildAreaApplyListRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getGuildAreaApplyListRequestEncoder, getGuildAreaApplyListRequestDecoder)
end


local function applyGuildFundRequestEncoder(msg)
	local input = guildFortHandler_pb.ApplyGuildFundRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function applyGuildFundRequestDecoder(stream)
	local res = guildFortHandler_pb.ApplyGuildFundResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildFortHandler.applyGuildFundRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.guildFortHandler.applyGuildFundRequest", option)
	Socket.Request("area.guildFortHandler.applyGuildFundRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildFortHandler.lastApplyGuildFundResponse = res
			Socket.OnRequestEnd("area.guildFortHandler.applyGuildFundRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildFortHandler.applyGuildFundRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildFortHandler.applyGuildFundRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, applyGuildFundRequestEncoder, applyGuildFundRequestDecoder)
end


local function applyFundRequestEncoder(msg)
	local input = guildFortHandler_pb.ApplyFundRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function applyFundRequestDecoder(stream)
	local res = guildFortHandler_pb.ApplyFundResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildFortHandler.applyFundRequest(areaId,applyFund,cb,option)
	local msg = {}
	msg.areaId = areaId
	msg.applyFund = applyFund
	Socket.OnRequestStart("area.guildFortHandler.applyFundRequest", option)
	Socket.Request("area.guildFortHandler.applyFundRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildFortHandler.lastApplyFundResponse = res
			Socket.OnRequestEnd("area.guildFortHandler.applyFundRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildFortHandler.applyFundRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildFortHandler.applyFundRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, applyFundRequestEncoder, applyFundRequestDecoder)
end


local function applyCancelFundRequestEncoder(msg)
	local input = guildFortHandler_pb.ApplyCancelFundRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function applyCancelFundRequestDecoder(stream)
	local res = guildFortHandler_pb.ApplyCancelFundResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildFortHandler.applyCancelFundRequest(areaId,cb,option)
	local msg = {}
	msg.areaId = areaId
	Socket.OnRequestStart("area.guildFortHandler.applyCancelFundRequest", option)
	Socket.Request("area.guildFortHandler.applyCancelFundRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildFortHandler.lastApplyCancelFundResponse = res
			Socket.OnRequestEnd("area.guildFortHandler.applyCancelFundRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildFortHandler.applyCancelFundRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildFortHandler.applyCancelFundRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, applyCancelFundRequestEncoder, applyCancelFundRequestDecoder)
end


local function applyDailyAwardListRequestEncoder(msg)
	local input = guildFortHandler_pb.ApplyDailyAwardListRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function applyDailyAwardListRequestDecoder(stream)
	local res = guildFortHandler_pb.ApplyDailyAwardListResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildFortHandler.applyDailyAwardListRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.guildFortHandler.applyDailyAwardListRequest", option)
	Socket.Request("area.guildFortHandler.applyDailyAwardListRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildFortHandler.lastApplyDailyAwardListResponse = res
			Socket.OnRequestEnd("area.guildFortHandler.applyDailyAwardListRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildFortHandler.applyDailyAwardListRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildFortHandler.applyDailyAwardListRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, applyDailyAwardListRequestEncoder, applyDailyAwardListRequestDecoder)
end


local function applyDailyAwardRequestEncoder(msg)
	local input = guildFortHandler_pb.ApplyDailyAwardRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function applyDailyAwardRequestDecoder(stream)
	local res = guildFortHandler_pb.ApplyDailyAwardResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildFortHandler.applyDailyAwardRequest(areaId,cb,option)
	local msg = {}
	msg.areaId = areaId
	Socket.OnRequestStart("area.guildFortHandler.applyDailyAwardRequest", option)
	Socket.Request("area.guildFortHandler.applyDailyAwardRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildFortHandler.lastApplyDailyAwardResponse = res
			Socket.OnRequestEnd("area.guildFortHandler.applyDailyAwardRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildFortHandler.applyDailyAwardRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildFortHandler.applyDailyAwardRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, applyDailyAwardRequestEncoder, applyDailyAwardRequestDecoder)
end


local function applyAccessRequestEncoder(msg)
	local input = guildFortHandler_pb.ApplyAccessRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function applyAccessRequestDecoder(stream)
	local res = guildFortHandler_pb.ApplyAccessResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildFortHandler.applyAccessRequest(areaId,cb,option)
	local msg = {}
	msg.areaId = areaId
	Socket.OnRequestStart("area.guildFortHandler.applyAccessRequest", option)
	Socket.Request("area.guildFortHandler.applyAccessRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildFortHandler.lastApplyAccessResponse = res
			Socket.OnRequestEnd("area.guildFortHandler.applyAccessRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildFortHandler.applyAccessRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildFortHandler.applyAccessRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, applyAccessRequestEncoder, applyAccessRequestDecoder)
end


local function applyFortGuildInfoRequestEncoder(msg)
	local input = guildFortHandler_pb.ApplyFortGuildInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function applyFortGuildInfoRequestDecoder(stream)
	local res = guildFortHandler_pb.ApplyFortGuildInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildFortHandler.applyFortGuildInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.guildFortHandler.applyFortGuildInfoRequest", option)
	Socket.Request("area.guildFortHandler.applyFortGuildInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildFortHandler.lastApplyFortGuildInfoResponse = res
			Socket.OnRequestEnd("area.guildFortHandler.applyFortGuildInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildFortHandler.applyFortGuildInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildFortHandler.applyFortGuildInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, applyFortGuildInfoRequestEncoder, applyFortGuildInfoRequestDecoder)
end


local function applyAllReportListRequestEncoder(msg)
	local input = guildFortHandler_pb.ApplyAllReportListRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function applyAllReportListRequestDecoder(stream)
	local res = guildFortHandler_pb.ApplyAllReportListResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildFortHandler.applyAllReportListRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.guildFortHandler.applyAllReportListRequest", option)
	Socket.Request("area.guildFortHandler.applyAllReportListRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildFortHandler.lastApplyAllReportListResponse = res
			Socket.OnRequestEnd("area.guildFortHandler.applyAllReportListRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildFortHandler.applyAllReportListRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildFortHandler.applyAllReportListRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, applyAllReportListRequestEncoder, applyAllReportListRequestDecoder)
end


local function applyReportDetailRequestEncoder(msg)
	local input = guildFortHandler_pb.ApplyReportDetailRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function applyReportDetailRequestDecoder(stream)
	local res = guildFortHandler_pb.ApplyReportDetailResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildFortHandler.applyReportDetailRequest(date,areaId,cb,option)
	local msg = {}
	msg.date = date
	msg.areaId = areaId
	Socket.OnRequestStart("area.guildFortHandler.applyReportDetailRequest", option)
	Socket.Request("area.guildFortHandler.applyReportDetailRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildFortHandler.lastApplyReportDetailResponse = res
			Socket.OnRequestEnd("area.guildFortHandler.applyReportDetailRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildFortHandler.applyReportDetailRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildFortHandler.applyReportDetailRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, applyReportDetailRequestEncoder, applyReportDetailRequestDecoder)
end


local function applyReportStatisticsRequestEncoder(msg)
	local input = guildFortHandler_pb.ApplyReportStatisticsRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function applyReportStatisticsRequestDecoder(stream)
	local res = guildFortHandler_pb.ApplyReportStatisticsResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildFortHandler.applyReportStatisticsRequest(date,areaId,guildId,cb,option)
	local msg = {}
	msg.date = date
	msg.areaId = areaId
	msg.guildId = guildId
	Socket.OnRequestStart("area.guildFortHandler.applyReportStatisticsRequest", option)
	Socket.Request("area.guildFortHandler.applyReportStatisticsRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildFortHandler.lastApplyReportStatisticsResponse = res
			Socket.OnRequestEnd("area.guildFortHandler.applyReportStatisticsRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildFortHandler.applyReportStatisticsRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildFortHandler.applyReportStatisticsRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, applyReportStatisticsRequestEncoder, applyReportStatisticsRequestDecoder)
end


local function onGuildFortPushDecoder(stream)
	local res = guildFortHandler_pb.OnGuildFortPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildFortHandler.onGuildFortPush(cb)
	Socket.On("area.guildFortPush.onGuildFortPush", function(res) 
		Pomelo.GuildFortHandler.lastOnGuildFortPush = res
		cb(nil,res) 
	end, onGuildFortPushDecoder) 
end


local function onGuildResultPushDecoder(stream)
	local res = guildFortHandler_pb.OnGuildResultPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildFortHandler.onGuildResultPush(cb)
	Socket.On("area.guildFortPush.onGuildResultPush", function(res) 
		Pomelo.GuildFortHandler.lastOnGuildResultPush = res
		cb(nil,res) 
	end, onGuildResultPushDecoder) 
end





return Pomelo
