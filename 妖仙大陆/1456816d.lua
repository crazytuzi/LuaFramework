





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "guildBlessHandler_pb"


Pomelo = Pomelo or {}


Pomelo.GuildBlessHandler = {}

local function getMyBlessInfoRequestEncoder(msg)
	local input = guildBlessHandler_pb.GetMyBlessInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getMyBlessInfoRequestDecoder(stream)
	local res = guildBlessHandler_pb.GetMyBlessInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildBlessHandler.getMyBlessInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.guildBlessHandler.getMyBlessInfoRequest", option)
	Socket.Request("area.guildBlessHandler.getMyBlessInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildBlessHandler.lastGetMyBlessInfoResponse = res
			Socket.OnRequestEnd("area.guildBlessHandler.getMyBlessInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildBlessHandler.getMyBlessInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildBlessHandler.getMyBlessInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getMyBlessInfoRequestEncoder, getMyBlessInfoRequestDecoder)
end


local function blessActionRequestEncoder(msg)
	local input = guildBlessHandler_pb.BlessActionRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function blessActionRequestDecoder(stream)
	local res = guildBlessHandler_pb.BlessActionResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildBlessHandler.blessActionRequest(id,cb,option)
	local msg = {}
	msg.id = id
	Socket.OnRequestStart("area.guildBlessHandler.blessActionRequest", option)
	Socket.Request("area.guildBlessHandler.blessActionRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildBlessHandler.lastBlessActionResponse = res
			Socket.OnRequestEnd("area.guildBlessHandler.blessActionRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildBlessHandler.blessActionRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildBlessHandler.blessActionRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, blessActionRequestEncoder, blessActionRequestDecoder)
end


local function receiveBlessGiftRequestEncoder(msg)
	local input = guildBlessHandler_pb.ReceiveBlessGiftRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function receiveBlessGiftRequestDecoder(stream)
	local res = guildBlessHandler_pb.ReceiveBlessGiftResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildBlessHandler.receiveBlessGiftRequest(index,cb,option)
	local msg = {}
	msg.index = index
	Socket.OnRequestStart("area.guildBlessHandler.receiveBlessGiftRequest", option)
	Socket.Request("area.guildBlessHandler.receiveBlessGiftRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildBlessHandler.lastReceiveBlessGiftResponse = res
			Socket.OnRequestEnd("area.guildBlessHandler.receiveBlessGiftRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildBlessHandler.receiveBlessGiftRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildBlessHandler.receiveBlessGiftRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, receiveBlessGiftRequestEncoder, receiveBlessGiftRequestDecoder)
end


local function upgradeBlessRequestEncoder(msg)
	local input = guildBlessHandler_pb.UpgradeBlessRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function upgradeBlessRequestDecoder(stream)
	local res = guildBlessHandler_pb.UpgradeBlessResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildBlessHandler.upgradeBlessRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.guildBlessHandler.upgradeBlessRequest", option)
	Socket.Request("area.guildBlessHandler.upgradeBlessRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildBlessHandler.lastUpgradeBlessResponse = res
			Socket.OnRequestEnd("area.guildBlessHandler.upgradeBlessRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildBlessHandler.upgradeBlessRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildBlessHandler.upgradeBlessRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, upgradeBlessRequestEncoder, upgradeBlessRequestDecoder)
end


local function blessRefreshPushDecoder(stream)
	local res = guildBlessHandler_pb.BlessRefreshPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildBlessHandler.blessRefreshPush(cb)
	Socket.On("area.guildBlessPush.blessRefreshPush", function(res) 
		Pomelo.GuildBlessHandler.lastBlessRefreshPush = res
		cb(nil,res) 
	end, blessRefreshPushDecoder) 
end





return Pomelo
