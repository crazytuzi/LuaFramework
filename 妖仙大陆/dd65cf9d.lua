





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "intergalMallHandler_pb"


Pomelo = Pomelo or {}


Pomelo.IntergalMallHandler = {}

local function getMallScoreItemListRequestEncoder(msg)
	local input = intergalMallHandler_pb.GetIntergalMallListRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getMallScoreItemListRequestDecoder(stream)
	local res = intergalMallHandler_pb.GetIntergalMallListResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.IntergalMallHandler.getMallScoreItemListRequest(c2s_type,cb,option)
	local msg = {}
	msg.c2s_type = c2s_type
	Socket.OnRequestStart("area.intergalMallHandler.getMallScoreItemListRequest", option)
	Socket.Request("area.intergalMallHandler.getMallScoreItemListRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.IntergalMallHandler.lastGetIntergalMallListResponse = res
			Socket.OnRequestEnd("area.intergalMallHandler.getMallScoreItemListRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.intergalMallHandler.getMallScoreItemListRequest decode error!!"
			end
			Socket.OnRequestEnd("area.intergalMallHandler.getMallScoreItemListRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getMallScoreItemListRequestEncoder, getMallScoreItemListRequestDecoder)
end


local function buyIntergalItemRequestEncoder(msg)
	local input = intergalMallHandler_pb.BuyIntergalItemRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function buyIntergalItemRequestDecoder(stream)
	local res = intergalMallHandler_pb.BuyIntergalItemResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.IntergalMallHandler.buyIntergalItemRequest(c2s_type,c2s_itemId,c2s_num,cb,option)
	local msg = {}
	msg.c2s_type = c2s_type
	msg.c2s_itemId = c2s_itemId
	msg.c2s_num = c2s_num
	Socket.OnRequestStart("area.intergalMallHandler.buyIntergalItemRequest", option)
	Socket.Request("area.intergalMallHandler.buyIntergalItemRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.IntergalMallHandler.lastBuyIntergalItemResponse = res
			Socket.OnRequestEnd("area.intergalMallHandler.buyIntergalItemRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.intergalMallHandler.buyIntergalItemRequest decode error!!"
			end
			Socket.OnRequestEnd("area.intergalMallHandler.buyIntergalItemRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, buyIntergalItemRequestEncoder, buyIntergalItemRequestDecoder)
end





return Pomelo
