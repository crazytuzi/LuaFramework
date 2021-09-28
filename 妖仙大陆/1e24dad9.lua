





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "upLevelHandler_pb"


Pomelo = Pomelo or {}


Pomelo.UpLevelHandler = {}

local function upInfoRequestEncoder(msg)
	local input = upLevelHandler_pb.UpInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function upInfoRequestDecoder(stream)
	local res = upLevelHandler_pb.UpInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.UpLevelHandler.upInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.upLevelHandler.upInfoRequest", option)
	Socket.Request("area.upLevelHandler.upInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.UpLevelHandler.lastUpInfoResponse = res
			Socket.OnRequestEnd("area.upLevelHandler.upInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.upLevelHandler.upInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.upLevelHandler.upInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, upInfoRequestEncoder, upInfoRequestDecoder)
end


local function upLevelRequestEncoder(msg)
	local input = upLevelHandler_pb.UpLevelRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function upLevelRequestDecoder(stream)
	local res = upLevelHandler_pb.UpLevelResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.UpLevelHandler.upLevelRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.upLevelHandler.upLevelRequest", option)
	Socket.Request("area.upLevelHandler.upLevelRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.UpLevelHandler.lastUpLevelResponse = res
			Socket.OnRequestEnd("area.upLevelHandler.upLevelRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.upLevelHandler.upLevelRequest decode error!!"
			end
			Socket.OnRequestEnd("area.upLevelHandler.upLevelRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, upLevelRequestEncoder, upLevelRequestDecoder)
end





return Pomelo
