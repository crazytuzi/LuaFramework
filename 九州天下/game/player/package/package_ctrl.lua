require("game/player/package/item_data")
require("game/player/package/equip_data")
require("game/player/package/package_data")

-- 背包
PackageCtrl = PackageCtrl or BaseClass(BaseController)

local CHECK_PACK_CD = 60
local CHECK_PACK_LEVEL = 130

local ITEM_CHANGE_FLUSH_CD = 1

function PackageCtrl:__init()
	if PackageCtrl.Instance then
		print_error("[PackageCtrl] Attemp to create a singleton twice !")
		return
	end
	PackageCtrl.Instance = self

	self:RegisterAllProtocols()
	self:RegisterAllEvents()

	self.item_data = ItemData.New()
	self.equip_data = EquipData.New()
	self.package_data = PackageData.New()

	self.item_change = false
	self.item_data_update_time = 0

	self.is_first_enter = true
end

function PackageCtrl:__delete()
	PackageCtrl.Instance = nil

	self.package_data:DeleteMe()
	self.package_data = nil

	self.item_data:DeleteMe()
	self.item_data = nil

	self.equip_data:DeleteMe()
	self.equip_data = nil

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	if self.item_change_timer_quest then
		GlobalTimerQuest:CancelQuest(self.item_change_timer_quest)
		self.item_change_timer_quest = nil
	end

	if self.item_param_change_timer_quest then
		GlobalTimerQuest:CancelQuest(self.item_param_change_timer_quest)
		self.item_param_change_timer_quest = nil
	end

	GlobalTimerQuest:CancelQuest(self.itemchange_delay_timer)
	self.itemchange_delay_timer = nil
	self.item_change = false

	if self.audit_version_handle then
		GlobalEventSystem:UnBind(self.audit_version_handle)
		self.audit_version_handle = nil
	end

	self.is_first_enter = false
end

-- 协议注册
function PackageCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCKnapsackInfoAck, "OnKnapsackInfoAck");
	self:RegisterProtocol(SCKnapsackInfoParam, "OnKnapsackInfoParam");
	self:RegisterProtocol(SCKnapsackItemChange, "OnKnapsackItemChange");
	self:RegisterProtocol(SCKnapsackItemChangeParam, "OnKnapsackItemChangeParam");
	self:RegisterProtocol(SCUseItemSuc, "OnUseItemSuc");
	self:RegisterProtocol(SCKnapsackMaxGridNum, "OnKnapsackMaxGridNum");
	self:RegisterProtocol(SCStorageMaxGridNum, "OnStorageMaxGridNum");
	self:RegisterProtocol(SCLeckItem, "OnLackItem")
	self:RegisterProtocol(SCRewardListInfo, "OnRewardListInfo")

	self:RegisterProtocol(CSKnapsackStoragePutInOrder)
	self:RegisterProtocol(CSUseItem)
end

function PackageCtrl:RegisterAllEvents()
	-- GlobalEventSystem:Bind(LoginEventType.LOGIN_SERVER_CONNECTED, enter_login_server_callback)
end

function PackageCtrl:CheckBetterEquipCountDown()
	-- if not self.time_quest then
	-- 	self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.ShowBatterEquipView, self), CHECK_PACK_CD)
	-- end

	local now_time = TimeCtrl.Instance:GetServerTime()
	if now_time > self.item_data_update_time then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end

		self.item_data_update_time = now_time + 10
		for _, v in ipairs(RemindByItemChange) do
			RemindManager.Instance:Fire(v)
		end
	else
		if not self.time_quest then
			self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.CheckBetterEquipCountDown, self), self.item_data_update_time - now_time + 1)
		end
	end
end

function PackageCtrl:ShowBatterEquipView()
	local item_id, index = PackageData.Instance:CheckBagBatterEquip()
	if item_id == 0 then
		return
	end
	TipsCtrl.Instance:ShowBetterEquipView(item_id, index)
end

function PackageCtrl:ShowQuickEquipVieww()
	local item_id, index = PackageData.Instance:CheckBagBatterEquip()
	if item_id == 0 then
		return
	end
	if self.is_first_enter and IS_AUDIT_VERSION then
		self.is_first_enter = false
		return
	end
	if not FishingData.Instance:GetFishingScene() then
		TipsCtrl.Instance:ShowShorCutEquipView(item_id, index)
	end
end

