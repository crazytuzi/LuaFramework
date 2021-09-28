





local Socket = require "Zeus.Pomelo.LuaGameSocket"
require "base64"
require "mallHandler_pb"


Pomelo = Pomelo or {}


Pomelo.MallHandler = {}

function Pomelo.MallHandler.refreshMallScoreItemListRequest(cb,option)
	local input = nil
	Socket.Request("area.mallHandler.refreshMallScoreItemListRequest", input,function(stream)
		stream = ZZBase64.decode(stream)
		local res = mallHandler_pb.RefreshMallScoreItemListResponse()
		res:ParseFromString(stream)
		if(res.s2c_code == 200) then
			Pomelo.MallHandler.lastRefreshMallScoreItemListResponse = res
			Socket.OnRequestEnd(true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.mallHandler.refreshMallScoreItemListRequest decode error!!"
			end
			Socket.OnRequestEnd(false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end,option)
end

function Pomelo.MallHandler.getMallScoreItemListRequest(cb,option)
	local input = nil
	Socket.Request("area.mallHandler.getMallScoreItemListRequest", input,function(stream)
		stream = ZZBase64.decode(stream)
		local res = mallHandler_pb.GetMallScoreItemListResponse()
		res:ParseFromString(stream)
		if(res.s2c_code == 200) then
			Pomelo.MallHandler.lastGetMallScoreItemListResponse = res
			Socket.OnRequestEnd(true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.mallHandler.getMallScoreItemListRequest decode error!!"
			end
			Socket.OnRequestEnd(false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end,option)
end

function Pomelo.MallHandler.buyMallItemRequest(c2s_itemId,c2s_count,c2s_playerId,cb,option)
	local msg = {}
	msg.c2s_itemId = c2s_itemId
	msg.c2s_count = c2s_count
	msg.c2s_playerId = c2s_playerId
	local input = mallHandler_pb.BuyMallItemRequest()
	protobuf.FromMessage(input,msg)
	Socket.Request("area.mallHandler.buyMallItemRequest", ZZBase64.encode(input:SerializeToString()),function(stream)
		stream = ZZBase64.decode(stream)
		local res = mallHandler_pb.BuyMallItemResponse()
		res:ParseFromString(stream)
		if(res.s2c_code == 200) then
			Pomelo.MallHandler.lastBuyMallItemResponse = res
			Socket.OnRequestEnd(true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.mallHandler.buyMallItemRequest decode error!!"
			end
			Socket.OnRequestEnd(false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end,option)
end

function Pomelo.MallHandler.getMallItemListRequest(c2s_moneyType,c2s_itemType,cb,option)
	local msg = {}
	msg.c2s_moneyType = c2s_moneyType
	msg.c2s_itemType = c2s_itemType
	local input = mallHandler_pb.GetMallItemListRequest()
	protobuf.FromMessage(input,msg)
	Socket.Request("area.mallHandler.getMallItemListRequest", ZZBase64.encode(input:SerializeToString()),function(stream)
		stream = ZZBase64.decode(stream)
		local res = mallHandler_pb.GetMallItemListResponse()
		res:ParseFromString(stream)
		if(res.s2c_code == 200) then
			Pomelo.MallHandler.lastGetMallItemListResponse = res
			Socket.OnRequestEnd(true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.mallHandler.getMallItemListRequest decode error!!"
			end
			Socket.OnRequestEnd(false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end,option)
end

function Pomelo.MallHandler.buyMallScoreItemRequest(c2s_itemId,cb,option)
	local msg = {}
	msg.c2s_itemId = c2s_itemId
	local input = mallHandler_pb.BuyMallScoreItemRequest()
	protobuf.FromMessage(input,msg)
	Socket.Request("area.mallHandler.buyMallScoreItemRequest", ZZBase64.encode(input:SerializeToString()),function(stream)
		stream = ZZBase64.decode(stream)
		local res = mallHandler_pb.BuyMallScoreItemResponse()
		res:ParseFromString(stream)
		if(res.s2c_code == 200) then
			Pomelo.MallHandler.lastBuyMallScoreItemResponse = res
			Socket.OnRequestEnd(true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.mallHandler.buyMallScoreItemRequest decode error!!"
			end
			Socket.OnRequestEnd(false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end,option)
end




return Pomelo
