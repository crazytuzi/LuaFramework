





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "dailyActivityHandler_pb"


Pomelo = Pomelo or {}


Pomelo.DailyActivityHandler = {}

local function dailyActivityRequestEncoder(msg)
	local input = dailyActivityHandler_pb.DailyActivityRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function dailyActivityRequestDecoder(stream)
	local res = dailyActivityHandler_pb.DailyActivityResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.DailyActivityHandler.dailyActivityRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.dailyActivityHandler.dailyActivityRequest", option)
	Socket.Request("area.dailyActivityHandler.dailyActivityRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.DailyActivityHandler.lastDailyActivityResponse = res
			Socket.OnRequestEnd("area.dailyActivityHandler.dailyActivityRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.dailyActivityHandler.dailyActivityRequest decode error!!"
			end
			Socket.OnRequestEnd("area.dailyActivityHandler.dailyActivityRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, dailyActivityRequestEncoder, dailyActivityRequestDecoder)
end


local function getDegreeRewardRequestEncoder(msg)
	local input = dailyActivityHandler_pb.GetDegreeRewardRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getDegreeRewardRequestDecoder(stream)
	local res = dailyActivityHandler_pb.GetDegreeRewardResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.DailyActivityHandler.getDegreeRewardRequest(id,cb,option)
	local msg = {}
	msg.id = id
	Socket.OnRequestStart("area.dailyActivityHandler.getDegreeRewardRequest", option)
	Socket.Request("area.dailyActivityHandler.getDegreeRewardRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.DailyActivityHandler.lastGetDegreeRewardResponse = res
			Socket.OnRequestEnd("area.dailyActivityHandler.getDegreeRewardRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.dailyActivityHandler.getDegreeRewardRequest decode error!!"
			end
			Socket.OnRequestEnd("area.dailyActivityHandler.getDegreeRewardRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getDegreeRewardRequestEncoder, getDegreeRewardRequestDecoder)
end


local function updateActivityPushDecoder(stream)
	local res = dailyActivityHandler_pb.UpdateActivityPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.DailyActivityHandler.updateActivityPush(cb)
	Socket.On("area.dailyActivityPush.updateActivityPush", function(res) 
		Pomelo.DailyActivityHandler.lastUpdateActivityPush = res
		cb(nil,res) 
	end, updateActivityPushDecoder) 
end





return Pomelo
