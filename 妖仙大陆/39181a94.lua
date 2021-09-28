





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "mailHandler_pb"


Pomelo = Pomelo or {}


Pomelo.MailHandler = {}

local function mailGetAllRequestEncoder(msg)
	local input = mailHandler_pb.MailGetAllRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function mailGetAllRequestDecoder(stream)
	local res = mailHandler_pb.MailGetAllResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.MailHandler.mailGetAllRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.mailHandler.mailGetAllRequest", option)
	Socket.Request("area.mailHandler.mailGetAllRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.MailHandler.lastMailGetAllResponse = res
			Socket.OnRequestEnd("area.mailHandler.mailGetAllRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.mailHandler.mailGetAllRequest decode error!!"
			end
			Socket.OnRequestEnd("area.mailHandler.mailGetAllRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, mailGetAllRequestEncoder, mailGetAllRequestDecoder)
end


local function mailSendMailRequestEncoder(msg)
	local input = mailHandler_pb.MailSendMailRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function mailSendMailRequestDecoder(stream)
	local res = mailHandler_pb.MailSendMailResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.MailHandler.mailSendMailRequest(toPlayerId,mailTitle,mailText,mailRead,toPlayerName,cb,option)
	local msg = {}
	msg.toPlayerId = toPlayerId
	msg.mailTitle = mailTitle
	msg.mailText = mailText
	msg.mailRead = mailRead
	msg.toPlayerName = toPlayerName
	Socket.OnRequestStart("area.mailHandler.mailSendMailRequest", option)
	Socket.Request("area.mailHandler.mailSendMailRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.MailHandler.lastMailSendMailResponse = res
			Socket.OnRequestEnd("area.mailHandler.mailSendMailRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.mailHandler.mailSendMailRequest decode error!!"
			end
			Socket.OnRequestEnd("area.mailHandler.mailSendMailRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, mailSendMailRequestEncoder, mailSendMailRequestDecoder)
end


local function mailDeleteRequestEncoder(msg)
	local input = mailHandler_pb.MailDeleteRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function mailDeleteRequestDecoder(stream)
	local res = mailHandler_pb.MailDeleteResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.MailHandler.mailDeleteRequest(c2s_id,cb,option)
	local msg = {}
	msg.c2s_id = c2s_id
	Socket.OnRequestStart("area.mailHandler.mailDeleteRequest", option)
	Socket.Request("area.mailHandler.mailDeleteRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.MailHandler.lastMailDeleteResponse = res
			Socket.OnRequestEnd("area.mailHandler.mailDeleteRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.mailHandler.mailDeleteRequest decode error!!"
			end
			Socket.OnRequestEnd("area.mailHandler.mailDeleteRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, mailDeleteRequestEncoder, mailDeleteRequestDecoder)
end


local function mailDeleteOneKeyRequestEncoder(msg)
	local input = mailHandler_pb.MailDeleteOneKeyRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function mailDeleteOneKeyRequestDecoder(stream)
	local res = mailHandler_pb.MailDeleteOneKeyResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.MailHandler.mailDeleteOneKeyRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.mailHandler.mailDeleteOneKeyRequest", option)
	Socket.Request("area.mailHandler.mailDeleteOneKeyRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.MailHandler.lastMailDeleteOneKeyResponse = res
			Socket.OnRequestEnd("area.mailHandler.mailDeleteOneKeyRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.mailHandler.mailDeleteOneKeyRequest decode error!!"
			end
			Socket.OnRequestEnd("area.mailHandler.mailDeleteOneKeyRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, mailDeleteOneKeyRequestEncoder, mailDeleteOneKeyRequestDecoder)
end


local function mailGetAttachmentRequestEncoder(msg)
	local input = mailHandler_pb.MailGetAttachmentRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function mailGetAttachmentRequestDecoder(stream)
	local res = mailHandler_pb.MailGetAttachmentResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.MailHandler.mailGetAttachmentRequest(c2s_id,cb,option)
	local msg = {}
	msg.c2s_id = c2s_id
	Socket.OnRequestStart("area.mailHandler.mailGetAttachmentRequest", option)
	Socket.Request("area.mailHandler.mailGetAttachmentRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.MailHandler.lastMailGetAttachmentResponse = res
			Socket.OnRequestEnd("area.mailHandler.mailGetAttachmentRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.mailHandler.mailGetAttachmentRequest decode error!!"
			end
			Socket.OnRequestEnd("area.mailHandler.mailGetAttachmentRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, mailGetAttachmentRequestEncoder, mailGetAttachmentRequestDecoder)
end


local function mailGetAttachmentOneKeyRequestEncoder(msg)
	local input = mailHandler_pb.MailGetAttachmentOneKeyRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function mailGetAttachmentOneKeyRequestDecoder(stream)
	local res = mailHandler_pb.MailGetAttachmentOneKeyResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.MailHandler.mailGetAttachmentOneKeyRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.mailHandler.mailGetAttachmentOneKeyRequest", option)
	Socket.Request("area.mailHandler.mailGetAttachmentOneKeyRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.MailHandler.lastMailGetAttachmentOneKeyResponse = res
			Socket.OnRequestEnd("area.mailHandler.mailGetAttachmentOneKeyRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.mailHandler.mailGetAttachmentOneKeyRequest decode error!!"
			end
			Socket.OnRequestEnd("area.mailHandler.mailGetAttachmentOneKeyRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, mailGetAttachmentOneKeyRequestEncoder, mailGetAttachmentOneKeyRequestDecoder)
end


local function mailReadNotifyEncoder(msg)
	local input = mailHandler_pb.MailReadNotify()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

function Pomelo.MailHandler.mailReadNotify(c2s_id)
	local msg = {}
	msg.c2s_id = c2s_id
	Socket.Notify("area.mailHandler.mailReadNotify", msg, mailReadNotifyEncoder)
end


local function mailSendTestNotifyEncoder(msg)
	local input = mailHandler_pb.MailSendTestNotify()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

function Pomelo.MailHandler.mailSendTestNotify(c2s_mailId,c2s_tcCode)
	local msg = {}
	msg.c2s_mailId = c2s_mailId
	msg.c2s_tcCode = c2s_tcCode
	Socket.Notify("area.mailHandler.mailSendTestNotify", msg, mailSendTestNotifyEncoder)
end


local function onGetMailPushDecoder(stream)
	local res = mailHandler_pb.OnGetMailPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.MailHandler.onGetMailPush(cb)
	Socket.On("area.mailPush.onGetMailPush", function(res) 
		Pomelo.MailHandler.lastOnGetMailPush = res
		cb(nil,res) 
	end, onGetMailPushDecoder) 
end





return Pomelo
