require("scripts/game/bag/bag_data")
require("scripts/game/bag/bag_storage_data")
require("scripts/game/bag/bag_recycle_data")
require("scripts/game/bag/bag_data_change_dispacther")
require("scripts/game/bag/item_data")

require("scripts/game/bag/bag_view")

require("scripts/game/bag/bag_shop_view")

require("scripts/game/bag/recycle/recycle_view")

require("scripts/game/bag/storage/storage_view")
require("scripts/game/bag/storage/bag_ck_encryption")
require("scripts/game/bag/storage/bag_ck_protect")
require("scripts/game/bag/storage/bag_ck_temp_unlock")
require("scripts/game/bag/storage/bag_ck_unlock")
require("scripts/game/bag/storage/bag_ck_reset_password")
require("scripts/game/bag/storage/bag_ck_open_cell")

require("scripts/game/bag/equip_decompose_view")
-- require("scripts/game/bag/decompose_view")
require("scripts/game/bag/item_synthesis_view")
require("scripts/game/bag/main_bag_view")
require("scripts/game/bag/bag_comspoe_panel")

require("scripts/game/bag/jiyan_zhu_view")
--------------------------------------------------------------
--背包相关
--------------------------------------------------------------
BagCtrl = BagCtrl or BaseClass(BaseController)
function BagCtrl:__init()
	if BagCtrl.Instance then
		ErrorLog("[BagCtrl] Attemp to create a singleton twice !")
	end
	BagCtrl.Instance = self

	self.bag_data = BagData.New()
	self.view = BagView.New(ViewDef.MainBagView.BagView)
	self.main_view = MainBagView.New(ViewDef.MainBagView)
	self.compose_panel = BagComspoePanel.New(ViewDef.MainBagView.ComspoePanel)
	self.storage_view = StorageView.New(ViewDef.Storage)
	self.per_shop_view = BagShopView.New(ViewDef.PerShop)
	self.recycle_view = RecycleView.New(ViewDef.Recycle)

	self.ck_encryption_view = BagCkEncryptionView.New(ViewDef.StorageEncryption)
	self.ck_protect_view = BagCkProtectView.New(ViewDef.StorageProtect)
	self.ck_temp_unlock_view = BagCkTempUnlockView.New(ViewDef.StorageTempUnlock)
	self.ck_unlock_view = BagCkUnlockView.New(ViewDef.StorageUnlock)
	self.ck_reset_password_view = BagCkResetPasswordView.New(ViewDef.StorageResetPassword)

	self.ck_open_cell_view = BagCkOpenCellView.New()

	-- 分解视图
	self.fw_decompose_view = EquipDecomposeView.New(ViewDef.FuwenDecompose)
	self.fw_decompose_view:SetDecomposeType(EQUIP_DECOMPOSE_TYPES.FUWEN)
	self.geq_decompose_view = EquipDecomposeView.New(ViewDef.GodEqDecompose)
	self.geq_decompose_view:SetDecomposeType(EQUIP_DECOMPOSE_TYPES.GOD_EQUIP)
	self.heart_decompose_view = EquipDecomposeView.New(ViewDef.HeartDecompose)
	self.heart_decompose_view:SetDecomposeType(EQUIP_DECOMPOSE_TYPES.HEART)

	self.jiyan_view = JiYanZhuView.New(ViewDef.JiYanView)
	
	-- 合成视图
	self.fw_synthesis_view = ItemSynthesisView.New(ViewDef.FuwenExchange)
	self.fw_synthesis_view:SetSynthesisType(ITEM_SYNTHESIS_TYPES.FUWEN)

	self:RegisterAllProtocols()

	self.animation_item_queue = {}
	self.prve_play_animation_time = 0
	Runner.Instance:AddRunObj(self, 8)

	self.use_item_temp_list = {}

	self.login_info_event = self:BindGlobalEvent(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.RecvMainInfoCallBack, self))
	--self.pass_data_event = self:BindGlobalEvent(OtherEventType.PASS_DAY, BindTool.Bind(self.OnPassDay, self))
	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleDataChangeCallback, self))

	self.other_data_event = self:BindGlobalEvent(OtherEventType.OPEN_DAY_GET, BindTool.Bind(self.OnPassDay, self))
end

function BagCtrl:__delete()
	BagCtrl.Instance = nil
	
	self.bag_data:DeleteMe()
	self.bag_data = nil

	self.recycle_view:DeleteMe()
	self.recycle_view = nil

	self.storage_view:DeleteMe()
	self.storage_view = nil

	self.per_shop_view:DeleteMe()
	self.per_shop_view = nil

	self.fw_decompose_view:DeleteMe()
	self.fw_decompose_view = nil

	self.geq_decompose_view:DeleteMe()
	self.geq_decompose_view = nil

	self.fw_synthesis_view:DeleteMe()
	self.fw_synthesis_view = nil

	self.heart_decompose_view:DeleteMe()
	self.heart_decompose_view = nil

	if self.main_view then
		self.main_view:DeleteMe()
		self.main_view = nil
		self.view = nil
	end

	self.animation_item_queue = {}

	self.use_item_temp_list = {}

	if self.delay_close_timer then
		GlobalTimerQuest:CancelQuest(self.delay_close_timer)
		self.delay_close_timer = nil
	end

	if self.alert then
		self.alert:DeleteMe()
		self.alert = nil
	end

	if self.decompose_alert then
		self.decompose_alert:DeleteMe()
		self.decompose_alert = nil
	end

	if self.compose_panel then
		self.compose_panel:DeleteMe()
		self.compose_panel = nil
	end

	if self.login_info_event then
		self:UnBindGlobalEvent(self.login_info_event)
		self.login_info_event = nil
	end

	if self.other_data_event then
		self:UnBindGlobalEvent(self.other_data_event)
		self.other_data_event = nil
	end

	if self.jiyan_view then
		self.jiyan_view:DeleteMe()
		self.jiyan_view = nil
	end
