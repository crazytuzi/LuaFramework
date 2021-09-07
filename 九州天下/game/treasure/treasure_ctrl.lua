require("game/treasure/treasure_data")
require("game/treasure/treasure_view")
require("game/treasure/treasure_reward_show")
TreasureCtrl = TreasureCtrl or BaseClass(BaseController)

function TreasureCtrl:__init()
	if TreasureCtrl.Instance then
		print_error("[TreasureCtrl] Attemp to create a singleton twice !")
	end
	TreasureCtrl.Instance = self
	self.data = TreasureData.New()
	self.view = TreasureView.New(ViewName.Treasure)
	self.reward_show = TreasureRewardShowView.New(ViewName.TreasureRewardShow)
	self:RegisterAllProtocols()
end

function TreasureCtrl:__delete()
	self.reward_show:DeleteMe()
	self.view:DeleteMe()
	self.data:DeleteMe()
	TreasureCtrl.Instance = nil
end

function TreasureCtrl:GetView()
	return self.view
end

function TreasureCtrl:GetData()
	return self.data
end

function TreasureCtrl:GetTreasureExchangeView()
	return self.view:GetTreasureExchange()
end

function TreasureCtrl:GetTreasureWareView()
	return self.view:GetTreasureWareView()
end

function TreasureCtrl:GetTreasureContentView()
	return self.view:GetTreasureContentView()
end

function TreasureCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCSelfChestShopItemList, "OnSelfChestShopItemList")
	self:RegisterProtocol(SCChestShopItemListPerBuy, 'OnChestShopItemListPerBuy')
	self:RegisterProtocol(SCChestShopFreeInfo, 'OnChestShopFreeInfo')
end

--返回宝物仓库的全部物品
function TreasureCtrl:OnSelfChestShopItemList(protocol)
	self.data:OnSelfChestShopItemList(protocol)
	LittlePetCtrl.Instance:OnSelfChestShopItemList(protocol.chest_item_info)
	if self.view:IsOpen() then
		self.view:Flush("warehouse")
	end

	if protocol.shop_type == CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_JINGLING then
		SpiritData.Instance:SetHuntSpiritWarehouseList(protocol.chest_item_info)	--精灵仓库
		-- RemindManager.Instance:Fire(RemindName.Spirit)
	end
	RemindManager.Instance:Fire(RemindName.XunBaoTreasure)
	RemindManager.Instance:Fire(RemindName.XunBaoExchange)
	RemindManager.Instance:Fire(RemindName.XunBaoWarehouse)
	RemindManager.Instance:Fire(RemindName.BeautyPray)
	BeautyCtrl.Instance:FlushViewInfo()
end

--返回每次开宝箱得到的物品
function TreasureCtrl:OnChestShopItemListPerBuy(protocol)
	local chest_item_info = TableCopy(protocol.chest_item_info)
	--拆分物品
	if protocol.count < 10 then
		for k, v in ipairs(chest_item_info) do
			if v.num > 1 then
				for i = 2, v.num do
					table.insert(chest_item_info, v)
				end
				v.num = 1
			end
		end
	end
	if protocol.shop_type == CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_JINGLING then
		SpiritData.Instance:SetHuntSpiritItemList(protocol.chest_item_info)		--精灵物品
	else
		self.data:OnChestShopItemListPerBuy(protocol)
		if protocol.shop_type == CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP then
			if self.view:IsOpen() then
				self.view:Flush("treasure")
				TipsCtrl.Instance:ShowTreasureView(TreasureData.Instance:GetChestShopMode())
			elseif FanFanZhuanCtrl.Instance:IsOpen() then
				FanFanZhuanData.Instance:SetTreasureItemList(protocol.chest_item_info)
				TipsCtrl.Instance:ShowTreasureView(TreasureData.Instance:GetChestShopMode())
				KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_PLEASE_DRAW_CARD, RA_KING_DRAW_OPERA_TYPE.RA_KING_DRAW_OPERA_TYPE_QUERY_INFO)
			end
		end
	end
	RemindManager.Instance:Fire(RemindName.XunBaoTreasure)
	RemindManager.Instance:Fire(RemindName.XunBaoExchange)
	RemindManager.Instance:Fire(RemindName.XunBaoWarehouse)
end

--获得寻宝倒计时
function TreasureCtrl:OnChestShopFreeInfo(protocol)
	self.data:OnChestShopFreeInfo(protocol)
	-- RemindManager.Instance:Fire(RemindName.Spirit)

	if protocol.chest_shop_jl_next_free_time_1 - TimeCtrl.Instance:GetServerTime() > 0 then
		MainUICtrl.Instance:SpiritHuntCountDown()
		SpiritData.Instance:SetHuntSpiritFreeTime(protocol.chest_shop_jl_next_free_time_1)	--精灵倒计时
	end
	RemindManager.Instance:Fire(RemindName.XunBaoTreasure)
	RemindManager.Instance:Fire(RemindName.XunBaoExchange)
	RemindManager.Instance:Fire(RemindName.XunBaoWarehouse)
end

-- 发送请求宝物仓库信息
function TreasureCtrl:SendChestShopItemListReq(shop_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetSelfChestShopItemList)
	protocol.shop_type = shop_type
	protocol:EncodeAndSend()
end

-- 发送寻宝请求
function TreasureCtrl:SendXunbaoReq(mode, shop_type, is_auto_buy)
	local protocol = ProtocolPool.Instance:GetProtocol(CSBuyChestShopItem)
	protocol.mode = mode
	protocol.shop_type = shop_type
	protocol.is_auto_buy = is_auto_buy
	protocol:EncodeAndSend()
end

-- 发送从宝箱中取出物品的协议
function TreasureCtrl:SendQuchuItemReq(grid_index, shop_type, if_fetch_all)
	local protocol = ProtocolPool.Instance:GetProtocol(CSFetchChestShopItem)
	protocol.grid_index = grid_index
	protocol.shop_type = shop_type
	protocol.if_fetch_all = if_fetch_all
	protocol:EncodeAndSend()
end

-- 发送请求寻宝免费
function TreasureCtrl:SendChestShopGetFreeInfo()
	local protocol = ProtocolPool.Instance:GetProtocol(CSChestShopGetFreeInfo)
	protocol:EncodeAndSend()
end

-- 发送回收精灵仓库中的精灵
function TreasureCtrl:SendChestShopAutoRecycle(shop_type, max_color)
	local protocol = ProtocolPool.Instance:GetProtocol(CSChestShopAutoRecycle)
	protocol.shop_type = shop_type
	protocol.max_color = max_color or 0
	protocol:EncodeAndSend()
end

--消耗积分兑换物品请求
function TreasureCtrl:SendScoreToItemConvertReq(conver_type, seq, num)
	local protocol = ProtocolPool.Instance:GetProtocol(CSScoreToItemConvert)
	protocol.scoretoitem_type = conver_type
	protocol.index = seq
	protocol.num = num
	protocol:EncodeAndSend()
end

--兑换记录信息请求
function TreasureCtrl:SendGetConvertRecordInfo()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetConvertRecordInfo)
	protocol:EncodeAndSend()
end

