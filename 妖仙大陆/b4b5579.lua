





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "hookSetHandler_pb"


Pomelo = Pomelo or {}


Pomelo.HookSetHandler = {}

local function changeHookSetRequestEncoder(msg)
	local input = hookSetHandler_pb.ChangeHookSetRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function changeHookSetRequestDecoder(stream)
	local res = hookSetHandler_pb.ChangeHookSetResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.HookSetHandler.changeHookSetRequest(c2s_hookSetData,cb,option)
	local msg = {}
	msg.c2s_hookSetData = c2s_hookSetData
	Socket.OnRequestStart("area.hookSetHandler.changeHookSetRequest", option)
	Socket.Request("area.hookSetHandler.changeHookSetRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.HookSetHandler.lastChangeHookSetResponse = res
			Socket.OnRequestEnd("area.hookSetHandler.changeHookSetRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.hookSetHandler.changeHookSetRequest decode error!!"
			end
			Socket.OnRequestEnd("area.hookSetHandler.changeHookSetRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, changeHookSetRequestEncoder, changeHookSetRequestDecoder)
end





return Pomelo
