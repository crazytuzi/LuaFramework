SpiritView = SpiritView or BaseClass(BaseView)

local STATE_LIST = {"spirit", "hunt", "warehouse", "exchange", "soul", "fazhen", "halo"}

function SpiritView:__init()
	self.ui_config = {"uis/views/spiritview", "SpiritView"}
	self.ui_scene = {"scenes/map/uijldt01", "UIjldt01"}
	self.full_screen = true
	if self.audio_config then
		self.open_audio_id = AssetID("audios/sfxs/uis", self.audio_config.other[1].OpenJingling)
	end
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self.state = 1

	self.open_trigger_handle = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.InitTab, self))
end

function SpiritView:__delete()
	if self.open_trigger_handle ~= nil then
		GlobalEventSystem:UnBind(self.open_trigger_handle)
		self.open_trigger_handle = nil
	end

	if UnityEngine.PlayerPrefs.GetInt("slotoldindex", 999) >= 8 then
		UnityEngine.PlayerPrefs.DeleteKey("slotoldindex")
	end
end

function SpiritView:ReleaseCallBack()
	if self.son_spirit_view then
		self.son_spirit_view:DeleteMe()
		self.son_spirit_view = nil
	end

	if self.hunt_view then
		self.hunt_view:DeleteMe()
		self.hunt_view = nil
	end

	if self.warehouse_view then
		self.warehouse_view:DeleteMe()
		self.warehouse_view = nil
	end

	if self.exchange_view then
		self.exchange_view:DeleteMe()
		self.exchange_view = nil
	end

	if self.soul_view then
		self.soul_view:DeleteMe()
		self.soul_view = nil
	end

	if self.fazhen_view then
		self.fazhen_view:DeleteMe()
		self.fazhen_view = nil
	end

	if self.halo_view then
		self.halo_view:DeleteMe()
		self.halo_view = nil
	end

	-- 清理变量
	self.gold = nil
	self.bind_gold = nil
	self.score = nil
	self.hunli = nil
	self.show_hunt_red_point = nil
	self.show_spirit_spirit_red_point = nil
	self.show_warehouse_red_point = nil
	self.show_soul_red_point = nil
	self.show_small_hunt_red_point = nil
	self.show_halo_red_point = nil
	self.show_fazhen_red_point = nil
	self.show_scene_mask = nil
	self.tab_warehouse = nil
	self.hunt_toggle = nil
	self.spirit_toggle = nil
	self.exchange_toggle = nil
	self.soul_toggle = nil
	self.fazhen_toggle = nil
	self.halo_toggle = nil
	self.top_hunt_toggle = nil
end

