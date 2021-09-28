





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "entryHandler_pb"


Pomelo = Pomelo or {}


Pomelo.EntryHandler = {}

local function entryRequestEncoder(msg)
	local input = entryHandler_pb.EntryRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function entryRequestDecoder(stream)
	local res = entryHandler_pb.EntryResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.EntryHandler.entryRequest(c2s_uid,c2s_token,c2s_logicServerId,c2s_deviceMac,c2s_deviceType,c2s_clientRegion,c2s_clientChannel,c2s_clientVersion,cb,option)
	local msg = {}
	msg.c2s_uid = c2s_uid
	msg.c2s_token = c2s_token
	msg.c2s_logicServerId = c2s_logicServerId
	msg.c2s_deviceMac = c2s_deviceMac
	msg.c2s_deviceType = c2s_deviceType
	msg.c2s_clientRegion = c2s_clientRegion
	msg.c2s_clientChannel = c2s_clientChannel
	msg.c2s_clientVersion = c2s_clientVersion
	Socket.OnRequestStart("connector.entryHandler.entryRequest", option)
	Socket.Request("connector.entryHandler.entryRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.EntryHandler.lastEntryResponse = res
			Socket.OnRequestEnd("connector.entryHandler.entryRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] connector.entryHandler.entryRequest decode error!!"
			end
			Socket.OnRequestEnd("connector.entryHandler.entryRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, entryRequestEncoder, entryRequestDecoder)
end


local function bindPlayerRequestEncoder(msg)
	local input = entryHandler_pb.BindPlayerRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function bindPlayerRequestDecoder(stream)
	local res = entryHandler_pb.BindPlayerResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.EntryHandler.bindPlayerRequest(c2s_playerId,cb,option)
	local msg = {}
	msg.c2s_playerId = c2s_playerId
	Socket.OnRequestStart("connector.entryHandler.bindPlayerRequest", option)
	Socket.Request("connector.entryHandler.bindPlayerRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.EntryHandler.lastBindPlayerResponse = res
			Socket.OnRequestEnd("connector.entryHandler.bindPlayerRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] connector.entryHandler.bindPlayerRequest decode error!!"
			end
			Socket.OnRequestEnd("connector.entryHandler.bindPlayerRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, bindPlayerRequestEncoder, bindPlayerRequestDecoder)
end


local function getSysTimeRequestEncoder(msg)
	local input = entryHandler_pb.GetSysTimeRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getSysTimeRequestDecoder(stream)
	local res = entryHandler_pb.GetSysTimeResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.EntryHandler.getSysTimeRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("connector.entryHandler.getSysTimeRequest", option)
	Socket.Request("connector.entryHandler.getSysTimeRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.EntryHandler.lastGetSysTimeResponse = res
			Socket.OnRequestEnd("connector.entryHandler.getSysTimeRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] connector.entryHandler.getSysTimeRequest decode error!!"
			end
			Socket.OnRequestEnd("connector.entryHandler.getSysTimeRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getSysTimeRequestEncoder, getSysTimeRequestDecoder)
end


local function loginQueuePushDecoder(stream)
	local res = entryHandler_pb.LoginQueuePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.EntryHandler.loginQueuePush(cb)
	Socket.On("connector.entryPush.loginQueuePush", function(res) 
		Pomelo.EntryHandler.lastLoginQueuePush = res
		cb(nil,res) 
	end, loginQueuePushDecoder) 
end





return Pomelo
