SpiritView = SpiritView or BaseClass(BaseView)

local STATE_LIST = {"spirit", "hunt", "warehouse", "exchange", "soul", "fazhen", "halo"}

function SpiritView:__init()
	self.ui_config = {"uis/views/spiritview_prefab", "SpiritView"}
	self.full_screen = true
	if self.audio_config then
		self.open_audio_id = AssetID("audios/sfxs/uis", self.audio_config.other[1].OpenJingling)
	end
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self.state = 1
	self.open_trigger_handle = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.InitTab, self))
	self.red_point_list = {}
end

function SpiritView:__delete()
	if UnityEngine.PlayerPrefs.GetInt("slotoldindex", 999) >= GameEnum.LIEMING_FUHUN_SLOT_COUNT then
		UnityEngine.PlayerPrefs.DeleteKey("slotoldindex")
	end

	if self.open_trigger_handle ~= nil then
		GlobalEventSystem:UnBind(self.open_trigger_handle)
		self.open_trigger_handle = nil
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

	if self.son_skill_view then
		self.son_skill_view:DeleteMe()
		self.son_skill_view = nil
	end

	if self.zhenfa_view then
		self.zhenfa_view:DeleteMe()
		self.zhenfa_view = nil
	end

	if self.home_view then
		self.home_view:DeleteMe()
		self.home_view = nil
	end

	if self.lingpo_view then
		self.lingpo_view:DeleteMe()
		self.lingpo_view = nil
	end

	if self.meet_view then
		self.meet_view:DeleteMe()
		self.meet_view = nil
	end

	for k, _ in pairs(self.red_point_list) do
		RemindManager.Instance:UnBind(self.remind_change, k)
	end
	self.red_point_list = {}

	if nil ~= self.bipin_remind_change then
		RemindManager.Instance:UnBind(self.bipin_remind_change)
		self.bipin_remind_change = nil
	end
	-- 清理变量
	self.gold = nil
	self.bind_gold = nil
	self.score = nil
	self.hunli = nil
	-- self.show_scene_mask = nil
	-- self.show_zhenfa_background = nil
	self.hunt_toggle = nil
	self.spirit_toggle = nil
	-- self.exchange_toggle = nil
	self.soul_toggle = nil
	self.fazhen_toggle = nil
	self.halo_toggle = nil
	self.top_hunt_toggle = nil
	self.aptitude_toggle =nil
	self.skill_toggle = nil
	self.growing_toggle = nil
	--self.show_spirit_topbutton = nil
	self.zhenfa_toggle = nil
	self.home_toggle = nil
	self.skill_bag_toggle = nil
	self.skill_storage_toggle = nil
	-- self.show_home_bg = nil
	self.bipin_icon_list = nil
	self.lingpo_toggle = nil
	-- self.show_lingpo_bg = nil
	self.warehouse_view = nil
	self.meet_toggle = nil
	self.meet_content = nil
	self.spirit_content = nil
	self.hunt_content = nil
	self.soul_content = nil
	self.skill_content = nil
	self.zhenfa_content = nil
	self.home_content = nil
	self.lingpo_content = nil
end

