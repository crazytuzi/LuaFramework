





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "mapHandler_pb"


Pomelo = Pomelo or {}


Pomelo.MapHandler = {}

local function enterSceneByAreaIdRequestEncoder(msg)
	local input = mapHandler_pb.GnterSceneByAreaIdRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function enterSceneByAreaIdRequestDecoder(stream)
	local res = mapHandler_pb.GnterSceneByAreaIdResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.MapHandler.enterSceneByAreaIdRequest(c2s_areaId,cb,option)
	local msg = {}
	msg.c2s_areaId = c2s_areaId
	Socket.OnRequestStart("area.mapHandler.enterSceneByAreaIdRequest", option)
	Socket.Request("area.mapHandler.enterSceneByAreaIdRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.MapHandler.lastGnterSceneByAreaIdResponse = res
			Socket.OnRequestEnd("area.mapHandler.enterSceneByAreaIdRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.mapHandler.enterSceneByAreaIdRequest decode error!!"
			end
			Socket.OnRequestEnd("area.mapHandler.enterSceneByAreaIdRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, enterSceneByAreaIdRequestEncoder, enterSceneByAreaIdRequestDecoder)
end


local function getWorldMapListRequestEncoder(msg)
	local input = mapHandler_pb.GetWorldMapListRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getWorldMapListRequestDecoder(stream)
	local res = mapHandler_pb.GetWorldMapListResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.MapHandler.getWorldMapListRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.mapHandler.getWorldMapListRequest", option)
	Socket.Request("area.mapHandler.getWorldMapListRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.MapHandler.lastGetWorldMapListResponse = res
			Socket.OnRequestEnd("area.mapHandler.getWorldMapListRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.mapHandler.getWorldMapListRequest decode error!!"
			end
			Socket.OnRequestEnd("area.mapHandler.getWorldMapListRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getWorldMapListRequestEncoder, getWorldMapListRequestDecoder)
end


local function getPlayerListRequestEncoder(msg)
	local input = mapHandler_pb.GetPlayerListRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getPlayerListRequestDecoder(stream)
	local res = mapHandler_pb.GetPlayerListResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.MapHandler.getPlayerListRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.mapHandler.getPlayerListRequest", option)
	Socket.Request("area.mapHandler.getPlayerListRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.MapHandler.lastGetPlayerListResponse = res
			Socket.OnRequestEnd("area.mapHandler.getPlayerListRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.mapHandler.getPlayerListRequest decode error!!"
			end
			Socket.OnRequestEnd("area.mapHandler.getPlayerListRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getPlayerListRequestEncoder, getPlayerListRequestDecoder)
end


local function getMonsterListRequestEncoder(msg)
	local input = mapHandler_pb.GetMonsterListRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getMonsterListRequestDecoder(stream)
	local res = mapHandler_pb.GetMonsterListResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.MapHandler.getMonsterListRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.mapHandler.getMonsterListRequest", option)
	Socket.Request("area.mapHandler.getMonsterListRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.MapHandler.lastGetMonsterListResponse = res
			Socket.OnRequestEnd("area.mapHandler.getMonsterListRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.mapHandler.getMonsterListRequest decode error!!"
			end
			Socket.OnRequestEnd("area.mapHandler.getMonsterListRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getMonsterListRequestEncoder, getMonsterListRequestDecoder)
end


local function getNpcListRequestEncoder(msg)
	local input = mapHandler_pb.GetNpcListRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getNpcListRequestDecoder(stream)
	local res = mapHandler_pb.GetNpcListResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.MapHandler.getNpcListRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.mapHandler.getNpcListRequest", option)
	Socket.Request("area.mapHandler.getNpcListRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.MapHandler.lastGetNpcListResponse = res
			Socket.OnRequestEnd("area.mapHandler.getNpcListRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.mapHandler.getNpcListRequest decode error!!"
			end
			Socket.OnRequestEnd("area.mapHandler.getNpcListRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getNpcListRequestEncoder, getNpcListRequestDecoder)
end


local function getMapListRequestEncoder(msg)
	local input = mapHandler_pb.GetMapListRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getMapListRequestDecoder(stream)
	local res = mapHandler_pb.GetMapListResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.MapHandler.getMapListRequest(c2s_mapId,cb,option)
	local msg = {}
	msg.c2s_mapId = c2s_mapId
	Socket.OnRequestStart("area.mapHandler.getMapListRequest", option)
	Socket.Request("area.mapHandler.getMapListRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.MapHandler.lastGetMapListResponse = res
			Socket.OnRequestEnd("area.mapHandler.getMapListRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.mapHandler.getMapListRequest decode error!!"
			end
			Socket.OnRequestEnd("area.mapHandler.getMapListRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getMapListRequestEncoder, getMapListRequestDecoder)
end


local function getAliveMonsterLineInfoRequestEncoder(msg)
	local input = mapHandler_pb.GetAliveMonsterLineInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getAliveMonsterLineInfoRequestDecoder(stream)
	local res = mapHandler_pb.GetAliveMonsterLineInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.MapHandler.getAliveMonsterLineInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.mapHandler.getAliveMonsterLineInfoRequest", option)
	Socket.Request("area.mapHandler.getAliveMonsterLineInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.MapHandler.lastGetAliveMonsterLineInfoResponse = res
			Socket.OnRequestEnd("area.mapHandler.getAliveMonsterLineInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.mapHandler.getAliveMonsterLineInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.mapHandler.getAliveMonsterLineInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getAliveMonsterLineInfoRequestEncoder, getAliveMonsterLineInfoRequestDecoder)
end





return Pomelo
