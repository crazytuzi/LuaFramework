





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "limitTimeActivityHandler_pb"


Pomelo = Pomelo or {}


Pomelo.LimitTimeActivityHandler = {}

local function getLimitTimeActivityInfoRequestEncoder(msg)
	local input = limitTimeActivityHandler_pb.GetLimitTimeActivityInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getLimitTimeActivityInfoRequestDecoder(stream)
	local res = limitTimeActivityHandler_pb.GetLimitTimeActivityInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.LimitTimeActivityHandler.getLimitTimeActivityInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.limitTimeActivityHandler.getLimitTimeActivityInfoRequest", option)
	Socket.Request("area.limitTimeActivityHandler.getLimitTimeActivityInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.LimitTimeActivityHandler.lastGetLimitTimeActivityInfoResponse = res
			Socket.OnRequestEnd("area.limitTimeActivityHandler.getLimitTimeActivityInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.limitTimeActivityHandler.getLimitTimeActivityInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.limitTimeActivityHandler.getLimitTimeActivityInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getLimitTimeActivityInfoRequestEncoder, getLimitTimeActivityInfoRequestDecoder)
end


local function ltActivityInfoPushDecoder(stream)
	local res = limitTimeActivityHandler_pb.LTActivityInfoPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.LimitTimeActivityHandler.ltActivityInfoPush(cb)
	Socket.On("area.limitTimeActivityPush.ltActivityInfoPush", function(res) 
		Pomelo.LimitTimeActivityHandler.lastLTActivityInfoPush = res
		cb(nil,res) 
	end, ltActivityInfoPushDecoder) 
end





return Pomelo
