require("game/player/player_shenbing_view")
AdvanceView = AdvanceView or BaseClass(BaseView)
local MOUNT = 1
local WING = 2
local HALO = 3
local HUASHEN = 4
local HUASHEN_PROTECT = 5
local FIGHT_MOUNT = 6
local SHEN_BING = 7
local FOOT = 8
local CLOAK = 9
local LINGCHONG = 10

local risingstar_img_path = {
	[SHENGXINGZHULI_SYSTEM_TYPE.SHENGXINGZHULI_SYSTEM_TYPE_MOUNT] = "Function_Open_Moqi",
	[SHENGXINGZHULI_SYSTEM_TYPE.SHENGXINGZHULI_SYSTEM_TYPE_WING] = "Function_Open_Yuyi",
	[SHENGXINGZHULI_SYSTEM_TYPE.SHENGXINGZHULI_SYSTEM_TYPE_SHENGONG] = "Function_Open_Guanghuan",
	[SHENGXINGZHULI_SYSTEM_TYPE.SHENGXINGZHULI_SYSTEM_TYPE_HALO] = "Function_Open_ZhuJueGuanghuan",
	[SHENGXINGZHULI_SYSTEM_TYPE.SHENGXINGZHULI_SYSTEM_TYPE_PIFENG] = "Icon_Function_Fazhen",
	[SHENGXINGZHULI_SYSTEM_TYPE.SHENGXINGZHULI_SYSTEM_TYPE_FIGHT_MOUNT] = "Function_Open_Zuoqi",
	[SHENGXINGZHULI_SYSTEM_TYPE.SHENGXINGZHULI_SYSTEM_TYPE_FOOT_PRINT] = "Function_Open_Zuji"
}

function AdvanceView:__init()
	self.ui_config = {"uis/views/advanceview_prefab", "AdvanceView"}
	self.ui_scene = {"scenes/map/uizqdt01", "UIzqdt01"}
	self.full_screen = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self.open_fun_t = {
		[TabIndex.mount_jinjie] = "OpenMount",
		[TabIndex.wing_jinjie] = "OpenWing",
		[TabIndex.halo_jinjie] = "OpenFoot",
		[TabIndex.foot_jinjie] = "OpenHalo",
		[TabIndex.fight_mount] = "OpenFightMount",
		[TabIndex.role_shenbing] = "HandleOpenShenBing",
		[TabIndex.cloak_jinjie] = "HandleOpenCloak",
		[TabIndex.lingchong_jinjie] = "OpenLingChong",
			}


	if self.audio_config then
		self.open_audio_id = AssetID("audios/sfxs/uis", self.audio_config.other[1].OpenAdvanced)
	end
	self.def_index = TabIndex.mount_jinjie
	self.play_audio = true
	self.view_state = MOUNT
	self.notips = false
	self.open_trigger_handle = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.InitTab, self))
end

function AdvanceView:__delete()
	GlobalEventSystem:UnBind(self.open_trigger_handle)
end

