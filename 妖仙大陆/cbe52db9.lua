





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "skillKeysHandler_pb"


Pomelo = Pomelo or {}


Pomelo.SkillKeysHandler = {}

local function saveSkillKeysRequestEncoder(msg)
	local input = skillKeysHandler_pb.SaveSkillKeysRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function saveSkillKeysRequestDecoder(stream)
	local res = skillKeysHandler_pb.SaveSkillKeysResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.SkillKeysHandler.saveSkillKeysRequest(s2c_skillKeys,cb,option)
	local msg = {}
	msg.s2c_skillKeys = s2c_skillKeys
	Socket.OnRequestStart("area.skillKeysHandler.saveSkillKeysRequest", option)
	Socket.Request("area.skillKeysHandler.saveSkillKeysRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.SkillKeysHandler.lastSaveSkillKeysResponse = res
			Socket.OnRequestEnd("area.skillKeysHandler.saveSkillKeysRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.skillKeysHandler.saveSkillKeysRequest decode error!!"
			end
			Socket.OnRequestEnd("area.skillKeysHandler.saveSkillKeysRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, saveSkillKeysRequestEncoder, saveSkillKeysRequestDecoder)
end


local function skillKeyUpdatePushDecoder(stream)
	local res = skillKeysHandler_pb.SkillKeyUpdatePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.SkillKeysHandler.skillKeyUpdatePush(cb)
	Socket.On("area.skillKeysPush.skillKeyUpdatePush", function(res) 
		Pomelo.SkillKeysHandler.lastSkillKeyUpdatePush = res
		cb(nil,res) 
	end, skillKeyUpdatePushDecoder) 
end





return Pomelo
