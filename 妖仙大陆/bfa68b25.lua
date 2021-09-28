





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "mountHandler_pb"


Pomelo = Pomelo or {}


Pomelo.MountHandler = {}

local function activeMountSkinRequestEncoder(msg)
	local input = mountHandler_pb.ActiveMountSkinRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function activeMountSkinRequestDecoder(stream)
	local res = mountHandler_pb.ActiveMountSkinResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.MountHandler.activeMountSkinRequest(c2s_skinId,cb,option)
	local msg = {}
	msg.c2s_skinId = c2s_skinId
	Socket.OnRequestStart("area.mountHandler.activeMountSkinRequest", option)
	Socket.Request("area.mountHandler.activeMountSkinRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.MountHandler.lastActiveMountSkinResponse = res
			Socket.OnRequestEnd("area.mountHandler.activeMountSkinRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.mountHandler.activeMountSkinRequest decode error!!"
			end
			Socket.OnRequestEnd("area.mountHandler.activeMountSkinRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, activeMountSkinRequestEncoder, activeMountSkinRequestDecoder)
end


local function saveMountRequestEncoder(msg)
	local input = mountHandler_pb.SaveMountRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function saveMountRequestDecoder(stream)
	local res = mountHandler_pb.SaveMountResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.MountHandler.saveMountRequest(c2s_mountId,c2s_skinId,cb,option)
	local msg = {}
	msg.c2s_mountId = c2s_mountId
	msg.c2s_skinId = c2s_skinId
	Socket.OnRequestStart("area.mountHandler.saveMountRequest", option)
	Socket.Request("area.mountHandler.saveMountRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.MountHandler.lastSaveMountResponse = res
			Socket.OnRequestEnd("area.mountHandler.saveMountRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.mountHandler.saveMountRequest decode error!!"
			end
			Socket.OnRequestEnd("area.mountHandler.saveMountRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, saveMountRequestEncoder, saveMountRequestDecoder)
end


local function upMountStageRequestEncoder(msg)
	local input = mountHandler_pb.UpMountStageRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function upMountStageRequestDecoder(stream)
	local res = mountHandler_pb.UpMountStageResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.MountHandler.upMountStageRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.mountHandler.upMountStageRequest", option)
	Socket.Request("area.mountHandler.upMountStageRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.MountHandler.lastUpMountStageResponse = res
			Socket.OnRequestEnd("area.mountHandler.upMountStageRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.mountHandler.upMountStageRequest decode error!!"
			end
			Socket.OnRequestEnd("area.mountHandler.upMountStageRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, upMountStageRequestEncoder, upMountStageRequestDecoder)
end


local function getMountInfoRequestEncoder(msg)
	local input = mountHandler_pb.GetMountInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getMountInfoRequestDecoder(stream)
	local res = mountHandler_pb.GetMountInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.MountHandler.getMountInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.mountHandler.getMountInfoRequest", option)
	Socket.Request("area.mountHandler.getMountInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.MountHandler.lastGetMountInfoResponse = res
			Socket.OnRequestEnd("area.mountHandler.getMountInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.mountHandler.getMountInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.mountHandler.getMountInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getMountInfoRequestEncoder, getMountInfoRequestDecoder)
end


local function trainingMountRequestEncoder(msg)
	local input = mountHandler_pb.TrainingMountRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function trainingMountRequestDecoder(stream)
	local res = mountHandler_pb.TrainingMountResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.MountHandler.trainingMountRequest(c2s_type,cb,option)
	local msg = {}
	msg.c2s_type = c2s_type
	Socket.OnRequestStart("area.mountHandler.trainingMountRequest", option)
	Socket.Request("area.mountHandler.trainingMountRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.MountHandler.lastTrainingMountResponse = res
			Socket.OnRequestEnd("area.mountHandler.trainingMountRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.mountHandler.trainingMountRequest decode error!!"
			end
			Socket.OnRequestEnd("area.mountHandler.trainingMountRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, trainingMountRequestEncoder, trainingMountRequestDecoder)
end


local function ridingMountRequestEncoder(msg)
	local input = mountHandler_pb.RidingMountRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function ridingMountRequestDecoder(stream)
	local res = mountHandler_pb.RidingMountResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.MountHandler.ridingMountRequest(c2s_isUp,cb,option)
	local msg = {}
	msg.c2s_isUp = c2s_isUp
	Socket.OnRequestStart("area.mountHandler.ridingMountRequest", option)
	Socket.Request("area.mountHandler.ridingMountRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.MountHandler.lastRidingMountResponse = res
			Socket.OnRequestEnd("area.mountHandler.ridingMountRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.mountHandler.ridingMountRequest decode error!!"
			end
			Socket.OnRequestEnd("area.mountHandler.ridingMountRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, ridingMountRequestEncoder, ridingMountRequestDecoder)
end


local function oneKeyTrainingRequestEncoder(msg)
	local input = mountHandler_pb.OneKeyTrainingRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function oneKeyTrainingRequestDecoder(stream)
	local res = mountHandler_pb.OneKeyTrainingResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.MountHandler.oneKeyTrainingRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.mountHandler.oneKeyTrainingRequest", option)
	Socket.Request("area.mountHandler.oneKeyTrainingRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.MountHandler.lastOneKeyTrainingResponse = res
			Socket.OnRequestEnd("area.mountHandler.oneKeyTrainingRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.mountHandler.oneKeyTrainingRequest decode error!!"
			end
			Socket.OnRequestEnd("area.mountHandler.oneKeyTrainingRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, oneKeyTrainingRequestEncoder, oneKeyTrainingRequestDecoder)
end


local function chooseFirstSkinRequestEncoder(msg)
	local input = mountHandler_pb.ChooseFirstSkinRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function chooseFirstSkinRequestDecoder(stream)
	local res = mountHandler_pb.ChooseFirstSkinResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.MountHandler.chooseFirstSkinRequest(c2s_skinId,cb,option)
	local msg = {}
	msg.c2s_skinId = c2s_skinId
	Socket.OnRequestStart("area.mountHandler.chooseFirstSkinRequest", option)
	Socket.Request("area.mountHandler.chooseFirstSkinRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.MountHandler.lastChooseFirstSkinResponse = res
			Socket.OnRequestEnd("area.mountHandler.chooseFirstSkinRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.mountHandler.chooseFirstSkinRequest decode error!!"
			end
			Socket.OnRequestEnd("area.mountHandler.chooseFirstSkinRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, chooseFirstSkinRequestEncoder, chooseFirstSkinRequestDecoder)
end


local function mountFlagPushDecoder(stream)
	local res = mountHandler_pb.MountFlagPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.MountHandler.mountFlagPush(cb)
	Socket.On("area.mountPush.mountFlagPush", function(res) 
		Pomelo.MountHandler.lastMountFlagPush = res
		cb(nil,res) 
	end, mountFlagPushDecoder) 
end


local function mountNewSkinPushDecoder(stream)
	local res = mountHandler_pb.MountNewSkinPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.MountHandler.mountNewSkinPush(cb)
	Socket.On("area.mountPush.mountNewSkinPush", function(res) 
		Pomelo.MountHandler.lastMountNewSkinPush = res
		cb(nil,res) 
	end, mountNewSkinPushDecoder) 
end





return Pomelo
