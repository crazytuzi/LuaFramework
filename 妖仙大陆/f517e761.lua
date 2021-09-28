





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "achievementHandler_pb"


Pomelo = Pomelo or {}


Pomelo.AchievementHandler = {}

local function achievementGetTypeElementRequestEncoder(msg)
	local input = achievementHandler_pb.AchievementGetTypeElementRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function achievementGetTypeElementRequestDecoder(stream)
	local res = achievementHandler_pb.AchievementGetTypeElementResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.AchievementHandler.achievementGetTypeElementRequest(c2s_id,cb,option)
	local msg = {}
	msg.c2s_id = c2s_id
	Socket.OnRequestStart("area.achievementHandler.achievementGetTypeElementRequest", option)
	Socket.Request("area.achievementHandler.achievementGetTypeElementRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.AchievementHandler.lastAchievementGetTypeElementResponse = res
			Socket.OnRequestEnd("area.achievementHandler.achievementGetTypeElementRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.achievementHandler.achievementGetTypeElementRequest decode error!!"
			end
			Socket.OnRequestEnd("area.achievementHandler.achievementGetTypeElementRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, achievementGetTypeElementRequestEncoder, achievementGetTypeElementRequestDecoder)
end


local function achievementGetAwardRequestEncoder(msg)
	local input = achievementHandler_pb.AchievementGetAwardRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function achievementGetAwardRequestDecoder(stream)
	local res = achievementHandler_pb.AchievementGetAwardResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.AchievementHandler.achievementGetAwardRequest(c2s_id,c2s_type,cb,option)
	local msg = {}
	msg.c2s_id = c2s_id
	msg.c2s_type = c2s_type
	Socket.OnRequestStart("area.achievementHandler.achievementGetAwardRequest", option)
	Socket.Request("area.achievementHandler.achievementGetAwardRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.AchievementHandler.lastAchievementGetAwardResponse = res
			Socket.OnRequestEnd("area.achievementHandler.achievementGetAwardRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.achievementHandler.achievementGetAwardRequest decode error!!"
			end
			Socket.OnRequestEnd("area.achievementHandler.achievementGetAwardRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, achievementGetAwardRequestEncoder, achievementGetAwardRequestDecoder)
end


local function getHolyArmorsRequestEncoder(msg)
	local input = achievementHandler_pb.GetHolyArmorsRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getHolyArmorsRequestDecoder(stream)
	local res = achievementHandler_pb.GetHolyArmorsResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.AchievementHandler.getHolyArmorsRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.achievementHandler.getHolyArmorsRequest", option)
	Socket.Request("area.achievementHandler.getHolyArmorsRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.AchievementHandler.lastGetHolyArmorsResponse = res
			Socket.OnRequestEnd("area.achievementHandler.getHolyArmorsRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.achievementHandler.getHolyArmorsRequest decode error!!"
			end
			Socket.OnRequestEnd("area.achievementHandler.getHolyArmorsRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getHolyArmorsRequestEncoder, getHolyArmorsRequestDecoder)
end


local function activateHolyArmorRequestEncoder(msg)
	local input = achievementHandler_pb.ActivateHolyArmorRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function activateHolyArmorRequestDecoder(stream)
	local res = achievementHandler_pb.ActivateHolyArmorResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.AchievementHandler.activateHolyArmorRequest(id,cb,option)
	local msg = {}
	msg.id = id
	Socket.OnRequestStart("area.achievementHandler.activateHolyArmorRequest", option)
	Socket.Request("area.achievementHandler.activateHolyArmorRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.AchievementHandler.lastActivateHolyArmorResponse = res
			Socket.OnRequestEnd("area.achievementHandler.activateHolyArmorRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.achievementHandler.activateHolyArmorRequest decode error!!"
			end
			Socket.OnRequestEnd("area.achievementHandler.activateHolyArmorRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, activateHolyArmorRequestEncoder, activateHolyArmorRequestDecoder)
end


local function onAchievementPushDecoder(stream)
	local res = achievementHandler_pb.OnAchievementPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.AchievementHandler.onAchievementPush(cb)
	Socket.On("area.achievementPush.onAchievementPush", function(res) 
		Pomelo.AchievementHandler.lastOnAchievementPush = res
		cb(nil,res) 
	end, onAchievementPushDecoder) 
end





return Pomelo
