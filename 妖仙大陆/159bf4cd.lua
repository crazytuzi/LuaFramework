





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "activityFavorHandler_pb"


Pomelo = Pomelo or {}


Pomelo.ActivityFavorHandler = {}

local function dailyRechargeGetInfoRequestEncoder(msg)
	local input = activityFavorHandler_pb.DailyRechargeGetInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function dailyRechargeGetInfoRequestDecoder(stream)
	local res = activityFavorHandler_pb.DailyRechargeGetInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ActivityFavorHandler.dailyRechargeGetInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.activityFavorHandler.dailyRechargeGetInfoRequest", option)
	Socket.Request("area.activityFavorHandler.dailyRechargeGetInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ActivityFavorHandler.lastDailyRechargeGetInfoResponse = res
			Socket.OnRequestEnd("area.activityFavorHandler.dailyRechargeGetInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.activityFavorHandler.dailyRechargeGetInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.activityFavorHandler.dailyRechargeGetInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, dailyRechargeGetInfoRequestEncoder, dailyRechargeGetInfoRequestDecoder)
end


local function dailyRechargeGetAwardRequestEncoder(msg)
	local input = activityFavorHandler_pb.DailyRechargeGetAwardRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function dailyRechargeGetAwardRequestDecoder(stream)
	local res = activityFavorHandler_pb.DailyRechargeGetAwardResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ActivityFavorHandler.dailyRechargeGetAwardRequest(awardId,cb,option)
	local msg = {}
	msg.awardId = awardId
	Socket.OnRequestStart("area.activityFavorHandler.dailyRechargeGetAwardRequest", option)
	Socket.Request("area.activityFavorHandler.dailyRechargeGetAwardRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ActivityFavorHandler.lastDailyRechargeGetAwardResponse = res
			Socket.OnRequestEnd("area.activityFavorHandler.dailyRechargeGetAwardRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.activityFavorHandler.dailyRechargeGetAwardRequest decode error!!"
			end
			Socket.OnRequestEnd("area.activityFavorHandler.dailyRechargeGetAwardRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, dailyRechargeGetAwardRequestEncoder, dailyRechargeGetAwardRequestDecoder)
end


local function superPackageGetInfoRequestEncoder(msg)
	local input = activityFavorHandler_pb.SuperPackageGetInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function superPackageGetInfoRequestDecoder(stream)
	local res = activityFavorHandler_pb.SuperPackageGetInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ActivityFavorHandler.superPackageGetInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.activityFavorHandler.superPackageGetInfoRequest", option)
	Socket.Request("area.activityFavorHandler.superPackageGetInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ActivityFavorHandler.lastSuperPackageGetInfoResponse = res
			Socket.OnRequestEnd("area.activityFavorHandler.superPackageGetInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.activityFavorHandler.superPackageGetInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.activityFavorHandler.superPackageGetInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, superPackageGetInfoRequestEncoder, superPackageGetInfoRequestDecoder)
end


local function superPackageBuyRequestEncoder(msg)
	local input = activityFavorHandler_pb.SuperPackageBuyRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function superPackageBuyRequestDecoder(stream)
	local res = activityFavorHandler_pb.SuperPackageBuyResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ActivityFavorHandler.superPackageBuyRequest(packageId,channelId,c2s_imei,c2s_os,cb,option)
	local msg = {}
	msg.packageId = packageId
	msg.channelId = channelId
	msg.c2s_imei = c2s_imei
	msg.c2s_os = c2s_os
	Socket.OnRequestStart("area.activityFavorHandler.superPackageBuyRequest", option)
	Socket.Request("area.activityFavorHandler.superPackageBuyRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ActivityFavorHandler.lastSuperPackageBuyResponse = res
			Socket.OnRequestEnd("area.activityFavorHandler.superPackageBuyRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.activityFavorHandler.superPackageBuyRequest decode error!!"
			end
			Socket.OnRequestEnd("area.activityFavorHandler.superPackageBuyRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, superPackageBuyRequestEncoder, superPackageBuyRequestDecoder)
end


local function sevenDayPackageGetInfoRequestEncoder(msg)
	local input = activityFavorHandler_pb.SevenDayPackageGetInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function sevenDayPackageGetInfoRequestDecoder(stream)
	local res = activityFavorHandler_pb.SevenDayPackageGetInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ActivityFavorHandler.sevenDayPackageGetInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.activityFavorHandler.sevenDayPackageGetInfoRequest", option)
	Socket.Request("area.activityFavorHandler.sevenDayPackageGetInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ActivityFavorHandler.lastSevenDayPackageGetInfoResponse = res
			Socket.OnRequestEnd("area.activityFavorHandler.sevenDayPackageGetInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.activityFavorHandler.sevenDayPackageGetInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.activityFavorHandler.sevenDayPackageGetInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, sevenDayPackageGetInfoRequestEncoder, sevenDayPackageGetInfoRequestDecoder)
end


local function sevenDayPackageAwardRequestEncoder(msg)
	local input = activityFavorHandler_pb.SevenDayPackageAwardRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function sevenDayPackageAwardRequestDecoder(stream)
	local res = activityFavorHandler_pb.SevenDayPackageAwardResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ActivityFavorHandler.sevenDayPackageAwardRequest(packageId,cb,option)
	local msg = {}
	msg.packageId = packageId
	Socket.OnRequestStart("area.activityFavorHandler.sevenDayPackageAwardRequest", option)
	Socket.Request("area.activityFavorHandler.sevenDayPackageAwardRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ActivityFavorHandler.lastSevenDayPackageAwardResponse = res
			Socket.OnRequestEnd("area.activityFavorHandler.sevenDayPackageAwardRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.activityFavorHandler.sevenDayPackageAwardRequest decode error!!"
			end
			Socket.OnRequestEnd("area.activityFavorHandler.sevenDayPackageAwardRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, sevenDayPackageAwardRequestEncoder, sevenDayPackageAwardRequestDecoder)
end


local function dailyDrawInfoRequestEncoder(msg)
	local input = activityFavorHandler_pb.DailyDrawInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function dailyDrawInfoRequestDecoder(stream)
	local res = activityFavorHandler_pb.DailyDrawInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ActivityFavorHandler.dailyDrawInfoRequest(id,cb,option)
	local msg = {}
	msg.id = id
	Socket.OnRequestStart("area.activityFavorHandler.dailyDrawInfoRequest", option)
	Socket.Request("area.activityFavorHandler.dailyDrawInfoRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ActivityFavorHandler.lastDailyDrawInfoResponse = res
			Socket.OnRequestEnd("area.activityFavorHandler.dailyDrawInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.activityFavorHandler.dailyDrawInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.activityFavorHandler.dailyDrawInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, dailyDrawInfoRequestEncoder, dailyDrawInfoRequestDecoder)
end


local function dailyDrawRequestEncoder(msg)
	local input = activityFavorHandler_pb.DailyDrawRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function dailyDrawRequestDecoder(stream)
	local res = activityFavorHandler_pb.DailyDrawResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ActivityFavorHandler.dailyDrawRequest(timeType,costType,id,cb,option)
	local msg = {}
	msg.timeType = timeType
	msg.costType = costType
	msg.id = id
	Socket.OnRequestStart("area.activityFavorHandler.dailyDrawRequest", option)
	Socket.Request("area.activityFavorHandler.dailyDrawRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ActivityFavorHandler.lastDailyDrawResponse = res
			Socket.OnRequestEnd("area.activityFavorHandler.dailyDrawRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.activityFavorHandler.dailyDrawRequest decode error!!"
			end
			Socket.OnRequestEnd("area.activityFavorHandler.dailyDrawRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, dailyDrawRequestEncoder, dailyDrawRequestDecoder)
end


local function recoveredInfoRequestEncoder(msg)
	local input = activityFavorHandler_pb.RecoveredInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function recoveredInfoRequestDecoder(stream)
	local res = activityFavorHandler_pb.RecoveredInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ActivityFavorHandler.recoveredInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.activityFavorHandler.recoveredInfoRequest", option)
	Socket.Request("area.activityFavorHandler.recoveredInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ActivityFavorHandler.lastRecoveredInfoResponse = res
			Socket.OnRequestEnd("area.activityFavorHandler.recoveredInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.activityFavorHandler.recoveredInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.activityFavorHandler.recoveredInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, recoveredInfoRequestEncoder, recoveredInfoRequestDecoder)
end


local function recoveredRequestEncoder(msg)
	local input = activityFavorHandler_pb.RecoveredRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function recoveredRequestDecoder(stream)
	local res = activityFavorHandler_pb.RecoveredResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ActivityFavorHandler.recoveredRequest(id,type,cb,option)
	local msg = {}
	msg.id = id
	msg.type = type
	Socket.OnRequestStart("area.activityFavorHandler.recoveredRequest", option)
	Socket.Request("area.activityFavorHandler.recoveredRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ActivityFavorHandler.lastRecoveredResponse = res
			Socket.OnRequestEnd("area.activityFavorHandler.recoveredRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.activityFavorHandler.recoveredRequest decode error!!"
			end
			Socket.OnRequestEnd("area.activityFavorHandler.recoveredRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, recoveredRequestEncoder, recoveredRequestDecoder)
end


local function limitTimeGiftInfoRequestEncoder(msg)
	local input = activityFavorHandler_pb.LimitTimeGiftInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function limitTimeGiftInfoRequestDecoder(stream)
	local res = activityFavorHandler_pb.LimitTimeGiftInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ActivityFavorHandler.limitTimeGiftInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.activityFavorHandler.limitTimeGiftInfoRequest", option)
	Socket.Request("area.activityFavorHandler.limitTimeGiftInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ActivityFavorHandler.lastLimitTimeGiftInfoResponse = res
			Socket.OnRequestEnd("area.activityFavorHandler.limitTimeGiftInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.activityFavorHandler.limitTimeGiftInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.activityFavorHandler.limitTimeGiftInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, limitTimeGiftInfoRequestEncoder, limitTimeGiftInfoRequestDecoder)
end


local function limitTimeGiftBuyRequestEncoder(msg)
	local input = activityFavorHandler_pb.LimitTimeGiftBuyRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function limitTimeGiftBuyRequestDecoder(stream)
	local res = activityFavorHandler_pb.LimitTimeGiftBuyResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ActivityFavorHandler.limitTimeGiftBuyRequest(id,cb,option)
	local msg = {}
	msg.id = id
	Socket.OnRequestStart("area.activityFavorHandler.limitTimeGiftBuyRequest", option)
	Socket.Request("area.activityFavorHandler.limitTimeGiftBuyRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ActivityFavorHandler.lastLimitTimeGiftBuyResponse = res
			Socket.OnRequestEnd("area.activityFavorHandler.limitTimeGiftBuyRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.activityFavorHandler.limitTimeGiftBuyRequest decode error!!"
			end
			Socket.OnRequestEnd("area.activityFavorHandler.limitTimeGiftBuyRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, limitTimeGiftBuyRequestEncoder, limitTimeGiftBuyRequestDecoder)
end


local function continuousRechargeGetInfoRequestEncoder(msg)
	local input = activityFavorHandler_pb.ContinuousRechargeGetInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function continuousRechargeGetInfoRequestDecoder(stream)
	local res = activityFavorHandler_pb.ContinuousRechargeGetInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ActivityFavorHandler.continuousRechargeGetInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.activityFavorHandler.continuousRechargeGetInfoRequest", option)
	Socket.Request("area.activityFavorHandler.continuousRechargeGetInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ActivityFavorHandler.lastContinuousRechargeGetInfoResponse = res
			Socket.OnRequestEnd("area.activityFavorHandler.continuousRechargeGetInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.activityFavorHandler.continuousRechargeGetInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.activityFavorHandler.continuousRechargeGetInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, continuousRechargeGetInfoRequestEncoder, continuousRechargeGetInfoRequestDecoder)
end


local function continuousRechargeAwardRequestEncoder(msg)
	local input = activityFavorHandler_pb.ContinuousRechargeAwardRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function continuousRechargeAwardRequestDecoder(stream)
	local res = activityFavorHandler_pb.ContinuousRechargeAwardResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ActivityFavorHandler.continuousRechargeAwardRequest(day,cb,option)
	local msg = {}
	msg.day = day
	Socket.OnRequestStart("area.activityFavorHandler.continuousRechargeAwardRequest", option)
	Socket.Request("area.activityFavorHandler.continuousRechargeAwardRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ActivityFavorHandler.lastContinuousRechargeAwardResponse = res
			Socket.OnRequestEnd("area.activityFavorHandler.continuousRechargeAwardRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.activityFavorHandler.continuousRechargeAwardRequest decode error!!"
			end
			Socket.OnRequestEnd("area.activityFavorHandler.continuousRechargeAwardRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, continuousRechargeAwardRequestEncoder, continuousRechargeAwardRequestDecoder)
end


local function singleRechargeGetInfoRequestEncoder(msg)
	local input = activityFavorHandler_pb.SingleRechargeGetInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function singleRechargeGetInfoRequestDecoder(stream)
	local res = activityFavorHandler_pb.SingleRechargeGetInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ActivityFavorHandler.singleRechargeGetInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.activityFavorHandler.singleRechargeGetInfoRequest", option)
	Socket.Request("area.activityFavorHandler.singleRechargeGetInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ActivityFavorHandler.lastSingleRechargeGetInfoResponse = res
			Socket.OnRequestEnd("area.activityFavorHandler.singleRechargeGetInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.activityFavorHandler.singleRechargeGetInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.activityFavorHandler.singleRechargeGetInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, singleRechargeGetInfoRequestEncoder, singleRechargeGetInfoRequestDecoder)
end


local function singleRechargeAwardRequestEncoder(msg)
	local input = activityFavorHandler_pb.SingleRechargeAwardRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function singleRechargeAwardRequestDecoder(stream)
	local res = activityFavorHandler_pb.SingleRechargeAwardResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ActivityFavorHandler.singleRechargeAwardRequest(id,cb,option)
	local msg = {}
	msg.id = id
	Socket.OnRequestStart("area.activityFavorHandler.singleRechargeAwardRequest", option)
	Socket.Request("area.activityFavorHandler.singleRechargeAwardRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ActivityFavorHandler.lastSingleRechargeAwardResponse = res
			Socket.OnRequestEnd("area.activityFavorHandler.singleRechargeAwardRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.activityFavorHandler.singleRechargeAwardRequest decode error!!"
			end
			Socket.OnRequestEnd("area.activityFavorHandler.singleRechargeAwardRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, singleRechargeAwardRequestEncoder, singleRechargeAwardRequestDecoder)
end


local function superPackageBuyPushDecoder(stream)
	local res = activityFavorHandler_pb.SuperPackageBuyPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ActivityFavorHandler.superPackageBuyPush(cb)
	Socket.On("area.activityFavorPush.superPackageBuyPush", function(res) 
		Pomelo.ActivityFavorHandler.lastSuperPackageBuyPush = res
		cb(nil,res) 
	end, superPackageBuyPushDecoder) 
end


local function limitTimeGiftInfoPushDecoder(stream)
	local res = activityFavorHandler_pb.LimitTimeGiftInfoPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ActivityFavorHandler.limitTimeGiftInfoPush(cb)
	Socket.On("area.activityFavorPush.limitTimeGiftInfoPush", function(res) 
		Pomelo.ActivityFavorHandler.lastLimitTimeGiftInfoPush = res
		cb(nil,res) 
	end, limitTimeGiftInfoPushDecoder) 
end





return Pomelo
