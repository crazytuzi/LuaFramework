





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "activityHandler_pb"


Pomelo = Pomelo or {}


Pomelo.ActivityHandler = {}

local function activityLsRequestEncoder(msg)
	local input = activityHandler_pb.ActivityLsRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function activityLsRequestDecoder(stream)
	local res = activityHandler_pb.ActivityLsResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ActivityHandler.activityLsRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.activityHandler.activityLsRequest", option)
	Socket.Request("area.activityHandler.activityLsRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ActivityHandler.lastActivityLsResponse = res
			Socket.OnRequestEnd("area.activityHandler.activityLsRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.activityHandler.activityLsRequest decode error!!"
			end
			Socket.OnRequestEnd("area.activityHandler.activityLsRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, activityLsRequestEncoder, activityLsRequestDecoder)
end


local function interestActivityAdRequestEncoder(msg)
	local input = activityHandler_pb.InterestActivityAdRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function interestActivityAdRequestDecoder(stream)
	local res = activityHandler_pb.InterestActivityAdResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ActivityHandler.interestActivityAdRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.activityHandler.interestActivityAdRequest", option)
	Socket.Request("area.activityHandler.interestActivityAdRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ActivityHandler.lastInterestActivityAdResponse = res
			Socket.OnRequestEnd("area.activityHandler.interestActivityAdRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.activityHandler.interestActivityAdRequest decode error!!"
			end
			Socket.OnRequestEnd("area.activityHandler.interestActivityAdRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, interestActivityAdRequestEncoder, interestActivityAdRequestDecoder)
end


local function payFirstRequestEncoder(msg)
	local input = activityHandler_pb.PayFirstRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function payFirstRequestDecoder(stream)
	local res = activityHandler_pb.PayFirstResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ActivityHandler.payFirstRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.activityHandler.payFirstRequest", option)
	Socket.Request("area.activityHandler.payFirstRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ActivityHandler.lastPayFirstResponse = res
			Socket.OnRequestEnd("area.activityHandler.payFirstRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.activityHandler.payFirstRequest decode error!!"
			end
			Socket.OnRequestEnd("area.activityHandler.payFirstRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, payFirstRequestEncoder, payFirstRequestDecoder)
end


local function paySecondRequestEncoder(msg)
	local input = activityHandler_pb.PaySecondRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function paySecondRequestDecoder(stream)
	local res = activityHandler_pb.PaySecondResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ActivityHandler.paySecondRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.activityHandler.paySecondRequest", option)
	Socket.Request("area.activityHandler.paySecondRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ActivityHandler.lastPaySecondResponse = res
			Socket.OnRequestEnd("area.activityHandler.paySecondRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.activityHandler.paySecondRequest decode error!!"
			end
			Socket.OnRequestEnd("area.activityHandler.paySecondRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, paySecondRequestEncoder, paySecondRequestDecoder)
end


local function payTotalRequestEncoder(msg)
	local input = activityHandler_pb.PayTotalRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function payTotalRequestDecoder(stream)
	local res = activityHandler_pb.PayTotalResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ActivityHandler.payTotalRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.activityHandler.payTotalRequest", option)
	Socket.Request("area.activityHandler.payTotalRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ActivityHandler.lastPayTotalResponse = res
			Socket.OnRequestEnd("area.activityHandler.payTotalRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.activityHandler.payTotalRequest decode error!!"
			end
			Socket.OnRequestEnd("area.activityHandler.payTotalRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, payTotalRequestEncoder, payTotalRequestDecoder)
end


local function consumeTotalRequestEncoder(msg)
	local input = activityHandler_pb.ConsumeTotalRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function consumeTotalRequestDecoder(stream)
	local res = activityHandler_pb.ConsumeTotalResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ActivityHandler.consumeTotalRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.activityHandler.consumeTotalRequest", option)
	Socket.Request("area.activityHandler.consumeTotalRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ActivityHandler.lastConsumeTotalResponse = res
			Socket.OnRequestEnd("area.activityHandler.consumeTotalRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.activityHandler.consumeTotalRequest decode error!!"
			end
			Socket.OnRequestEnd("area.activityHandler.consumeTotalRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, consumeTotalRequestEncoder, consumeTotalRequestDecoder)
end


local function activityAwardRequestEncoder(msg)
	local input = activityHandler_pb.ActivityAwardRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function activityAwardRequestDecoder(stream)
	local res = activityHandler_pb.ActivityAwardResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ActivityHandler.activityAwardRequest(s2c_awardId,s2c_activityId,cb,option)
	local msg = {}
	msg.s2c_awardId = s2c_awardId
	msg.s2c_activityId = s2c_activityId
	Socket.OnRequestStart("area.activityHandler.activityAwardRequest", option)
	Socket.Request("area.activityHandler.activityAwardRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ActivityHandler.lastActivityAwardResponse = res
			Socket.OnRequestEnd("area.activityHandler.activityAwardRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.activityHandler.activityAwardRequest decode error!!"
			end
			Socket.OnRequestEnd("area.activityHandler.activityAwardRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, activityAwardRequestEncoder, activityAwardRequestDecoder)
end


local function activityInviteCodeRequestEncoder(msg)
	local input = activityHandler_pb.ActivityInviteCodeRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function activityInviteCodeRequestDecoder(stream)
	local res = activityHandler_pb.ActivityInviteCodeResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ActivityHandler.activityInviteCodeRequest(c2s_inviteCode,cb,option)
	local msg = {}
	msg.c2s_inviteCode = c2s_inviteCode
	Socket.OnRequestStart("area.activityHandler.activityInviteCodeRequest", option)
	Socket.Request("area.activityHandler.activityInviteCodeRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ActivityHandler.lastActivityInviteCodeResponse = res
			Socket.OnRequestEnd("area.activityHandler.activityInviteCodeRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.activityHandler.activityInviteCodeRequest decode error!!"
			end
			Socket.OnRequestEnd("area.activityHandler.activityInviteCodeRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, activityInviteCodeRequestEncoder, activityInviteCodeRequestDecoder)
end


local function activityNoticeRequestEncoder(msg)
	local input = activityHandler_pb.ActivityNoticeReq()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function activityNoticeRequestDecoder(stream)
	local res = activityHandler_pb.ActivityNoticeRes()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ActivityHandler.activityNoticeRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.activityHandler.activityNoticeRequest", option)
	Socket.Request("area.activityHandler.activityNoticeRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ActivityHandler.lastActivityNoticeRes = res
			Socket.OnRequestEnd("area.activityHandler.activityNoticeRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.activityHandler.activityNoticeRequest decode error!!"
			end
			Socket.OnRequestEnd("area.activityHandler.activityNoticeRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, activityNoticeRequestEncoder, activityNoticeRequestDecoder)
end


local function activityLevelOrSwordRequestEncoder(msg)
	local input = activityHandler_pb.ActivityLevelOrSwordRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function activityLevelOrSwordRequestDecoder(stream)
	local res = activityHandler_pb.ActivityLevelOrSwordResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ActivityHandler.activityLevelOrSwordRequest(c2s_activityId,cb,option)
	local msg = {}
	msg.c2s_activityId = c2s_activityId
	Socket.OnRequestStart("area.activityHandler.activityLevelOrSwordRequest", option)
	Socket.Request("area.activityHandler.activityLevelOrSwordRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ActivityHandler.lastActivityLevelOrSwordResponse = res
			Socket.OnRequestEnd("area.activityHandler.activityLevelOrSwordRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.activityHandler.activityLevelOrSwordRequest decode error!!"
			end
			Socket.OnRequestEnd("area.activityHandler.activityLevelOrSwordRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, activityLevelOrSwordRequestEncoder, activityLevelOrSwordRequestDecoder)
end


local function activityBuyFundsRequestEncoder(msg)
	local input = activityHandler_pb.ActivityBuyFundsReq()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function activityBuyFundsRequestDecoder(stream)
	local res = activityHandler_pb.ActivityBuyFundsRes()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ActivityHandler.activityBuyFundsRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.activityHandler.activityBuyFundsRequest", option)
	Socket.Request("area.activityHandler.activityBuyFundsRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ActivityHandler.lastActivityBuyFundsRes = res
			Socket.OnRequestEnd("area.activityHandler.activityBuyFundsRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.activityHandler.activityBuyFundsRequest decode error!!"
			end
			Socket.OnRequestEnd("area.activityHandler.activityBuyFundsRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, activityBuyFundsRequestEncoder, activityBuyFundsRequestDecoder)
end


local function activityOpenFundsRequestEncoder(msg)
	local input = activityHandler_pb.ActivityOpenFundsReq()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function activityOpenFundsRequestDecoder(stream)
	local res = activityHandler_pb.ActivityOpenFundsRes()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ActivityHandler.activityOpenFundsRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.activityHandler.activityOpenFundsRequest", option)
	Socket.Request("area.activityHandler.activityOpenFundsRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ActivityHandler.lastActivityOpenFundsRes = res
			Socket.OnRequestEnd("area.activityHandler.activityOpenFundsRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.activityHandler.activityOpenFundsRequest decode error!!"
			end
			Socket.OnRequestEnd("area.activityHandler.activityOpenFundsRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, activityOpenFundsRequestEncoder, activityOpenFundsRequestDecoder)
end


local function activityLuckyAwardViewRequestEncoder(msg)
	local input = activityHandler_pb.ActivityLuckyAwardViewRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function activityLuckyAwardViewRequestDecoder(stream)
	local res = activityHandler_pb.ActivityLuckyAwardViewResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ActivityHandler.activityLuckyAwardViewRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.activityHandler.activityLuckyAwardViewRequest", option)
	Socket.Request("area.activityHandler.activityLuckyAwardViewRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ActivityHandler.lastActivityLuckyAwardViewResponse = res
			Socket.OnRequestEnd("area.activityHandler.activityLuckyAwardViewRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.activityHandler.activityLuckyAwardViewRequest decode error!!"
			end
			Socket.OnRequestEnd("area.activityHandler.activityLuckyAwardViewRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, activityLuckyAwardViewRequestEncoder, activityLuckyAwardViewRequestDecoder)
end


local function luckyAwardViewRequestEncoder(msg)
	local input = activityHandler_pb.LuckyAwardViewRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function luckyAwardViewRequestDecoder(stream)
	local res = activityHandler_pb.LuckyAwardViewResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ActivityHandler.luckyAwardViewRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.activityHandler.luckyAwardViewRequest", option)
	Socket.Request("area.activityHandler.luckyAwardViewRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ActivityHandler.lastLuckyAwardViewResponse = res
			Socket.OnRequestEnd("area.activityHandler.luckyAwardViewRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.activityHandler.luckyAwardViewRequest decode error!!"
			end
			Socket.OnRequestEnd("area.activityHandler.luckyAwardViewRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, luckyAwardViewRequestEncoder, luckyAwardViewRequestDecoder)
end


local function reSetluckyAwardRequestEncoder(msg)
	local input = activityHandler_pb.ReSetluckyAwardRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function reSetluckyAwardRequestDecoder(stream)
	local res = activityHandler_pb.ReSetluckyAwardResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ActivityHandler.reSetluckyAwardRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.activityHandler.reSetluckyAwardRequest", option)
	Socket.Request("area.activityHandler.reSetluckyAwardRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ActivityHandler.lastReSetluckyAwardResponse = res
			Socket.OnRequestEnd("area.activityHandler.reSetluckyAwardRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.activityHandler.reSetluckyAwardRequest decode error!!"
			end
			Socket.OnRequestEnd("area.activityHandler.reSetluckyAwardRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, reSetluckyAwardRequestEncoder, reSetluckyAwardRequestDecoder)
end


local function openSevenDayRequestEncoder(msg)
	local input = activityHandler_pb.OpenSevenDayRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function openSevenDayRequestDecoder(stream)
	local res = activityHandler_pb.OpenSevenDayResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ActivityHandler.openSevenDayRequest(c2s_day,cb,option)
	local msg = {}
	msg.c2s_day = c2s_day
	Socket.OnRequestStart("area.activityHandler.openSevenDayRequest", option)
	Socket.Request("area.activityHandler.openSevenDayRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ActivityHandler.lastOpenSevenDayResponse = res
			Socket.OnRequestEnd("area.activityHandler.openSevenDayRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.activityHandler.openSevenDayRequest decode error!!"
			end
			Socket.OnRequestEnd("area.activityHandler.openSevenDayRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, openSevenDayRequestEncoder, openSevenDayRequestDecoder)
end


local function openChangeRequestEncoder(msg)
	local input = activityHandler_pb.OpenChangeRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function openChangeRequestDecoder(stream)
	local res = activityHandler_pb.OpenChangeResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ActivityHandler.openChangeRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.activityHandler.openChangeRequest", option)
	Socket.Request("area.activityHandler.openChangeRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ActivityHandler.lastOpenChangeResponse = res
			Socket.OnRequestEnd("area.activityHandler.openChangeRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.activityHandler.openChangeRequest decode error!!"
			end
			Socket.OnRequestEnd("area.activityHandler.openChangeRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, openChangeRequestEncoder, openChangeRequestDecoder)
end


local function activityDrawInfoRequestEncoder(msg)
	local input = activityHandler_pb.ActivityDrawInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function activityDrawInfoRequestDecoder(stream)
	local res = activityHandler_pb.ActivityDrawInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ActivityHandler.activityDrawInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.activityHandler.activityDrawInfoRequest", option)
	Socket.Request("area.activityHandler.activityDrawInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ActivityHandler.lastActivityDrawInfoResponse = res
			Socket.OnRequestEnd("area.activityHandler.activityDrawInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.activityHandler.activityDrawInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.activityHandler.activityDrawInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, activityDrawInfoRequestEncoder, activityDrawInfoRequestDecoder)
end


local function drawInfoRequestEncoder(msg)
	local input = activityHandler_pb.DrawInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function drawInfoRequestDecoder(stream)
	local res = activityHandler_pb.DrawInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ActivityHandler.drawInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.activityHandler.drawInfoRequest", option)
	Socket.Request("area.activityHandler.drawInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ActivityHandler.lastDrawInfoResponse = res
			Socket.OnRequestEnd("area.activityHandler.drawInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.activityHandler.drawInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.activityHandler.drawInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, drawInfoRequestEncoder, drawInfoRequestDecoder)
end


local function drawRankRequestEncoder(msg)
	local input = activityHandler_pb.DrawRankRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function drawRankRequestDecoder(stream)
	local res = activityHandler_pb.DrawRankResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ActivityHandler.drawRankRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.activityHandler.drawRankRequest", option)
	Socket.Request("area.activityHandler.drawRankRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ActivityHandler.lastDrawRankResponse = res
			Socket.OnRequestEnd("area.activityHandler.drawRankRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.activityHandler.drawRankRequest decode error!!"
			end
			Socket.OnRequestEnd("area.activityHandler.drawRankRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, drawRankRequestEncoder, drawRankRequestDecoder)
end


local function drawSetLowRequestEncoder(msg)
	local input = activityHandler_pb.DrawSetLowRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function drawSetLowRequestDecoder(stream)
	local res = activityHandler_pb.DrawSetLowResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ActivityHandler.drawSetLowRequest(isLow,cb,option)
	local msg = {}
	msg.isLow = isLow
	Socket.OnRequestStart("area.activityHandler.drawSetLowRequest", option)
	Socket.Request("area.activityHandler.drawSetLowRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ActivityHandler.lastDrawSetLowResponse = res
			Socket.OnRequestEnd("area.activityHandler.drawSetLowRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.activityHandler.drawSetLowRequest decode error!!"
			end
			Socket.OnRequestEnd("area.activityHandler.drawSetLowRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, drawSetLowRequestEncoder, drawSetLowRequestDecoder)
end


local function drawAwardRequestEncoder(msg)
	local input = activityHandler_pb.DrawAwardRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function drawAwardRequestDecoder(stream)
	local res = activityHandler_pb.DrawAwardResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ActivityHandler.drawAwardRequest(type,useItem,cb,option)
	local msg = {}
	msg.type = type
	msg.useItem = useItem
	Socket.OnRequestStart("area.activityHandler.drawAwardRequest", option)
	Socket.Request("area.activityHandler.drawAwardRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ActivityHandler.lastDrawAwardResponse = res
			Socket.OnRequestEnd("area.activityHandler.drawAwardRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.activityHandler.drawAwardRequest decode error!!"
			end
			Socket.OnRequestEnd("area.activityHandler.drawAwardRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, drawAwardRequestEncoder, drawAwardRequestDecoder)
end





return Pomelo