end

function BagCtrl:RegisterAllProtocols()
	-- 背包相关
	self:RegisterProtocol(SCRoleBagItemList, "OnRoleBagItemList")
	self:RegisterProtocol(SCDeleteOneItem, "OnDeleteOneItem")
	self:RegisterProtocol(SCAddOneItemToBag, "OnAddOneItemToBag")
	self:RegisterProtocol(SCItemChangeNum, "OnItemChangeNum")
	self:RegisterProtocol(SCUseItemResult, "OnUseItemResult")
	self:RegisterProtocol(SCOneItemInfoChange, "OnOneItemInfoChange")

	-- self:RegisterProtocol(SCClearItemUseLimit, "OnClearItemUseLimit")
	-- self:RegisterProtocol(SCOneItemUseLimit, "OnOneItemUseLimit")

	self:RegisterProtocol(SCItemRestTime, "OnItemUseLimit")
	self:RegisterProtocol(SCOneItemRestTime, "OnOneItemUseLimit")

	-- 仓库
	self:RegisterProtocol(SCStorageList, "OnStorageList")
	self:RegisterProtocol(SCStorageAddItem, "OnStorageAddItem")
	self:RegisterProtocol(SCStorageRemoveItem, "OnStorageRemoveItem")
	self:RegisterProtocol(SCStorageDeadline, "OnStorageDeadline")
	self:RegisterProtocol(SCStoragRentInfo, "OnStoragRentInfo")
	self:RegisterProtocol(SCStoragItemNumchange, "OnStoragItemNumchange")
	self:RegisterProtocol(SCStoragLockType, "OnStoragLockType")

	-- 回收
	self:RegisterProtocol(SCEquipRecycleResult, "OnEquipRecycleResult")
	-- self:RegisterProtocol(SCWearHouseRecycleNotify, "OnWearHouseRecycleNotify")


	-- 藏宝图
	self:RegisterProtocol(SCMysticGateOpen, "OnMysticGateOpen")

	-- 其它
	self:RegisterProtocol(SCComposeItemResult, "OnComposeItemResult")
	self:RegisterProtocol(SCEquipDecompResult, "OnEquipDecompResult")

	self:RegisterProtocol(SCEquipDurabilityChange, "OnEquipDurabilityChange")
	self:RegisterProtocol(SCEquipFrozenTimeChange, "OnEquipFrozenTimeChange")

	--经验珠次数

	self:RegisterProtocol(SCUSeSpecialItemNum, "OnUSeSpecialItemNum")
end

function BagCtrl:RegisterRemind()
	if IS_ON_CROSSSERVER then return end
end

function BagCtrl:OpenCellView(view_def)
	self.ck_open_cell_view:SetViewForm(view_def)
end

function BagCtrl:RecvMainInfoCallBack()
	if IS_ON_CROSSSERVER then return end
	BagCtrl.SendGetBagListReq()
	self:SendStorageListReq(1)

	self:RegisterRemind()
	self.bag_data:InitComposeData()
	self:UpdateBallIconTips()
end

function BagCtrl:RoleDataChangeCallback(vo)
	if vo.key == OBJ_ATTR.ACTOR_CIRCLE or vo.key == OBJ_ATTR.CREATURE_LEVEL then
		self.bag_data:InitComposeData()
	end
end

function BagCtrl:OnRoleBagItemList(protocol)
	self.bag_data:SetDataList(protocol)
	self:UpdateBallIconTips()
end

function BagCtrl:OnDeleteOneItem(protocol)
	local data = self.bag_data:GetOneItemBySeries(protocol.series)
	if not data then return end
	if StoneData.Instance:IsStone(data.item_id) then
		self.bag_data:DeleteOneItem(data, true)
	else
		self.bag_data:UpdateData(ITEM_CHANGE_TYPE.DEL, data)
	end
	self.bag_data.grid_data_series_list[protocol.series] = nil
	GlobalEventSystem:Fire(KnapsackEventType.KNAPSACK_ITEM_DELETE, protocol.series)
end

function BagCtrl:OnAddOneItemToBag(protocol)
	self.bag_data.grid_data_series_list[protocol.equip.series] = protocol.equip
	if StoneData.Instance:IsStone(protocol.equip.item_id) then
		self.bag_data:AddOneItem(protocol.equip, true)
	else
		self.bag_data:UpdateData(ITEM_CHANGE_TYPE.ADD, protocol.equip, protocol.reason)
	end