function AdvanceView:LoadCallBack()
	self.BiPingAnim = self:FindObj("BiPingIconAnim")
	self.BiPing_flag = true

	self:ListenEvent("Close",
		BindTool.Bind(self.HandleClose, self))
	self:ListenEvent("OpenMount",
		BindTool.Bind(self.OpenIndexCheck, self, TabIndex.mount_jinjie))
	self:ListenEvent("OpenWing",
		BindTool.Bind(self.OpenIndexCheck, self, TabIndex.wing_jinjie))
	self:ListenEvent("OpenFoot",
		BindTool.Bind(self.OpenIndexCheck, self, TabIndex.halo_jinjie))
	self:ListenEvent("OpenHalo",
		BindTool.Bind(self.OpenIndexCheck, self, TabIndex.foot_jinjie))
	-- self:ListenEvent("OpenHuaShen",
	-- 	BindTool.Bind(self.OpenHuaShen, self))
	-- self:ListenEvent("OpenHuaShenProtect",
	-- 	BindTool.Bind(self.OpenHuaShenProtect, self))
	self:ListenEvent("OpenFightMount",
		BindTool.Bind(self.OpenIndexCheck, self, TabIndex.fight_mount))
	self:ListenEvent("AddGold",
		BindTool.Bind(self.HandleAddGold, self))
	self:ListenEvent("OnClickBiPin",
		BindTool.Bind(self.OnClickBiPin, self))
	self:ListenEvent("OpenShenBing",
		BindTool.Bind(self.OpenIndexCheck, self, TabIndex.role_shenbing))
	self:ListenEvent("OpenCloak",
		BindTool.Bind(self.OpenIndexCheck, self, TabIndex.cloak_jinjie))
	self:ListenEvent("OpenLingChong",
		BindTool.Bind(self.OpenIndexCheck, self, TabIndex.lingchong_jinjie))
	self:ListenEvent("OpenRisingStar",
		BindTool.Bind(self.OpenRisingStar,self))

	self.tab_mount = self:FindObj("TabMount")
	self.tab_wing = self:FindObj("TabWing")
	self.tab_halo = self:FindObj("TabHalo")
	self.tab_foot = self:FindObj("FootTab")
	self.toggle_shenbing = self:FindObj("ToggleShenBing")
	self.tab_fight_mount = self:FindObj("TabFightMount")
	self.tab_cloak = self:FindObj("TabCloak")
	self.tab_lingchong = self:FindObj("TabLingChong")

	self.rotate_event_trigger = self:FindObj("RotateEventTrigger")
	local event_trigger = self.rotate_event_trigger:GetComponent(typeof(EventTriggerListener))
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDrag, self))

	self.gold = self:FindVariable("Gold")
	self.bind_gold = self:FindVariable("bind_gold")
	self.show_scene_mask = self:FindVariable("ShowBlueBg")
	self.show_red_point_list = {}
	for i = 1, 8 do
		self.show_red_point_list[i] = self:FindVariable("ShowRedPoint"..i)
	end

	self.bipin_icon_list = {}
	self.bipin_icon_list[1] = self:FindVariable("ShowMountBiPin")
	self.bipin_icon_list[2] = self:FindVariable("ShowWingBiPin")
	self.bipin_icon_list[4] = self:FindVariable("ShowHaloBiPin")
	self.bipin_icon_list[6] = self:FindVariable("ShowFightMountBiPin")
	self.show_bipin_icon = self:FindVariable("ShowBiPingIcon")
	self.bipingredpoint = self:FindVariable("ShowBipingRedPoint")
	self.rising_star_flag = self:FindVariable("RisingStarFlag")
	self.rising_type = self:FindVariable("RisingType")
	self.show_rising_star_red = self:FindVariable("ShowRisingStarRed")

	self.mount_content = self:FindObj("MountContent")

	self.wing_content = self:FindObj("WingContent")

	self.foot_content = self:FindObj("FootContent")

	self.halo_content = self:FindObj("HaloContent")

	self.fight_mount_content = self:FindObj("FightMountContent")

	self.shenbing_content = self:FindObj("ShenBingContent")

	self.cloak_content = self:FindObj("CloakContent")

	self.lingchong_content = self:FindObj("LingChongContent")

	self:InitTab()
	self.btn_close = self:FindObj("BtnClose")

	self.remind_change = function()
		self:FlushSonView()
	end
	RemindManager.Instance:Bind(self.remind_change,  RemindName.BiPin)

	self.rising_star_remind_change = function()
		self:FlushRisingStarRed()
	end
	RemindManager.Instance:Bind(self.rising_star_remind_change,  RemindName.RisingStar)

	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.Advance, BindTool.Bind(self.GetUiCallBack, self))
end

function AdvanceView:ReleaseCallBack()

	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.Advance)
	end
	if self.data_listen ~= nil then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	if self.mount_view ~= nil then
		self.mount_view:DeleteMe()
		self.mount_view = nil
	end

	if self.wing_view ~= nil then
		self.wing_view:DeleteMe()
		self.wing_view = nil
	end

	if self.foot_view ~= nil then
		self.foot_view:DeleteMe()
		self.foot_view = nil
	end

	if self.halo_view ~= nil then
		self.halo_view:DeleteMe()
		self.halo_view = nil
	end

	if self.fight_mount_view ~= nil then
		self.fight_mount_view:DeleteMe()
		self.fight_mount_view = nil
	end

	if self.shenbing_view ~= nil then
		self.shenbing_view:DeleteMe()
		self.shenbing_view = nil
	end

	if self.cloak_view ~= nil then
		self.cloak_view:DeleteMe()
		self.cloak_view = nil
	end

	if self.lingchong_view ~= nil then
		self.lingchong_view:DeleteMe()
		self.lingchong_view = nil
	end

	if nil ~= self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end

	if nil ~= self.rising_star_remind_change then
		RemindManager.Instance:UnBind(self.rising_star_remind_change)
		self.rising_star_remind_change = nil
	end

	-- 清理变量和对象

	self.BiPing_flag=nil
	self.BiPingAnim = nil
	self.tab_mount = nil
	self.tab_wing = nil
	self.tab_halo = nil
	self.tab_foot = nil
	self.tab_cloak = nil
	self.tab_fight_mount = nil
	self.toggle_shenbing = nil
	self.tab_lingchong = nil
	self.rotate_event_trigger = nil
	self.gold = nil
	self.bind_gold = nil
	self.show_scene_mask = nil
	self.show_red_point_list = nil
	self.mount_content = nil
	self.wing_content = nil
	self.foot_content = nil
	self.halo_content = nil
	self.cloak_content = nil
	self.lingchong_content = nil
	self.shenbing_view = nil
	self.fight_mount_content = nil
	self.shenbing_content = nil
	self.btn_close = nil
	self.mount_start_up = nil
	self.bipin_icon_list = nil
	self.wing_start_up = nil
	self.foot_start_up = nil
	self.show_bipin_icon = nil
	self.halo_start_up = nil
	self.rising_star_flag = nil
	self.rising_type = nil
	self.show_rising_star_red = nil
	self.bipingredpoint = nil
