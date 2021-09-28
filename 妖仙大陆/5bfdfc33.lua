





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "offlineAwardHandler_pb"


Pomelo = Pomelo or {}


Pomelo.OfflineAwardHandler = {}

local function queryAllAreasRequestEncoder(msg)
	local input = offlineAwardHandler_pb.QueryAllAreasRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function queryAllAreasRequestDecoder(stream)
	local res = offlineAwardHandler_pb.QueryAllAreasResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.OfflineAwardHandler.queryAllAreasRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.offlineAwardHandler.queryAllAreasRequest", option)
	Socket.Request("area.offlineAwardHandler.queryAllAreasRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.OfflineAwardHandler.lastQueryAllAreasResponse = res
			Socket.OnRequestEnd("area.offlineAwardHandler.queryAllAreasRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.offlineAwardHandler.queryAllAreasRequest decode error!!"
			end
			Socket.OnRequestEnd("area.offlineAwardHandler.queryAllAreasRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, queryAllAreasRequestEncoder, queryAllAreasRequestDecoder)
end


local function setOfflineAreaIdRequestEncoder(msg)
	local input = offlineAwardHandler_pb.SetOfflineAreaIdRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function setOfflineAreaIdRequestDecoder(stream)
	local res = offlineAwardHandler_pb.SetOfflineAreaIdResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.OfflineAwardHandler.setOfflineAreaIdRequest(c2s_areaId,cb,option)
	local msg = {}
	msg.c2s_areaId = c2s_areaId
	Socket.OnRequestStart("area.offlineAwardHandler.setOfflineAreaIdRequest", option)
	Socket.Request("area.offlineAwardHandler.setOfflineAreaIdRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.OfflineAwardHandler.lastSetOfflineAreaIdResponse = res
			Socket.OnRequestEnd("area.offlineAwardHandler.setOfflineAreaIdRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.offlineAwardHandler.setOfflineAreaIdRequest decode error!!"
			end
			Socket.OnRequestEnd("area.offlineAwardHandler.setOfflineAreaIdRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, setOfflineAreaIdRequestEncoder, setOfflineAreaIdRequestDecoder)
end


local function queryOfflineAwardRequestEncoder(msg)
	local input = offlineAwardHandler_pb.QueryOfflineAwardRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function queryOfflineAwardRequestDecoder(stream)
	local res = offlineAwardHandler_pb.QueryOfflineAwardResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.OfflineAwardHandler.queryOfflineAwardRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.offlineAwardHandler.queryOfflineAwardRequest", option)
	Socket.Request("area.offlineAwardHandler.queryOfflineAwardRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.OfflineAwardHandler.lastQueryOfflineAwardResponse = res
			Socket.OnRequestEnd("area.offlineAwardHandler.queryOfflineAwardRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.offlineAwardHandler.queryOfflineAwardRequest decode error!!"
			end
			Socket.OnRequestEnd("area.offlineAwardHandler.queryOfflineAwardRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, queryOfflineAwardRequestEncoder, queryOfflineAwardRequestDecoder)
end


local function getOfflineAwardRequestEncoder(msg)
	local input = offlineAwardHandler_pb.GetOfflineAwardRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getOfflineAwardRequestDecoder(stream)
	local res = offlineAwardHandler_pb.GetOfflineAwardResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.OfflineAwardHandler.getOfflineAwardRequest(c2s_type,cb,option)
	local msg = {}
	msg.c2s_type = c2s_type
	Socket.OnRequestStart("area.offlineAwardHandler.getOfflineAwardRequest", option)
	Socket.Request("area.offlineAwardHandler.getOfflineAwardRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.OfflineAwardHandler.lastGetOfflineAwardResponse = res
			Socket.OnRequestEnd("area.offlineAwardHandler.getOfflineAwardRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.offlineAwardHandler.getOfflineAwardRequest decode error!!"
			end
			Socket.OnRequestEnd("area.offlineAwardHandler.getOfflineAwardRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getOfflineAwardRequestEncoder, getOfflineAwardRequestDecoder)
end


local function getCurrentOfflineAreaRequestEncoder(msg)
	local input = offlineAwardHandler_pb.GetCurrentOfflineAreaRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getCurrentOfflineAreaRequestDecoder(stream)
	local res = offlineAwardHandler_pb.GetCurrentOfflineAreaResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.OfflineAwardHandler.getCurrentOfflineAreaRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.offlineAwardHandler.getCurrentOfflineAreaRequest", option)
	Socket.Request("area.offlineAwardHandler.getCurrentOfflineAreaRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.OfflineAwardHandler.lastGetCurrentOfflineAreaResponse = res
			Socket.OnRequestEnd("area.offlineAwardHandler.getCurrentOfflineAreaRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.offlineAwardHandler.getCurrentOfflineAreaRequest decode error!!"
			end
			Socket.OnRequestEnd("area.offlineAwardHandler.getCurrentOfflineAreaRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getCurrentOfflineAreaRequestEncoder, getCurrentOfflineAreaRequestDecoder)
end





return Pomelo
