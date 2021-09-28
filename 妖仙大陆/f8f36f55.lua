





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "medalHandler_pb"


Pomelo = Pomelo or {}


Pomelo.MedalHandler = {}

local function getMedalInfoRequestEncoder(msg)
	local input = medalHandler_pb.GetMedalInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getMedalInfoRequestDecoder(stream)
	local res = medalHandler_pb.GetMedalInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.MedalHandler.getMedalInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.medalHandler.getMedalInfoRequest", option)
	Socket.Request("area.medalHandler.getMedalInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.MedalHandler.lastGetMedalInfoResponse = res
			Socket.OnRequestEnd("area.medalHandler.getMedalInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.medalHandler.getMedalInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.medalHandler.getMedalInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getMedalInfoRequestEncoder, getMedalInfoRequestDecoder)
end


local function gainMedalRequestEncoder(msg)
	local input = medalHandler_pb.GainMedalRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function gainMedalRequestDecoder(stream)
	local res = medalHandler_pb.GainMedalResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.MedalHandler.gainMedalRequest(c2s_id,cb,option)
	local msg = {}
	msg.c2s_id = c2s_id
	Socket.OnRequestStart("area.medalHandler.gainMedalRequest", option)
	Socket.Request("area.medalHandler.gainMedalRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.MedalHandler.lastGainMedalResponse = res
			Socket.OnRequestEnd("area.medalHandler.gainMedalRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.medalHandler.gainMedalRequest decode error!!"
			end
			Socket.OnRequestEnd("area.medalHandler.gainMedalRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, gainMedalRequestEncoder, gainMedalRequestDecoder)
end


local function medalListRequestEncoder(msg)
	local input = medalHandler_pb.MedalListRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function medalListRequestDecoder(stream)
	local res = medalHandler_pb.MedalListResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.MedalHandler.medalListRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.medalHandler.medalListRequest", option)
	Socket.Request("area.medalHandler.medalListRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.MedalHandler.lastMedalListResponse = res
			Socket.OnRequestEnd("area.medalHandler.medalListRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.medalHandler.medalListRequest decode error!!"
			end
			Socket.OnRequestEnd("area.medalHandler.medalListRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, medalListRequestEncoder, medalListRequestDecoder)
end


local function getMedalInfoByCodeRequestEncoder(msg)
	local input = medalHandler_pb.GetMedalInfoByCodeRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getMedalInfoByCodeRequestDecoder(stream)
	local res = medalHandler_pb.GetMedalInfoByCodeResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.MedalHandler.getMedalInfoByCodeRequest(c2s_code,cb,option)
	local msg = {}
	msg.c2s_code = c2s_code
	Socket.OnRequestStart("area.medalHandler.getMedalInfoByCodeRequest", option)
	Socket.Request("area.medalHandler.getMedalInfoByCodeRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.MedalHandler.lastGetMedalInfoByCodeResponse = res
			Socket.OnRequestEnd("area.medalHandler.getMedalInfoByCodeRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.medalHandler.getMedalInfoByCodeRequest decode error!!"
			end
			Socket.OnRequestEnd("area.medalHandler.getMedalInfoByCodeRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getMedalInfoByCodeRequestEncoder, getMedalInfoByCodeRequestDecoder)
end


local function medalTitleChangePushDecoder(stream)
	local res = medalHandler_pb.MedalTitleChangePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.MedalHandler.medalTitleChangePush(cb)
	Socket.On("area.medalPush.medalTitleChangePush", function(res) 
		Pomelo.MedalHandler.lastMedalTitleChangePush = res
		cb(nil,res) 
	end, medalTitleChangePushDecoder) 
end





return Pomelo