end

function AdvanceView:SetRendering(value)
	BaseView.SetRendering(self, value)
	if not value then
		self:StopAutoAdvance()
	end
end

function AdvanceView:OnRoleDrag(data)
end

function AdvanceView:HandleClose()
	AdvanceCtrl.Instance:OpenClearBlessView(ViewName.Advance, self.show_index)
end

function AdvanceView:OnHuashenUpgradeResult(result)
	-- self.huashen_view:OnHuashenUpgradeResult(result)
end

function AdvanceView:OnSpiritUpgradeResult(result)
	-- self.huashen_protect_view:OnSpiritUpgradeResult(result)
end

function AdvanceView:OnFightMountUpgradeResult(result)
	if self.fight_mount_view then
		self.fight_mount_view:OnFightMountUpgradeResult(result)
	end
end

function AdvanceView:MountUpgradeResult(result)
	if self.mount_view then
		self.mount_view:MountUpgradeResult(result)
	end
end

function AdvanceView:WingUpgradeResult(result)
	if self.wing_view then
		self.wing_view:WingUpgradeResult(result)
	end
end

function AdvanceView:HaloUpgradeResult(result)
	if self.halo_view then
		self.halo_view:HaloUpgradeResult(result)
	end
end

function AdvanceView:FootUpgradeResult(result)
	if self.foot_view then
		self.foot_view:FootUpgradeResult(result)
	end
end

function AdvanceView:CloakUpgradeResult(result)
	if self.cloak_view then
		self.cloak_view:CloakUpgradeResult(result)
	end
end

function AdvanceView:OnClickBiPin()
	if self.BiPing_flag then
		self.BiPingAnim.animator:SetBool("isClick", false)
		self.BiPing_flag = true
	end
	local cur_index = self:GetShowIndex()
	local activity_type = KaiFuDegreeRewardsData.Instance:GetBiPingActivity(cur_index)
	KaiFuDegreeRewardsCtrl.Instance:SetDegreeRewardsActivityType(activity_type)
	ViewManager.Instance:Open(ViewName.KaiFuDegreeRewardsView)
	-- ViewManager.Instance:Open(ViewName.CompetitionActivity)
end

function AdvanceView:OpenIndexCheck(index)
	local open_fun = self.open_fun_t[index]
	if open_fun and self[open_fun] then
		AdvanceCtrl.Instance:OpenClearBlessView(ViewName.Advance, self.show_index, BindTool.Bind(self[open_fun], self))
	end
end

function AdvanceView:OpenMount()
	if self.view_state == MOUNT then
		return
	end
	self:ShowIndex(TabIndex.mount_jinjie)
	self:StopAutoAdvance(MOUNT)
end

function AdvanceView:OpenWing()
	if self.view_state == WING then
		return
	end
	self:ShowIndex(TabIndex.wing_jinjie)
	self:StopAutoAdvance(WING)
end

function AdvanceView:OpenFoot()
	if self.view_state == FOOT then
		return
	end
	self:ShowIndex(TabIndex.foot_jinjie)
	self:StopAutoAdvance(FOOT)
end

function AdvanceView:OpenHalo()
	if self.view_state == HALO then
		return
	end
	self:ShowIndex(TabIndex.halo_jinjie)
	self:StopAutoAdvance(HALO)
end

function AdvanceView:OpenFightMount()
	if self.view_state == FIGHT_MOUNT then
		return
	end
	self:ShowIndex(TabIndex.fight_mount)
	self:StopAutoAdvance(FIGHT_MOUNT)
end