function SpiritView:LoadCallBack()
	self.spirit_content = self:FindObj("SpiritContent")
	self.hunt_content = self:FindObj("HuntContent")
	self.warehouse_view = SpiritCtrl.Instance.spirit_warehouse_view
	self.soul_content = self:FindObj("SoulContent")
	self.skill_bag_toggle = self:FindObj("SkillBagToggle")
	self.skill_storage_toggle = self:FindObj("SkillStorageToggle")
	self.skill_content = self:FindObj("SkillContent")
	self.zhenfa_content = self:FindObj("ZhenFaContent")
	self.home_content = self:FindObj("HomeContent")
	self.lingpo_toggle = self:FindObj("LingPoToggle")
	self.lingpo_content = self:FindObj("LingPoContent")

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
	self:ListenEvent("OpenSkill",
		BindTool.Bind(self.OpenSkill, self))
	self:ListenEvent("AddGold",
		BindTool.Bind(self.HandleAddGold, self))
	self:ListenEvent("OpenZhenfa",
		BindTool.Bind(self.OpenZhenfa,self))
	self:ListenEvent("OpenHome",
		BindTool.Bind(self.OpenHome,self))
	self:ListenEvent("OpenSkillBagView",
		BindTool.Bind(self.OpenSkillBagView, self))
	self:ListenEvent("OpenSkillStorageView",
		BindTool.Bind(self.OpenSkillStorageView, self))
	self:ListenEvent("OnClickBiPin",
		BindTool.Bind(self.OnClickBiPin, self))
	self:ListenEvent("OpenAttrView",
		BindTool.Bind(self.OpenAttrView,self))
	self:ListenEvent("OpenAptitudeView",
		BindTool.Bind(self.OpenAptitudeView,self))
	self:ListenEvent("OpenLingPo",
		BindTool.Bind(self.OpenLingPo,self))
	self:ListenEvent("OpenMeet",
		BindTool.Bind(self.OpenMeet,self))
	self:ListenEvent("OnClickBiPingReward",
		BindTool.Bind(self.OnClickBiPingReward, self))

	self.meet_content = self:FindObj("MeetContent")

	self.gold = self:FindVariable("Gold")
	self.bind_gold = self:FindVariable("BindGold")
	self.score = self:FindVariable("Score")
	self.hunli = self:FindVariable("HunLi")

	--self.tab_warehouse = self:FindObj("TabWarehouse")
	self.hunt_toggle = self:FindObj("TabHunt")
	self.spirit_toggle = self:FindObj("TabSpirit")
	self.meet_toggle = self:FindObj("TabMeet")
	-- self.exchange_toggle = self:FindObj("TabExchange")
	self.soul_toggle = self:FindObj("TabSoul")
	self.fazhen_toggle = self:FindObj("TabFaZhen")
	self.halo_toggle = self:FindObj("TabHalo")
	self.top_hunt_toggle = self:FindObj("TopTabHunt")
	self.skill_toggle = self:FindObj("TabSkill")
	self.zhenfa_toggle = self:FindObj("TabZhenFa")
	--self.show_spirit_topbutton=self:FindObj("SpiritTopButton")
	self.home_toggle = self:FindObj("TabHome")
	self.bipin_icon_list = {}
	self.bipin_icon_list[5] = self:FindVariable("ShowJingLingBiPin")

	self.red_point_list = {
		[RemindName.SpiritInfo] = self:FindVariable("ShowSpiritRedPoint"),
		[RemindName.SpiritUpgrade] = self:FindVariable("ShowGrowRedPoint"),
		[RemindName.SpiritUpgradeWuxing] = self:FindVariable("ShowWuXingRedPoint"),
		[RemindName.SpiritLingpo] = self:FindVariable("ShowLingPoRedPoint"),
		[RemindName.SpiritHunt] = self:FindVariable("ShowHuntRedPoint"),
		[RemindName.SpiritFreeHunt] = self:FindVariable("ShowSmallHuntRedPoint"),
		[RemindName.SpiritWarehouse] = self:FindVariable("ShowWarehouseRedPoint"),
		[RemindName.SpiritHome] = self:FindVariable("ShowHomeRedPoint"),
		[RemindName.SpiritSkill] = self:FindVariable("ShowSkillRedPoint"),
		[RemindName.SpiritSkillLearn] = self:FindVariable("ShowSkillTogRedPoint"),
		[RemindName.SpiritSoulGroup] = self:FindVariable("ShowSoulRedPoint"),
		[RemindName.SpiritZhenFa] = self:FindVariable("ShowZhenFaRedPoint"),
		[RemindName.SpiritMeet] = self:FindVariable("ShowMeetRedPoint"),
	}
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	for k, _ in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end

	self.bipin_remind_change = function() self:Flush("spirit") end
	RemindManager.Instance:Bind(self.bipin_remind_change,  RemindName.BiPin)
end

function SpiritView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetValue(num > 0)
	end
end

