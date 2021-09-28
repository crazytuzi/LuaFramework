





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "guildTechHandler_pb"


Pomelo = Pomelo or {}


Pomelo.GuildTechHandler = {}

local function getGuildTechInfoRequestEncoder(msg)
	local input = guildTechHandler_pb.GetGuildTechInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getGuildTechInfoRequestDecoder(stream)
	local res = guildTechHandler_pb.GetGuildTechInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildTechHandler.getGuildTechInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.guildTechHandler.getGuildTechInfoRequest", option)
	Socket.Request("area.guildTechHandler.getGuildTechInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildTechHandler.lastGetGuildTechInfoResponse = res
			Socket.OnRequestEnd("area.guildTechHandler.getGuildTechInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildTechHandler.getGuildTechInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildTechHandler.getGuildTechInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getGuildTechInfoRequestEncoder, getGuildTechInfoRequestDecoder)
end


local function upgradeGuildTechRequestEncoder(msg)
	local input = guildTechHandler_pb.UpgradeGuildTechRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function upgradeGuildTechRequestDecoder(stream)
	local res = guildTechHandler_pb.UpgradeGuildTechResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildTechHandler.upgradeGuildTechRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.guildTechHandler.upgradeGuildTechRequest", option)
	Socket.Request("area.guildTechHandler.upgradeGuildTechRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildTechHandler.lastUpgradeGuildTechResponse = res
			Socket.OnRequestEnd("area.guildTechHandler.upgradeGuildTechRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildTechHandler.upgradeGuildTechRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildTechHandler.upgradeGuildTechRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, upgradeGuildTechRequestEncoder, upgradeGuildTechRequestDecoder)
end


local function upgradeGuildBuffRequestEncoder(msg)
	local input = guildTechHandler_pb.UpgradeGuildBuffRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function upgradeGuildBuffRequestDecoder(stream)
	local res = guildTechHandler_pb.UpgradeGuildBuffResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildTechHandler.upgradeGuildBuffRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.guildTechHandler.upgradeGuildBuffRequest", option)
	Socket.Request("area.guildTechHandler.upgradeGuildBuffRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildTechHandler.lastUpgradeGuildBuffResponse = res
			Socket.OnRequestEnd("area.guildTechHandler.upgradeGuildBuffRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildTechHandler.upgradeGuildBuffRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildTechHandler.upgradeGuildBuffRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, upgradeGuildBuffRequestEncoder, upgradeGuildBuffRequestDecoder)
end


local function upgradeGuildSkillRequestEncoder(msg)
	local input = guildTechHandler_pb.UpgradeGuildSkillRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function upgradeGuildSkillRequestDecoder(stream)
	local res = guildTechHandler_pb.UpgradeGuildSkillResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildTechHandler.upgradeGuildSkillRequest(skillId,cb,option)
	local msg = {}
	msg.skillId = skillId
	Socket.OnRequestStart("area.guildTechHandler.upgradeGuildSkillRequest", option)
	Socket.Request("area.guildTechHandler.upgradeGuildSkillRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildTechHandler.lastUpgradeGuildSkillResponse = res
			Socket.OnRequestEnd("area.guildTechHandler.upgradeGuildSkillRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildTechHandler.upgradeGuildSkillRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildTechHandler.upgradeGuildSkillRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, upgradeGuildSkillRequestEncoder, upgradeGuildSkillRequestDecoder)
end


local function buyGuildProductRequestEncoder(msg)
	local input = guildTechHandler_pb.BuyGuildProductRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function buyGuildProductRequestDecoder(stream)
	local res = guildTechHandler_pb.BuyGuildProductResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildTechHandler.buyGuildProductRequest(productId,cb,option)
	local msg = {}
	msg.productId = productId
	Socket.OnRequestStart("area.guildTechHandler.buyGuildProductRequest", option)
	Socket.Request("area.guildTechHandler.buyGuildProductRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildTechHandler.lastBuyGuildProductResponse = res
			Socket.OnRequestEnd("area.guildTechHandler.buyGuildProductRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildTechHandler.buyGuildProductRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildTechHandler.buyGuildProductRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, buyGuildProductRequestEncoder, buyGuildProductRequestDecoder)
end


local function guildTechRefreshPushDecoder(stream)
	local res = guildTechHandler_pb.GuildTechRefreshPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildTechHandler.guildTechRefreshPush(cb)
	Socket.On("area.guildTechPush.guildTechRefreshPush", function(res) 
		Pomelo.GuildTechHandler.lastGuildTechRefreshPush = res
		cb(nil,res) 
	end, guildTechRefreshPushDecoder) 
end





return Pomelo