function AdvanceView:InitPanel(index)

	if index == TabIndex.mount_jinjie and not self.mount_view then
		UtilU3d.PrefabLoad("uis/views/advanceview_prefab", "MountContent",
			function(obj)
				obj.transform:SetParent(self.mount_content.transform, false)
				obj = U3DObject(obj)
				self.mount_view = AdvanceMountView.New(obj)
				--引导用按钮
				self.mount_start_up = self.mount_view.start_button
				self.mount_view:OpenCallBack()
				self.mount_view:Flush("mount")
				self.mount_view:SetModle(true)
				self:ShowContent(MOUNT)
			end
		)
	elseif index == TabIndex.wing_jinjie and not self.wing_view then
		UtilU3d.PrefabLoad("uis/views/advanceview_prefab", "WingContent",
			function(obj)
				obj.transform:SetParent(self.wing_content.transform, false)
				obj = U3DObject(obj)
				self.wing_view = AdvanceWingView.New(obj)
				--引导用按钮
				self.wing_start_up = self.wing_view.start_button
				self.wing_view:OpenCallBack()
				self.wing_view:Flush("wing")
				self.wing_view:SetModle(true)
				self:ShowContent(WING)
			end
		)
	elseif index == TabIndex.halo_jinjie and not self.halo_view then
		UtilU3d.PrefabLoad("uis/views/advanceview_prefab", "HaloContent",
			function(obj)
				obj.transform:SetParent(self.halo_content.transform, false)
				obj = U3DObject(obj)
				self.halo_view = AdvanceHaloView.New(obj)
				--引导用按钮
				self.halo_start_up = self.halo_view.start_button
				self.halo_view:OpenCallBack()
				self.halo_view:Flush("halo")
				self.halo_view:SetModle(true)
				self:ShowContent(HALO)
			end
		)
	elseif index == TabIndex.foot_jinjie and not self.foot_view then
		UtilU3d.PrefabLoad("uis/views/advanceview_prefab", "FootContent",
			function(obj)
				obj.transform:SetParent(self.foot_content.transform, false)
				obj = U3DObject(obj)
				self.foot_view = AdvanceFootView.New(obj)
				--引导用按钮
				self.foot_start_up = self.foot_view.start_button
				self.foot_view:OpenCallBack()
				self.foot_view:Flush("foot")
				self.foot_view:SetModle(true)
				self:ShowContent(FOOT)
			end
		)
	elseif index == TabIndex.fight_mount and not self.fight_mount_view then
		UtilU3d.PrefabLoad("uis/views/advanceview_prefab", "FightMountContent",
			function(obj)
				obj.transform:SetParent(self.fight_mount_content.transform, false)
				obj = U3DObject(obj)
				self.fight_mount_view = AdvanceFightMountView.New(obj)
				self.fight_mount_view:OpenCallBack()
				self.fight_mount_view:Flush("fightmount")
				self.fight_mount_view:SetModle(true)
				self:ShowContent(FIGHT_MOUNT)
			end
		)
	elseif index == TabIndex.role_shenbing and not self.shenbing_view then
		UtilU3d.PrefabLoad("uis/views/player_prefab", "ShenBingContent",
			function(obj)
				obj.transform:SetParent(self.shenbing_content.transform, false)
				obj = U3DObject(obj)
				self.shenbing_view = PlayerShenBingView.New(obj, self)
				self.shenbing_view:OpenCallBack()
				self.shenbing_view:Flush("shenbing")
				self:ShowContent(SHEN_BING)
			end
		)
 	elseif index == TabIndex.cloak_jinjie and not self.cloak_view then
		UtilU3d.PrefabLoad("uis/views/advanceview_prefab", "CloakContent",
			function(obj)
				obj.transform:SetParent(self.cloak_content.transform, false)
				obj = U3DObject(obj)
				self.cloak_view = AdvanceCloakView.New(obj, self)
				self.cloak_view:OpenCallBack()
				self.cloak_view:Flush("cloak")
				self.cloak_view:SetModle(true)
				self:ShowContent(CLOAK)
			end
		)
	elseif index == TabIndex.lingchong_jinjie and not self.lingchong_view then
		UtilU3d.PrefabLoad("uis/views/advanceview_prefab", "LingChongContent",
			function(obj)
				obj.transform:SetParent(self.lingchong_content.transform, false)
				obj = U3DObject(obj)
				self.lingchong_view = LingChongContentView.New(obj)
				self.lingchong_view:InitView()
			end
		)
	end

end

function AdvanceView:ShowIndexCallBack(index)
	AdvanceData.Instance:SetViewOpenFlag(ViewName.Advance, index)
	if self.mount_view then
		self.mount_view:ClearTempData()
	end
	if self.wing_view then
		self.wing_view:ClearTempData()
	end
	if self.foot_view then
		self.foot_view:ClearTempData()
	end
	if self.halo_view then
		self.halo_view:ClearTempData()
	end
	if self.fight_mount_view then
		self.fight_mount_view:ClearTempData()
	end
	if self.cloak_view then
		self.cloak_view:ClearTempData()
	end
	if self.shenbing_view then
		self.shenbing_view:StopJinJie()
	end

	self:InitPanel(index)
	self:Flush()

	if index == TabIndex.mount_jinjie then
		self.tab_mount.toggle.isOn = true
		self:ShowContent(MOUNT)
	elseif index == TabIndex.wing_jinjie then
		self.tab_wing.toggle.isOn = true
		self:ShowContent(WING)
	elseif index == TabIndex.halo_jinjie then
		self.tab_halo.toggle.isOn = true
		self:ShowContent(HALO)
	elseif index == TabIndex.foot_jinjie then
		self.tab_foot.toggle.isOn = true
		self:ShowContent(FOOT)
	elseif index == TabIndex.fight_mount then
		self.tab_fight_mount.toggle.isOn = true
		self:ShowContent(FIGHT_MOUNT)
	elseif index == TabIndex.role_shenbing then
		self.toggle_shenbing.toggle.isOn = true
		self:ShowContent(SHEN_BING)
	elseif index == TabIndex.cloak_jinjie then
		self.tab_cloak.toggle.isOn = true
		self:ShowContent(CLOAK)
	elseif index == TabIndex.lingchong_jinjie then
		self.tab_lingchong.toggle.isOn = true
		if self.lingchong_view then
			self.lingchong_view:InitView()
		end
		self:ShowContent(LINGCHONG)
	end

	-- local index_cfg = CompetitionActivityData.Instance:GetBiPinTips(index) or false
	-- TipsCtrl.Instance:ShowTipBiPingView(index_cfg, self.BiPingAnim)
	local isopen = KaiFuDegreeRewardsData.Instance:GetIsOpenBiPing(index) or false
	self.show_bipin_icon:SetValue(isopen)
	-- self.show_bipin_icon:SetValue(index_cfg)

	local flag = -1
	-- 是否显示升星助力图标
	self.rising_star_flag:SetValue(flag)
	if flag ~= -1 then
		self.rising_type:SetAsset(ResPath.GetRisingStarActivityRes(risingstar_img_path[flag] .. ".png"))
	end
