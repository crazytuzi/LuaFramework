





local Socket = require "Zeus.Pomelo.LuaGameSocket"
require "base64"
require "fubenHandler_pb"


Pomelo = Pomelo or {}


Pomelo.FubenHandler = {}

function Pomelo.FubenHandler.fubenListRequest(c2s_type,c2s_difficulty,cb,option)
	local msg = {}
	msg.c2s_type = c2s_type
	msg.c2s_difficulty = c2s_difficulty
	local input = fubenHandler_pb.FubenListRequest()
	protobuf.FromMessage(input,msg)
	Socket.Request("area.fubenHandler.fubenListRequest", ZZBase64.encode(input:SerializeToString()),function(stream)
		stream = ZZBase64.decode(stream)
		local res = fubenHandler_pb.fubenListResponse()
		res:ParseFromString(stream)
		if(res.s2c_code == 200) then
			Pomelo.FubenHandler.lastfubenListResponse = res
			Socket.OnRequestEnd(true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.fubenHandler.fubenListRequest decode error!!"
			end
			Socket.OnRequestEnd(false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end,option)
end

function Pomelo.FubenHandler.onlineFriendListRequest(cb,option)
	local input = nil
	Socket.Request("area.fubenHandler.onlineFriendListRequest", input,function(stream)
		stream = ZZBase64.decode(stream)
		local res = fubenHandler_pb.OnlineFriendListResponse()
		res:ParseFromString(stream)
		if(res.s2c_code == 200) then
			Pomelo.FubenHandler.lastOnlineFriendListResponse = res
			Socket.OnRequestEnd(true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.fubenHandler.onlineFriendListRequest decode error!!"
			end
			Socket.OnRequestEnd(false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end,option)
end

function Pomelo.FubenHandler.enterFubenRequest(fubenId,cb,option)
	local msg = {}
	msg.fubenId = fubenId
	local input = fubenHandler_pb.EnterFubenRequest()
	protobuf.FromMessage(input,msg)
	Socket.Request("area.fubenHandler.enterFubenRequest", ZZBase64.encode(input:SerializeToString()),function(stream)
		stream = ZZBase64.decode(stream)
		local res = fubenHandler_pb.EnterFubenResponse()
		res:ParseFromString(stream)
		if(res.s2c_code == 200) then
			Pomelo.FubenHandler.lastEnterFubenResponse = res
			Socket.OnRequestEnd(true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.fubenHandler.enterFubenRequest decode error!!"
			end
			Socket.OnRequestEnd(false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end,option)
end

function Pomelo.FubenHandler.setConfirmEnterFubenStateRequest(fubenTeamId,isReady,cb,option)
	local msg = {}
	msg.fubenTeamId = fubenTeamId
	msg.isReady = isReady
	local input = fubenHandler_pb.SetConfirmEnterFubenStateRequest()
	protobuf.FromMessage(input,msg)
	Socket.Request("area.fubenHandler.setConfirmEnterFubenStateRequest", ZZBase64.encode(input:SerializeToString()),function(stream)
		stream = ZZBase64.decode(stream)
		local res = fubenHandler_pb.SetConfirmEnterFubenStateResponse()
		res:ParseFromString(stream)
		if(res.s2c_code == 200) then
			Pomelo.FubenHandler.lastSetConfirmEnterFubenStateResponse = res
			Socket.OnRequestEnd(true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.fubenHandler.setConfirmEnterFubenStateRequest decode error!!"
			end
			Socket.OnRequestEnd(false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end,option)
end

function Pomelo.FubenHandler.onConfirmEnterFubenPush(cb)
	Socket.On("area.fubenPush.onConfirmEnterFubenPush", function(stream) 
		stream = ZZBase64.decode(stream) 
		local res = fubenHandler_pb.OnConfirmEnterFubenPush() 
		res:ParseFromString(stream) 
		if(res.s2c_code == 200) then 
			Pomelo.FubenHandler.lastOnConfirmEnterFubenPush = res
			Socket.OnRequestEnd(true) 
			cb(nil,res) 
		else 
			local ex = {} 
			if(res.s2c_code) then 
				ex.Code = res.s2c_code 
				ex.Message = res.s2c_msg 
			else 
				ex.Code = 501 
				ex.Message = "[LuaXmdsNetClient] area.fubenPush.onConfirmEnterFubenPush decode error!!" 
			end 
			Socket.OnRequestEnd(false,ex.Code,ex.Message) 
			cb(ex,nil) 
		end 
	end) 
end

function Pomelo.FubenHandler.onMemberEnterFubenStateChangePush(cb)
	Socket.On("area.fubenPush.onMemberEnterFubenStateChangePush", function(stream) 
		stream = ZZBase64.decode(stream) 
		local res = fubenHandler_pb.OnMemberEnterFubenStateChangePush() 
		res:ParseFromString(stream) 
		if(res.s2c_code == 200) then 
			Pomelo.FubenHandler.lastOnMemberEnterFubenStateChangePush = res
			Socket.OnRequestEnd(true) 
			cb(nil,res) 
		else 
			local ex = {} 
			if(res.s2c_code) then 
				ex.Code = res.s2c_code 
				ex.Message = res.s2c_msg 
			else 
				ex.Code = 501 
				ex.Message = "[LuaXmdsNetClient] area.fubenPush.onMemberEnterFubenStateChangePush decode error!!" 
			end 
			Socket.OnRequestEnd(false,ex.Code,ex.Message) 
			cb(ex,nil) 
		end 
	end) 
end




return Pomelo