function SpiritView:OpenCallBack()
	SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_SPECIAL_JINGLING_INFO)
	self.time_bipin_quest = GlobalEventSystem:Bind(OtherEventType.PASS_DAY, BindTool.Bind(self.SetBiPinIcon, self))

	SpiritCtrl.Instance:SendHuntSpiritGetFreeInfo()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	SpiritCtrl.Instance:SendJingLingHomeOperReq(JING_LING_HOME_REASON.JING_LING_HOME_REASON_DEF, main_role_vo.role_id)

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

	self:SetBiPinIcon()
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
	if self.son_skill_view then
		self.son_skill_view:CloseCallBack()
	end

	if self.home_view then
		self.home_view:CloseCallBack()
	end

	if self.lingpo_view then
		self.lingpo_view:OnClose()
	end

	if ViewManager.Instance:IsOpen(ViewName.RollingBarrageView) then
		ViewManager.Instance:Close(ViewName.RollingBarrageView)
	end

	if self.time_bipin_quest ~= nil then
		GlobalEventSystem:UnBind(self.time_bipin_quest)
		self.time_bipin_quest = nil
	end

	-- 清除精灵技能获取界面自动购买
	SpiritCtrl.Instance:CloseGetSkillViewAutoBuy()
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
	elseif cur_index == TabIndex.spirit_skill then
		if self.son_skill_view then
			self.son_skill_view:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
		end
	elseif cur_index == TabIndex.spirit_lingpo then
		if self.lingpo_view then
			self.lingpo_view:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
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

function SpiritView:OnClickBiPin()
	ViewManager.Instance:Open(ViewName.CompetitionActivity)
	self:Close()
end

function SpiritView:SetBiPinIcon()
	local bipin_cfg = CompetitionActivityData.Instance:GetBiPinActTypeList()
	if nil == bipin_cfg then
		return
	end

	for k, v in pairs(bipin_cfg) do
		if self.bipin_icon_list[k] then
			self.bipin_icon_list[k]:SetValue(ActivityData.Instance:GetActivityIsOpen(v.activity_type))
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

function SpiritView:AsyncLoadView(index)
	if index == TabIndex.spirit_spirit and not self.son_spirit_view then
		UtilU3d.PrefabLoad("uis/views/spiritview_prefab", "SpiritContent",
			function(obj)
				obj.transform:SetParent(self.spirit_content.transform, false)
				obj = U3DObject(obj)
				self.son_spirit_view = SonSpiritView.New(obj)
				if TabIndex.spirit_spirit == self:GetShowIndex() then
					self.son_spirit_view:OpenCallBack()
				end
			end)
	end
	if index == TabIndex.spirit_hunt and not self.hunt_view then
		UtilU3d.PrefabLoad("uis/views/spiritview_prefab", "HuntContent",
			function(obj)
				obj.transform:SetParent(self.hunt_content.transform, false)
				obj = U3DObject(obj)
				self.hunt_view = SpiritHuntView.New(obj)
				if TabIndex.spirit_hunt == self:GetShowIndex() then
					self.hunt_view:Flush()
				end
			end)
	end
	if index == TabIndex.spirit_soul and not self.soul_view then
		UtilU3d.PrefabLoad("uis/views/spiritview_prefab", "SoulContent",
			function(obj)
				obj.transform:SetParent(self.soul_content.transform, false)
				obj = U3DObject(obj)
				self.soul_view = SpiritSoulView.New(obj)
				if TabIndex.spirit_soul == self:GetShowIndex() then
					self.soul_view:Flush()
				end
			end)
	end

	if index == TabIndex.spirit_skill and not self.son_skill_view then
		UtilU3d.PrefabLoad("uis/views/spiritview_prefab", "SkillContent",
			function(obj)
				obj.transform:SetParent(self.skill_content.transform, false)
				obj = U3DObject(obj)
				self.son_skill_view = SonSkillView.New(obj)
				self.son_skill_view:SetToggle(self.skill_bag_toggle, self.skill_storage_toggle)
				if TabIndex.spirit_skill == self:GetShowIndex() then
					self.son_skill_view:Flush()
				end
			end)
	end

	if index == TabIndex.spirit_zhenfa and not self.zhenfa_view then
		UtilU3d.PrefabLoad("uis/views/spiritview_prefab", "ZhenFaContent",
			function(obj)
			obj.transform:SetParent(self.zhenfa_content.transform, false)
			obj = U3DObject(obj)
			self.zhenfa_view = SpiritZhenfaView.New(obj)
			if TabIndex.spirit_zhenfa == self:GetShowIndex() then
				self.zhenfa_view:Flush()
			end
			end)
	end

	if index == TabIndex.spirit_home and not self.home_view then
		UtilU3d.PrefabLoad("uis/views/spiritview_prefab", "HomeContent",
			function(obj)
				obj.transform:SetParent(self.home_content.transform, false)
				obj = U3DObject(obj)
				self.home_view = SpiritHomeView.New(obj)
				self.home_view:Flush()
			end)
	end

	if index == TabIndex.spirit_lingpo and not self.lingpo_view then
		UtilU3d.PrefabLoad("uis/views/spiritview_prefab", "SpiritLingPo",
			function(obj)
				obj.transform:SetParent(self.lingpo_content.transform, false)
				obj = U3DObject(obj)
				self.lingpo_view = SpiritLingPoView.New(obj)
				self.lingpo_view:Flush("flush_modle")
			end)
	end
