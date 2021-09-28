





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "resourceHandler_pb"


Pomelo = Pomelo or {}


Pomelo.ResourceHandler = {}

local function queryAreaDataRequestEncoder(msg)
	local input = resourceHandler_pb.QueryAreaDataRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function queryAreaDataRequestDecoder(stream)
	local res = resourceHandler_pb.QueryAreaDataResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ResourceHandler.queryAreaDataRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.resourceHandler.queryAreaDataRequest", option)
	Socket.Request("area.resourceHandler.queryAreaDataRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ResourceHandler.lastQueryAreaDataResponse = res
			Socket.OnRequestEnd("area.resourceHandler.queryAreaDataRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.resourceHandler.queryAreaDataRequest decode error!!"
			end
			Socket.OnRequestEnd("area.resourceHandler.queryAreaDataRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, queryAreaDataRequestEncoder, queryAreaDataRequestDecoder)
end





return Pomelo
