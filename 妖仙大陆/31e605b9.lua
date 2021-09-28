





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "messageHandler_pb"


Pomelo = Pomelo or {}


Pomelo.MessageHandler = {}

local function handleMessageRequestEncoder(msg)
	local input = messageHandler_pb.HandleMessageRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function handleMessageRequestDecoder(stream)
	local res = messageHandler_pb.HandleMessageResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.MessageHandler.handleMessageRequest(c2s_id,c2s_type,c2s_operate,cb,option)
	local msg = {}
	msg.c2s_id = c2s_id
	msg.c2s_type = c2s_type
	msg.c2s_operate = c2s_operate
	Socket.OnRequestStart("area.messageHandler.handleMessageRequest", option)
	Socket.Request("area.messageHandler.handleMessageRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.MessageHandler.lastHandleMessageResponse = res
			Socket.OnRequestEnd("area.messageHandler.handleMessageRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.messageHandler.handleMessageRequest decode error!!"
			end
			Socket.OnRequestEnd("area.messageHandler.handleMessageRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, handleMessageRequestEncoder, handleMessageRequestDecoder)
end


local function onMessageAddPushDecoder(stream)
	local res = messageHandler_pb.OnMessageAddPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.MessageHandler.onMessageAddPush(cb)
	Socket.On("area.messagePush.onMessageAddPush", function(res) 
		Pomelo.MessageHandler.lastOnMessageAddPush = res
		cb(nil,res) 
	end, onMessageAddPushDecoder) 
end





return Pomelo