function SpiritView:LoadCallBack()
	self:ListenEvent("Close",
		BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OpenSpirit",
		BindTool.Bind(self.OpenSpirit, self))
	self:ListenEvent("OpenHunt",
		BindTool.Bind(self.OpenHunt, self))
	self:ListenEvent("OpenWarehouse",
		BindTool.Bind(self.OpenWarehouse, self))
	self:ListenEvent("OpenExchange",
		BindTool.Bind(self.OpenExchange, self))
	self:ListenEvent("OpenSoul",
		BindTool.Bind(self.OpenSoul, self))
	self:ListenEvent("OpenHalo",
		BindTool.Bind(self.OpenHalo, self))
	self:ListenEvent("OpenFaZhen",
		BindTool.Bind(self.OpenFaZhen, self))
	self:ListenEvent("AddGold",
		BindTool.Bind(self.HandleAddGold, self))

	local spirit_content = self:FindObj("SpiritContent")
	spirit_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.son_spirit_view = SonSpiritView.New(obj)
		if TabIndex.spirit_spirit == self:GetShowIndex() then
			self.son_spirit_view:OpenCallBack()
			self.son_spirit_view:Flush()
		end
	end)

	local hunt_content = self:FindObj("HuntContent")
	hunt_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.hunt_view = SpiritHuntView.New(obj)
		if TabIndex.spirit_hunt == self:GetShowIndex() then
			self.hunt_view:Flush()
		end
	end)

	local warehouse_content = self:FindObj("WarehouseContent")
	warehouse_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.warehouse_view = SpiritWarehouseView.New(obj)
	end)

	local exchange_content = self:FindObj("ExchangeContent")
	exchange_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.exchange_view = SpiritExchangeView.New(obj)
	end)

	local soul_content = self:FindObj("SoulContent")
	soul_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.soul_view = SpiritSoulView.New(obj)
		if TabIndex.spirit_soul == self:GetShowIndex() then
			self.soul_view:Flush()
		end
	end)

	local fazhen_content = self:FindObj("FaZhenContent")
	fazhen_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.fazhen_view = SpiritFazhenView.New(obj)
		self.fazhen_view:OpenCallBack()
	end)

	local halo_content = self:FindObj("HaloContent")
	halo_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.halo_view = SpiritHaloView.New(obj)
	end)

	self.gold = self:FindVariable("Gold")
	self.bind_gold = self:FindVariable("BindGold")
	self.score = self:FindVariable("Score")
	self.hunli = self:FindVariable("HunLi")
	self.show_hunt_red_point = self:FindVariable("ShowHuntRedPoint")
	self.show_spirit_spirit_red_point = self:FindVariable("ShowSpiritRedPoint")
	self.show_warehouse_red_point = self:FindVariable("ShowWarehouseRedPoint")
	self.show_soul_red_point = self:FindVariable("ShowSoulRedPoint")
	self.show_small_hunt_red_point = self:FindVariable("ShowSmallHuntRedPoint")
	self.show_halo_red_point = self:FindVariable("ShowHaloRedPoint")
	self.show_fazhen_red_point = self:FindVariable("ShowFazhenRedPoint")

	-- self.show_default_bg = self:FindVariable("ShowDefaultBG")
	-- self.show_hunt_bg = self:FindVariable("ShowHuntBG")
	self.show_scene_mask = self:FindVariable("ShowBlueBg")
	-- self.show_yellow_mask = self:FindVariable("ShowYellowBg")

	self.tab_warehouse = self:FindObj("TabWarehouse")
	self.hunt_toggle = self:FindObj("TabHunt")
	self.spirit_toggle = self:FindObj("TabSpirit")
	self.exchange_toggle = self:FindObj("TabExchange")
	self.soul_toggle = self:FindObj("TabSoul")
	self.fazhen_toggle = self:FindObj("TabFaZhen")
	self.halo_toggle = self:FindObj("TabHalo")
	self.top_hunt_toggle = self:FindObj("TopTabHunt")
	-- 监听系统事件
	-- if self.item_data_event == nil then
	-- 	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
	-- 	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	-- end
end

function SpiritView:OpenCallBack()
	SpiritCtrl.Instance:SendHuntSpiritGetFreeInfo()
	if self.data_listen == nil then
		self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
		PlayerData.Instance:ListenerAttrChange(self.data_listen)

		self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
		self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])
	end

	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end

	self:SetExchangeScore()
	self:Flush()
	if self.son_spirit_view then
		self.son_spirit_view:OpenCallBack()
	end
	if self.fazhen_view then
		self.fazhen_view:OpenCallBack()
	end
	self:InitTab()
	-- local scene_load_callback = function()
	-- 	self.show_scene_mask:SetValue(false)
	-- end
	-- UIScene:SetUISceneLoadCallBack(scene_load_callback)
	-- UIScene:IsNotCreateRoleModel(true)
	-- UIScene:ChangeScene(self, self.ui_scene, {[1] = {"Pingtai01", true}}, scene_load_callback)
end

function SpiritView:CloseCallBack()
	if self.data_listen ~= nil then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	if self.hunt_view then
		self.hunt_view:CloseCallBack()
	end

	if self.son_spirit_view then
		self.son_spirit_view:CloseCallBack()
	end

	if self.fazhen_view then
		self.fazhen_view:CloseCallBack()
	end

	if self.soul_view then
		self.soul_view:CloseCallBack()
	end
	if self.halo_view then
		self.halo_view:CloseCallBack()
	end

	UIScene:DeleteMe()

	self.show_scene_mask:SetValue(true)