end

function AdvanceView:HandleAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function AdvanceView:HandleOpenShenBing()
	ViewManager.Instance:Close(ViewName.Warehouse)--关闭仓库

	self:ShowIndex(TabIndex.role_shenbing)
	if self.shenbing_view then
		self.shenbing_view:Flush()
	end
	self:StopAutoAdvance(SHEN_BING)
	self:ShowContent(SHEN_BING)
end

function AdvanceView:HandleOpenCloak()
	if self.view_state == CLOAK then
		return
	end
	self:ShowIndex(TabIndex.cloak_jinjie)
	self:StopAutoAdvance(CLOAK)
	self:ShowContent(CLOAK)
end

function AdvanceView:OpenLingChong()
	if self.view_state == LINGCHONG then
		return
	end
	self:ShowIndex(TabIndex.lingchong_jinjie)
	self:StopAutoAdvance(LINGCHONG)
end

function AdvanceView:PlayerDataChangeCallback(attr_name, value, old_value)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if attr_name == "gold" then
		local count = CommonDataManager.ConverMoney(vo.gold)
		self.gold:SetValue(count)
	end
	if attr_name == "bind_gold" then
		local count = CommonDataManager.ConverMoney(vo.bind_gold)
		self.bind_gold:SetValue(count)
	end
end

function AdvanceView:FlushRisingStarRed()
	if self.show_rising_star_red then
		self.show_rising_star_red:SetValue(KaifuActivityData.Instance:GetRisingStarRemind())
	end
end

function AdvanceView:FlushSonView()
	if self.view_state == MOUNT then
		if self.mount_view then
			self.mount_view:Flush("mount")
			self.show_red_point_list[1]:SetValue(AdvanceData.Instance:IsShowMountRedPoint())
			RemindManager.Instance:Fire(RemindName.Advance)
		end
	elseif self.view_state == WING then
		if self.wing_view then
			self.wing_view:Flush("wing")
			self.show_red_point_list[2]:SetValue(AdvanceData.Instance:IsShowWingRedPoint())
			RemindManager.Instance:Fire(RemindName.Advance)
		end
	elseif self.view_state == HALO then
		if self.halo_view then
			self.halo_view:Flush("halo")
			self.show_red_point_list[3]:SetValue(AdvanceData.Instance:IsShowHaloRedPoint())
			RemindManager.Instance:Fire(RemindName.Advance)
		end
	elseif self.view_state == FOOT then
		if self.foot_view then
			self.foot_view:Flush("foot")
			self.show_red_point_list[6]:SetValue(AdvanceData.Instance:IsShowFootRedPoint())
			RemindManager.Instance:Fire(RemindName.Advance)
		end
	--elseif self.view_state == HUASHEN then
		-- self.huashen_view:Flush("huashen")
	--elseif self.view_state == HUASHEN_PROTECT then
		-- self.huashen_protect_view:Flush("huashenprotect")
	elseif self.view_state == FIGHT_MOUNT then
		if self.fight_mount_view then
			self.fight_mount_view:Flush("fightmount")
			self.show_red_point_list[4]:SetValue(AdvanceData.Instance:IsShowFightMountRedPoint())
			RemindManager.Instance:Fire(RemindName.Advance)
		end
	elseif self.view_state == CLOAK then
		if self.cloak_view then
			self.cloak_view:Flush("cloak")
		end
	end
end