end

function BagCtrl:OnItemChangeNum(protocol)
	local data = self.bag_data:GetOneItemBySeries(protocol.series)
	if not data then return end
	local is_stone = StoneData.Instance:IsStone(data.item_id) 
	if is_stone or not self.bag_data.is_daley then
		self.bag_data:BagItemNumChange(protocol.series, protocol.num, is_stone)
	else
		self.bag_data:UpdateData(ITEM_CHANGE_TYPE.CHANGE, {series = protocol.series, num = protocol.num, is_stone = is_stone}, 0)
	end
end

function BagCtrl:OnUseItemResult(protocol)
	GlobalEventSystem:Fire(KnapsackEventType.KNAPSACK_ITEM_USE, {item_id = protocol.item_id, result = protocol.result})
	if protocol.result == 0 then
		 Log("Use Failed!!!!")
	else
		-- Log("Use Succeed!!!")
	end
end

-- 物品合成结果
function BagCtrl:OnComposeItemResult(protocol)
	GlobalEventSystem:Fire(KnapsackEventType.KNAPSACK_COMPOSE_EQUIP, protocol.item_type, protocol.result)

	if 1 == protocol.result then
		EquipData.Instance:ClearCsComposeData()
		local cfg = ConfigManager.Instance:GetClientConfig("item_synthesis_view_cfg")
		if cfg and cfg[protocol.item_type] then
			local eff_id = cfg[protocol.item_type].success_play_eff_id
			if nil ~= eff_id then
				local ui_node = HandleRenderUnit:GetUiNode()
				local ui_size = HandleRenderUnit:GetSize()
				RenderUnit.PlayEffectOnce(eff_id, ui_node, COMMON_CONSTS.ZORDER_SYSTEM_EFFECT, ui_size.width / 2, ui_size.height / 2, true)
			end
		end
	end	
end

function BagCtrl:OnOneItemInfoChange(protocol)
	local equip = EquipData.Instance:GetEquipBySeries(protocol.equip.series)
	if equip then
		-- 客户端直接走穿带
		EquipData.Instance:PutOnEquip(protocol.equip)
	else
		local is_stone = StoneData.Instance:IsStone(protocol.equip.item_id)
		self.bag_data:BagItemInfoChange(protocol.equip, is_stone)
	end
end

-- 分解装备结果
function BagCtrl:OnEquipDecompResult(protocol)
	local ui_node = HandleRenderUnit:GetUiNode()
	local ui_size = HandleRenderUnit:GetSize()
	EquipData.Instance:ClearCsDecomposeData()
	RenderUnit.PlayEffectOnce(CLIENT_GAME_GLOBAL_CFG.decompose_eff_id, ui_node, COMMON_CONSTS.ZORDER_SYSTEM_EFFECT, ui_size.width / 2, ui_size.height / 2, true)
end

-- 分解装备
function BagCtrl.SendEquipDecompose(type, series)
	local protocol = ProtocolPool.Instance:GetProtocol(CSEquipDecompose)
	protocol.decomp_type = type
	protocol.series = series
	protocol:EncodeAndSend()
end

-- 合成物品
function BagCtrl.SendComposeItem(compose_type, compose_second_type, compose_index, is_onekey_compose, compose_num)
	local protocol = ProtocolPool.Instance:GetProtocol(CSComposeItem)
	protocol.compose_type = compose_type
	protocol.secompose_type = compose_second_type
	protocol.compose_index = compose_index
	protocol.is_onekey_compose = is_onekey_compose
	protocol.compose_num = compose_num or 1 --，默认是一次
	protocol:EncodeAndSend()
end

-- 使用可选择物品
function BagCtrl.SendSelectItemReq(id, pro, index, num)
	local protocol = ProtocolPool.Instance:GetProtocol(CSSelectItem)
	protocol.id = id
	protocol.pro = pro
	protocol.index = index
	protocol.num = num
	protocol:EncodeAndSend()
end
----------------------------------------------------------------------------------------------

-- 分解装备 带提示框
function BagCtrl:OpenDecomposeEquipAlert(type, data)
	if nil == data or nil == type then
		return
	end

	self.decompose_alert = self.decompose_alert or Alert.New()
	local str = string.format("是否确定分解%s？", ItemData.Instance:GetItemNameRich(data.item_id))
	self.decompose_alert:SetLableString(str)
	self.decompose_alert:SetOkFunc(function()
		BagCtrl.SendEquipDecompose(type, data.series)
	end)
	self.decompose_alert:Open()
end

function BagCtrl:OnPassDay()
	if self.alert then
		self.alert:Close()
	end
	self.bag_data:InitComposeData()
	RemindManager.Instance:DoRemindDelayTime(RemindName.BagCompose, 0.2)
end