end

-- 物品不足，购买成功后刷新物品数量
function SpiritView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	if self.son_spirit_view then
		self.son_spirit_view:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	end
	local cur_index = self:GetShowIndex()
	if cur_index == TabIndex.spirit_fazhen then
		if self.fazhen_view then
			self.fazhen_view:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
		end
	elseif cur_index == TabIndex.spirit_halo then
		if self.halo_view then
			self.halo_view:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
		end
	end
	if (self.auto_equip_time == nil or self.auto_equip_time < Status.NowTime) and old_num < new_num then
		self.auto_equip_time = Status.NowTime + 2
		local item_cfg, big_type = ItemData.Instance:GetItemConfig(item_id)
		if SpiritData.Instance:HasNotSprite() and item_cfg and EquipData.IsJLType(item_cfg.sub_type) then
			PackageCtrl.Instance:SendUseItem(index, 1, 0, item_cfg.need_gold)
			SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_FIGHTOUT,
							0, 0, 0, 0, item_cfg.name)
		end
	end
end

-- 法阵进阶结果返回
function SpiritView:SetFazhenUppGradeOptResult(result)
	if self.fazhen_view then
		self.fazhen_view:SetUppGradeOptResult(result)
	end
end

-- 光环进阶结果返回
function SpiritView:SetHaloUpGradeOptResult(result)
	if self.halo_view then
		self.halo_view:SetUppGradeOptResult(result)
	end
end

function SpiritView:OnClickClose()
	self:Close()
	self:StopAutoJinjie()
end

-- 切换标签调用
function SpiritView:ShowIndexCallBack(index)
	if index ~= TabIndex.spirit_spirit then
		if self.son_spirit_view then
			self.son_spirit_view:CloseCallBack()
		end
	end

	if index ~= TabIndex.spirit_hunt then
		if self.hunt_view then
			self.hunt_view:CloseCallBack()
		end
	end

	if index ~= TabIndex.spirit_halo then
		if self.halo_view then
			self.halo_view:CloseCallBack()
		end
	end

	if index ~= TabIndex.spirit_fazhen then
		if self.fazhen_view then
			self.fazhen_view:CloseCallBack()
		end
	end

	local call_back = function()
		self.show_scene_mask:SetValue(false)
	end
	UIScene:SetUISceneLoadCallBack(call_back)

	if index == TabIndex.spirit_spirit then
		UIScene:ChangeScene(self, self.ui_scene, {[1] = {"Pingtai02", true, 1}})
		if self.son_spirit_view then
			self.son_spirit_view:OpenCallBack()
		end
		self.state = 1
	elseif index == TabIndex.spirit_fazhen then
		self.state = 6
		UIScene:ChangeScene(self, self.ui_scene, {[1] = {"Pingtai02", true, 1}})

	elseif index == TabIndex.spirit_hunt then
		-- self.show_yellow_mask:SetValue(true)
		-- local call_back = function()
		-- 	self.show_yellow_mask:SetValue(false)
		-- end
		-- UIScene:SetUISceneLoadCallBack(call_back)
		UIScene:ChangeScene(self, self.ui_scene, {[1] = {"Pingtai01", true, 1}, [2] = {"Pingtai01", true, 2}, [3] = {"Pingtai01", true, 3}, [4] = {"Pingtai01", true, 4}})
		self.state = 2
		self.top_hunt_toggle.toggle.isOn = true
	elseif index == TabIndex.spirit_halo then
		-- self.show_yellow_mask:SetValue(true)
		-- local call_back = function()
		-- 	self.show_yellow_mask:SetValue(false)
		-- end
		-- UIScene:SetUISceneLoadCallBack(call_back)
		local halo_info = SpiritData.Instance:GetSpiritHaloInfo()
		if halo_info and halo_info.grade then
			if halo_info.grade >= SpiritData.Instance:GetMaxSpiritHaloGrade() then
				UIScene:ChangeScene(self, self.ui_scene, {[1] = {"Pingtai04", true, 1}})
			else
				UIScene:ChangeScene(self, self.ui_scene, {[1] = {"Pingtai03", true, 1}, [2] = {"Pingtai03", true, 2}})
			end
		end
		self.state = 7
	else
		UIScene:ChangeScene(self, self.ui_scene, {[1] = {"Pingtai02", true, 1}})
	end
