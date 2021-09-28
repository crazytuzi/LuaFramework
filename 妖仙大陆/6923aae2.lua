





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "signHandler_pb"


Pomelo = Pomelo or {}


Pomelo.SignHandler = {}

local function signGetAllInfoRequestEncoder(msg)
	local input = signHandler_pb.SignGetAllInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function signGetAllInfoRequestDecoder(stream)
	local res = signHandler_pb.SignGetAllInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.SignHandler.signGetAllInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.signHandler.signGetAllInfoRequest", option)
	Socket.Request("area.signHandler.signGetAllInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.SignHandler.lastSignGetAllInfoResponse = res
			Socket.OnRequestEnd("area.signHandler.signGetAllInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.signHandler.signGetAllInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.signHandler.signGetAllInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, signGetAllInfoRequestEncoder, signGetAllInfoRequestDecoder)
end


local function signDayRequestEncoder(msg)
	local input = signHandler_pb.SignDayRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function signDayRequestDecoder(stream)
	local res = signHandler_pb.SignDayResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.SignHandler.signDayRequest(c2s_signId,cb,option)
	local msg = {}
	msg.c2s_signId = c2s_signId
	Socket.OnRequestStart("area.signHandler.signDayRequest", option)
	Socket.Request("area.signHandler.signDayRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.SignHandler.lastSignDayResponse = res
			Socket.OnRequestEnd("area.signHandler.signDayRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.signHandler.signDayRequest decode error!!"
			end
			Socket.OnRequestEnd("area.signHandler.signDayRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, signDayRequestEncoder, signDayRequestDecoder)
end


local function signDayAddRequestEncoder(msg)
	local input = signHandler_pb.SignDayAddRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function signDayAddRequestDecoder(stream)
	local res = signHandler_pb.SignDayAddResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.SignHandler.signDayAddRequest(c2s_signId,cb,option)
	local msg = {}
	msg.c2s_signId = c2s_signId
	Socket.OnRequestStart("area.signHandler.signDayAddRequest", option)
	Socket.Request("area.signHandler.signDayAddRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.SignHandler.lastSignDayAddResponse = res
			Socket.OnRequestEnd("area.signHandler.signDayAddRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.signHandler.signDayAddRequest decode error!!"
			end
			Socket.OnRequestEnd("area.signHandler.signDayAddRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, signDayAddRequestEncoder, signDayAddRequestDecoder)
end


local function signDayAddOneKeyRequestEncoder(msg)
	local input = signHandler_pb.SignDayAddOneKeyRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function signDayAddOneKeyRequestDecoder(stream)
	local res = signHandler_pb.SignDayAddOneKeyResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.SignHandler.signDayAddOneKeyRequest(c2s_signId,cb,option)
	local msg = {}
	msg.c2s_signId = c2s_signId
	Socket.OnRequestStart("area.signHandler.signDayAddOneKeyRequest", option)
	Socket.Request("area.signHandler.signDayAddOneKeyRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.SignHandler.lastSignDayAddOneKeyResponse = res
			Socket.OnRequestEnd("area.signHandler.signDayAddOneKeyRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.signHandler.signDayAddOneKeyRequest decode error!!"
			end
			Socket.OnRequestEnd("area.signHandler.signDayAddOneKeyRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, signDayAddOneKeyRequestEncoder, signDayAddOneKeyRequestDecoder)
end


local function signGetAwardRequestEncoder(msg)
	local input = signHandler_pb.SignGetAwardRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function signGetAwardRequestDecoder(stream)
	local res = signHandler_pb.SignGetAwardResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.SignHandler.signGetAwardRequest(c2s_signAwardId,cb,option)
	local msg = {}
	msg.c2s_signAwardId = c2s_signAwardId
	Socket.OnRequestStart("area.signHandler.signGetAwardRequest", option)
	Socket.Request("area.signHandler.signGetAwardRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.SignHandler.lastSignGetAwardResponse = res
			Socket.OnRequestEnd("area.signHandler.signGetAwardRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.signHandler.signGetAwardRequest decode error!!"
			end
			Socket.OnRequestEnd("area.signHandler.signGetAwardRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, signGetAwardRequestEncoder, signGetAwardRequestDecoder)
end





return Pomelo