function AdvanceView:ShowContent(id)
	self.view_state = id
	self.mount_content:SetActive(id == MOUNT)
	self.wing_content:SetActive(id == WING)
	self.halo_content:SetActive(id == HALO)
	self.foot_content:SetActive(id == FOOT)
	self.cloak_content:SetActive(id == CLOAK)
	self.fight_mount_content:SetActive(id == FIGHT_MOUNT)

	if id == MOUNT then
		if self.mount_view then
			self.mount_view:OpenCallBack()
			self.mount_view:Flush("mount")
		end
	elseif id == WING then
		if self.wing_view then
			self.wing_view:OpenCallBack()
			self.wing_view:Flush("wing")
		end
	elseif id == HALO then
		if self.halo_view then
			self.halo_view:OpenCallBack()
			self.halo_view:Flush("halo")
		end
	elseif id == FOOT then
		if self.foot_view then
			self.foot_view:OpenCallBack()
			self.foot_view:Flush("foot")
		end
	elseif id == FIGHT_MOUNT then
		if self.fight_mount_view then
			self.fight_mount_view:OpenCallBack()
			self.fight_mount_view:Flush("fightmount")
		end
	elseif id == SHEN_BING then
		if self.shenbing_view then
			self.shenbing_view:OpenCallBack()
			self.shenbing_view:Flush()
		end
	elseif id == CLOAK then
		if self.cloak_view then
			self.cloak_view:OpenCallBack()
			self.cloak_view:Flush("cloak")
		end
	end
end

function AdvanceView:StopAutoAdvance(id)
	if (self.mount_view and self.mount_view.is_auto) or (self.wing_view and self.wing_view.is_auto) or
		(self.halo_view and self.halo_view.is_auto) or (self.foot_view and self.foot_view.is_auto) or
		(self.fight_mount_view and self.fight_mount_view.is_auto) or (self.cloak_view and self.cloak_view.is_auto)
		or (self.shenbing_view and self.shenbing_view.is_auto) then
		if self.view_state ~= id then
			if self.view_state == MOUNT then
				self.mount_view:OnAutomaticAdvance()
			elseif self.view_state == WING then
				self.wing_view:OnAutomaticAdvance()
			elseif self.view_state == HALO then
				self.halo_view:OnAutomaticAdvance()
			elseif self.view_state == FOOT then
				self.foot_view:OnAutomaticAdvance()
			elseif self.view_state == FIGHT_MOUNT then
				self.fight_mount_view:OnAutomaticAdvance()-- or self.shenyi_view.is_auto
			elseif self.view_state == CLOAK then
				self.cloak_view:OnAutomaticAdvance()
			elseif self.view_state == SHEN_BING then
				self.shenbing_view:StopJinJie()
			end
		end
	end
end

function AdvanceView:CloseCallBack()
	AdvanceCtrl.HAS_TIPS_CLEAR_BLESS_T = {}
	FunctionGuide.Instance:DelWaitGuideListByName("mount_up")
	FunctionGuide.Instance:DelWaitGuideListByName("wing_up")
	self:StopAutoAdvance()
	if self.mount_view then
		self.mount_view:RemoveNotifyDataChangeCallBack()
	end
	if self.wing_view then
		self.wing_view:RemoveNotifyDataChangeCallBack()
	end
	if self.halo_view then
		self.halo_view:RemoveNotifyDataChangeCallBack()
	end
	if self.foot_view then
		self.foot_view:RemoveNotifyDataChangeCallBack()
	end

	if self.fight_mount_view then
		self.fight_mount_view:RemoveNotifyDataChangeCallBack()
	end
	if self.cloak_view then
		self.cloak_view:RemoveNotifyDataChangeCallBack()
	end
	if self.data_listen ~= nil then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end
	self.notips = false

	if self.show_scene_mask then
		self.show_scene_mask:SetValue(true)
	end

	if self.time_quest ~= nil then
		GlobalEventSystem:UnBind(self.time_quest)
		self.time_quest = nil
	end
	if TipsCtrl.Instance:GetBiPingView() then
		TipsCtrl.Instance:GetBiPingView():Close()
	end
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
	Scene.Instance:GetMainRole():FixMeshRendererBug()
end

function AdvanceView:OpenCallBack()
	self.time_quest = GlobalEventSystem:Bind(OtherEventType.PASS_DAY, BindTool.Bind(self.SetBiPinIcon, self))

	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end

	-- 监听系统事件
	if self.data_listen == nil then
		self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
		PlayerData.Instance:ListenerAttrChange(self.data_listen)
	end
		-- 首次刷新数据
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])
	self.notips = true
	self:InitTab()
	self:SetBiPinIcon()

	--开始引导
	FunctionGuide.Instance:TriggerGuideByName("mount_up")
	FunctionGuide.Instance:TriggerGuideByName("wing_up")
end