--使用物品
function PackageCtrl:SendUseItem(index, num, equip_index, need_gold)
	-- print("点击使用","index====",index, "equip_index=====",equip_index)
	local cmd = ProtocolPool.Instance:GetProtocol(CSUseItem)
	cmd.index = index
	cmd.num = num or 1
	cmd.equip_index = equip_index or 0
	if need_gold and tonumber(need_gold) > 0 then
		print_log("SendUseItem: "..need_gold)
	end
	cmd:EncodeAndSend()
end

--移除物品，把物品放仓库
function PackageCtrl:SendRemoveItem(from_index, to_index)
	-- print("把物品放仓库或取出到背包")
	local cmd = ProtocolPool.Instance:GetProtocol(CSMoveItem)
	cmd.from_index = from_index
	cmd.to_index = to_index
	cmd:EncodeAndSend()
end

--丢弃物品
--discard_medthod 0出售 1回收
function PackageCtrl:SendDiscardItem(index, discard_num, item_id_in_client, item_num_in_client, discard_medthod)
	local exp = CampData.Instance:GetEquipMonsterExp(item_id_in_client)
	if exp > 0 then
		TipsCtrl.Instance:ShowFloatingLabel(string.format(Language.Camp.ShenShouExp, exp))
	end

	local cmd = ProtocolPool.Instance:GetProtocol(CSDiscardItem)
	cmd.index = index
	cmd.discard_num = discard_num or 1
	cmd.item_id_in_client = item_id_in_client or 0
	cmd.item_num_in_client = item_num_in_client or 0
	cmd.discard_medthod = discard_medthod or 0
	cmd:EncodeAndSend()
end

function PackageCtrl:GetIsInit()
	return self.is_init
end

--背包所有物品数据
function PackageCtrl:OnKnapsackInfoAck(protocol)
	ItemData.Instance:SetMaxKnapsackValidNum(protocol.max_knapsack_valid_num)
	ItemData.Instance:SetMaxStorageValidNum(protocol.max_storage_valid_num)
	local old_empty_num = self.item_data:GetEmptyNum()
	ItemData.Instance:SetDataList(protocol.info_list)

	self:CheckBagClearEquipmentAlert(old_empty_num)

	if EquipData.Instance:IsSetEquipInfo() then
		self:ShowQuickEquipVieww()
	end

	-- 每5分钟检测一次背包
	self:CheckBetterEquipCountDown()
	ComposeData.Instance:InitRedList()

	-- for _, v in ipairs(RemindByItemChange) do
	-- 	RemindManager.Instance:Fire(v)
	-- end
end

function PackageCtrl:CheckBagClearEquipmentAlert(old_empty_num)
end

function PackageCtrl:OnLackItem(protocol)
	print_log("使用失败回调", protocol.item_id, protocol.item_count)
	local item_id = protocol.item_id
	local item_count = protocol.item_count
	GlobalEventSystem:Fire(KnapsackEventType.KNAPSACK_LECK_ITEM, protocol.item_id, protocol.item_count)
end

function PackageCtrl:OnRewardListInfo(protocol)
	ItemData.Instance:SetNormalRewardList(protocol.reward_list)
	if protocol.reward_num > 0 then
		TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_RANK_GIFT)
	end
end

function PackageCtrl:OnKnapsackItemChange(protocol)
	--print_log("物品变动回调", protocol)
	ItemData.Instance:ChangeDataInGrid(protocol)
	self:CheckBagClearEquipmentAlert(old_empty_num)
	self:ItemChangeFlush()

	local mian_view = MainUICtrl.Instance:GetView()
	if mian_view then
		mian_view:Flush("flush_package")
	end
end

function PackageCtrl:OnKnapsackInfoParam(protocol)
	--print_log("背包参数变动回调", protocol)
	local info_list = protocol.info_list
	for k,v in pairs(info_list) do
		ItemData.Instance:ChangeParamInGrid(v)
	end
	GlobalEventSystem:Fire(BagFlushEventType.BAG_FLUSH_CONTENT)
	GlobalEventSystem:Fire(OtherEventType.WAREHOUSE_FLUSH_VIEW)
end

--合并整理物品
function PackageCtrl:SendKnapsackStoragePutInOrder(is_storage, ignore_bind)
	local cmd = ProtocolPool.Instance:GetProtocol(CSKnapsackStoragePutInOrder)
	cmd.is_storage = is_storage			--整理的是哪个，1为仓库，0为背包
	cmd.ignore_bind = ignore_bind		--是否忽略绑定，1为是，0为否
	cmd:EncodeAndSend()
