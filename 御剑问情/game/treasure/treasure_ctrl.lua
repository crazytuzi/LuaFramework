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
	-- self.reward_show = TreasureRewardShowView.New(ViewName.TreasureRewardShow)
	self:RegisterAllProtocols()
end

function TreasureCtrl:__delete()
	-- self.reward_show:DeleteMe()
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
	self:RegisterProtocol(CSRedEquipItemConvert)
	self:RegisterProtocol(SCRedEquipItemConvertInfo, 'OnRedEquipItemConvertInfo')
	self:RegisterProtocol(SCRedEquipItemConvertSingleInfo, 'OnRedEquipItemConvertSingleInfo')
end

--返回宝物仓库的全部物品
function TreasureCtrl:OnSelfChestShopItemList(protocol)
	if protocol.shop_type == CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_JINGLING then
		SpiritData.Instance:SetHuntSpiritWarehouseList(protocol.chest_item_info)	--精灵仓库
		RemindManager.Instance:Fire(RemindName.SpiritWarehouse)

	elseif protocol.shop_type == CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP then	-- 装备寻宝
		self.data:OnSelfChestShopItemList(protocol)
		LittlePetCtrl.Instance:OnSelfChestShopItemList(protocol.chest_item_info)
		if self.view:IsOpen() then
			self.view:Flush("warehouse")
		end
	end
	RemindManager.Instance:Fire(RemindName.XunBaoTreasure)
	RemindManager.Instance:Fire(RemindName.XunBaoWarehouse)
end

--返回每次开宝箱得到的物品
function TreasureCtrl:OnChestShopItemListPerBuy(protocol)
	local chest_item_info = protocol.chest_item_info
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
				self.view:FlushCoinText()
				self.view.treasure_content_view:FlushTime()
				self.view.treasure_content_view:FlushText()
				TipsCtrl.Instance:ShowTreasureView(TreasureData.Instance:GetChestShopMode())
			elseif FanFanZhuanCtrl.Instance:IsOpen() then
				FanFanZhuanData.Instance:SetTreasureItemList(protocol.chest_item_info)
				TipsCtrl.Instance:ShowTreasureView(TreasureData.Instance:GetChestShopMode())
			end
		end
	end
	RemindManager.Instance:Fire(RemindName.XunBaoTreasure)
	RemindManager.Instance:Fire(RemindName.XunBaoWarehouse)
end

--获得寻宝倒计时
function TreasureCtrl:OnChestShopFreeInfo(protocol)
	self.data:OnChestShopFreeInfo(protocol)

	if protocol.chest_shop_jl_next_free_time_1 - TimeCtrl.Instance:GetServerTime() > 0 then
		MainUICtrl.Instance:SpiritHuntCountDown()
		SpiritData.Instance:SetHuntSpiritFreeTime(protocol.chest_shop_jl_next_free_time_1)	--精灵倒计时
		RemindManager.Instance:Fire(RemindName.SpiritWarehouse)
		RemindManager.Instance:Fire(RemindName.SpiritFreeHunt)
	end
	RemindManager.Instance:Fire(RemindName.XunBaoTreasure)
	RemindManager.Instance:Fire(RemindName.XunBaoWarehouse)
end

function TreasureCtrl:OnRedEquipItemConvertInfo(protocol)
	self.data:SetEquipItemConvertInfo(protocol.convert_count_list)
	if self.view:IsOpen() then
		self.view:Flush("equip_exchange")
	end

	RemindManager.Instance:Fire(RemindName.RedEquipExchange)
end


function TreasureCtrl:OnRedEquipItemConvertSingleInfo(protocol)
	self.data:UpDateEquipItemConvertInfo(protocol.seq, protocol.convert_count)
	if self.view:IsOpen() then
		self.view:Flush("equip_exchange")
	end
	
	RemindManager.Instance:Fire(RemindName.RedEquipExchange)
end

function TreasureCtrl:ReqRedEquipItemConvert(seq)
	local protocol = ProtocolPool.Instance:GetProtocol(CSRedEquipItemConvert)
	protocol.seq = seq or 0
	protocol:EncodeAndSend()
end

-- 发送请求宝物仓库信息
function TreasureCtrl:SendChestShopItemListReq(shop_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetSelfChestShopItemList)
	protocol.shop_type = shop_type
	protocol:EncodeAndSend()
end

-- 发送寻宝请求
function TreasureCtrl:SendXunbaoReq(mode, shop_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSBuyChestShopItem)
	protocol.mode = mode
	protocol.shop_type = shop_type
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

