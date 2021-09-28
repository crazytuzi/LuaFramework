





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "skillHandler_pb"


Pomelo = Pomelo or {}


Pomelo.SkillHandler = {}

local function unlockSkillRequestEncoder(msg)
	local input = skillHandler_pb.UnlockSkillRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function unlockSkillRequestDecoder(stream)
	local res = skillHandler_pb.UnlockSkillResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.SkillHandler.unlockSkillRequest(s2c_skillId,cb,option)
	local msg = {}
	msg.s2c_skillId = s2c_skillId
	Socket.OnRequestStart("area.skillHandler.unlockSkillRequest", option)
	Socket.Request("area.skillHandler.unlockSkillRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.SkillHandler.lastUnlockSkillResponse = res
			Socket.OnRequestEnd("area.skillHandler.unlockSkillRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.skillHandler.unlockSkillRequest decode error!!"
			end
			Socket.OnRequestEnd("area.skillHandler.unlockSkillRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, unlockSkillRequestEncoder, unlockSkillRequestDecoder)
end


local function upgradeSkillRequestEncoder(msg)
	local input = skillHandler_pb.UpgradeSkillRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function upgradeSkillRequestDecoder(stream)
	local res = skillHandler_pb.UpgradeSkillResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.SkillHandler.upgradeSkillRequest(s2c_skillId,cb,option)
	local msg = {}
	msg.s2c_skillId = s2c_skillId
	Socket.OnRequestStart("area.skillHandler.upgradeSkillRequest", option)
	Socket.Request("area.skillHandler.upgradeSkillRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.SkillHandler.lastUpgradeSkillResponse = res
			Socket.OnRequestEnd("area.skillHandler.upgradeSkillRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.skillHandler.upgradeSkillRequest decode error!!"
			end
			Socket.OnRequestEnd("area.skillHandler.upgradeSkillRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, upgradeSkillRequestEncoder, upgradeSkillRequestDecoder)
end


local function upgradeSkillOneKeyRequestEncoder(msg)
	local input = skillHandler_pb.UpgradeSkillOneKeyRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function upgradeSkillOneKeyRequestDecoder(stream)
	local res = skillHandler_pb.UpgradeSkillOneKeyResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.SkillHandler.upgradeSkillOneKeyRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.skillHandler.upgradeSkillOneKeyRequest", option)
	Socket.Request("area.skillHandler.upgradeSkillOneKeyRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.SkillHandler.lastUpgradeSkillOneKeyResponse = res
			Socket.OnRequestEnd("area.skillHandler.upgradeSkillOneKeyRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.skillHandler.upgradeSkillOneKeyRequest decode error!!"
			end
			Socket.OnRequestEnd("area.skillHandler.upgradeSkillOneKeyRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, upgradeSkillOneKeyRequestEncoder, upgradeSkillOneKeyRequestDecoder)
end


local function getSkillDetailRequestEncoder(msg)
	local input = skillHandler_pb.GetSkillDetailRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getSkillDetailRequestDecoder(stream)
	local res = skillHandler_pb.GetSkillDetailResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.SkillHandler.getSkillDetailRequest(s2c_skillId,cb,option)
	local msg = {}
	msg.s2c_skillId = s2c_skillId
	Socket.OnRequestStart("area.skillHandler.getSkillDetailRequest", option)
	Socket.Request("area.skillHandler.getSkillDetailRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.SkillHandler.lastGetSkillDetailResponse = res
			Socket.OnRequestEnd("area.skillHandler.getSkillDetailRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.skillHandler.getSkillDetailRequest decode error!!"
			end
			Socket.OnRequestEnd("area.skillHandler.getSkillDetailRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getSkillDetailRequestEncoder, getSkillDetailRequestDecoder)
end


local function getAllSkillRequestEncoder(msg)
	local input = skillHandler_pb.GetAllSkillRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getAllSkillRequestDecoder(stream)
	local res = skillHandler_pb.GetAllSkillResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.SkillHandler.getAllSkillRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.skillHandler.getAllSkillRequest", option)
	Socket.Request("area.skillHandler.getAllSkillRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.SkillHandler.lastGetAllSkillResponse = res
			Socket.OnRequestEnd("area.skillHandler.getAllSkillRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.skillHandler.getAllSkillRequest decode error!!"
			end
			Socket.OnRequestEnd("area.skillHandler.getAllSkillRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getAllSkillRequestEncoder, getAllSkillRequestDecoder)
end


local function skillUpdatePushDecoder(stream)
	local res = skillHandler_pb.SkillUpdatePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.SkillHandler.skillUpdatePush(cb)
	Socket.On("area.skillPush.skillUpdatePush", function(res) 
		Pomelo.SkillHandler.lastSkillUpdatePush = res
		cb(nil,res) 
	end, skillUpdatePushDecoder) 
end





return Pomelo