end

-- 背包、仓库扩展
function PackageCtrl:SendKnapsackStorageExtendGridNum(bag_type, extend_num, can_use_gold)
	-- print("extend_num", extend_num)
	local cmd = ProtocolPool.Instance:GetProtocol(CSKnapsackStorageExtendGridNum)
	cmd.type = bag_type 				--1为仓库，0为背包
	cmd.extend_num = extend_num
	cmd.can_use_gold = can_use_gold or 1
	cmd:EncodeAndSend()
end

function PackageCtrl:OnKnapsackItemChangeParam(protocol)
	-- print_log("OnKnapsackItemChangeParam  物品参数改变", protocol)
	local old_empty_num = self.item_data:GetEmptyNum()
	ItemData.Instance:ChangeDataInGrid(protocol)
	self:CheckBagClearEquipmentAlert(old_empty_num)
	self:ItemChangeFlush()
end

function PackageCtrl:OnUseItemSuc(protocol)
	-- print_log("使用成功回调", protocol)
	local itemcfg, big_type = ItemData.Instance:GetItemConfig(protocol.item_id)
	if nil ~= itemcfg and nil ~= itemcfg.colddown_id and nil ~= itemcfg.client_colddown then
		PackageData.Instance:SetColddownInfo(itemcfg.colddown_id, itemcfg.client_colddown + Status.NowTime)
	end
end

function PackageCtrl:OnKnapsackMaxGridNum(protocol)
	ItemData.Instance:SetMaxKnapsackValidNum(protocol.max_grid_num)
	GlobalEventSystem:Fire(BagFlushEventType.BAG_FLUSH_CONTENT, -1)
end

function PackageCtrl:OnStorageMaxGridNum(protocol)
	ItemData.Instance:SetMaxStorageValidNum(protocol.max_grid_num)
	GlobalEventSystem:Fire(OtherEventType.WAREHOUSE_FLUSH_VIEW, protocol.max_grid_num)
end

-- 打开回收界面(装备回收, 精灵回收)
function PackageCtrl:OpenBagRecycle(view_state)
	if not ViewManager.Instance:IsOpen(ViewName.BagRecycle) then
		ViewManager.Instance:Open(ViewName.BagRecycle)
	end
end

-- 关闭回收界面(装备回收, 精灵回收)
function PackageCtrl:CloseBagRecycle()
	if ViewManager.Instance:IsOpen(ViewName.BagRecycle) then
		ViewManager.Instance:Close(ViewName.BagRecycle)
	end
end

-- 刷新女娲石
function PackageCtrl:ChangeNvwashiValue()
	self.bag_recycle_view:ChangeNvwashiValue()
end

--外部增加回收装备
function PackageCtrl:AddRecycleItem(data)
	self.bag_recycle_view:AddRecycleItem(data)
end

--外部删除回收装备
function PackageCtrl:DelRecycleItem(data)
	self.bag_recycle_view:DelRecycleItem(data)
end

--获取当前回收界面的所有回收装备
function PackageCtrl:GetAllSaleData()
	self.bag_recycle_view:GetAllSaleData()
end

function PackageCtrl:IsInSaleData(data)
	return self.bag_recycle_view:IsInSaleData(data)
end

function PackageCtrl:ItemChangeFlush()
	if self.itemchange_delay_timer then self.item_change = true return end
	self:ItemChangeFlushCache()
	self.itemchange_delay_timer = GlobalTimerQuest:AddDelayTimer(function()
		self.itemchange_delay_timer = nil
		if self.item_change then
			self:ItemChangeFlushCache()
			self.item_change = false
		end
	end, ITEM_CHANGE_FLUSH_CD)
end

function PackageCtrl:ItemChangeFlushCache()
	ViewManager.Instance:FlushView(ViewName.SpiritView)
	if ViewManager.Instance:IsOpen(ViewName.Advance) then
		AdvanceCtrl.Instance:FlushView("all")
	end

	-- for _, v in ipairs(RemindByItemChange) do
	-- 	RemindManager.Instance:Fire(v)
	-- end
	self:CheckBetterEquipCountDown()

	if not EquipData.Instance:GetTakeOffFlag() then
		PackageData.Instance:AutoRecyclEquip()
	end
end