function BagCtrl:OnEquipDurabilityChange(protocol)
	self.bag_data:SetDurabilityChange(protocol)

	local item_data  = BagData.Instance:GetOneItemBySeries(protocol.series)
	if item_data ~= nil then
		local item_cfg = ItemData.Instance:GetItemConfig(item_data.item_id)
		if ItemData.IsJinYanZhuUseItemType(item_cfg.type) then
			self:UpdateBallIconTips()
		end
	end
end

-- 装备使用的冻结时间发生变化
function BagCtrl:OnEquipFrozenTimeChange(protocol)
	self.bag_data:SetFrozenTimeChange(protocol)
end

-----------------------------------------------------------------------------------------------------------------------------------
--- 以下可能废弃
-----------------------------------------------------------------------------------------------------------------------------------



function BagCtrl:OpenQuickUseView()
	self.quick_use_view:Open()
end

function BagCtrl:FlushQuickUseView()
	self.quick_use_view:Flush()
end

function BagCtrl:OnItemConfig(protocol)
	-- ItemData.Instance:AddItemConfig(protocol.item_list)
	-- self:ItemDataChangeCallback()
end

function BagCtrl:OnItemUseLimit(protocol)
	for k,v in pairs (protocol.item_list) do
		local cfg = UseCountItemsConfig[v.index] 
		if cfg and type(cfg[1]) == "table" then
			for k1,v1 in pairs(cfg[1]) do
				ItemData.Instance:SetItemUseLimit(v1, v.rest_time)
			end
		end
	end
end

function BagCtrl:OnOneItemUseLimit(protocol)
	local cfg = UseCountItemsConfig[protocol.index]
	if cfg and type(cfg[1]) == "table" then
		for k1,v1 in pairs(cfg[1]) do
			ItemData.Instance:SetItemUseLimit(v1, protocol.rest_time)
			--self.view:Flush(0, "bag_limit", {[v1] = true})
		end
	end
end

-- 获取背包列表
function BagCtrl.SendGetBagListReq()
	local cmd = ProtocolPool.Instance:GetProtocol(CSGetBagListReq)
	cmd:EncodeAndSend()
end

-- 请求配置的物品信息
function BagCtrl:SendItemConfigReq(item_list)
	local protocol = ProtocolPool.Instance:GetProtocol(CSItemConfigReq)
	protocol.count = #item_list
	protocol.item_list = item_list
	protocol:EncodeAndSend()
end

-- 删除物品
function BagCtrl:SendDeleteItem(series)
	local protocol = ProtocolPool.Instance:GetProtocol(CSDeleteItemReq)
	protocol.series = series
	protocol:EncodeAndSend()
end

-- 拆分物品
function BagCtrl:SendSplitItem(series, split_num)
	local protocol = ProtocolPool.Instance:GetProtocol(CSSplitItemReq)
	protocol.series = series
	protocol.split_num = split_num
	protocol:EncodeAndSend()
end

-- 合并物品
function BagCtrl:SendMergeItem(source_series, target_series)
	local protocol = ProtocolPool.Instance:GetProtocol(CSMergeItemReq)
	protocol.source_series = source_series
	protocol.target_series = target_series
	protocol:EncodeAndSend()
end

-- 使用物品
function BagCtrl:SendUseItem(series, is_hero, num, target_role_name, param)
	local protocol = ProtocolPool.Instance:GetProtocol(CSUseItemReq)
	protocol.series = series
	protocol.is_hero = is_hero or 0
	protocol.num = num or 1
	protocol.target_role_name = target_role_name or ""
	protocol.param = param or 0
	protocol:EncodeAndSend()
	
	self.use_item_temp_list = {}
	self.use_item_temp_list.series = series
	self.use_item_temp_list.is_hero = is_hero
	self.use_item_temp_list.num = num
	self.use_item_temp_list.target_role_name = target_role_name
end

-- 一键使用物品
function BagCtrl.SentOnekeyUseItemReq(series)
	local protocol = ProtocolPool.Instance:GetProtocol(CSOnekeyUseItemReq)
	protocol.series = series
	protocol:EncodeAndSend()
end

-- 获取扩大背包费用
function BagCtrl:SendGetExpandBagCost(expand_num)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetExpandBagCost)
	protocol.expand_num = expand_num
	protocol:EncodeAndSend()
end

-- 扩大背包
function BagCtrl:SendExpandBagReq(expand_num)
	local protocol = ProtocolPool.Instance:GetProtocol(CSExpandBagReq)
	protocol.expand_num = expand_num
	protocol:EncodeAndSend()
end

-- 获取处理一件装备需要的消耗
function BagCtrl:SendGetDisposeEquipNeed(series)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetDisposeEquipNeed)
	protocol.series = series
	protocol:EncodeAndSend()
end

-- 灌注源泉
function BagCtrl:SendFillSourceReq(drugs_series, source_series)
	local protocol = ProtocolPool.Instance:GetProtocol(CSFillSourceReq)
	protocol.drugs_series = drugs_series
	protocol.source_series = source_series
	protocol:EncodeAndSend()
end

-- 丢弃金币
function BagCtrl:SendDiscardGoldReq(num)
	local protocol = ProtocolPool.Instance:GetProtocol(CSDiscardGoldReq)
	protocol.num = num
	protocol:EncodeAndSend()
