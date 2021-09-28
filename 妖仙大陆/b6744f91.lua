





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "redPacketHandler_pb"


Pomelo = Pomelo or {}


Pomelo.RedPacketHandler = {}

local function getRedPacketListRequestEncoder(msg)
	local input = redPacketHandler_pb.GetRedPacketListRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getRedPacketListRequestDecoder(stream)
	local res = redPacketHandler_pb.GetRedPacketListResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.RedPacketHandler.getRedPacketListRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("redpacket.redPacketHandler.getRedPacketListRequest", option)
	Socket.Request("redpacket.redPacketHandler.getRedPacketListRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.RedPacketHandler.lastGetRedPacketListResponse = res
			Socket.OnRequestEnd("redpacket.redPacketHandler.getRedPacketListRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] redpacket.redPacketHandler.getRedPacketListRequest decode error!!"
			end
			Socket.OnRequestEnd("redpacket.redPacketHandler.getRedPacketListRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getRedPacketListRequestEncoder, getRedPacketListRequestDecoder)
end


local function dispatchRedPacketRequestEncoder(msg)
	local input = redPacketHandler_pb.DispatchRedPacketRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function dispatchRedPacketRequestDecoder(stream)
	local res = redPacketHandler_pb.DispatchRedPacketResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.RedPacketHandler.dispatchRedPacketRequest(count,totalNum,channelType,fetchType,benifitType,message,cb,option)
	local msg = {}
	msg.count = count
	msg.totalNum = totalNum
	msg.channelType = channelType
	msg.fetchType = fetchType
	msg.benifitType = benifitType
	msg.message = message
	Socket.OnRequestStart("redpacket.redPacketHandler.dispatchRedPacketRequest", option)
	Socket.Request("redpacket.redPacketHandler.dispatchRedPacketRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.RedPacketHandler.lastDispatchRedPacketResponse = res
			Socket.OnRequestEnd("redpacket.redPacketHandler.dispatchRedPacketRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] redpacket.redPacketHandler.dispatchRedPacketRequest decode error!!"
			end
			Socket.OnRequestEnd("redpacket.redPacketHandler.dispatchRedPacketRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, dispatchRedPacketRequestEncoder, dispatchRedPacketRequestDecoder)
end


local function fetchRedPacketRequestEncoder(msg)
	local input = redPacketHandler_pb.FetchRedPacketRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function fetchRedPacketRequestDecoder(stream)
	local res = redPacketHandler_pb.FetchRedPacketResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.RedPacketHandler.fetchRedPacketRequest(id,cb,option)
	local msg = {}
	msg.id = id
	Socket.OnRequestStart("redpacket.redPacketHandler.fetchRedPacketRequest", option)
	Socket.Request("redpacket.redPacketHandler.fetchRedPacketRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.RedPacketHandler.lastFetchRedPacketResponse = res
			Socket.OnRequestEnd("redpacket.redPacketHandler.fetchRedPacketRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] redpacket.redPacketHandler.fetchRedPacketRequest decode error!!"
			end
			Socket.OnRequestEnd("redpacket.redPacketHandler.fetchRedPacketRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, fetchRedPacketRequestEncoder, fetchRedPacketRequestDecoder)
end


local function onRedPacketDispatchPushDecoder(stream)
	local res = redPacketHandler_pb.OnRedPacketDispatchPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.RedPacketHandler.onRedPacketDispatchPush(cb)
	Socket.On("redpacket.redPacketPush.onRedPacketDispatchPush", function(res) 
		Pomelo.RedPacketHandler.lastOnRedPacketDispatchPush = res
		cb(nil,res) 
	end, onRedPacketDispatchPushDecoder) 
end





return Pomelo
