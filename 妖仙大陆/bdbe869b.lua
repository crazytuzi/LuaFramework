





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "amuletHandler_pb"


Pomelo = Pomelo or {}


Pomelo.AmuletHandler = {}

local function getAllAmuletRequestEncoder(msg)
	local input = amuletHandler_pb.GetAllAmuletDetailReq()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getAllAmuletRequestDecoder(stream)
	local res = amuletHandler_pb.GetAllAmuletDetailRes()
	res:ParseFromString(stream)
	return res
end

function Pomelo.AmuletHandler.getAllAmuletRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.amuletHandler.getAllAmuletRequest", option)
	Socket.Request("area.amuletHandler.getAllAmuletRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.AmuletHandler.lastGetAllAmuletDetailRes = res
			Socket.OnRequestEnd("area.amuletHandler.getAllAmuletRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.amuletHandler.getAllAmuletRequest decode error!!"
			end
			Socket.OnRequestEnd("area.amuletHandler.getAllAmuletRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getAllAmuletRequestEncoder, getAllAmuletRequestDecoder)
end


local function equipAmuletRequestEncoder(msg)
	local input = amuletHandler_pb.EquipAmuletReq()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function equipAmuletRequestDecoder(stream)
	local res = amuletHandler_pb.EquipAmuletRes()
	res:ParseFromString(stream)
	return res
end

function Pomelo.AmuletHandler.equipAmuletRequest(c2s_gridIndex,cb,option)
	local msg = {}
	msg.c2s_gridIndex = c2s_gridIndex
	Socket.OnRequestStart("area.amuletHandler.equipAmuletRequest", option)
	Socket.Request("area.amuletHandler.equipAmuletRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.AmuletHandler.lastEquipAmuletRes = res
			Socket.OnRequestEnd("area.amuletHandler.equipAmuletRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.amuletHandler.equipAmuletRequest decode error!!"
			end
			Socket.OnRequestEnd("area.amuletHandler.equipAmuletRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, equipAmuletRequestEncoder, equipAmuletRequestDecoder)
end


local function unEquipAmuletRequestEncoder(msg)
	local input = amuletHandler_pb.UnEquipAmuletReq()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function unEquipAmuletRequestDecoder(stream)
	local res = amuletHandler_pb.UnEquipAmuletRes()
	res:ParseFromString(stream)
	return res
end

function Pomelo.AmuletHandler.unEquipAmuletRequest(c2s_gridIndex,cb,option)
	local msg = {}
	msg.c2s_gridIndex = c2s_gridIndex
	Socket.OnRequestStart("area.amuletHandler.unEquipAmuletRequest", option)
	Socket.Request("area.amuletHandler.unEquipAmuletRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.AmuletHandler.lastUnEquipAmuletRes = res
			Socket.OnRequestEnd("area.amuletHandler.unEquipAmuletRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.amuletHandler.unEquipAmuletRequest decode error!!"
			end
			Socket.OnRequestEnd("area.amuletHandler.unEquipAmuletRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, unEquipAmuletRequestEncoder, unEquipAmuletRequestDecoder)
end


local function unAllEquipAmuletRequestEncoder(msg)
	local input = amuletHandler_pb.UnAllEquipAmuletReq()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function unAllEquipAmuletRequestDecoder(stream)
	local res = amuletHandler_pb.UnAllEquipAmuletRes()
	res:ParseFromString(stream)
	return res
end

function Pomelo.AmuletHandler.unAllEquipAmuletRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.amuletHandler.unAllEquipAmuletRequest", option)
	Socket.Request("area.amuletHandler.unAllEquipAmuletRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.AmuletHandler.lastUnAllEquipAmuletRes = res
			Socket.OnRequestEnd("area.amuletHandler.unAllEquipAmuletRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.amuletHandler.unAllEquipAmuletRequest decode error!!"
			end
			Socket.OnRequestEnd("area.amuletHandler.unAllEquipAmuletRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, unAllEquipAmuletRequestEncoder, unAllEquipAmuletRequestDecoder)
end


local function amuletEquipNewPushDecoder(stream)
	local res = amuletHandler_pb.AmuletEquipNewPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.AmuletHandler.amuletEquipNewPush(cb)
	Socket.On("area.amuletPush.amuletEquipNewPush", function(res) 
		Pomelo.AmuletHandler.lastAmuletEquipNewPush = res
		cb(nil,res) 
	end, amuletEquipNewPushDecoder) 
end





return Pomelo