end

-- 获取能升级的装备
function BagCtrl:SendGetCanUpEquipReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetCanUpEquipReq)
	protocol:EncodeAndSend()
end

-- 使用完美强化符物品
function BagCtrl:SendUsePerfectStrengthenTalisman(equip_series, talisman_series, equip_pos)
	local protocol = ProtocolPool.Instance:GetProtocol(CSUsePerfectStrengthenTalisman)
	protocol.equip_series = equip_series
	protocol.talisman_series = talisman_series
	protocol.equip_pos = equip_pos
	protocol:EncodeAndSend()
end

-- 获取仓库的物品列表
function BagCtrl:SendStorageListReq(storage_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSStorageListReq)
	protocol.storage_id = storage_id
	protocol:EncodeAndSend()
end

-- 自动获取所有仓库的物品列表 @begin_page 从第几页开始
function BagCtrl:AutoSendAllStorageListReq(begin_page)
	self:SendStorageListReq(begin_page)
	if begin_page < BagData.STORAGE_PAGE then
		GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.AutoSendAllStorageListReq, self, begin_page + 1), 0.5)
	end
end

-- 把一个物品从背包拖放到仓库
function BagCtrl:SendMoveItemToStorageFromBag(storage_id, item_series)
	local protocol = ProtocolPool.Instance:GetProtocol(CSMoveItemToStorageFromBag)
	protocol.storage_id = storage_id
	protocol.item_series = item_series
	protocol:EncodeAndSend()
end

-- 把一个物品从仓库拖放到背包
function BagCtrl:SendMoveItemToBagFromStorage(storage_id, item_series)
	local protocol = ProtocolPool.Instance:GetProtocol(CSMoveItemToBagFromStorage)
	protocol.storage_id = storage_id
	protocol.item_series = item_series
	protocol:EncodeAndSend()
end

-- 获取仓库的租用信息
function BagCtrl:SendStorageRentInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSStorageRentInfoReq)
	protocol:EncodeAndSend()
end

-- 删除仓库物品
function BagCtrl:SendRemoveStorageItem(storage_id, item_series)
	local protocol = ProtocolPool.Instance:GetProtocol(CSRemoveStorageItem)
	protocol.storage_id = storage_id
	protocol.item_series = item_series
	protocol:EncodeAndSend()
end

--仓库临时解锁
function BagCtrl:SendStorageTempUnlockReq(password)
	self:SendStorageLockReq(LOCK_OP_ID.OP_UNLOCK, password)
end

--仓库恢复保护
function BagCtrl:SendStorageRecoveryLockReq()
	self:SendStorageLockReq(LOCK_OP_ID.OP_LOCK)
end

--仓库设置密锁
function BagCtrl:SendStorageSetLockReq(password)
	self:SendStorageLockReq(LOCK_OP_ID.OP_SET_LOCK, password)
end

--仓库修改密锁
function BagCtrl:SendStorageChangeLockReq(password, n_password)
	self:SendStorageLockReq(LOCK_OP_ID.OP_CHG_LOCK, password, n_password)
end

--仓库取消密锁
function BagCtrl:SendStorageDelLockReq(password)
	self:SendStorageLockReq(LOCK_OP_ID.OP_DEL_LOCK, password)
end

-- 仓库锁操作
function BagCtrl:SendStorageLockReq(req_type, password, n_password)
	local protocol = ProtocolPool.Instance:GetProtocol(CSStorageLockReq)
	protocol.req_type = req_type
	protocol.password = password or 0
	protocol.n_password = n_password or 0
	protocol:EncodeAndSend()
end

-- 请求密码锁状态
function BagCtrl:SendStorageLockTypeReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSStorageLockTypeReq)
	protocol:EncodeAndSend()
end

-- 仓库金钱操作
function BagCtrl:SendStorageMoneyReq(type, money_type, money_num)
	local protocol = ProtocolPool.Instance:GetProtocol(CSStorageMoneyReq)
	protocol.type = type
	protocol.money_type = money_type
	protocol.money_num = money_num
	protocol:EncodeAndSend()
end

-- 购买仓库格子
function BagCtrl:SendStorageBuyCell(cell_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSStorageBuyCell)
	protocol.cell_id = cell_id
	protocol:EncodeAndSend()
end

-- 使用特殊物品
function BagCtrl:SendUseSpecialItemReq(req_id, reward_type, item_guid)
	local protocol = ProtocolPool.Instance:GetProtocol(CSUseSpecialItemReq)
	protocol.req_id = req_id
	protocol.reward_type = reward_type
	protocol.item_guid = item_guid
	protocol:EncodeAndSend()
end

-- 请求回收（返回回收详情）
function BagCtrl:SendBagRecycleSecondPanelReq(equip_num, recycle_type, equip_list)
	local protocol = ProtocolPool.Instance:GetProtocol(CSBagRecycleSecondPanelReq)
	protocol.equip_num = equip_num
	protocol.recycle_type = recycle_type
	protocol.equip_list = equip_list
	protocol:EncodeAndSend()
end

