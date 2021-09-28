





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "chatHandler_pb"


Pomelo = Pomelo or {}


Pomelo.ChatHandler = {}

local function sendChatRequestEncoder(msg)
	local input = chatHandler_pb.SendChatRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function sendChatRequestDecoder(stream)
	local res = chatHandler_pb.SendChatResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ChatHandler.sendChatRequest(c2s_scope,c2s_content,c2s_serverData,c2s_acceptRoleId,cb,option)
	local msg = {}
	msg.c2s_scope = c2s_scope
	msg.c2s_content = c2s_content
	msg.c2s_serverData = c2s_serverData
	msg.c2s_acceptRoleId = c2s_acceptRoleId
	Socket.OnRequestStart("chat.chatHandler.sendChatRequest", option)
	Socket.Request("chat.chatHandler.sendChatRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ChatHandler.lastSendChatResponse = res
			Socket.OnRequestEnd("chat.chatHandler.sendChatRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] chat.chatHandler.sendChatRequest decode error!!"
			end
			Socket.OnRequestEnd("chat.chatHandler.sendChatRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, sendChatRequestEncoder, sendChatRequestDecoder)
end


local function getSaveChatMsgRequestEncoder(msg)
	local input = chatHandler_pb.GetSaveChatMsgRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getSaveChatMsgRequestDecoder(stream)
	local res = chatHandler_pb.GetSaveChatMsgResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ChatHandler.getSaveChatMsgRequest(c2s_scope,c2s_index,c2s_uid,cb,option)
	local msg = {}
	msg.c2s_scope = c2s_scope
	msg.c2s_index = c2s_index
	msg.c2s_uid = c2s_uid
	Socket.OnRequestStart("chat.chatHandler.getSaveChatMsgRequest", option)
	Socket.Request("chat.chatHandler.getSaveChatMsgRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ChatHandler.lastGetSaveChatMsgResponse = res
			Socket.OnRequestEnd("chat.chatHandler.getSaveChatMsgRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] chat.chatHandler.getSaveChatMsgRequest decode error!!"
			end
			Socket.OnRequestEnd("chat.chatHandler.getSaveChatMsgRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getSaveChatMsgRequestEncoder, getSaveChatMsgRequestDecoder)
end


local function onChatPushDecoder(stream)
	local res = chatHandler_pb.OnChatPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ChatHandler.onChatPush(cb)
	Socket.On("chat.chatPush.onChatPush", function(res) 
		Pomelo.ChatHandler.lastOnChatPush = res
		cb(nil,res) 
	end, onChatPushDecoder) 
end


local function onChatErrorPushDecoder(stream)
	local res = chatHandler_pb.OnChatErrorPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ChatHandler.onChatErrorPush(cb)
	Socket.On("chat.chatPush.onChatErrorPush", function(res) 
		Pomelo.ChatHandler.lastOnChatErrorPush = res
		cb(nil,res) 
	end, onChatErrorPushDecoder) 
end


local function tipPushDecoder(stream)
	local res = chatHandler_pb.TipPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ChatHandler.tipPush(cb)
	Socket.On("chat.chatPush.tipPush", function(res) 
		Pomelo.ChatHandler.lastTipPush = res
		cb(nil,res) 
	end, tipPushDecoder) 
end





return Pomelo