end
-- 切换标签调用
function SpiritView:ShowIndexCallBack(index)
	self:AsyncLoadView(index)
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

	if index ~= TabIndex.spirit_soul then
		if self.soul_view then
			self.soul_view:CloseCallBack()
		end
	end

	if index ~= TabIndex.spirit_skill then
		if self.son_skill_view then
			self.son_skill_view:CloseCallBack()
		end
	end
	if index ~= TabIndex.spirit_zhenfa then
		if self.zhenfa_view then
			self.zhenfa_view:CloseCallBack()
		end
	end

	if index ~= TabIndex.spirit_home then
		if self.home_view then
			self.home_view:CloseCallBack()
		end
	end

	if index == TabIndex.spirit_spirit then
		if self.son_spirit_view then
			self.son_spirit_view:OpenCallBack()
		end
		self.state = 1
	elseif index == TabIndex.spirit_fazhen then
		self.state = 6
	elseif index == TabIndex.spirit_hunt then
		self.state = 2
		self.top_hunt_toggle.toggle.isOn = true

		-- 判断是否打开弹幕
		if RollingBarrageData.Instance:GetRecordBarrageState(CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_JINGLING) then
			return
		end
		RollingBarrageData.Instance:SetNowCheckType(CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_JINGLING)
		GlobalTimerQuest:AddDelayTimer(function()
			ViewManager.Instance:Open(ViewName.RollingBarrageView)
		end, 0)
	elseif index == TabIndex.spirit_halo then
		local halo_info = SpiritData.Instance:GetSpiritHaloInfo()
		if halo_info and halo_info.grade then
			if halo_info.grade >= SpiritData.Instance:GetMaxSpiritHaloGrade() then
				-- UIScene:ChangeScene(self, self.ui_scene, {[1] = {"Pingtai04", true, 1}})
			else
				-- UIScene:ChangeScene(self, self.ui_scene, {[1] = {"Pingtai03", true, 1}, [2] = {"Pingtai03", true, 2}})
			end
		end
		self.state = 7
	elseif index == TabIndex.spirit_skill then
		self.state = 8
		self.skill_toggle.toggle.isOn = true
		if self.son_skill_view then
			self.son_skill_view:OpenCallBack()
		end
	elseif index == TabIndex.spirit_zhenfa then
		self.state = 9
		self.zhenfa_toggle.toggle.isOn = true
	elseif index == TabIndex.spirit_home then
		self.state = 10
		self.home_toggle.toggle.isOn = true
		if self.home_view then
			self.home_view:OpenCallBack()
		end
	elseif index == TabIndex.spirit_lingpo then
		self.state = 11
		if self.lingpo_view then
			self:Flush("ling_po_model")
		end
	elseif index == TabIndex.spirit_meet then
		self:LoadMeetContent()
		if self.meet_view then
			self.meet_view:OpenCallBack()
		end
	elseif index == TabIndex.spirit_soul then

	else
		self:ShowIndex(TabIndex.spirit_spirit)
	end

	self:CloseRollingView(index)
end

function SpiritView:CloseRollingView(index)
	if index ~= TabIndex.spirit_hunt then
		if ViewManager.Instance:IsOpen(ViewName.RollingBarrageView) then
			ViewManager.Instance:Close(ViewName.RollingBarrageView)
		end
	end
end
-- function SpiritView:CloseWareHouse()
--     self.show_warehouse_1:SetValue(false)
-- end

-- function SpiritView:CloseExchange()
--     self.show_exchange_1:SetValue(false)
-- end

