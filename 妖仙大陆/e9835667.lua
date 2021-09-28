





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "auctionHandler_pb"


Pomelo = Pomelo or {}


Pomelo.AuctionHandler = {}

local function syncAuctionInfoRequestEncoder(msg)
	local input = auctionHandler_pb.SyncAuctionInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function syncAuctionInfoRequestDecoder(stream)
	local res = auctionHandler_pb.SyncAuctionInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.AuctionHandler.syncAuctionInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("auction.auctionHandler.syncAuctionInfoRequest", option)
	Socket.Request("auction.auctionHandler.syncAuctionInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.AuctionHandler.lastSyncAuctionInfoResponse = res
			Socket.OnRequestEnd("auction.auctionHandler.syncAuctionInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] auction.auctionHandler.syncAuctionInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("auction.auctionHandler.syncAuctionInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, syncAuctionInfoRequestEncoder, syncAuctionInfoRequestDecoder)
end


local function cancelSyncAuctionInfoRequestEncoder(msg)
	local input = auctionHandler_pb.CancelSyncAuctionInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function cancelSyncAuctionInfoRequestDecoder(stream)
	local res = auctionHandler_pb.CancelSyncAuctionInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.AuctionHandler.cancelSyncAuctionInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("auction.auctionHandler.cancelSyncAuctionInfoRequest", option)
	Socket.Request("auction.auctionHandler.cancelSyncAuctionInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.AuctionHandler.lastCancelSyncAuctionInfoResponse = res
			Socket.OnRequestEnd("auction.auctionHandler.cancelSyncAuctionInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] auction.auctionHandler.cancelSyncAuctionInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("auction.auctionHandler.cancelSyncAuctionInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, cancelSyncAuctionInfoRequestEncoder, cancelSyncAuctionInfoRequestDecoder)
end


local function auctionListRequestEncoder(msg)
	local input = auctionHandler_pb.AuctionListRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function auctionListRequestDecoder(stream)
	local res = auctionHandler_pb.AuctionListResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.AuctionHandler.auctionListRequest(c2s_type,cb,option)
	local msg = {}
	msg.c2s_type = c2s_type
	Socket.OnRequestStart("auction.auctionHandler.auctionListRequest", option)
	Socket.Request("auction.auctionHandler.auctionListRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.AuctionHandler.lastAuctionListResponse = res
			Socket.OnRequestEnd("auction.auctionHandler.auctionListRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] auction.auctionHandler.auctionListRequest decode error!!"
			end
			Socket.OnRequestEnd("auction.auctionHandler.auctionListRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, auctionListRequestEncoder, auctionListRequestDecoder)
end


local function auctionRequestEncoder(msg)
	local input = auctionHandler_pb.AuctionRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function auctionRequestDecoder(stream)
	local res = auctionHandler_pb.AuctionResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.AuctionHandler.auctionRequest(itemId,price,cb,option)
	local msg = {}
	msg.itemId = itemId
	msg.price = price
	Socket.OnRequestStart("auction.auctionHandler.auctionRequest", option)
	Socket.Request("auction.auctionHandler.auctionRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.AuctionHandler.lastAuctionResponse = res
			Socket.OnRequestEnd("auction.auctionHandler.auctionRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] auction.auctionHandler.auctionRequest decode error!!"
			end
			Socket.OnRequestEnd("auction.auctionHandler.auctionRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, auctionRequestEncoder, auctionRequestDecoder)
end


local function auctionLogRequestEncoder(msg)
	local input = auctionHandler_pb.AuctionLogRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function auctionLogRequestDecoder(stream)
	local res = auctionHandler_pb.AuctionLogResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.AuctionHandler.auctionLogRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("auction.auctionHandler.auctionLogRequest", option)
	Socket.Request("auction.auctionHandler.auctionLogRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.AuctionHandler.lastAuctionLogResponse = res
			Socket.OnRequestEnd("auction.auctionHandler.auctionLogRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] auction.auctionHandler.auctionLogRequest decode error!!"
			end
			Socket.OnRequestEnd("auction.auctionHandler.auctionLogRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, auctionLogRequestEncoder, auctionLogRequestDecoder)
end


local function auctionItemPushDecoder(stream)
	local res = auctionHandler_pb.AuctionItemPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.AuctionHandler.auctionItemPush(cb)
	Socket.On("auction.auctionPush.auctionItemPush", function(res) 
		Pomelo.AuctionHandler.lastAuctionItemPush = res
		cb(nil,res) 
	end, auctionItemPushDecoder) 
end


local function addAuctionItemPushDecoder(stream)
	local res = auctionHandler_pb.AddAuctionItemPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.AuctionHandler.addAuctionItemPush(cb)
	Socket.On("auction.auctionPush.addAuctionItemPush", function(res) 
		Pomelo.AuctionHandler.lastAddAuctionItemPush = res
		cb(nil,res) 
	end, addAuctionItemPushDecoder) 
end


local function removeAuctionItemPushDecoder(stream)
	local res = auctionHandler_pb.RemoveAuctionItemPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.AuctionHandler.removeAuctionItemPush(cb)
	Socket.On("auction.auctionPush.removeAuctionItemPush", function(res) 
		Pomelo.AuctionHandler.lastRemoveAuctionItemPush = res
		cb(nil,res) 
	end, removeAuctionItemPushDecoder) 
end





return Pomelo