end

function SpiritView:OpenSpirit()
	if self.state == 1 then
		return
	end
	self:StopAutoJinjie(1)
	self.state = 1
	-- self.show_default_bg:SetValue(false)
	-- self.show_hunt_bg:SetValue(false)
	self:ShowIndex(TabIndex.spirit_spirit)
	if self.son_spirit_view then
		self.son_spirit_view.is_click_item = false
		self.son_spirit_view:SetBackPackState(true)
		self.son_spirit_view:Flush()
	end
end

function SpiritView:OpenHunt()
	if self.state == 2 then
		return
	end
	self:StopAutoJinjie(2)
	self.state = 2
	-- self.show_default_bg:SetValue(false)
	-- self.show_hunt_bg:SetValue(false)
	self:ShowIndex(TabIndex.spirit_hunt)
	if self.son_spirit_view then
		self.son_spirit_view:SetBackPackState(false)
	end
	if self.hunt_view then
		self.hunt_view:Flush()
	end
	self.top_hunt_toggle.toggle.isOn = true
end

function SpiritView:OpenWarehouse()
	if self.state == 3 then
		return
	end
	self:StopAutoJinjie(3)
	self.state = 3
	-- self.show_default_bg:SetValue(false)
	-- self.show_hunt_bg:SetValue(false)
	self:ShowIndex(TabIndex.spirit_warehouse)
	if self.son_spirit_view then
		self.son_spirit_view:SetBackPackState(false)
	end
	self.tab_warehouse.toggle.isOn = true
	if self.warehouse_view then
		self.warehouse_view:FlushBagView()
	end
end

-- 兑换
function SpiritView:OpenExchange()
	if self.state == 4 then
		return
	end
	self:StopAutoJinjie(4)
	self.state = 4
	-- self.show_default_bg:SetValue(false)
	-- self.show_hunt_bg:SetValue(false)
	self:ShowIndex(TabIndex.spirit_exchange)
	if self.son_spirit_view then
		self.son_spirit_view:SetBackPackState(false)
	end
end

-- 命魂
function SpiritView:OpenSoul()
	local slot_soul_info = SpiritData.Instance:GetSpiritSlotSoulInfo()
	local bit_list = bit:d2b(slot_soul_info and slot_soul_info.slot_activity_flag or {})
	local index = 0
	if bit_list then
		for k, v in pairs(bit_list) do
			if v == 1 then
				index = index + 1
			end
		end
		if index > 0 then
			UnityEngine.PlayerPrefs.SetInt("slotoldindex", index)
		end
	end
	if self.state == 5 then
		return
	end
	self:StopAutoJinjie(5)
	self.state = 5
	-- self.show_default_bg:SetValue(false)
	-- self.show_hunt_bg:SetValue(false)
	self:ShowIndex(TabIndex.spirit_soul)
	if self.soul_view then
		self.soul_view:ResetOpenState()
		self.soul_view:Flush()
	end
	self.show_soul_red_point:SetValue(false)
	self:SetHunLiNum()
end

-- 法阵
function SpiritView:OpenFaZhen()
	if self.state == 6 then
		return
	end
	self:StopAutoJinjie(6)
	self.state = 6
	-- self.show_default_bg:SetValue(false)
	-- self.show_hunt_bg:SetValue(false)
	self:ShowIndex(TabIndex.spirit_fazhen)
	if self.fazhen_view then
		self.fazhen_view:Flush()
	end
end

-- 光环
function SpiritView:OpenHalo()
	if self.state == 7 then
		return
	end
	self:StopAutoJinjie(7)
	self.state = 7
	-- self.show_default_bg:SetValue(false)
	-- self.show_hunt_bg:SetValue(false)
	self:ShowIndex(TabIndex.spirit_halo)
	if self.halo_view then
		self.halo_view:Flush()
	end
end

