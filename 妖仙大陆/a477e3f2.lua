





local Socket = require "Xmds.Pomelo.LuaGateSocket"
require "base64"
require "gateHandler_pb"


Pomelo = Pomelo or {}


Pomelo.GateHandler = {}

local function queryEntryRequestEncoder(msg)
	local input = gateHandler_pb.QueryEntryRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function queryEntryRequestDecoder(stream)
	local res = gateHandler_pb.QueryEntryResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GateHandler.queryEntryRequest(c2s_uid,c2s_sign,c2s_time,c2s_logicServerId,cb,option)
	local msg = {}
	msg.c2s_uid = c2s_uid
	msg.c2s_sign = c2s_sign
	msg.c2s_time = c2s_time
	msg.c2s_logicServerId = c2s_logicServerId
	Socket.OnRequestStart("gate.gateHandler.queryEntryRequest", option)
	Socket.Request("gate.gateHandler.queryEntryRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GateHandler.lastQueryEntryResponse = res
			Socket.OnRequestEnd("gate.gateHandler.queryEntryRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] gate.gateHandler.queryEntryRequest decode error!!"
			end
			Socket.OnRequestEnd("gate.gateHandler.queryEntryRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, queryEntryRequestEncoder, queryEntryRequestDecoder)
end





return Pomelo
