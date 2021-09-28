





local Socket = require "Zeus.Pomelo.LuaGameSocket"
require "base64"
require "storeHandler_pb"


Pomelo = Pomelo or {}


Pomelo.StoreHandler = {}

function Pomelo.StoreHandler.unEmbedGemRequest(c2s_target,c2s_gridIndex,c2s_holeIndexs,cb,option)
	local msg = {}
	msg.c2s_target = c2s_target
	msg.c2s_gridIndex = c2s_gridIndex
	msg.c2s_holeIndexs = c2s_holeIndexs
	local input = storeHandler_pb.UnEmbedGemRequest()
	protobuf.FromMessage(input,msg)
	Socket.Request("area.storeHandler.unEmbedGemRequest", ZZBase64.encode(input:SerializeToString()),function(stream)
		stream = ZZBase64.decode(stream)
		local res = storeHandler_pb.UnEmbedGemResponse()
		res:ParseFromString(stream)
		if(res.s2c_code == 200) then
			Pomelo.StoreHandler.lastUnEmbedGemResponse = res
			Socket.OnRequestEnd(true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.storeHandler.unEmbedGemRequest decode error!!"
			end
			Socket.OnRequestEnd(false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end,option)
end

function Pomelo.StoreHandler.embedGemRequest(c2s_target,c2s_gridIndex,c2s_gems,cb,option)
	local msg = {}
	msg.c2s_target = c2s_target
	msg.c2s_gridIndex = c2s_gridIndex
	msg.c2s_gems = c2s_gems
	local input = storeHandler_pb.EmbedGemRequest()
	protobuf.FromMessage(input,msg)
	Socket.Request("area.storeHandler.embedGemRequest", ZZBase64.encode(input:SerializeToString()),function(stream)
		stream = ZZBase64.decode(stream)
		local res = storeHandler_pb.EmbedGemResponse()
		res:ParseFromString(stream)
		if(res.s2c_code == 200) then
			Pomelo.StoreHandler.lastEmbedGemResponse = res
			Socket.OnRequestEnd(true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.storeHandler.embedGemRequest decode error!!"
			end
			Socket.OnRequestEnd(false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end,option)
end

function Pomelo.StoreHandler.synGemRequest(c2s_templateId,c2s_num,cb,option)
	local msg = {}
	msg.c2s_templateId = c2s_templateId
	msg.c2s_num = c2s_num
	local input = storeHandler_pb.SynGemRequest()
	protobuf.FromMessage(input,msg)
	Socket.Request("area.storeHandler.synGemRequest", ZZBase64.encode(input:SerializeToString()),function(stream)
		stream = ZZBase64.decode(stream)
		local res = storeHandler_pb.SynGemResponse()
		res:ParseFromString(stream)
		if(res.s2c_code == 200) then
			Pomelo.StoreHandler.lastSynGemResponse = res
			Socket.OnRequestEnd(true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.storeHandler.synGemRequest decode error!!"
			end
			Socket.OnRequestEnd(false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end,option)
end

function Pomelo.StoreHandler.sellItemsOfBagRequest(c2s_grids,cb,option)
	local msg = {}
	msg.c2s_grids = c2s_grids
	local input = storeHandler_pb.SellItemsOfBagRequest()
	protobuf.FromMessage(input,msg)
	Socket.Request("area.storeHandler.sellItemsOfBagRequest", ZZBase64.encode(input:SerializeToString()),function(stream)
		stream = ZZBase64.decode(stream)
		local res = storeHandler_pb.SellItemsOfBagResponse()
		res:ParseFromString(stream)
		if(res.s2c_code == 200) then
			Pomelo.StoreHandler.lastSellItemsOfBagResponse = res
			Socket.OnRequestEnd(true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.storeHandler.sellItemsOfBagRequest decode error!!"
			end
			Socket.OnRequestEnd(false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end,option)
end

function Pomelo.StoreHandler.buyItemFromTJPRequest(c2s_grid,cb,option)
	local msg = {}
	msg.c2s_grid = c2s_grid
	local input = storeHandler_pb.BuyItemFromTJPRequest()
	protobuf.FromMessage(input,msg)
	Socket.Request("area.storeHandler.buyItemFromTJPRequest", ZZBase64.encode(input:SerializeToString()),function(stream)
		stream = ZZBase64.decode(stream)
		local res = storeHandler_pb.BuyItemFromTJPResponse()
		res:ParseFromString(stream)
		if(res.s2c_code == 200) then
			Pomelo.StoreHandler.lastBuyItemFromTJPResponse = res
			Socket.OnRequestEnd(true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.storeHandler.buyItemFromTJPRequest decode error!!"
			end
			Socket.OnRequestEnd(false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end,option)
end

function Pomelo.StoreHandler.refreshItemsOfTJPRequest(cb,option)
	local input = nil
	Socket.Request("area.storeHandler.refreshItemsOfTJPRequest", input,function(stream)
		stream = ZZBase64.decode(stream)
		local res = storeHandler_pb.RefreshItemsOfTJPResponse()
		res:ParseFromString(stream)
		if(res.s2c_code == 200) then
			Pomelo.StoreHandler.lastRefreshItemsOfTJPResponse = res
			Socket.OnRequestEnd(true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.storeHandler.refreshItemsOfTJPRequest decode error!!"
			end
			Socket.OnRequestEnd(false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end,option)
end

function Pomelo.StoreHandler.getItemsOfTJPRequest(cb,option)
	local input = nil
	Socket.Request("area.storeHandler.getItemsOfTJPRequest", input,function(stream)
		stream = ZZBase64.decode(stream)
		local res = storeHandler_pb.GetItemsOfTJPResponse()
		res:ParseFromString(stream)
		if(res.s2c_code == 200) then
			Pomelo.StoreHandler.lastGetItemsOfTJPResponse = res
			Socket.OnRequestEnd(true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.storeHandler.getItemsOfTJPRequest decode error!!"
			end
			Socket.OnRequestEnd(false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end,option)
end

function Pomelo.StoreHandler.getNpcShopRequest(c2s_npcId,cb,option)
	local msg = {}
	msg.c2s_npcId = c2s_npcId
	local input = storeHandler_pb.GetNpcShopRequest()
	protobuf.FromMessage(input,msg)
	Socket.Request("area.storeHandler.getNpcShopRequest", ZZBase64.encode(input:SerializeToString()),function(stream)
		stream = ZZBase64.decode(stream)
		local res = storeHandler_pb.GetNpcShopResponse()
		res:ParseFromString(stream)
		if(res.s2c_code == 200) then
			Pomelo.StoreHandler.lastGetNpcShopResponse = res
			Socket.OnRequestEnd(true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.storeHandler.getNpcShopRequest decode error!!"
			end
			Socket.OnRequestEnd(false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end,option)
end

function Pomelo.StoreHandler.buyItemFromNpcShopRequest(c2s_npcId,c2s_grid,cb,option)
	local msg = {}
	msg.c2s_npcId = c2s_npcId
	msg.c2s_grid = c2s_grid
	local input = storeHandler_pb.BuyItemFromNpcShopRequest()
	protobuf.FromMessage(input,msg)
	Socket.Request("area.storeHandler.buyItemFromNpcShopRequest", ZZBase64.encode(input:SerializeToString()),function(stream)
		stream = ZZBase64.decode(stream)
		local res = storeHandler_pb.BuyItemFromNpcShopResponse()
		res:ParseFromString(stream)
		if(res.s2c_code == 200) then
			Pomelo.StoreHandler.lastBuyItemFromNpcShopResponse = res
			Socket.OnRequestEnd(true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.storeHandler.buyItemFromNpcShopRequest decode error!!"
			end
			Socket.OnRequestEnd(false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end,option)
end

function Pomelo.StoreHandler.viewBagItemRequest(c2s_gridIndex,cb,option)
	local msg = {}
	msg.c2s_gridIndex = c2s_gridIndex
	local input = storeHandler_pb.ViewBagItemRequest()
	protobuf.FromMessage(input,msg)
	Socket.Request("area.storeHandler.viewBagItemRequest", ZZBase64.encode(input:SerializeToString()),function(stream)
		stream = ZZBase64.decode(stream)
		local res = storeHandler_pb.ViewBagItemResponse()
		res:ParseFromString(stream)
		if(res.s2c_code == 200) then
			Pomelo.StoreHandler.lastViewBagItemResponse = res
			Socket.OnRequestEnd(true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.storeHandler.viewBagItemRequest decode error!!"
			end
			Socket.OnRequestEnd(false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end,option)
end

function Pomelo.StoreHandler.packUpBagRequest(cb,option)
	local input = nil
	Socket.Request("area.storeHandler.packUpBagRequest", input,function(stream)
		stream = ZZBase64.decode(stream)
		local res = storeHandler_pb.PackUpBagResponse()
		res:ParseFromString(stream)
		if(res.s2c_code == 200) then
			Pomelo.StoreHandler.lastPackUpBagResponse = res
			Socket.OnRequestEnd(true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.storeHandler.packUpBagRequest decode error!!"
			end
			Socket.OnRequestEnd(false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end,option)
end

function Pomelo.StoreHandler.openBagGridRequest(c2s_stackIndex,cb,option)
	local msg = {}
	msg.c2s_stackIndex = c2s_stackIndex
	local input = storeHandler_pb.OpenBagGridRequest()
	protobuf.FromMessage(input,msg)
	Socket.Request("area.storeHandler.openBagGridRequest", ZZBase64.encode(input:SerializeToString()),function(stream)
		stream = ZZBase64.decode(stream)
		local res = storeHandler_pb.OpenBagGridResponse()
		res:ParseFromString(stream)
		if(res.s2c_code == 200) then
			Pomelo.StoreHandler.lastOpenBagGridResponse = res
			Socket.OnRequestEnd(true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.storeHandler.openBagGridRequest decode error!!"
			end
			Socket.OnRequestEnd(false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end,option)
end

function Pomelo.StoreHandler.disCardBagItemNotify(c2s_gridIndex,c2s_itemNum)
	local msg = {}
	msg.c2s_gridIndex = c2s_gridIndex
	msg.c2s_itemNum = c2s_itemNum
	local input = storeHandler_pb.DisCardBagItemNotify()
	protobuf.FromMessage(input,msg)
	Socket.Notify("area.storeHandler.disCardBagItemNotify",ZZBase64.encode(input:SerializeToString()))
end

function Pomelo.StoreHandler.disCardBagItemByPosNotify(c2s_gridIndex)
	local msg = {}
	msg.c2s_gridIndex = c2s_gridIndex
	local input = storeHandler_pb.DisCardBagItemByPosNotify()
	protobuf.FromMessage(input,msg)
	Socket.Notify("area.storeHandler.disCardBagItemByPosNotify",ZZBase64.encode(input:SerializeToString()))
end

function Pomelo.StoreHandler.addBagItemTestNotify(c2s_itemId)
	local msg = {}
	msg.c2s_itemId = c2s_itemId
	local input = storeHandler_pb.AddBagItemTestNotify()
	protobuf.FromMessage(input,msg)
	Socket.Notify("area.storeHandler.addBagItemTestNotify",ZZBase64.encode(input:SerializeToString()))
end

function Pomelo.StoreHandler.bagItemDynamicPush(cb)
	Socket.On("area.storePush.bagItemDynamicPush", function(stream) 
		stream = ZZBase64.decode(stream) 
		local res = storeHandler_pb.BagItemDynamicPush() 
		res:ParseFromString(stream) 
		if(res.s2c_code == 200) then 
			Pomelo.StoreHandler.lastBagItemDynamicPush = res
			Socket.OnRequestEnd(true) 
			cb(nil,res) 
		else 
			local ex = {} 
			if(res.s2c_code) then 
				ex.Code = res.s2c_code 
				ex.Message = res.s2c_msg 
			else 
				ex.Code = 501 
				ex.Message = "[LuaXmdsNetClient] area.storePush.bagItemDynamicPush decode error!!" 
			end 
			Socket.OnRequestEnd(false,ex.Code,ex.Message) 
			cb(ex,nil) 
		end 
	end) 
end

function Pomelo.StoreHandler.bagItemUpdatePush(cb)
	Socket.On("area.storePush.bagItemUpdatePush", function(stream) 
		stream = ZZBase64.decode(stream) 
		local res = storeHandler_pb.BagItemUpdatePush() 
		res:ParseFromString(stream) 
		if(res.s2c_code == 200) then 
			Pomelo.StoreHandler.lastBagItemUpdatePush = res
			Socket.OnRequestEnd(true) 
			cb(nil,res) 
		else 
			local ex = {} 
			if(res.s2c_code) then 
				ex.Code = res.s2c_code 
				ex.Message = res.s2c_msg 
			else 
				ex.Code = 501 
				ex.Message = "[LuaXmdsNetClient] area.storePush.bagItemUpdatePush decode error!!" 
			end 
			Socket.OnRequestEnd(false,ex.Code,ex.Message) 
			cb(ex,nil) 
		end 
	end) 
end

function Pomelo.StoreHandler.itemDetailDynamicPush(cb)
	Socket.On("area.storePush.itemDetailDynamicPush", function(stream) 
		stream = ZZBase64.decode(stream) 
		local res = storeHandler_pb.ItemDetailDynamicPush() 
		res:ParseFromString(stream) 
		if(res.s2c_code == 200) then 
			Pomelo.StoreHandler.lastItemDetailDynamicPush = res
			Socket.OnRequestEnd(true) 
			cb(nil,res) 
		else 
			local ex = {} 
			if(res.s2c_code) then 
				ex.Code = res.s2c_code 
				ex.Message = res.s2c_msg 
			else 
				ex.Code = 501 
				ex.Message = "[LuaXmdsNetClient] area.storePush.itemDetailDynamicPush decode error!!" 
			end 
			Socket.OnRequestEnd(false,ex.Code,ex.Message) 
			cb(ex,nil) 
		end 
	end) 
end




return Pomelo
