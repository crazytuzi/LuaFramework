





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "npcHandler_pb"


Pomelo = Pomelo or {}


Pomelo.NpcHandler = {}

local function recoverByNpcRequestEncoder(msg)
	local input = npcHandler_pb.RecoverByNpcRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function recoverByNpcRequestDecoder(stream)
	local res = npcHandler_pb.RecoverByNpcResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.NpcHandler.recoverByNpcRequest(npcObjId,cb,option)
	local msg = {}
	msg.npcObjId = npcObjId
	Socket.OnRequestStart("area.npcHandler.recoverByNpcRequest", option)
	Socket.Request("area.npcHandler.recoverByNpcRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.NpcHandler.lastRecoverByNpcResponse = res
			Socket.OnRequestEnd("area.npcHandler.recoverByNpcRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.npcHandler.recoverByNpcRequest decode error!!"
			end
			Socket.OnRequestEnd("area.npcHandler.recoverByNpcRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, recoverByNpcRequestEncoder, recoverByNpcRequestDecoder)
end





return Pomelo
