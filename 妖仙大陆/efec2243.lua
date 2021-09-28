





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "demonTowerHandler_pb"


Pomelo = Pomelo or {}


Pomelo.DemonTowerHandler = {}

local function getDemonTowerInfoRequestEncoder(msg)
	local input = demonTowerHandler_pb.GetDemonTowerInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getDemonTowerInfoRequestDecoder(stream)
	local res = demonTowerHandler_pb.GetDemonTowerInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.DemonTowerHandler.getDemonTowerInfoRequest(floorId,cb,option)
	local msg = {}
	msg.floorId = floorId
	Socket.OnRequestStart("area.demonTowerHandler.getDemonTowerInfoRequest", option)
	Socket.Request("area.demonTowerHandler.getDemonTowerInfoRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.DemonTowerHandler.lastGetDemonTowerInfoResponse = res
			Socket.OnRequestEnd("area.demonTowerHandler.getDemonTowerInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.demonTowerHandler.getDemonTowerInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.demonTowerHandler.getDemonTowerInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getDemonTowerInfoRequestEncoder, getDemonTowerInfoRequestDecoder)
end


local function getDemonTowerSweepInfoRequestEncoder(msg)
	local input = demonTowerHandler_pb.GetDemonTowerSweepInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getDemonTowerSweepInfoRequestDecoder(stream)
	local res = demonTowerHandler_pb.GetDemonTowerSweepInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.DemonTowerHandler.getDemonTowerSweepInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.demonTowerHandler.getDemonTowerSweepInfoRequest", option)
	Socket.Request("area.demonTowerHandler.getDemonTowerSweepInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.DemonTowerHandler.lastGetDemonTowerSweepInfoResponse = res
			Socket.OnRequestEnd("area.demonTowerHandler.getDemonTowerSweepInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.demonTowerHandler.getDemonTowerSweepInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.demonTowerHandler.getDemonTowerSweepInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getDemonTowerSweepInfoRequestEncoder, getDemonTowerSweepInfoRequestDecoder)
end


local function startToSweepDemonTowerRequestEncoder(msg)
	local input = demonTowerHandler_pb.StartToSweepDemonTowerRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function startToSweepDemonTowerRequestDecoder(stream)
	local res = demonTowerHandler_pb.StartToSweepDemonTowerResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.DemonTowerHandler.startToSweepDemonTowerRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.demonTowerHandler.startToSweepDemonTowerRequest", option)
	Socket.Request("area.demonTowerHandler.startToSweepDemonTowerRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.DemonTowerHandler.lastStartToSweepDemonTowerResponse = res
			Socket.OnRequestEnd("area.demonTowerHandler.startToSweepDemonTowerRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.demonTowerHandler.startToSweepDemonTowerRequest decode error!!"
			end
			Socket.OnRequestEnd("area.demonTowerHandler.startToSweepDemonTowerRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, startToSweepDemonTowerRequestEncoder, startToSweepDemonTowerRequestDecoder)
end


local function startDemonTowerRequestEncoder(msg)
	local input = demonTowerHandler_pb.StartDemonTowerRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function startDemonTowerRequestDecoder(stream)
	local res = demonTowerHandler_pb.StartDemonTowerResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.DemonTowerHandler.startDemonTowerRequest(floorId,cb,option)
	local msg = {}
	msg.floorId = floorId
	Socket.OnRequestStart("area.demonTowerHandler.startDemonTowerRequest", option)
	Socket.Request("area.demonTowerHandler.startDemonTowerRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.DemonTowerHandler.lastStartDemonTowerResponse = res
			Socket.OnRequestEnd("area.demonTowerHandler.startDemonTowerRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.demonTowerHandler.startDemonTowerRequest decode error!!"
			end
			Socket.OnRequestEnd("area.demonTowerHandler.startDemonTowerRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, startDemonTowerRequestEncoder, startDemonTowerRequestDecoder)
end


local function finishSweepDemonTowerRequestEncoder(msg)
	local input = demonTowerHandler_pb.FinishSweepDemonTowerRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function finishSweepDemonTowerRequestDecoder(stream)
	local res = demonTowerHandler_pb.FinishSweepDemonTowerResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.DemonTowerHandler.finishSweepDemonTowerRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.demonTowerHandler.finishSweepDemonTowerRequest", option)
	Socket.Request("area.demonTowerHandler.finishSweepDemonTowerRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.DemonTowerHandler.lastFinishSweepDemonTowerResponse = res
			Socket.OnRequestEnd("area.demonTowerHandler.finishSweepDemonTowerRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.demonTowerHandler.finishSweepDemonTowerRequest decode error!!"
			end
			Socket.OnRequestEnd("area.demonTowerHandler.finishSweepDemonTowerRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, finishSweepDemonTowerRequestEncoder, finishSweepDemonTowerRequestDecoder)
end


local function sweepDemonTowerEndPushDecoder(stream)
	local res = demonTowerHandler_pb.SweepDemonTowerEndPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.DemonTowerHandler.sweepDemonTowerEndPush(cb)
	Socket.On("area.demonTowerPush.sweepDemonTowerEndPush", function(res) 
		Pomelo.DemonTowerHandler.lastSweepDemonTowerEndPush = res
		cb(nil,res) 
	end, sweepDemonTowerEndPushDecoder) 
end





return Pomelo
