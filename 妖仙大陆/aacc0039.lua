





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "prepaidHandler_pb"


Pomelo = Pomelo or {}


Pomelo.PrepaidHandler = {}

local function prepaidSDKRequestEncoder(msg)
	local input = prepaidHandler_pb.PrepaidSDKRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function prepaidSDKRequestDecoder(stream)
	local res = prepaidHandler_pb.PrepaidSDKResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PrepaidHandler.prepaidSDKRequest(s2c_param,cb,option)
	local msg = {}
	msg.s2c_param = s2c_param
	Socket.OnRequestStart("area.prepaidHandler.prepaidSDKRequest", option)
	Socket.Request("area.prepaidHandler.prepaidSDKRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PrepaidHandler.lastPrepaidSDKResponse = res
			Socket.OnRequestEnd("area.prepaidHandler.prepaidSDKRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.prepaidHandler.prepaidSDKRequest decode error!!"
			end
			Socket.OnRequestEnd("area.prepaidHandler.prepaidSDKRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, prepaidSDKRequestEncoder, prepaidSDKRequestDecoder)
end


local function prepaidListRequestEncoder(msg)
	local input = prepaidHandler_pb.PrepaidListRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function prepaidListRequestDecoder(stream)
	local res = prepaidHandler_pb.PrepaidListResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PrepaidHandler.prepaidListRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.prepaidHandler.prepaidListRequest", option)
	Socket.Request("area.prepaidHandler.prepaidListRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PrepaidHandler.lastPrepaidListResponse = res
			Socket.OnRequestEnd("area.prepaidHandler.prepaidListRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.prepaidHandler.prepaidListRequest decode error!!"
			end
			Socket.OnRequestEnd("area.prepaidHandler.prepaidListRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, prepaidListRequestEncoder, prepaidListRequestDecoder)
end


local function prepaidAwardRequestEncoder(msg)
	local input = prepaidHandler_pb.PrepaidAwardRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function prepaidAwardRequestDecoder(stream)
	local res = prepaidHandler_pb.PrepaidAwardResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PrepaidHandler.prepaidAwardRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.prepaidHandler.prepaidAwardRequest", option)
	Socket.Request("area.prepaidHandler.prepaidAwardRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PrepaidHandler.lastPrepaidAwardResponse = res
			Socket.OnRequestEnd("area.prepaidHandler.prepaidAwardRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.prepaidHandler.prepaidAwardRequest decode error!!"
			end
			Socket.OnRequestEnd("area.prepaidHandler.prepaidAwardRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, prepaidAwardRequestEncoder, prepaidAwardRequestDecoder)
end


local function prepaidAPPRequestEncoder(msg)
	local input = prepaidHandler_pb.PrepaidAPPRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function prepaidAPPRequestDecoder(stream)
	local res = prepaidHandler_pb.PrepaidAPPResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PrepaidHandler.prepaidAPPRequest(s2c_param,cb,option)
	local msg = {}
	msg.s2c_param = s2c_param
	Socket.OnRequestStart("area.prepaidHandler.prepaidAPPRequest", option)
	Socket.Request("area.prepaidHandler.prepaidAPPRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PrepaidHandler.lastPrepaidAPPResponse = res
			Socket.OnRequestEnd("area.prepaidHandler.prepaidAPPRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.prepaidHandler.prepaidAPPRequest decode error!!"
			end
			Socket.OnRequestEnd("area.prepaidHandler.prepaidAPPRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, prepaidAPPRequestEncoder, prepaidAPPRequestDecoder)
end


local function prepaidOrderIdRequestEncoder(msg)
	local input = prepaidHandler_pb.PrepaidOrderIdRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function prepaidOrderIdRequestDecoder(stream)
	local res = prepaidHandler_pb.PrepaidOrderIdResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PrepaidHandler.prepaidOrderIdRequest(c2s_productId,c2s_type,c2s_channelId,c2s_imei,c2s_os,cb,option)
	local msg = {}
	msg.c2s_productId = c2s_productId
	msg.c2s_type = c2s_type
	msg.c2s_channelId = c2s_channelId
	msg.c2s_imei = c2s_imei
	msg.c2s_os = c2s_os
	Socket.OnRequestStart("area.prepaidHandler.prepaidOrderIdRequest", option)
	Socket.Request("area.prepaidHandler.prepaidOrderIdRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PrepaidHandler.lastPrepaidOrderIdResponse = res
			Socket.OnRequestEnd("area.prepaidHandler.prepaidOrderIdRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.prepaidHandler.prepaidOrderIdRequest decode error!!"
			end
			Socket.OnRequestEnd("area.prepaidHandler.prepaidOrderIdRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, prepaidOrderIdRequestEncoder, prepaidOrderIdRequestDecoder)
end


local function prepaidFirstAwardRequestEncoder(msg)
	local input = prepaidHandler_pb.PrepaidFirstRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function prepaidFirstAwardRequestDecoder(stream)
	local res = prepaidHandler_pb.PrepaidFirstResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PrepaidHandler.prepaidFirstAwardRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.prepaidHandler.prepaidFirstAwardRequest", option)
	Socket.Request("area.prepaidHandler.prepaidFirstAwardRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PrepaidHandler.lastPrepaidFirstResponse = res
			Socket.OnRequestEnd("area.prepaidHandler.prepaidFirstAwardRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.prepaidHandler.prepaidFirstAwardRequest decode error!!"
			end
			Socket.OnRequestEnd("area.prepaidHandler.prepaidFirstAwardRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, prepaidFirstAwardRequestEncoder, prepaidFirstAwardRequestDecoder)
end





return Pomelo
