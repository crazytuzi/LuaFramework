





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "treasureHandler_pb"


Pomelo = Pomelo or {}


Pomelo.TreasureHandler = {}

local function getTreasureInfoRequestEncoder(msg)
	local input = treasureHandler_pb.GetTreasureInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getTreasureInfoRequestDecoder(stream)
	local res = treasureHandler_pb.GetTreasureInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.TreasureHandler.getTreasureInfoRequest(c2s_treasureMsg,cb,option)
	local msg = {}
	msg.c2s_treasureMsg = c2s_treasureMsg
	Socket.OnRequestStart("area.treasureHandler.getTreasureInfoRequest", option)
	Socket.Request("area.treasureHandler.getTreasureInfoRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.TreasureHandler.lastGetTreasureInfoResponse = res
			Socket.OnRequestEnd("area.treasureHandler.getTreasureInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.treasureHandler.getTreasureInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.treasureHandler.getTreasureInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getTreasureInfoRequestEncoder, getTreasureInfoRequestDecoder)
end


local function getTreasureBagInfoRequestEncoder(msg)
	local input = treasureHandler_pb.GetTreasureBagInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getTreasureBagInfoRequestDecoder(stream)
	local res = treasureHandler_pb.GetTreasureBagInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.TreasureHandler.getTreasureBagInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.treasureHandler.getTreasureBagInfoRequest", option)
	Socket.Request("area.treasureHandler.getTreasureBagInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.TreasureHandler.lastGetTreasureBagInfoResponse = res
			Socket.OnRequestEnd("area.treasureHandler.getTreasureBagInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.treasureHandler.getTreasureBagInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.treasureHandler.getTreasureBagInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getTreasureBagInfoRequestEncoder, getTreasureBagInfoRequestDecoder)
end


local function openTreasureRequestEncoder(msg)
	local input = treasureHandler_pb.OpenTreasureRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function openTreasureRequestDecoder(stream)
	local res = treasureHandler_pb.OpenTreasureResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.TreasureHandler.openTreasureRequest(c2s_openType,c2s_useDiamond,cb,option)
	local msg = {}
	msg.c2s_openType = c2s_openType
	msg.c2s_useDiamond = c2s_useDiamond
	Socket.OnRequestStart("area.treasureHandler.openTreasureRequest", option)
	Socket.Request("area.treasureHandler.openTreasureRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.TreasureHandler.lastOpenTreasureResponse = res
			Socket.OnRequestEnd("area.treasureHandler.openTreasureRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.treasureHandler.openTreasureRequest decode error!!"
			end
			Socket.OnRequestEnd("area.treasureHandler.openTreasureRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, openTreasureRequestEncoder, openTreasureRequestDecoder)
end


local function receiveTreasureBagRequestEncoder(msg)
	local input = treasureHandler_pb.ReceiveTreasureBagRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function receiveTreasureBagRequestDecoder(stream)
	local res = treasureHandler_pb.ReceiveTreasureBagResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.TreasureHandler.receiveTreasureBagRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.treasureHandler.receiveTreasureBagRequest", option)
	Socket.Request("area.treasureHandler.receiveTreasureBagRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.TreasureHandler.lastReceiveTreasureBagResponse = res
			Socket.OnRequestEnd("area.treasureHandler.receiveTreasureBagRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.treasureHandler.receiveTreasureBagRequest decode error!!"
			end
			Socket.OnRequestEnd("area.treasureHandler.receiveTreasureBagRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, receiveTreasureBagRequestEncoder, receiveTreasureBagRequestDecoder)
end





return Pomelo
