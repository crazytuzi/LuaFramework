





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "richHandler_pb"


Pomelo = Pomelo or {}


Pomelo.RichHandler = {}

local function getRichInfoRequestEncoder(msg)
	local input = richHandler_pb.GetRichInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getRichInfoRequestDecoder(stream)
	local res = richHandler_pb.GetRichInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.RichHandler.getRichInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("rich.richHandler.getRichInfoRequest", option)
	Socket.Request("rich.richHandler.getRichInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.RichHandler.lastGetRichInfoResponse = res
			Socket.OnRequestEnd("rich.richHandler.getRichInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] rich.richHandler.getRichInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("rich.richHandler.getRichInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getRichInfoRequestEncoder, getRichInfoRequestDecoder)
end


local function diceRequestEncoder(msg)
	local input = richHandler_pb.DiceRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function diceRequestDecoder(stream)
	local res = richHandler_pb.DiceResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.RichHandler.diceRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("rich.richHandler.diceRequest", option)
	Socket.Request("rich.richHandler.diceRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.RichHandler.lastDiceResponse = res
			Socket.OnRequestEnd("rich.richHandler.diceRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] rich.richHandler.diceRequest decode error!!"
			end
			Socket.OnRequestEnd("rich.richHandler.diceRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, diceRequestEncoder, diceRequestDecoder)
end


local function fetchTurnAwardRequestEncoder(msg)
	local input = richHandler_pb.FetchTurnAwardRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function fetchTurnAwardRequestDecoder(stream)
	local res = richHandler_pb.FetchTurnAwardResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.RichHandler.fetchTurnAwardRequest(id,cb,option)
	local msg = {}
	msg.id = id
	Socket.OnRequestStart("rich.richHandler.fetchTurnAwardRequest", option)
	Socket.Request("rich.richHandler.fetchTurnAwardRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.RichHandler.lastFetchTurnAwardResponse = res
			Socket.OnRequestEnd("rich.richHandler.fetchTurnAwardRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] rich.richHandler.fetchTurnAwardRequest decode error!!"
			end
			Socket.OnRequestEnd("rich.richHandler.fetchTurnAwardRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, fetchTurnAwardRequestEncoder, fetchTurnAwardRequestDecoder)
end





return Pomelo