-- 确认回收
function BagCtrl:SendBagRecycleRewardReq(equip_num, recycle_type, btn_index, equip_list)
	local protocol = ProtocolPool.Instance:GetProtocol(CSBagRecycleRewardReq)
	protocol.equip_num = equip_num
	protocol.recycle_type = recycle_type
	protocol.btn_index = btn_index
	protocol.equip_list = equip_list
	protocol:EncodeAndSend()
end

-- 下发仓库的物品的列表
function BagCtrl:OnStorageList(protocol)
	self.bag_data:AddStorageList(protocol)
end

-- 仓库获得物品
function BagCtrl:OnStorageAddItem(protocol)
	self.bag_data:AddOneStorageItem(protocol)
end

-- 仓库删除物品
function BagCtrl:OnStorageRemoveItem(protocol)
	local index = self.bag_data:GetStorageItemIndexBySeries(protocol.item_series)
	self.bag_data:DelOneStorageItem(index)
end

-- 设置一个仓库的过期时间
function BagCtrl:OnStorageDeadline()
end

-- 下发几个仓库的租用信息
function BagCtrl:OnStoragRentInfo()
end

-- 玩家的物品的数量发生改变
function BagCtrl:OnStoragItemNumchange(protocol)
	local index = self.bag_data:GetStorageItemIndexBySeries(protocol.item_series)
	self.bag_data:ChangeOneStorageItemNum(index, protocol.item_change_num)
end

-- 下发密码锁状态
function BagCtrl:OnStoragLockType(protocol)
	self.bag_data:SetStorageLockType(protocol.lock_type)
end

function BagCtrl:PlayAnimationOnGetItem(item_id)
	table.insert(self.animation_item_queue, item_id)
	if #self.animation_item_queue > 12 then
		table.remove(self.animation_item_queue, 1)
	end
end

function BagCtrl:Update(now_time, elapse_time)
	if now_time - self.prve_play_animation_time < 0.06 then
		return
	end
	self.prve_play_animation_time = now_time

	local item_id = table.remove(self.animation_item_queue, 1)
	if nil ~= item_id then
		self:StartFlyItem(item_id)
	end
end

function BagCtrl:StartFlyItem(item_id)
	local fly_to_target = ViewManager.Instance:GetUiNode("MainUi", "btn_Bag")
	local path = ""
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if nil ~= item_cfg and item_cfg.icon and item_cfg.icon > 0 then
		path = ResPath.GetItem(item_cfg.icon)
	end
	
	if "" == path or nil == fly_to_target then return end

	local screen_w = HandleRenderUnit:GetWidth()
	local screen_h = HandleRenderUnit:GetHeight()
	local fly_icon = XUI.CreateImageView(0, 0, path, false)
	fly_icon:setAnchorPoint(0, 0)
	HandleRenderUnit:AddUi(fly_icon, COMMON_CONSTS.ZORDER_SYSTEM_EFFECT, COMMON_CONSTS.ZORDER_SYSTEM_EFFECT)
	local world_pos = fly_icon:convertToWorldSpace(cc.p(0,0))
	fly_icon:setPosition(screen_w / 2, screen_h / 2)

	local fly_to_pos = fly_to_target:convertToWorldSpace(cc.p(0,0))
	local move_to =cc.MoveTo:create(0.8, cc.p(fly_to_pos.x, fly_to_pos.y))
	local spawn = cc.Spawn:create(move_to)
	local callback = cc.CallFunc:create(BindTool.Bind2(self.ItemFlyEnd, self, fly_icon))
	local action = cc.Sequence:create(spawn, callback)
	fly_icon:runAction(action)
end

function BagCtrl:ItemFlyEnd(fly_icon)
	if fly_icon then
		fly_icon:removeFromParent()
	end
end

-- 请求熔炼(7, 41)
function BagCtrl.SendBagRecycleReq(index, recycle_series_list)
	local cmd = ProtocolPool.Instance:GetProtocol(CSBagMeltingReq)
	cmd.from_index = index
	cmd.is_quick_melting = 0 --不需一键回收
	cmd.recycle_series_list = recycle_series_list
	cmd:EncodeAndSend()
end

-- 装备回收
function BagCtrl.EquipRecycle(recycle_cfg_index, recycle_type, equip_t)
	local protocol = ProtocolPool.Instance:GetProtocol(CSEquipRecycle)
	protocol.recycle_type = recycle_type
	protocol:EncodeAndSend()
end

-- 装备回收结果
function BagCtrl:OnEquipRecycleResult(protocol)
	if 2 == protocol.from_index then
		ExploreData.Instance:SetXunBaoBag(protocol)
	end

	BagData.Instance:RecycleSuccess()
end