function SpiritView:StopAutoJinjie(state)
	if state ~= self.state and ((self.fazhen_view and self.fazhen_view.is_auto) or (self.halo_view and self.halo_view.is_auto)) then
		if self.state == 6 then
			if self.fazhen_view then
				self.fazhen_view:OnClickAutomaticAdvance()
			end
		elseif self.state == 7 then
			if self.halo_view then
				self.halo_view:OnClickAutoJinjie()
			end
		end
	end
end

function SpiritView:HandleAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

-- function SpiritView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
-- 	self:Flush(STATE_LIST[self.state])
-- end

function SpiritView:PlayerDataChangeCallback(attr_name, value, old_value)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if attr_name == "gold" then
		local count = vo.gold
		if count > 99999 and count <= 99999999 then
			count = count / 10000
			count = math.floor(count)
			count = count .. Language.Common.Wan
		elseif count > 99999999 then
			count = count / 100000000
			count = math.floor(count)
			count = count .. Language.Common.Yi
		end
		self.gold:SetValue(count)
	elseif attr_name == "hunli" then
		self:SetHunLiNum()
	elseif attr_name == "bind_gold" then
		local count = vo.bind_gold
		if count > 99999 and count <= 99999999 then
			count = count / 10000
			count = math.floor(count)
			count = count .. Language.Common.Wan
		elseif count > 99999999 then
			count = count / 100000000
			count = math.floor(count)
			count = count .. Language.Common.Yi
		end
		self.bind_gold:SetValue(count)
	end
end

function SpiritView:SetExchangeScore()
	local count = SpiritData.Instance:GetSpiritExchangeScore()
	if count > 99999 and count <= 99999999 then
		count = count / 10000
		count = math.floor(count)
		count = count .. Language.Common.Wan
	elseif count > 99999999 then
		count = count / 100000000
		count = math.floor(count)
		count = count .. Language.Common.Yi
	end
	self.score:SetValue(count)
end

function SpiritView:SetHunLiNum()
	local count = GameVoManager.Instance:GetMainRoleVo().hunli
	if count > 99999 and count <= 99999999 then
		count = count / 10000
		count = math.floor(count)
		count = count .. Language.Common.Wan
	elseif count > 99999999 then
		count = count / 100000000
		count = math.floor(count)
		count = count .. Language.Common.Yi
	end
	self.hunli:SetValue(count)
end

function SpiritView:InitTab()
	if not self:IsOpen() then return end

	self.tab_warehouse:SetActive(OpenFunData.Instance:CheckIsHide("spirit_warehouse"))
	self.hunt_toggle:SetActive(OpenFunData.Instance:CheckIsHide("spirit_hunt"))
	self.spirit_toggle:SetActive(OpenFunData.Instance:CheckIsHide("spirit_spirit"))
	self.exchange_toggle:SetActive(OpenFunData.Instance:CheckIsHide("spirit_exchange"))
	self.soul_toggle:SetActive(OpenFunData.Instance:CheckIsHide("spirit_soul"))
	self.fazhen_toggle:SetActive(OpenFunData.Instance:CheckIsHide("spirit_fazhen"))
	self.halo_toggle:SetActive(OpenFunData.Instance:CheckIsHide("spirit_halo"))
end