function SpiritView:OpenSpirit()
	if self.state == 1 then
		return
	end
	self:StopAutoJinjie(1)
	self.state = 1
	self:ShowIndex(TabIndex.spirit_spirit)
	if self.son_spirit_view then
	   self.son_spirit_view:OpenCallBack()
	end
end

function SpiritView:OpenHunt()
	if self.state == 2 then
		return
	end
	self:StopAutoJinjie(2)
	self.state = 2
	self:ShowIndex(TabIndex.spirit_hunt)
	if self.hunt_view then
		self.hunt_view:Flush()
	end
	self.top_hunt_toggle.toggle.isOn = true
end

function SpiritView:OpenWarehouse()
	-- if self.state == 3 then
	-- 	return
	-- end
	-- self:StopAutoJinjie(3)
	-- self.state = 3
	-- self:ShowIndex(TabIndex.spirit_warehouse)
	-- self.tab_warehouse.toggle.isOn = true
	SpiritCtrl.Instance:OpenWarehouseView()
	-- self.show_warehouse_1:SetValue(true)
	if self.warehouse_view then
		self.warehouse_view:FlushBagView()
	end
end

-- 兑换
function SpiritView:OpenExchange()
	SpiritCtrl.Instance:OpenExchangeview()
	-- self.show_exchange_1:SetValue(true)
	-- if self.state == 4 then
	-- 	return
	-- end
	-- self:StopAutoJinjie(4)
	-- self.state = 4
	-- self:ShowIndex(TabIndex.spirit_exchange)
end

--奇遇
function SpiritView:OpenMeet()
	self.state = 13
	self:ShowIndex(TabIndex.spirit_meet)
	if self.meet_view then
		self.meet_view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.SpiritMeet, true)
end

function SpiritView:OnClickBiPingReward()
	ViewManager.Instance:Open(ViewName.CompetitionTips)
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
	self:ShowIndex(TabIndex.spirit_soul)
	if self.soul_view then
		self.show_index = TabIndex.spirit_soul
		self.soul_view:ResetOpenState()
		self.soul_view:Flush()
	end
	self:SetHunLiNum()
end

-- 法阵
function SpiritView:OpenFaZhen()
	if self.state == 6 then
		return
	end
	self:StopAutoJinjie(6)
	self.state = 6
	self:ShowIndex(TabIndex.spirit_fazhen)
	if self.fazhen_view then
		self.fazhen_view:Flush()
	end
end

function SpiritView:OpenSkill()
	self.state = 8
	self:ShowIndex(TabIndex.spirit_skill)
	if self.son_skill_view then
		self.son_skill_view:Flush()
	end

end

-- 光环
function SpiritView:OpenHalo()
	if self.state == 7 then
		return
	end
	self:StopAutoJinjie(7)
	self.state = 7
	self:ShowIndex(TabIndex.spirit_halo)
	if self.halo_view then
		self.halo_view:Flush()
	end
end

--阵法
function SpiritView:OpenZhenfa()
	if self.state == 9 then
		return
	end
	self:StopAutoJinjie(9)
	self.state = 9
	self:ShowIndex(TabIndex.spirit_zhenfa)
	if self.zhenfa_view then
		self.zhenfa_view:Flush()
	end
end


-- 家园
function SpiritView:OpenHome()
	if self.state == 10 then
		return
	end
	self:StopAutoJinjie(10)
	self.state = 10
	self:ShowIndex(TabIndex.spirit_home)
	if self.home_view then
		self.home_view:Flush()
	end
end

function SpiritView:LoadMeetContent()
	if self.meet_content.transform.childCount == 0 then
		UtilU3d.PrefabLoad(
			"uis/views/spiritview_prefab",
			"MeetContent",
			function(obj)
				obj = U3DObject(obj)
				obj.transform:SetParent(self.meet_content.transform, false)
				self.meet_view = SpiritMeetView.New(obj)
				self.meet_view:Flush()
			end)
	end
end

