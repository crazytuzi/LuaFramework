





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "bloodHandler_pb"


Pomelo = Pomelo or {}


Pomelo.BloodHandler = {}

local function getEquipedBloodsRequestEncoder(msg)
	local input = bloodHandler_pb.GetEquipedBloodsRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getEquipedBloodsRequestDecoder(stream)
	local res = bloodHandler_pb.GetEquipedBloodsResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.BloodHandler.getEquipedBloodsRequest(playerId,cb,option)
	local msg = {}
	msg.playerId = playerId
	Socket.OnRequestStart("area.bloodHandler.getEquipedBloodsRequest", option)
	Socket.Request("area.bloodHandler.getEquipedBloodsRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.BloodHandler.lastGetEquipedBloodsResponse = res
			Socket.OnRequestEnd("area.bloodHandler.getEquipedBloodsRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.bloodHandler.getEquipedBloodsRequest decode error!!"
			end
			Socket.OnRequestEnd("area.bloodHandler.getEquipedBloodsRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getEquipedBloodsRequestEncoder, getEquipedBloodsRequestDecoder)
end


local function equipBloodRequestEncoder(msg)
	local input = bloodHandler_pb.EquipBloodRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function equipBloodRequestDecoder(stream)
	local res = bloodHandler_pb.EquipBloodResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.BloodHandler.equipBloodRequest(itemId,cb,option)
	local msg = {}
	msg.itemId = itemId
	Socket.OnRequestStart("area.bloodHandler.equipBloodRequest", option)
	Socket.Request("area.bloodHandler.equipBloodRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.BloodHandler.lastEquipBloodResponse = res
			Socket.OnRequestEnd("area.bloodHandler.equipBloodRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.bloodHandler.equipBloodRequest decode error!!"
			end
			Socket.OnRequestEnd("area.bloodHandler.equipBloodRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, equipBloodRequestEncoder, equipBloodRequestDecoder)
end


local function unequipBloodRequestEncoder(msg)
	local input = bloodHandler_pb.UnequipBloodRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function unequipBloodRequestDecoder(stream)
	local res = bloodHandler_pb.UnequipBloodResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.BloodHandler.unequipBloodRequest(sortId,cb,option)
	local msg = {}
	msg.sortId = sortId
	Socket.OnRequestStart("area.bloodHandler.unequipBloodRequest", option)
	Socket.Request("area.bloodHandler.unequipBloodRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.BloodHandler.lastUnequipBloodResponse = res
			Socket.OnRequestEnd("area.bloodHandler.unequipBloodRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.bloodHandler.unequipBloodRequest decode error!!"
			end
			Socket.OnRequestEnd("area.bloodHandler.unequipBloodRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, unequipBloodRequestEncoder, unequipBloodRequestDecoder)
end


local function getBloodAttrsRequestEncoder(msg)
	local input = bloodHandler_pb.GetBloodAttrsRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getBloodAttrsRequestDecoder(stream)
	local res = bloodHandler_pb.GetBloodAttrsResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.BloodHandler.getBloodAttrsRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.bloodHandler.getBloodAttrsRequest", option)
	Socket.Request("area.bloodHandler.getBloodAttrsRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.BloodHandler.lastGetBloodAttrsResponse = res
			Socket.OnRequestEnd("area.bloodHandler.getBloodAttrsRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.bloodHandler.getBloodAttrsRequest decode error!!"
			end
			Socket.OnRequestEnd("area.bloodHandler.getBloodAttrsRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getBloodAttrsRequestEncoder, getBloodAttrsRequestDecoder)
end





return Pomelo
