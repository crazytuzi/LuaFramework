





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "roleHandler_pb"


Pomelo = Pomelo or {}


Pomelo.RoleHandler = {}

local function createPlayerRequestEncoder(msg)
	local input = roleHandler_pb.CreatePlayerRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function createPlayerRequestDecoder(stream)
	local res = roleHandler_pb.CreatePlayerResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.RoleHandler.createPlayerRequest(c2s_pro,c2s_name,cb,option)
	local msg = {}
	msg.c2s_pro = c2s_pro
	msg.c2s_name = c2s_name
	Socket.OnRequestStart("connector.roleHandler.createPlayerRequest", option)
	Socket.Request("connector.roleHandler.createPlayerRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.RoleHandler.lastCreatePlayerResponse = res
			Socket.OnRequestEnd("connector.roleHandler.createPlayerRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] connector.roleHandler.createPlayerRequest decode error!!"
			end
			Socket.OnRequestEnd("connector.roleHandler.createPlayerRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, createPlayerRequestEncoder, createPlayerRequestDecoder)
end


local function changePlayerNameRequestEncoder(msg)
	local input = roleHandler_pb.ChangePlayerNameRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function changePlayerNameRequestDecoder(stream)
	local res = roleHandler_pb.ChangePlayerNameResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.RoleHandler.changePlayerNameRequest(c2s_name,pos,cb,option)
	local msg = {}
	msg.c2s_name = c2s_name
	msg.pos = pos
	Socket.OnRequestStart("connector.roleHandler.changePlayerNameRequest", option)
	Socket.Request("connector.roleHandler.changePlayerNameRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.RoleHandler.lastChangePlayerNameResponse = res
			Socket.OnRequestEnd("connector.roleHandler.changePlayerNameRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] connector.roleHandler.changePlayerNameRequest decode error!!"
			end
			Socket.OnRequestEnd("connector.roleHandler.changePlayerNameRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, changePlayerNameRequestEncoder, changePlayerNameRequestDecoder)
end


local function deletePlayerRequestEncoder(msg)
	local input = roleHandler_pb.DeletePlayerRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function deletePlayerRequestDecoder(stream)
	local res = roleHandler_pb.DeletePlayerResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.RoleHandler.deletePlayerRequest(c2s_playerId,cb,option)
	local msg = {}
	msg.c2s_playerId = c2s_playerId
	Socket.OnRequestStart("connector.roleHandler.deletePlayerRequest", option)
	Socket.Request("connector.roleHandler.deletePlayerRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.RoleHandler.lastDeletePlayerResponse = res
			Socket.OnRequestEnd("connector.roleHandler.deletePlayerRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] connector.roleHandler.deletePlayerRequest decode error!!"
			end
			Socket.OnRequestEnd("connector.roleHandler.deletePlayerRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, deletePlayerRequestEncoder, deletePlayerRequestDecoder)
end


local function getRandomNameRequestEncoder(msg)
	local input = roleHandler_pb.GetRandomNameRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getRandomNameRequestDecoder(stream)
	local res = roleHandler_pb.GetRandomNameResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.RoleHandler.getRandomNameRequest(c2s_pro,cb,option)
	local msg = {}
	msg.c2s_pro = c2s_pro
	Socket.OnRequestStart("connector.roleHandler.getRandomNameRequest", option)
	Socket.Request("connector.roleHandler.getRandomNameRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.RoleHandler.lastGetRandomNameResponse = res
			Socket.OnRequestEnd("connector.roleHandler.getRandomNameRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] connector.roleHandler.getRandomNameRequest decode error!!"
			end
			Socket.OnRequestEnd("connector.roleHandler.getRandomNameRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getRandomNameRequestEncoder, getRandomNameRequestDecoder)
end





return Pomelo