--灵魄
function SpiritView:OpenLingPo()
	if self.index ~= TabIndex.spirit_lingpo then
		self:ShowIndex(TabIndex.spirit_lingpo)
		self:Flush()
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
	local open_data = OpenFunData.Instance
	--self.tab_warehouse:SetActive(open_data:CheckIsHide("spirit_warehouse"))
	self.hunt_toggle:SetActive(open_data:CheckIsHide("spirit_hunt"))
	self.spirit_toggle:SetActive(open_data:CheckIsHide("spirit_spirit"))
	-- self.exchange_toggle:SetActive(open_data:CheckIsHide("spirit_exchange"))
	self.soul_toggle:SetActive(open_data:CheckIsHide("spirit_soul"))
	self.fazhen_toggle:SetActive(open_data:CheckIsHide("spirit_fazhen"))
	self.halo_toggle:SetActive(open_data:CheckIsHide("spirit_halo"))
	self.skill_toggle:SetActive(open_data:CheckIsHide("spirit_skill"))
	self.home_toggle:SetActive(open_data:CheckIsHide("spirit_home"))
	self.lingpo_toggle:SetActive(open_data:CheckIsHide("spirit_lingpo"))
	self.zhenfa_toggle:SetActive(open_data:CheckIsHide("spirit_zhenfa"))
	self.meet_toggle:SetActive(open_data:CheckIsHide("spirit_meet"))
end

function SpiritView:OnFlush(param_t)
	local cur_index = self:GetShowIndex()
	for k, v in pairs(param_t) do
		if k == "spirit" then
			if TabIndex.spirit_spirit == self:GetShowIndex() then
				if self.son_spirit_view then
					self.son_spirit_view:Flush()
				end
			elseif TabIndex.spirit_zhenfa == self:GetShowIndex() then
				if self.zhenfa_view then
					self.zhenfa_view:Flush()
				end
			elseif TabIndex.spirit_skill == self:GetShowIndex() then
				if self.son_skill_view then
					self.son_skill_view:Flush()
				end
			end
		elseif k == "from_bag" then
			self.spirit_toggle.toggle.isOn = true
			self:OpenSpirit()
			if self.son_spirit_view then
				self.son_spirit_view:OnClickBackPack()
			end
		elseif k == "all" then
			if cur_index == TabIndex.spirit_spirit then
				self.spirit_toggle.toggle.isOn = true
				if self.son_spirit_view then
					self.son_spirit_view.is_click_item = false

					local open_param = SpiritData.Instance:GetOpenParam()
					if nil ~= open_param then
						SpiritData.Instance:ClearOpenParam()
						if open_param == "spirit_wuxing" then
							self:OpenAptitudeView()
						elseif open_param == "spirit_grow" then
							self:OpenAttrView()
						end
					end

					self.son_spirit_view:Flush()
				end
			elseif cur_index == TabIndex.spirit_hunt then
				self.hunt_toggle.toggle.isOn = true
				--self.tab_warehouse.toggle.isOn = false
				-- self.exchange_toggle.toggle.isOn = false
				if self.hunt_view then
					self.hunt_view:Flush()
				end
			elseif cur_index == TabIndex.spirit_warehouse then
				--self.tab_warehouse.toggle.isOn = true
				if self.warehouse_view then
					self.warehouse_view:FlushBagView()
				end
			elseif cur_index == TabIndex.spirit_exchange then
				-- self.exchange_toggle.toggle.isOn = true
				self:SetExchangeScore()
			elseif cur_index == TabIndex.spirit_soul then
				if self.soul_view then
					self.soul_view:Flush()
				end
				self:SetHunLiNum()
				self.soul_toggle.toggle.isOn = true
			elseif cur_index == TabIndex.spirit_fazhen then
				if self.fazhen_view then
					self.fazhen_view:Flush()
				end
				self.fazhen_toggle.toggle.isOn = true
			elseif cur_index == TabIndex.spirit_halo then
				if self.halo_view then
					self.halo_view:Flush()
				end
				self.halo_toggle.toggle.isOn = true
			elseif cur_index == TabIndex.spirit_skill then
				self.skill_toggle.toggle.isOn = true
			elseif cur_index == TabIndex.spirit_zhenfa then
				if self.zhenfa_view then
					self.zhenfa_view:Flush()
				end
				self.zhenfa_toggle.isOn = true

				if nil ~= v.item_id then
					-- 生命之魂，攻击之魂，防御之魂
					if v.item_id == 27835 or v.item_id == 27835 or v.item_id == 27835 then
						SpiritCtrl.Instance:ShowSpiritZhenFaPromoteView(SPIRITPROMOTETAB_TYPE.TABHUNYU)
					elseif v.item_id == 27834 then
						SpiritCtrl.Instance:ShowSpiritZhenFaPromoteView(SPIRITPROMOTETAB_TYPE.TABXIANZHEN)
					end
				end
			elseif cur_index == TabIndex.spirit_home then
				if self.home_view then
					self.home_view:Flush()
				end
			elseif cur_index == TabIndex.spirit_meet then
				self.meet_toggle.toggle.isOn = true
				if self.meet_view then
					self.meet_view:Flush()
				end
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
		elseif k == "home_opera" then
			if cur_index == TabIndex.spirit_home and self.home_toggle.toggle.isOn then
				if self.home_view then
					self.home_view:Flush("home_opera")
				end
			end
		elseif k == "people_state" then
			if self.home_view ~= nil then
				self.home_view:ChangeBtnPeople(v.state)
			end
		elseif "enter_other_home" == k then
			if cur_index == TabIndex.spirit_home and self.home_toggle.toggle.isOn then
				if self.home_view then
					self.home_view:Flush("enter_other_home")
				end
			end
		elseif "flush_plunder" == k then
			if cur_index == TabIndex.spirit_home and self.home_toggle.toggle.isOn then
				if self.home_view then
					self.home_view:Flush("flush_plunder")
				end
			end
		elseif "add_reward" == k then
			if cur_index == TabIndex.spirit_home and self.home_toggle.toggle.isOn then
				if self.home_view then
					self.home_view:Flush("add_reward")
				end
			end
		elseif "change_fight_choose" == k then
			if cur_index == TabIndex.spirit_home and self.home_toggle.toggle.isOn then
				if self.home_view then
					self.home_view:Flush("change_fight_choose")
				end
			end
		elseif "ling_po" == k then
			if self.lingpo_view then
				--刷新包不含model
				self.lingpo_view:Flush()
			end
		elseif "ling_po_slider" == k then
			if self.lingpo_view then
				self.lingpo_view:FlushSlider(true)
			end
		elseif "ling_po_model" == k then
			if self.lingpo_view then
				--刷新包含model
				self.lingpo_view:Flush("flush_modle", {[1] = true})
			end
		elseif "flush_explore_red" == k then
			if cur_index == TabIndex.spirit_home and self.home_toggle.toggle.isOn then
				if self.home_view then
					self.home_view:Flush("flush_explore_red")
				end
			end
		elseif "flush_revenge_red" == k then
			if cur_index == TabIndex.spirit_home and self.home_toggle.toggle.isOn then
				if self.home_view then
					self.home_view:Flush("flush_revenge_red")
				end
			end
		elseif "flush_cap" == k then
			if cur_index == TabIndex.spirit_home and self.home_toggle.toggle.isOn then
				if self.home_view then
					self.home_view:Flush("flush_cap")
				end
			end
		elseif "flush_meet" == k then
			if cur_index == TabIndex.spirit_meet and self.meet_view then
				self.meet_view:Flush()
			end
		end
	end