function SpiritView:OnFlush(param_t)
	local cur_index = self:GetShowIndex()
	local huanhua_list = SpiritData.Instance:ShowHuanhuaRedPoint()
	local diff_time = SpiritData.Instance:GetHuntSpiritFreeTime() - TimeCtrl.Instance:GetServerTime()
	local warehouse_item_list = SpiritData.Instance:GetHuntSpiritWarehouseList()
	local slot_soul_info = SpiritData.Instance:GetSpiritSlotSoulInfo()
	local bit_list = bit:d2b(slot_soul_info and slot_soul_info.slot_activity_flag or {})
	local index = 0
	local old_index = UnityEngine.PlayerPrefs.GetInt("slotoldindex", 999)
	if bit_list then
		for k, v in pairs(bit_list) do
			if v == 1 then
				index = index + 1
			end
		end
	end

	self.show_spirit_spirit_red_point:SetValue(nil ~= next(huanhua_list) or SpiritData.Instance:ShowSonSpiritRedPoint())
	self.show_hunt_red_point:SetValue(diff_time <= 0 or nil ~= next(warehouse_item_list))
	self.show_warehouse_red_point:SetValue(nil ~= next(warehouse_item_list))
	self.show_soul_red_point:SetValue(old_index < index)
	self.show_small_hunt_red_point:SetValue(diff_time <= 0)
	self.show_halo_red_point:SetValue(SpiritData.Instance:ShowHaloRedPoint() or nil ~= next(SpiritData.Instance:ShowHaloHuanhuaRedPoint()))
	self.show_fazhen_red_point:SetValue(nil ~= next(SpiritData.Instance:ShowFazhenHuanhuaRedPoint()))

	for k, v in pairs(param_t) do
		if k == "spirit" then
			self.spirit_toggle.toggle.isOn = true
			-- self:OpenSpirit()
			-- self.show_default_bg:SetValue(false)
			-- self.show_hunt_bg:SetValue(false)
			if self.son_spirit_view then
				self.son_spirit_view:Flush()
				self.son_spirit_view:SetBackPackState(true)
			end
		elseif k == "from_bag" then
			self.spirit_toggle.toggle.isOn = true
			self:OpenSpirit()
			-- self.show_default_bg:SetValue(false)
			-- self.show_hunt_bg:SetValue(false)
			if self.son_spirit_view then
				self.son_spirit_view:OnClickBackPack()
			end
		elseif k == "all" then
			if cur_index == TabIndex.spirit_spirit then
				-- self:OpenSpirit()
				self.spirit_toggle.toggle.isOn = true
				-- self.show_default_bg:SetValue(false)
				-- self.show_hunt_bg:SetValue(false)
				if self.son_spirit_view then
					self.son_spirit_view.is_click_item = false
					self.son_spirit_view:SetBackPackState(true)
					self.son_spirit_view:Flush()
				end
			elseif cur_index == TabIndex.spirit_hunt then
				-- self:OpenHunt()
				-- self.show_default_bg:SetValue(false)
				-- self.show_hunt_bg:SetValue(false)
				if self.son_spirit_view then
					self.son_spirit_view:SetBackPackState(false)
				end
				self.hunt_toggle.toggle.isOn = true
				self.tab_warehouse.toggle.isOn = false
				self.exchange_toggle.toggle.isOn = false
				if self.hunt_view then
					self.hunt_view:Flush()
				end
			elseif cur_index == TabIndex.spirit_warehouse then
				self.tab_warehouse.toggle.isOn = true
				if self.warehouse_view then
					self.warehouse_view:FlushBagView()
				end
			elseif cur_index == TabIndex.spirit_exchange then
				self.exchange_toggle.toggle.isOn = true
				self:SetExchangeScore()
			elseif cur_index == TabIndex.spirit_soul then
				if self.soul_view then
					self.soul_view:Flush()
				end
				-- self.show_default_bg:SetValue(false)
				-- self.show_hunt_bg:SetValue(false)
				self:SetHunLiNum()
				self.soul_toggle.toggle.isOn = true
			elseif cur_index == TabIndex.spirit_fazhen then
				if self.fazhen_view then
					self.fazhen_view:Flush()
				end
				-- self.show_default_bg:SetValue(false)
				-- self.show_hunt_bg:SetValue(false)
				self.fazhen_toggle.toggle.isOn = true
			elseif cur_index == TabIndex.spirit_halo then
				if self.halo_view then
					self.halo_view:Flush()
				end
				-- self.show_default_bg:SetValue(false)
				-- self.show_hunt_bg:SetValue(false)
				self.halo_toggle.toggle.isOn = true
			end
		elseif k == "warehouse" then
			if self.warehouse_view then
				self.warehouse_view:FlushBagView()
			end
		elseif k == "hunt" then
			if self.hunt_toggle.toggle.isOn then
				if self.hunt_view then
					self.hunt_view:Flush()
				end
			end
		elseif k == "exchange" then
			self:SetExchangeScore()
		end
	end
end
