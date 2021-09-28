





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "xianYuanHandler_pb"


Pomelo = Pomelo or {}


Pomelo.XianYuanHandler = {}

local function applyXianYuanRequestEncoder(msg)
	local input = xianYuanHandler_pb.XianYuanRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function applyXianYuanRequestDecoder(stream)
	local res = xianYuanHandler_pb.XianYuanResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.XianYuanHandler.applyXianYuanRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("xianyuan.xianYuanHandler.applyXianYuanRequest", option)
	Socket.Request("xianyuan.xianYuanHandler.applyXianYuanRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.XianYuanHandler.lastXianYuanResponse = res
			Socket.OnRequestEnd("xianyuan.xianYuanHandler.applyXianYuanRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] xianyuan.xianYuanHandler.applyXianYuanRequest decode error!!"
			end
			Socket.OnRequestEnd("xianyuan.xianYuanHandler.applyXianYuanRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, applyXianYuanRequestEncoder, applyXianYuanRequestDecoder)
end





return Pomelo