end

function SpiritView:FlushSpiritTopButton(enable)
	-- self.show_spirit_topbutton:SetActive(enable)
	-- self.growing_toggle.toggle.isOn = enable
	-- self.aptitude_toggle.toggle.isOn = not enable
end

function SpiritView:OpenAttrView()

	self.son_spirit_view:OpenTagView(true)
end

function SpiritView:OpenAptitudeView()
	self.son_spirit_view:OpenTagView(false)
end

function SpiritView:OpenSkillBagView()
	if self.son_skill_view then
		self.son_skill_view:OpenSkillView()
	end
end

function SpiritView:OpenSkillStorageView()
	if self.son_skill_view then
		self.son_skill_view:OpenStorageView()
	end
end

function SpiritView:SetSelectPlunderIndex(index)
	if self:GetShowIndex() == TabIndex.spirit_home and self.home_toggle.toggle.isOn then
		if self.home_view then
			self.home_view:SetSelectPlunderIndex(index)
		end
	end
end

function SpiritView:SoulQuickFlushButtonState(state)
	if self.soul_view and self.soul_toggle and self.soul_toggle.toggle.isOn then
		self.soul_view:ShowButtonState(state)
	end
end

function SpiritView:IsOpenSoulView()
	if self.soul_view and self.soul_toggle and self.soul_toggle.toggle.isOn then
		return true
	end
	return false
end