-- 装备回收结果
function BagCtrl:PlayAnimationOnRecycle(protocol)
	if 0 == protocol.result or 0 == protocol.num then return end

	if 0 == protocol.bind_gold and 0 == protocol.exp and 0 == protocol.jade_debris 
		and 0 == protocol.fuwen and 0 == protocol.loongstone and 0 == protocol.shadowstone then
		return
	end
	local total_num = protocol.num

	local detail = {}
	detail[1] = protocol.exp
	detail[2] = protocol.jade_debris
	detail[3] = protocol.bind_gold
	detail[4] = protocol.fuwen
	--detail[5] = protocol.loongstone
	--detail[6] = protocol.shadowstone

	local screen_w = HandleRenderUnit:GetWidth()
	local screen_h = HandleRenderUnit:GetHeight()
	local screen_w_m = screen_w * 0.5
	local screen_h_m = screen_h * 0.5

	local num_layout = XUI.CreateLayout(screen_w_m, screen_h_m, 0, 0)
	num_layout:setVisible(false)
	HandleRenderUnit:AddUi(num_layout, COMMON_CONSTS.ZORDER_SYSTEM_EFFECT + 10)
	-- 经验

	for i, value in ipairs(detail) do
		local g_num_list = {}
		local len = string.len(value)
		for i = 0, len - 1 do
			local num = string.sub(value, 1, len - i) % 10
			g_num_list[len - i] = num
		end

		local rich_text_node = XUI.CreateRichText(0, 15 - 45 * i, 200, 30, true)
		rich_text_node:setAnchorPoint(0.5, 0.5)
		XUI.RichTextAddImage(rich_text_node, ResPath.GetWord("word_reward_" .. i), true)
		XUI.RichTextAddImage(rich_text_node, ResPath.GetFightResPath("g_plus"), true)
		for i=1, #g_num_list do
			XUI.RichTextAddImage(rich_text_node, ResPath.GetFightResPath("g_" .. g_num_list[i]), true)
		end
		num_layout:addChild(rich_text_node)
	end
	
	num_layout:setVisible(true)
	num_layout:setAnchorPoint(0.5, 1)
	local callback = cc.CallFunc:create(function ()
		num_layout:removeFromParent()

		local cur_num = 1
		if total_num < 1 then
			cur_num = 1
		elseif total_num > 20 then
			cur_num = 20
		else
			cur_num = total_num
		end
		for i=1, cur_num do
			Scene.PlayOneFlyEffect(918, 0.86 + math.random() * 0.6)
		end	
	end)
	num_layout:runAction(cc.Sequence:create(cc.DelayTime:create(1.2), cc.EaseExponentialIn:create(cc.ScaleTo:create(0.8, 0)), callback))
end

function BagCtrl:StartFlyEff(view_name, x, y, eff_id, num, fly_callfunc)
	if self.is_flying_eff then
		return 
	end
	self.is_flying_eff = true
	local eff_num = num or 8
	for i = 1, eff_num do
		local fly_to_target = ViewManager.Instance:GetUiNode("MainUi", view_name)
		
		if nil == fly_to_target then return end

		local screen_w = HandleRenderUnit:GetWidth()
		local screen_h = HandleRenderUnit:GetHeight()
		x = x or screen_w / 2
		y = y or screen_h / 2 
		local fly_eff = BagCtrl.CreateFlyEff(eff_id or 925)
		HandleRenderUnit:AddUi(fly_eff, COMMON_CONSTS.ZORDER_SYSTEM_EFFECT, COMMON_CONSTS.ZORDER_SYSTEM_EFFECT)
		fly_eff:setPosition(x, y)

		local fly_to_pos = fly_to_target:convertToWorldSpace(cc.p(0,0))
		fly_to_pos.x = fly_to_pos.x + 45
		fly_to_pos.y = fly_to_pos.y + 45
		local angel = math.deg(math.atan2((x - fly_to_pos.x), (y - fly_to_pos.y)))
		local beziers = {cc.p(x - (x - fly_to_pos.x) / 3 + 200 * math.cos(math.rad(angel)), y - (y - fly_to_pos.y) / 3 - 200 * math.sin(math.rad(angel))), 
						 cc.p(x - (x - fly_to_pos.x) / 3 * 2 - 200 * math.cos(math.rad(angel)), y - (y - fly_to_pos.y) / 3 * 2 + 200 * math.sin(math.rad(angel))), 
						 cc.p(fly_to_pos.x, fly_to_pos.y)
						}
		local delay = cc.DelayTime:create(i * 0.08)
		local bezier_to = cc.BezierTo:create(1 - i / 50, beziers)
		local scale_to = cc.ScaleTo:create(1 - i / 50, 0)
		local spawn = cc.Spawn:create(bezier_to, scale_to)
		local callback = cc.CallFunc:create(BindTool.Bind(self.EffFlyEnd, self, fly_eff, i == eff_num, fly_callfunc))
		local action = cc.Sequence:create(delay, spawn, callback)
		fly_eff:runAction(action)
	end
end

function BagCtrl.CreateFlyEff(eff_id)
	local layout = XUI.CreateLayout(0, 0, 100, 100)
	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(eff_id)
	for i = 1, 3 do
		local eff = AnimateSprite:create(anim_path, anim_name, 10, FrameTime.Effect, false)
		layout:addChild(eff)
		eff:setPosition(math.random(100), math.random(100))
	end
	return layout
end

function BagCtrl:EffFlyEnd(fly_eff, is_fly_end, fly_callfunc)
	if fly_eff then
		fly_eff:removeFromParent()
	end
	self.is_flying_eff = not is_fly_end
	
	if fly_callfunc then
		fly_callfunc()
	end
