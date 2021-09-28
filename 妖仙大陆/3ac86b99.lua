





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "arenaHandler_pb"


Pomelo = Pomelo or {}


Pomelo.ArenaHandler = {}

local function arenaInfoRequestEncoder(msg)
	local input = arenaHandler_pb.ArenaInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function arenaInfoRequestDecoder(stream)
	local res = arenaHandler_pb.ArenaInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ArenaHandler.arenaInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.arenaHandler.arenaInfoRequest", option)
	Socket.Request("area.arenaHandler.arenaInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ArenaHandler.lastArenaInfoResponse = res
			Socket.OnRequestEnd("area.arenaHandler.arenaInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.arenaHandler.arenaInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.arenaHandler.arenaInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, arenaInfoRequestEncoder, arenaInfoRequestDecoder)
end


local function enterArenaAreaRequestEncoder(msg)
	local input = arenaHandler_pb.EnterArenaAreaRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function enterArenaAreaRequestDecoder(stream)
	local res = arenaHandler_pb.EnterArenaAreaResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ArenaHandler.enterArenaAreaRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.arenaHandler.enterArenaAreaRequest", option)
	Socket.Request("area.arenaHandler.enterArenaAreaRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ArenaHandler.lastEnterArenaAreaResponse = res
			Socket.OnRequestEnd("area.arenaHandler.enterArenaAreaRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.arenaHandler.enterArenaAreaRequest decode error!!"
			end
			Socket.OnRequestEnd("area.arenaHandler.enterArenaAreaRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, enterArenaAreaRequestEncoder, enterArenaAreaRequestDecoder)
end


local function leaveArenaAreaRequestEncoder(msg)
	local input = arenaHandler_pb.LeaveArenaAreaRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function leaveArenaAreaRequestDecoder(stream)
	local res = arenaHandler_pb.LeaveArenaAreaResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ArenaHandler.leaveArenaAreaRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.arenaHandler.leaveArenaAreaRequest", option)
	Socket.Request("area.arenaHandler.leaveArenaAreaRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ArenaHandler.lastLeaveArenaAreaResponse = res
			Socket.OnRequestEnd("area.arenaHandler.leaveArenaAreaRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.arenaHandler.leaveArenaAreaRequest decode error!!"
			end
			Socket.OnRequestEnd("area.arenaHandler.leaveArenaAreaRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, leaveArenaAreaRequestEncoder, leaveArenaAreaRequestDecoder)
end


local function arenaRewardRequestEncoder(msg)
	local input = arenaHandler_pb.ArenaRewardRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function arenaRewardRequestDecoder(stream)
	local res = arenaHandler_pb.ArenaRewardResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ArenaHandler.arenaRewardRequest(c2s_type,cb,option)
	local msg = {}
	msg.c2s_type = c2s_type
	Socket.OnRequestStart("area.arenaHandler.arenaRewardRequest", option)
	Socket.Request("area.arenaHandler.arenaRewardRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ArenaHandler.lastArenaRewardResponse = res
			Socket.OnRequestEnd("area.arenaHandler.arenaRewardRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.arenaHandler.arenaRewardRequest decode error!!"
			end
			Socket.OnRequestEnd("area.arenaHandler.arenaRewardRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, arenaRewardRequestEncoder, arenaRewardRequestDecoder)
end


local function onArenaBattleInfoPushDecoder(stream)
	local res = arenaHandler_pb.OnArenaBattleInfoPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ArenaHandler.onArenaBattleInfoPush(cb)
	Socket.On("area.arenaPush.onArenaBattleInfoPush", function(res) 
		Pomelo.ArenaHandler.lastOnArenaBattleInfoPush = res
		cb(nil,res) 
	end, onArenaBattleInfoPushDecoder) 
end


local function onArenaBattleEndPushDecoder(stream)
	local res = arenaHandler_pb.OnArenaBattleEndPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ArenaHandler.onArenaBattleEndPush(cb)
	Socket.On("area.arenaPush.onArenaBattleEndPush", function(res) 
		Pomelo.ArenaHandler.lastOnArenaBattleEndPush = res
		cb(nil,res) 
	end, onArenaBattleEndPushDecoder) 
end





return Pomelo
