





local Socket = require "Xmds.Pomelo.LuaGateSocket"
require "base64"
require "loginHandler_pb"


Pomelo = Pomelo or {}


Pomelo.LoginHandler = {}

local function loginRequestEncoder(msg)
	local input = loginHandler_pb.LoginRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function loginRequestDecoder(stream)
	local res = loginHandler_pb.LoginResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.LoginHandler.loginRequest(appId,uid,token,channel,os,imei,version,channelUid,cb,option)
	local msg = {}
	msg.appId = appId
	msg.uid = uid
	msg.token = token
	msg.channel = channel
	msg.os = os
	msg.imei = imei
	msg.version = version
	msg.channelUid = channelUid
	Socket.OnRequestStart("login.loginHandler.loginRequest", option)
	Socket.Request("login.loginHandler.loginRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.LoginHandler.lastLoginResponse = res
			Socket.OnRequestEnd("login.loginHandler.loginRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] login.loginHandler.loginRequest decode error!!"
			end
			Socket.OnRequestEnd("login.loginHandler.loginRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, loginRequestEncoder, loginRequestDecoder)
end


local function registerRequestEncoder(msg)
	local input = loginHandler_pb.RegisterRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function registerRequestDecoder(stream)
	local res = loginHandler_pb.RegisterResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.LoginHandler.registerRequest(appId,account,password,channel,os,model,imei,version,tel,cb,option)
	local msg = {}
	msg.appId = appId
	msg.account = account
	msg.password = password
	msg.channel = channel
	msg.os = os
	msg.model = model
	msg.imei = imei
	msg.version = version
	msg.tel = tel
	Socket.OnRequestStart("login.loginHandler.registerRequest", option)
	Socket.Request("login.loginHandler.registerRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.LoginHandler.lastRegisterResponse = res
			Socket.OnRequestEnd("login.loginHandler.registerRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] login.loginHandler.registerRequest decode error!!"
			end
			Socket.OnRequestEnd("login.loginHandler.registerRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, registerRequestEncoder, registerRequestDecoder)
end


local function serverStatePushDecoder(stream)
	local res = loginHandler_pb.ServerStatePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.LoginHandler.serverStatePush(cb)
	Socket.On("login.loginPush.serverStatePush", function(res) 
		Pomelo.LoginHandler.lastServerStatePush = res
		cb(nil,res) 
	end, serverStatePushDecoder) 
end





return Pomelo