end

-- 根据名字打开左侧面板
function BagCtrl:OpenBagLeft(name, data)
	if nil == self.view then return end
	self.view:ShowLeftLayout(name, data)
end

function BagCtrl:UseExpBall(data)
	if ItemData.Instance:GetExpBallIsFull(data) then
		self:OpenBagLeft("exp_ball", data)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Bag.ExpBallNotFull)
	end
end

function BagCtrl:UseNGBall(data)
	if ItemData.Instance:GetExpBallIsFull(data) then
		self:OpenBagLeft("ng_ball", data)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Bag.NGBallNotFull)
	end
end

-- 物品数据改变时的回调
function BagCtrl:ItemDataChangeCallback(change_type, change_item_id)
	-- self:UpdateBallIconTips()
	-- BagCtrl.CheckUseItemBelowLv(50)
	
	-- RemindManager.Instance:DoRemind(RemindName.CanEquip)
	-- RemindManager.Instance:DoRemind(RemindName.FashionReward)
	-- RemindManager.Instance:DoRemind(RemindName.HuanWuReward)
 --  	RemindManager.Instance:DoRemind(RemindName.ZhanjingCanEquip)

 --  	CrossServerData.Instance:TryRemindCrossEqByItemId(change_item_id)
end

local auto_use_config = {
	[50] = {559, 560, 561},
}
function BagCtrl.CheckUseItemBelowLv(level)
	local cur_level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	if cur_level <= level then
		local auto_use_ids = auto_use_config[level]
		if auto_use_ids ~= nil then
			for k, v in ipairs(auto_use_ids) do
				local item_data = BagData.Instance:GetItem(v)
				if item_data ~= nil then
					BagCtrl.Instance:SendUseItem(item_data.series)
				end
			end
		end
	end
end

function BagCtrl:UpdateBallIconTips()
	local exp_ball_data = BagData.Instance:GetNextFullExpBall()
	if exp_ball_data then
		self.is_exp_ball_icon_show = true
		MainuiCtrl.Instance:InvateTip(MAINUI_TIP_TYPE.EXPBALL, 1, function()
			ViewManager.Instance:OpenViewByDef(ViewDef.JiYanView)
		end)
	else
		if self.is_exp_ball_icon_show then
			self.is_exp_ball_icon_show = false
			MainuiCtrl.Instance:InvateTip(MAINUI_TIP_TYPE.EXPBALL, 0)
		end
	end
end

function BagCtrl:GetRemindNum(remind_name)
	if remind_name == RemindName.CanEquip then
		return ItemData.Instance:GetCanEquipRemind()
	elseif remind_name == RemindName.CanPeerlessEquip then
		return ItemData.Instance:GetCanPeerEquipRemind()
	elseif remind_name == RemindName.CanEquipLunhui then
		return ItemData.Instance:GetEquipLunhuiRemind()
	elseif remind_name == RemindName.CanEquipNormal then
		return ItemData.Instance:GetEquipNormal()
	elseif remind_name == RemindName.CanEquipCrossEq then
		return ItemData.Instance:GetCanCrossEquipRemind()
	end
	return 0
end


-- 确认使用物品(提示框用)
function BagCtrl:ConfirmUseItem(param)
	if not self.use_item_temp_list or not self.use_item_temp_list.series then return end
	self:SendUseItem(self.use_item_temp_list.series,
		self.use_item_temp_list.is_hero,
		self.use_item_temp_list.num,
		self.use_item_temp_list.target_role_name,
		param)
	self.use_item_temp_list = {}
end

function BagCtrl.SendEnterMysticGate(scene_id, scene_x, scene_y)
	local protocol = ProtocolPool.Instance:GetProtocol(CSEnterMysticGate)
	protocol.scene_id = scene_id
	protocol.scene_x = scene_x
	protocol.scene_y = scene_y
	protocol:EncodeAndSend()
end

function BagCtrl:OnMysticGateOpen(protocol)
	self.alert = self.alert or Alert.New()
	local scene_cfg = ConfigManager.Instance:GetSceneConfig(protocol.scene_id)
	if scene_cfg then
		self.alert:SetLableString(string.format(Language.Tip.MySticGateDesc, scene_cfg.name, protocol.scene_x, protocol.scene_y))
	end
	self.alert:SetOkFunc(function()
		BagCtrl.SendEnterMysticGate(protocol.scene_id, protocol.scene_x, protocol.scene_y)
	end)
	self.alert:Open()
	if self.delay_close_timer then
		GlobalTimerQuest:CancelQuest(self.delay_close_timer)
	end
	self.delay_close_timer = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.alert.Close, self.alert), 60)
end


function BagCtrl:OnUSeSpecialItemNum(protocol)
	self.bag_data:SetSpecialItemNUm(protocol)
	self:UpdateBallIconTips()
end

---兑换神装
function BagCtrl:SendDuiHuanGodEquipReq(index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSDuiHuanItemReq)
	protocol.index = index
	protocol:EncodeAndSend()
end