function AdvanceView:ItemDataChangeCallback()
	self.show_red_point_list[1]:SetValue(AdvanceData.Instance:IsShowMountRedPoint())
	self.show_red_point_list[2]:SetValue(AdvanceData.Instance:IsShowWingRedPoint())
	self.show_red_point_list[3]:SetValue(AdvanceData.Instance:IsShowHaloRedPoint())
	self.show_red_point_list[4]:SetValue(AdvanceData.Instance:IsShowFightMountRedPoint())
	self.show_red_point_list[5]:SetValue(ShenBingData.Instance:GetRemind() == 1)
	self.show_red_point_list[6]:SetValue(AdvanceData.Instance:IsShowFootRedPoint())
	self.show_red_point_list[7]:SetValue(AdvanceData.Instance:IsShowCloakRedPoint())
	self.show_red_point_list[8]:SetValue(AdvanceData.Instance:IsShowLingChongRed())
	if self.view_state == MOUNT and self.mount_view then
		self.mount_view:ItemDataChangeCallback()
	elseif self.view_state == WING and self.wing_view then
		self.wing_view:ItemDataChangeCallback()
	elseif self.view_state == HALO and self.halo_view then
		self.halo_view:ItemDataChangeCallback()
	elseif self.view_state == FOOT and self.foot_view then
		self.foot_view:ItemDataChangeCallback()
	elseif self.view_state == FIGHT_MOUNT and self.fight_mount_view then
		self.fight_mount_view:ItemDataChangeCallback()-- or self.shenyi_view.is_auto
	elseif self.view_state == CLOAK and self.cloak_view then
		self.cloak_view:ItemDataChangeCallback()
	elseif self.view_state == LINGCHONG then
		self:Flush("lingchong_item_change")
	end
end

function AdvanceView:OnFlush(param_list)
	local cur_index = self:GetShowIndex()
	if cur_index == TabIndex.mount_jinjie then
		self.bipingredpoint:SetValue(KaiFuDegreeRewardsData.Instance:GetMountDegreeRemind() == 1)
	elseif cur_index == TabIndex.wing_jinjie then
		self.bipingredpoint:SetValue(KaiFuDegreeRewardsData.Instance:GetWingDegreeRemind() == 1)
	elseif cur_index == TabIndex.halo_jinjie then
		self.bipingredpoint:SetValue(KaiFuDegreeRewardsData.Instance:GetHaloDegreeRemind() == 1)
	elseif cur_index == TabIndex.foot_jinjie then
		self.bipingredpoint:SetValue(KaiFuDegreeRewardsData.Instance:GetFootDegreeRemind() == 1)
	elseif cur_index == TabIndex.fight_mount then
		self.bipingredpoint:SetValue(KaiFuDegreeRewardsData.Instance:GetFightMountDegreeRemind() == 1)
	end
	for k, v in pairs(param_list) do
		if cur_index == TabIndex.role_bag then
			self.notips = true
		end

		if k == "mount" then
			if self.mount_view and self.tab_mount.toggle.isOn then
				self.mount_view:OnFlush(param_list)
			end
			self.show_red_point_list[1]:SetValue(AdvanceData.Instance:IsShowMountRedPoint())
			RemindManager.Instance:Fire(RemindName.Advance)
		elseif k == "wing" then
			if self.wing_view and self.tab_wing.toggle.isOn then
				self.wing_view:OnFlush(param_list)
			end
			self.show_red_point_list[2]:SetValue(AdvanceData.Instance:IsShowWingRedPoint())
			RemindManager.Instance:Fire(RemindName.Advance)
		elseif k == "halo" then
			if self.halo_view and self.tab_halo.toggle.isOn then
				self.halo_view:OnFlush(param_list)
			end
			self.show_red_point_list[3]:SetValue(AdvanceData.Instance:IsShowHaloRedPoint())
			RemindManager.Instance:Fire(RemindName.Advance)
		elseif k == "foot" then
			if self.foot_view and self.tab_foot.toggle.isOn then
				self.foot_view:OnFlush(param_list)
			end
			self.show_red_point_list[6]:SetValue(AdvanceData.Instance:IsShowFootRedPoint())
			RemindManager.Instance:Fire(RemindName.Advance)
		elseif k == "fightmount" then
			if self.fight_mount_view and self.tab_fight_mount.toggle.isOn then
				self.fight_mount_view:OnFlush(param_list)
			end
			self.show_red_point_list[4]:SetValue(AdvanceData.Instance:IsShowFightMountRedPoint())
			RemindManager.Instance:Fire(RemindName.Advance)
		elseif k == "shenbing" then
			if self.shenbing_view and self.toggle_shenbing.toggle.isOn then
				self.shenbing_view:Flush()
			end
			self.show_red_point_list[5]:SetValue(ShenBingData.Instance:GetRemind() == 1)
			RemindManager.Instance:Fire(RemindName.Advance)
			if true == v.flag and self.shenbing_view then
				self.shenbing_view:PlayUpStarEffect()
			end
		elseif k == "cloak" then
			if self.cloak_view and self.tab_cloak.toggle.isOn then
				self.cloak_view:Flush("cloak")
			end
			self.show_red_point_list[7]:SetValue(CloakData.Instance:GetRemind() == 1)
			RemindManager.Instance:Fire(RemindName.Advance)
		elseif k == "upgraderesult" then
			if self.shenbing_view and self.toggle_shenbing.toggle.isOn then
				self.shenbing_view:Flush("upgraderesult", {v[1]})
			end
		elseif k == "lingchong" or k == "lingchong_upgrade" or k == "lingchong_item_change" then
			if self.lingchong_view and self.tab_lingchong.toggle.isOn then
				self.lingchong_view:Flush(k, v)
			end
		elseif k == "all" then
			self.show_red_point_list[1]:SetValue(AdvanceData.Instance:IsShowMountRedPoint())
			self.show_red_point_list[2]:SetValue(AdvanceData.Instance:IsShowWingRedPoint())
			self.show_red_point_list[3]:SetValue(AdvanceData.Instance:IsShowHaloRedPoint())
			self.show_red_point_list[4]:SetValue(AdvanceData.Instance:IsShowFightMountRedPoint())
			self.show_red_point_list[5]:SetValue(ShenBingData.Instance:GetRemind() == 1)
			self.show_red_point_list[6]:SetValue(AdvanceData.Instance:IsShowFootRedPoint())
			self.show_red_point_list[7]:SetValue(AdvanceData.Instance:IsShowCloakRedPoint())
			self.show_red_point_list[8]:SetValue(AdvanceData.Instance:IsShowLingChongRed())
			RemindManager.Instance:Fire(RemindName.Advance)
		end
	end
