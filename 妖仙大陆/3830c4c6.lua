





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "wingHandler_pb"


Pomelo = Pomelo or {}


Pomelo.WingHandler = {}

local function getWingInfoRequestEncoder(msg)
	local input = wingHandler_pb.GetWingInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getWingInfoRequestDecoder(stream)
	local res = wingHandler_pb.GetWingInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.WingHandler.getWingInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.wingHandler.getWingInfoRequest", option)
	Socket.Request("area.wingHandler.getWingInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.WingHandler.lastGetWingInfoResponse = res
			Socket.OnRequestEnd("area.wingHandler.getWingInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.wingHandler.getWingInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.wingHandler.getWingInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getWingInfoRequestEncoder, getWingInfoRequestDecoder)
end


local function trainingWingRequestEncoder(msg)
	local input = wingHandler_pb.TrainingWingRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function trainingWingRequestDecoder(stream)
	local res = wingHandler_pb.TrainingWingResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.WingHandler.trainingWingRequest(c2s_type,cb,option)
	local msg = {}
	msg.c2s_type = c2s_type
	Socket.OnRequestStart("area.wingHandler.trainingWingRequest", option)
	Socket.Request("area.wingHandler.trainingWingRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.WingHandler.lastTrainingWingResponse = res
			Socket.OnRequestEnd("area.wingHandler.trainingWingRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.wingHandler.trainingWingRequest decode error!!"
			end
			Socket.OnRequestEnd("area.wingHandler.trainingWingRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, trainingWingRequestEncoder, trainingWingRequestDecoder)
end


local function saveWingNotifyEncoder(msg)
	local input = wingHandler_pb.SaveWingNotify()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

function Pomelo.WingHandler.saveWingNotify(c2s_wingLevel)
	local msg = {}
	msg.c2s_wingLevel = c2s_wingLevel
	Socket.Notify("area.wingHandler.saveWingNotify", msg, saveWingNotifyEncoder)
end





return Pomelo
