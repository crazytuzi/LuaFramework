





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "sysSetHandler_pb"


Pomelo = Pomelo or {}


Pomelo.SysSetHandler = {}

local function changeSysSetRequestEncoder(msg)
	local input = sysSetHandler_pb.ChangeSysSetRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function changeSysSetRequestDecoder(stream)
	local res = sysSetHandler_pb.ChangeSysSetResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.SysSetHandler.changeSysSetRequest(c2s_setData,cb,option)
	local msg = {}
	msg.c2s_setData = c2s_setData
	Socket.OnRequestStart("area.sysSetHandler.changeSysSetRequest", option)
	Socket.Request("area.sysSetHandler.changeSysSetRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.SysSetHandler.lastChangeSysSetResponse = res
			Socket.OnRequestEnd("area.sysSetHandler.changeSysSetRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.sysSetHandler.changeSysSetRequest decode error!!"
			end
			Socket.OnRequestEnd("area.sysSetHandler.changeSysSetRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, changeSysSetRequestEncoder, changeSysSetRequestDecoder)
end





return Pomelo