end

function AdvanceView:SetBiPinIcon()
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

function AdvanceView:InitTab()
	if not self:IsOpen() then return end

	self.tab_mount.transform.parent.gameObject:SetActive(OpenFunData.Instance:CheckIsHide("mount_jinjie") == true)
	self.tab_wing.transform.parent.gameObject:SetActive(OpenFunData.Instance:CheckIsHide("wing_jinjie") == true)
	self.tab_halo.transform.parent.gameObject:SetActive(OpenFunData.Instance:CheckIsHide("halo_jinjie") == true)
	self.tab_foot.transform.parent.gameObject:SetActive(OpenFunData.Instance:CheckIsHide("foot_jinjie") == true)
	self.tab_fight_mount.transform.parent.gameObject:SetActive(OpenFunData.Instance:CheckIsHide("fight_mount") == true)
	self.tab_cloak.transform.parent.gameObject:SetActive(OpenFunData.Instance:CheckIsHide("cloak_jinjie") == true)
	self.toggle_shenbing.transform.parent.gameObject:SetActive(OpenFunData.Instance:CheckIsHide("player_role_shenbing") == true)
	self.tab_lingchong.transform.parent.gameObject:SetActive(OpenFunData.Instance:CheckIsHide("lingchong_jinjie") == true)
end

--引导用函数
function AdvanceView:OnChangeToggle(index)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if index == TabIndex.mount_jinjie then
		self.tab_mount.toggle.isOn = true
	elseif index == TabIndex.wing_jinjie then
		self.tab_wing.toggle.isOn = true
	elseif index == TabIndex.halo_jinjie then
		self.tab_halo.toggle.isOn = true
	elseif index == TabIndex.foot_jinjie then
		self.tab_foot.toggle.isOn = true
	elseif index == TabIndex.fight_mount then
		self.tab_fight_mount.toggle.isOn = true
	elseif index == TabIndex.role_shenbing then
		self.toggle_shenbing.toggle.isOn = true
	elseif index == TabIndex.cloak_jinjie then
		self.tab_cloak.toggle.isOn = true
	end
end

function AdvanceView:OpenRisingStar()
	ViewManager.Instance:Open(ViewName.KiaFuRisingStarView)
end

function AdvanceView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if ui_name == GuideUIName.Tab then
		local index = TabIndex[ui_param]
		if index == self.show_index then
			return NextGuideStepFlag
		end
		if index == TabIndex.mount_jinjie then
			if self.tab_mount.gameObject.activeInHierarchy then
				local callback = BindTool.Bind(self.OnChangeToggle, self, TabIndex.mount_jinjie)
				return self.tab_mount, callback
			end
		elseif index == TabIndex.wing_jinjie then
			if self.tab_wing.gameObject.activeInHierarchy then
				local callback = BindTool.Bind(self.OnChangeToggle, self, TabIndex.wing_jinjie)
				return self.tab_wing, callback
			end
		elseif index == TabIndex.halo_jinjie then
			if self.tab_halo.gameObject.activeInHierarchy then
				local callback = BindTool.Bind(self.OnChangeToggle, self, TabIndex.halo_jinjie)
				return self.tab_halo, callback
			end
		elseif index == TabIndex.foot_jinjie then
			if self.tab_foot.gameObject.activeInHierarchy then
				local callback = BindTool.Bind(self.OnChangeToggle, self, TabIndex.foot_jinjie)
				return self.foot_jinjie, callback
			end
		elseif index == TabIndex.fight_mount then
			if self.tab_fight_mount.gameObject.activeInHierarchy then
				local callback = BindTool.Bind(self.OnChangeToggle, self, TabIndex.fight_mount)
				return self.tab_fight_mount, callback
			end
		elseif index == TabIndex.cloak_jinjie then
			if self.tab_cloak.gameObject.activeInHierarchy then
				local callback = BindTool.Bind(self.OnChangeToggle, self, TabIndex.cloak_jinjie)
				return self.tab_cloak, callback
			end
		end
	elseif self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	end
end