





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "attendanceHandler_pb"


Pomelo = Pomelo or {}


Pomelo.AttendanceHandler = {}

local function getAttendanceInfoRequestEncoder(msg)
	local input = attendanceHandler_pb.GetAttendanceInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getAttendanceInfoRequestDecoder(stream)
	local res = attendanceHandler_pb.GetAttendanceInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.AttendanceHandler.getAttendanceInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.attendanceHandler.getAttendanceInfoRequest", option)
	Socket.Request("area.attendanceHandler.getAttendanceInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.AttendanceHandler.lastGetAttendanceInfoResponse = res
			Socket.OnRequestEnd("area.attendanceHandler.getAttendanceInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.attendanceHandler.getAttendanceInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.attendanceHandler.getAttendanceInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getAttendanceInfoRequestEncoder, getAttendanceInfoRequestDecoder)
end


local function getDailyRewardRequestEncoder(msg)
	local input = attendanceHandler_pb.GetDailyRewardRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getDailyRewardRequestDecoder(stream)
	local res = attendanceHandler_pb.GetDailyRewardResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.AttendanceHandler.getDailyRewardRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.attendanceHandler.getDailyRewardRequest", option)
	Socket.Request("area.attendanceHandler.getDailyRewardRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.AttendanceHandler.lastGetDailyRewardResponse = res
			Socket.OnRequestEnd("area.attendanceHandler.getDailyRewardRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.attendanceHandler.getDailyRewardRequest decode error!!"
			end
			Socket.OnRequestEnd("area.attendanceHandler.getDailyRewardRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getDailyRewardRequestEncoder, getDailyRewardRequestDecoder)
end


local function getCumulativeRewardRequestEncoder(msg)
	local input = attendanceHandler_pb.GetCumulativeRewardRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getCumulativeRewardRequestDecoder(stream)
	local res = attendanceHandler_pb.GetCumulativeRewardResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.AttendanceHandler.getCumulativeRewardRequest(id,cb,option)
	local msg = {}
	msg.id = id
	Socket.OnRequestStart("area.attendanceHandler.getCumulativeRewardRequest", option)
	Socket.Request("area.attendanceHandler.getCumulativeRewardRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.AttendanceHandler.lastGetCumulativeRewardResponse = res
			Socket.OnRequestEnd("area.attendanceHandler.getCumulativeRewardRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.attendanceHandler.getCumulativeRewardRequest decode error!!"
			end
			Socket.OnRequestEnd("area.attendanceHandler.getCumulativeRewardRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getCumulativeRewardRequestEncoder, getCumulativeRewardRequestDecoder)
end


local function getLuxuryRewardRequestEncoder(msg)
	local input = attendanceHandler_pb.GetLuxuryRewardRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getLuxuryRewardRequestDecoder(stream)
	local res = attendanceHandler_pb.GetLuxuryRewardResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.AttendanceHandler.getLuxuryRewardRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.attendanceHandler.getLuxuryRewardRequest", option)
	Socket.Request("area.attendanceHandler.getLuxuryRewardRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.AttendanceHandler.lastGetLuxuryRewardResponse = res
			Socket.OnRequestEnd("area.attendanceHandler.getLuxuryRewardRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.attendanceHandler.getLuxuryRewardRequest decode error!!"
			end
			Socket.OnRequestEnd("area.attendanceHandler.getLuxuryRewardRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getLuxuryRewardRequestEncoder, getLuxuryRewardRequestDecoder)
end


local function getLeftVipRewardRequestEncoder(msg)
	local input = attendanceHandler_pb.GetLeftVipRewardRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getLeftVipRewardRequestDecoder(stream)
	local res = attendanceHandler_pb.GetLeftVipRewardResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.AttendanceHandler.getLeftVipRewardRequest(id,cb,option)
	local msg = {}
	msg.id = id
	Socket.OnRequestStart("area.attendanceHandler.getLeftVipRewardRequest", option)
	Socket.Request("area.attendanceHandler.getLeftVipRewardRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.AttendanceHandler.lastGetLeftVipRewardResponse = res
			Socket.OnRequestEnd("area.attendanceHandler.getLeftVipRewardRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.attendanceHandler.getLeftVipRewardRequest decode error!!"
			end
			Socket.OnRequestEnd("area.attendanceHandler.getLeftVipRewardRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getLeftVipRewardRequestEncoder, getLeftVipRewardRequestDecoder)
end


local function luxuryRewardPushDecoder(stream)
	local res = attendanceHandler_pb.LuxuryRewardPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.AttendanceHandler.luxuryRewardPush(cb)
	Socket.On("area.attendancePush.luxuryRewardPush", function(res) 
		Pomelo.AttendanceHandler.lastLuxuryRewardPush = res
		cb(nil,res) 
	end, luxuryRewardPushDecoder) 
end





return Pomelo
