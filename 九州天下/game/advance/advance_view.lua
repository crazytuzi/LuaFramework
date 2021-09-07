AdvanceView = AdvanceView or BaseClass(BaseView)

function AdvanceView:__init()
	self:SetMaskBg()
	self.ui_config = {"uis/views/advanceview", "AdvanceView"}
	-- self.ui_scene = {"scenes/map/uizqdt01", "UIzqdt01"}
	if self.audio_config then
		self.open_audio_id = AssetID("audios/sfxs/uis", self.audio_config.other[1].OpenAdvanced)
	end
	self.def_index = TabIndex.mount_jinjie
	self.play_audio = true
	self.view_state = ViewState.MOUNT
	self.notips = false
	self.open_trigger_handle = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.InitTab, self))
end

function AdvanceView:__delete()
	if self.open_trigger_handle ~= nil then
		GlobalEventSystem:UnBind(self.open_trigger_handle)
		self.open_trigger_handle = nil
	end
end

function AdvanceView:LoadCallBack()
	self:ListenEvent("Close",BindTool.Bind(self.HandleClose, self))
	self:ListenEvent("OpenMount",BindTool.Bind(self.OpenMount, self))
	self:ListenEvent("OpenMultiMount",BindTool.Bind(self.OpenMultiMount, self))
	self:ListenEvent("OpenWing",BindTool.Bind(self.OpenWing, self))
	self:ListenEvent("OpenHalo",BindTool.Bind(self.OpenHalo, self))
	self:ListenEvent("OpenFightMount",BindTool.Bind(self.OpenFightMount, self))
	self:ListenEvent("OpenBeautyHalo",BindTool.Bind(self.OpenBeautyHalo, self))
	self:ListenEvent("OpenHalidom",BindTool.Bind(self.OpenHalidom, self))
	self:ListenEvent("OpenFootMark",BindTool.Bind(self.OpenFootMark, self))
	self:ListenEvent("OpenMantle",BindTool.Bind(self.OpenMantle, self))
	self:ListenEvent("AddGold",BindTool.Bind(self.HandleAddGold, self))

	self.right_bar = self:FindObj("RightBar")
	self.tab_mount = self:FindObj("TabMount")
	self.tab_multi_mount = self:FindObj("TabMultiMount")
	self.tab_wing = self:FindObj("TabWing")
	self.tab_halo = self:FindObj("TabHalo")
	-- self.tab_haushen_protect = self:FindObj("TabHuaShenProtect")
	self.tab_fight_mount = self:FindObj("TabFightMount")
	self.tab_beauty_halo = self:FindObj("TabBeautyHalo")
	self.tab_halidom = self:FindObj("TabHalidom")
	self.tab_footmark = self:FindObj("TabFootMark")
	self.tab_mantle = self:FindObj("TabMantle")

	self.rotate_event_trigger = self:FindObj("RotateEventTrigger")
	local event_trigger = self.rotate_event_trigger:GetComponent(typeof(EventTriggerListener))
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDrag, self))

	self.gold = self:FindVariable("Gold")
	self.bind_gold = self:FindVariable("bind_gold")
	self.show_scene_mask = self:FindVariable("ShowBlueBg")
	self.show_red_point_list = {}
	for i = 1, ViewState.MAX do
		self.show_red_point_list[i] = self:FindVariable("ShowRedPoint"..i)
	end
	-- self.show_top_haushen_red_point = self:FindVariable("ShowSecondHuashenRedPoint")
	-- self.show_huashen_protect_red_point = self:FindVariable("ShowHuashenProtectRedPoint")

	self.mount_content = self:FindObj("MountContent")
	self.mount_view = AdvanceMountView.New()
	self.mount_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		--引导用按钮
		self.mount_view:SetInstance(obj)
		self.mount_start_up = self.mount_view.start_button
		self.mount_view:SetNotifyDataChangeCallBack()
	end)

	self.multi_mount_content = self:FindObj("MultiMountContent")
	self.multi_mount_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.multi_mount_view = AdvanceMultiMountView.New(obj)
		--引导用按钮
		--self.multi_mount_content = self.multi_mount_content.start_button
		self.multi_mount_view:SetNotifyDataChangeCallBack()
	end)

	self.wing_content = self:FindObj("WingContent")
	self.wing_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.wing_view = AdvanceWingView.New(obj)
		--引导用按钮
		self.wing_start_up = self.wing_view.start_button
		self.wing_view:SetNotifyDataChangeCallBack()
	end)


	self.halo_content = self:FindObj("HaloContent")
	self.halo_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.halo_view = AdvanceHaloView.New(obj)
		self.halo_view:SetNotifyDataChangeCallBack()
	end)

	-- self.huashen_and_protect_content = self:FindObj("HuaShenAndProtectContent")

	-- self.huashen_content = self:FindObj("HuaShenContent")
	-- self.huashen_view = AdvanceHuashenView.New(self.huashen_content)

	-- self.huashen_protect_content = self:FindObj("HuaShenProtectContent")
	-- self.huashen_protect_view = AdvanceHuashenProtectView.New(self.huashen_protect_content)

	self.fight_mount_content = self:FindObj("FightMountContent")
	self.fight_mount_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.fazhen_view = AdvanceFaZhenView.New(obj)
		self.fazhen_view:SetNotifyDataChangeCallBack()
	end)

	self.beauty_halo_content = self:FindObj("BeautyHaloContent")
	self.beauty_halo_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.beauty_halo_view = AdvanceBeautyHaloView.New(obj)
		self.beauty_halo_view:SetNotifyDataChangeCallBack()
	end)

	self.halidom_content = self:FindObj("HalidomContent")
	self.halidom_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.halidom_view = AdvanceHalidomView.New(obj)
		self.halidom_view:SetNotifyDataChangeCallBack()
	end)

	self.footmark_content = self:FindObj("FootMarkContent")
	self.footmark_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.footmark_view = AdvanceShengongView.New(obj)
		self.footmark_view:SetNotifyDataChangeCallBack()
	end)

	self.mantle_content = self:FindObj("MantleContent")
	self.mantle_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.mantle_view = AdvanceShenyiView.New(obj)
		self.mantle_view:SetNotifyDataChangeCallBack()
	end)


	self.money_bar = MoneyBar.New()
	self.money_bar:SetInstanceParent(self:FindObj("MoneyBar"))
	self:InitTab()
	self.btn_close = self:FindObj("BtnClose")

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

	if self.mount_view ~= nil then
		self.mount_view:DeleteMe()
		self.mount_view = nil
	end

	if self.multi_mount_view ~= nil then
		self.multi_mount_view:DeleteMe()
		self.multi_mount_view = nil
	end

	if self.wing_view ~= nil then
		self.wing_view:DeleteMe()
		self.wing_view = nil
	end

	if self.halo_view ~= nil then
		self.halo_view:DeleteMe()
		self.halo_view = nil
	end
	
	if self.footmark_view ~= nil then
		self.footmark_view:DeleteMe()
		self.footmark_view = nil
	end

	if self.halidom_view ~= nil then
		self.halidom_view:DeleteMe()
		self.halidom_view = nil
	end

	if self.mantle_view ~= nil then
		self.mantle_view:DeleteMe()
		self.mantle_view = nil
	end

	if self.fazhen_view ~= nil then
		self.fazhen_view:DeleteMe()
		self.fazhen_view = nil
	end

	if self.beauty_halo_view ~= nil then
		self.beauty_halo_view:DeleteMe()
		self.beauty_halo_view = nil
	end

	if self.money_bar then
		self.money_bar:DeleteMe()
		self.money_bar = nil
	end

	self.right_bar = nil
	self.tab_mount = nil
	self.tab_multi_mount = nil
	self.tab_wing = nil
	self.tab_halo = nil
	self.tab_fight_mount = nil
	self.tab_beauty_halo = nil
	self.tab_halidom = nil
	self.tab_footmark = nil
	self.tab_mantle = nil
	self.rotate_event_trigger = nil
	self.gold = nil
	self.bind_gold = nil
	self.show_scene_mask = nil
	self.show_red_point_list = {}
	self.btn_close = nil

	self.mount_content = nil
	self.wing_content = nil
	self.halo_content = nil
	self.fight_mount_content = nil
	self.beauty_halo_content = nil
	self.halidom_content = nil
	self.footmark_content = nil
	self.mantle_content = nil
	self.mount_start_up = nil
	self.wing_start_up = nil
	self.multi_mount_content = nil
end

function AdvanceView:OnRoleDrag(data)
	if UIScene.role_model then
		-- UIScene:Rotate(0, -data.delta.x * 0.25, 0)
	end
end

function AdvanceView:HandleClose()
	self:Close()
end

function AdvanceView:OnHuashenUpgradeResult(result)
	-- self.huashen_view:OnHuashenUpgradeResult(result)
end

function AdvanceView:OnSpiritUpgradeResult(result)
	-- self.huashen_protect_view:OnSpiritUpgradeResult(result)
end

function AdvanceView:OnFightMountUpgradeResult(result)
	if self.fazhen_view then
		self.fazhen_view:OnFightMountUpgradeResult(result)
	end
end

function AdvanceView:MountUpgradeResult(result)
	if self.mount_view then
		self.mount_view:MountUpgradeResult(result)
	end
end

function AdvanceView:MultiMountUpGradeResult(result)
	if self.multi_mount_view then
		self.multi_mount_view:MultiMountUpGradeResult(result)
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

function AdvanceView:ShengongUpGradeResult(result)
	if self.footmark_view then
		self.footmark_view:ShengongUpGradeResult(result)
	end
end

function AdvanceView:ShenyiUpGradeResult(result)
	if self.mantle_view then
		self.mantle_view:ShenyiUpGradeResult(result)
	end
end

function AdvanceView:HalidomUpGradeResult(result)
	if self.halidom_view then
		self.halidom_view:SetHalidomUppGradeOptResult(result)
	end
end

-- 美人光环进阶结果返回
function AdvanceView:BeautyHaloUppGradeOptResult(result)
	self.beauty_halo_view:SetBeautyHaloUppGradeOptResult(result)
end

function AdvanceView:OpenMount()
	if self.view_state == ViewState.MOUNT then
		return
	end
	self:ShowIndex(TabIndex.mount_jinjie)
	self:StopAutoAdvance(ViewState.MOUNT)
	self:ShowContent(ViewState.MOUNT)
	self:SetToggleHighLight(self.view_state)
	if self.mount_view then
		self.mount_view:ResetModleRotation()
	end
end

function AdvanceView:OpenMultiMount()
	if self.view_state == ViewState.MULTI_MOUNT then
		return
	end
	self:ShowIndex(TabIndex.multi_mount_jinjie)
	self:StopAutoAdvance(ViewState.MULTI_MOUNT)
	self:ShowContent(ViewState.MULTI_MOUNT)
	self:SetToggleHighLight(self.view_state)
	-- if self.multi_mount_view then
	-- 	self.multi_mount_view:ResetModleRotation()
	-- end
end

function AdvanceView:OpenWing()
	if self.view_state == ViewState.WING then
		return
	end
	self:ShowIndex(TabIndex.wing_jinjie)
	self:StopAutoAdvance(ViewState.WING)
	self:ShowContent(ViewState.WING)
	self:SetToggleHighLight(self.view_state)
	if self.wing_view then
		self.wing_view:ResetModleRotation()
	end
end

function AdvanceView:OpenHalo()
	if self.view_state == ViewState.HALO then
		return
	end
	self:ShowIndex(TabIndex.halo_jinjie)
	self:StopAutoAdvance(ViewState.HALO)
	self:ShowContent(ViewState.HALO)
	self:SetToggleHighLight(self.view_state)
	if self.halo_view then
		self.halo_view:ResetModleRotation()
	end
end

function AdvanceView:OpenFootMark()
	if self.view_state == ViewState.FOOTMARK then
		return
	end
	self:ShowIndex(TabIndex.shengong_jinjie)
	self:StopAutoAdvance(ViewState.FOOTMARK)
	self:ShowContent(ViewState.FOOTMARK)
	self:SetToggleHighLight(self.view_state)
end

function AdvanceView:OpenMantle()
	if self.view_state == ViewState.MANTLE then
		return
	end
	self:ShowIndex(TabIndex.shenyi_jinjie)
	self:StopAutoAdvance(ViewState.MANTLE)
	self:ShowContent(ViewState.MANTLE)
	self:SetToggleHighLight(self.view_state)
end

-- 美人光环
function AdvanceView:OpenBeautyHalo()
	if self.view_state == ViewState.HUASHEN then
		return
	end
	self:ShowIndex(TabIndex.meiren_guanghuan)
	self:StopAutoAdvance(ViewState.HUASHEN)
	self:ShowContent(ViewState.HUASHEN)
	self:SetToggleHighLight(self.view_state)
end

-- 圣物
function AdvanceView:OpenHalidom()
	if self.view_state == ViewState.HALIDOM then
		return
	end
	self:ShowIndex(TabIndex.halidom_jinjie)
	self:StopAutoAdvance(ViewState.HALIDOM)
	self:ShowContent(ViewState.HALIDOM)
	self:SetToggleHighLight(self.view_state)
end

-- -- 点击化神守护
-- function AdvanceView:OpenHuaShenProtect()
-- 	self:StopAutoAdvance(HUASHEN_PROTECT)
-- 	self:ShowContent(HUASHEN_PROTECT)
-- 	self:SetToggleHighLight(self.view_state)
-- 	self.huashen_protect_view:SetNotifyDataChangeCallBack()
-- end

function AdvanceView:OpenFightMount()
	if self.view_state == ViewState.FIGHT_MOUNT then
		return
	end
	self:ShowIndex(TabIndex.fight_mount)
	self:StopAutoAdvance(ViewState.FIGHT_MOUNT)
	self:ShowContent(ViewState.FIGHT_MOUNT)
	self:SetToggleHighLight(self.view_state)
end

-- function AdvanceView:Open(index)
-- 	BaseView.Open(self, index)

-- end

function AdvanceView:ShowIndexCallBack(index)
	local scene_load_callback = function()
		if self.show_scene_mask then
			self.show_scene_mask:SetValue(false)
		end
	end
	-- UIScene:SetUISceneLoadCallBack(scene_load_callback)

	if self.mount_view then
		self.mount_view:ClearTempData()
	end

	if self.multi_mount_view then
		self.multi_mount_view:ClearTempData()
	end

	if self.wing_view then
		self.wing_view:ClearTempData()
	end

	if self.halo_view then
		self.halo_view:ClearTempData()
	end
	
	if self.fazhen_view then
		self.fazhen_view:ClearTempData()
	end

	self:Flush()
	if index == TabIndex.mount_jinjie then
		local callback = function()
			if self.mount_view then
				self.mount_view:Flush("mount")
			end
		end
		if self.mount_view then
			self.mount_view:OpenCallBack()
		end
		-- UIScene:ChangeScene(self, self.ui_scene, {[1] = {"Pingtai01", true}}, callback)
	elseif index == TabIndex.multi_mount_jinjie then
		local callback = function()
			if self.multi_mount_view then
				self.multi_mount_view:Flush("multi_mount")
			end
		end
		if self.multi_mount_view then
			self.multi_mount_view:OpenCallBack()
		end

	elseif index == TabIndex.wing_jinjie then
		local callback = function()
			if self.wing_view then
				self.wing_view:Flush("wing")
			end
		end
		if self.wing_view then
			self.wing_view:OpenCallBack()
		end
		-- UIScene:ChangeScene(self, self.ui_scene, {[1] = {"Pingtai01", true}}, callback)
	elseif index == TabIndex.halo_jinjie then
		local callback = function()
			if self.halo_view then
				self.halo_view:Flush("halo")
			end
		end
		if self.halo_view then
			self.halo_view:OpenCallBack()
		end
		-- UIScene:ChangeScene(self, self.ui_scene, {[1] = {"Pingtai01"}})
	elseif index == TabIndex.fight_mount then
		local callback = function()
			if self.fazhen_view then
				self.fazhen_view:Flush("fazhen")
			end
		end
		if self.fazhen_view then
			self.fazhen_view:OpenCallBack()
		end
		-- UIScene:ChangeScene(self, self.ui_scene, {[1] = {"Pingtai01", true}}, callback)
	elseif index == TabIndex.meiren_guanghuan then
		local callback = function()
			if self.beauty_halo_view then
				self.beauty_halo_view:Flush()
			end
		end
		if self.beauty_halo_view then
			self.beauty_halo_view:OpenCallBack()
		end
		-- UIScene:ChangeScene(self, self.ui_scene, {[1] = {"Pingtai01", true}}, callback)
	elseif index == TabIndex.halidom_jinjie then
		local callback = function()
			if self.halidom_view then
				self.halidom_view:Flush()
			end
		end
		if self.halidom_view then
			self.halidom_view:OpenCallBack()
		end
		-- UIScene:ChangeScene(self, self.ui_scene, {[1] = {"Pingtai01"}})
	elseif index == TabIndex.shengong_jinjie then
		local callback = function()
			if self.footmark_view then
				self.footmark_view:Flush()
			end
		end
		if self.footmark_view then
			self.footmark_view:OpenCallBack()
		end
		-- UIScene:ChangeScene(self, self.ui_scene)
		-- UIScene:ChangeScene(self, self.ui_scene, {[1] = {"Pingtai01"}})
	elseif index == TabIndex.shenyi_jinjie then
		local callback = function()
			if self.mantle_view then
				self.mantle_view:Flush()
			end
		end
		if self.mantle_view then
			self.mantle_view:OpenCallBack()
		end
		-- UIScene:ChangeScene(self, self.ui_scene, {[1] = {"Pingtai01"}})
	end
end

function AdvanceView:HandleAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function AdvanceView:PlayerDataChangeCallback(attr_name, value, old_value)
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
	end
	if attr_name == "bind_gold" then
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

function AdvanceView:FlushSonView()
	if self.view_state == ViewState.MOUNT then
		if self.mount_view then
			self.mount_view:Flush("mount")
		end
	elseif self.view_state == ViewState.WING then
		if self.wing_view then
			self.wing_view:Flush("wing")
		end
	elseif self.view_state == ViewState.HALO then
		if self.halo_view then
			self.halo_view:Flush("halo")
		end
	--elseif self.view_state == HUASHEN_PROTECT then
		-- self.huashen_protect_view:Flush("huashenprotect")
	elseif self.view_state == ViewState.FIGHT_MOUNT then
		if self.fazhen_view then
			self.fazhen_view:Flush("fazhen")
		end
	elseif self.view_state == ViewState.HUASHEN then
		if self.beauty_halo_view then
			self.beauty_halo_view:Flush()
		end
	elseif self.view_state == ViewState.HALIDOM then
		if self.halidom_view then
			self.halidom_view:Flush()
		end
	elseif self.view_state == ViewState.FOOTMARK then
		if self.footmark_view then
			self.footmark_view:Flush()
		end
	elseif self.view_state == ViewState.MANTLE then
		if self.mantle_view then
			self.mantle_view:Flush()
		end
	end
end

function AdvanceView:ShowContent(id)
	self.view_state = id
	self.mount_content:SetActive(id == ViewState.MOUNT)
	self.multi_mount_content:SetActive(id == ViewState.MULTI_MOUNT)
	self.wing_content:SetActive(id == ViewState.WING)
	self.halo_content:SetActive(id == ViewState.HALO)
	-- self.huashen_and_protect_content:SetActive(id == ViewState.HUASHEN or id == HUASHEN_PROTECT)
	self.beauty_halo_content:SetActive(id == ViewState.HUASHEN)
	self.halidom_content:SetActive(id == ViewState.HALIDOM)
	self.fight_mount_content:SetActive(id == ViewState.FIGHT_MOUNT)
	self.footmark_content:SetActive(id == ViewState.FOOTMARK)
	self.mantle_content:SetActive(id == ViewState.MANTLE)
	
	if id > ViewState.HALIDOM and id ~= ViewState.MULTI_MOUNT then
		self.right_bar:GetComponent(typeof(UnityEngine.UI.ScrollRect)).normalizedPosition = Vector2(0, 0)
	end

	if id == ViewState.MOUNT then
		if self.mount_view then
			self.mount_view:Flush("mount")
		end
	elseif id == ViewState.MULTI_MOUNT then
		if self.multi_mount_view then
			self.multi_mount_view:Flush("multi_mount")
		end
	elseif id == ViewState.WING then
		if self.wing_view then
			self.wing_view:Flush("wing")
		end
	elseif id == ViewState.HALO then
		if self.halo_view then
			self.halo_view:Flush("halo")
		end
	elseif id == ViewState.HALIDOM then
		if self.halidom_view then
			self.halidom_view:Flush()
		end
	elseif id == ViewState.FIGHT_MOUNT then
		if self.fazhen_view then
			self.fazhen_view:Flush("fazhen")
		end
	elseif id == ViewState.HUASHEN then
		if self.beauty_halo_view then
			self.beauty_halo_view:Flush()
		end
	elseif id == ViewState.FOOTMARK then
		if self.footmark_view then
			self.footmark_view:Flush()
		end
	elseif id == ViewState.MANTLE then
		if self.mantle_view then
			self.mantle_view:Flush()
		end
	end
end

function AdvanceView:SetToggleHighLight(id)
	self.tab_mount.toggle.isOn = ViewState.MOUNT == id
	self.tab_multi_mount.toggle.isOn = ViewState.MULTI_MOUNT == id
	self.tab_wing.toggle.isOn = ViewState.WING == id
	self.tab_halo.toggle.isOn = ViewState.HALO == id
	self.tab_beauty_halo.toggle.isOn = ViewState.HUASHEN == id
	self.tab_halidom.toggle.isOn = ViewState.HALIDOM == id
	self.tab_fight_mount.toggle.isOn = ViewState.FIGHT_MOUNT == id
	self.tab_footmark.toggle.isOn = ViewState.FOOTMARK == id
	self.tab_mantle.toggle.isOn = ViewState.MANTLE == id

	if self.mount_view then
		self.mount_view:SetModle(ViewState.MOUNT == id)
	end
	-- if self.multi_mount_view then
	-- 	self.multi_mount_view:SetModle(ViewState.MULTI_MOUNT == id)
	-- end
	if self.wing_view then
		self.wing_view:SetModle(ViewState.WING == id)
	end
	if self.halo_view then
		self.halo_view:SetModle(ViewState.HALO == id)
	end
	-- self.huashen_protect_view:SetModle(HUASHEN_PROTECT == id)
	if self.fazhen_view then
		self.fazhen_view:SetModle(ViewState.FIGHT_MOUNT == id)
	end
	if self.beauty_halo_view then
		self.beauty_halo_view:SetModle(ViewState.HUASHEN == id)
	end
	if self.halidom_view then
		self.halidom_view:SetModle(ViewState.HALIDOM == id)
	end
	if self.footmark_view and ViewState.FOOTMARK == id then
		self.footmark_view:Flush()
	end
	if self.mantle_view then
		self.mantle_view:SetModle(ViewState.MANTLE == id)
	end
end

function AdvanceView:StopAutoAdvance(id)
	if (self.mount_view and self.mount_view.is_auto) or (self.wing_view and self.wing_view.is_auto) or
		(self.halo_view and self.halo_view.is_auto) or (self.fazhen_view and self.fazhen_view.is_auto) or
		(self.footmark_view and self.footmark_view.is_auto) or (self.mantle_view and self.mantle_view.is_auto) or 
		(self.beauty_halo_view and self.beauty_halo_view.is_auto) or (self.multi_mount_view and self.multi_mount_view.is_auto) then
		if self.view_state ~= id then
			if self.view_state == ViewState.MOUNT then
				self.mount_view:OnAutomaticAdvance()
			elseif self.view_state == ViewState.MULTI_MOUNT then
				self.multi_mount_view:OnAutomaticAdvance()
			elseif self.view_state == ViewState.WING then
				self.wing_view:OnAutomaticAdvance()
			elseif self.view_state == ViewState.HALO then
				self.halo_view:OnAutomaticAdvance()
			elseif self.view_state == ViewState.FIGHT_MOUNT then
				self.fazhen_view:OnAutomaticAdvance()-- or self.shenyi_view.is_auto
			elseif self.view_state == ViewState.HUASHEN then
				self.beauty_halo_view:OnAutomaticAdvance()
			elseif self.view_state == ViewState.FOOTMARK then
				self.footmark_view:OnAutomaticAdvance()
			elseif self.view_state == ViewState.MANTLE then
				self.mantle_view:OnAutomaticAdvance()
			end
		end
	end
end

function AdvanceView:CloseCallBack()
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
	self:StopAutoAdvance()
	-- if self.mount_view then
	-- 	self.mount_view:RemoveNotifyDataChangeCallBack()
	-- end
	-- if self.wing_view then
	-- 	self.wing_view:RemoveNotifyDataChangeCallBack()
	-- end
	-- if self.halo_view then
	-- 	self.halo_view:RemoveNotifyDataChangeCallBack()
	-- end
	-- self.huashen_view:RemoveNotifyDataChangeCallBack()
	-- self.huashen_protect_view:RemoveNotifyDataChangeCallBack()
	-- if self.fazhen_view then
	-- 	self.fazhen_view:RemoveNotifyDataChangeCallBack()
	-- end
	-- if self.beauty_halo_view then
	-- 	self.beauty_halo_view:RemoveNotifyDataChangeCallBack()
	-- end
	-- if self.footmark_view then
	-- 	self.footmark_view:RemoveNotifyDataChangeCallBack()
	-- end
	-- if self.mantle_view then
	-- 	self.mantle_view:RemoveNotifyDataChangeCallBack()
	-- end
	-- if self.halidom_view then
	-- 	self.halidom_view:RemoveNotifyDataChangeCallBack()
	-- end
	if self.data_listen ~= nil then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end
	self.notips = false
	-- UIScene:DeleteModel()
	if self.show_scene_mask then
		self.show_scene_mask:SetValue(true)
	end
end

function AdvanceView:OpenCallBack()
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end

	-- if self.mount_view then
	-- 	self.mount_view:SetNotifyDataChangeCallBack()
	-- end
	-- if self.wing_view then
	-- 	self.wing_view:SetNotifyDataChangeCallBack()
	-- end
	-- if self.halo_view then
	-- 	self.halo_view:SetNotifyDataChangeCallBack()
	-- end
	-- -- self.huashen_view:SetNotifyDataChangeCallBack()
	-- if self.fazhen_view then
	-- 	self.fazhen_view:SetNotifyDataChangeCallBack()
	-- end
	-- if self.beauty_halo_view then
	-- 	self.beauty_halo_view:SetNotifyDataChangeCallBack()
	-- end
	-- if self.footmark_view then
	-- 	self.footmark_view:SetNotifyDataChangeCallBack()
	-- end
	-- if self.mantle_view then
	-- 	self.mantle_view:SetNotifyDataChangeCallBack()
	-- end
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
end

function AdvanceView:ItemDataChangeCallback()
	self.show_red_point_list[1]:SetValue(AdvanceData.Instance:IsShowMountRedPoint())
	self.show_red_point_list[2]:SetValue(AdvanceData.Instance:IsShowWingRedPoint())
	self.show_red_point_list[3]:SetValue(AdvanceData.Instance:IsShowHaloRedPoint())
	self.show_red_point_list[4]:SetValue(AdvanceData.Instance:IsShowFightMountRedPoint())
	self.show_red_point_list[5]:SetValue(AdvanceData.Instance:IsShowBeautyHaloRedPoint())
	self.show_red_point_list[6]:SetValue(AdvanceData.Instance:IsShowHalidomRedPoint())
	self.show_red_point_list[7]:SetValue(AdvanceData.Instance:IsShowFootRedPoint())
	self.show_red_point_list[8]:SetValue(AdvanceData.Instance:IsShowMantleRedPoint())
	self.show_red_point_list[9]:SetValue(AdvanceData.Instance:IsShowMultiMountRedPoint())
	-- for k,v in pairs(self.show_red_point_list) do
	-- 	v:SetValue(AdvanceData.Instance:GetIsShowRed(k))
	-- end
	self:Flush()
end

function AdvanceView:OnFlush(param_list)
	local cur_index = self:GetShowIndex()
	for k, v in pairs(param_list) do
		if cur_index == TabIndex.role_bag then
			self.notips = true
		end

		if k == "mount" then
			if self.mount_view and self.tab_mount.toggle.isOn then
				self.mount_view:Flush(k)
			end
			self.show_red_point_list[1]:SetValue(AdvanceData.Instance:IsShowMountRedPoint())
			-- MainUICtrl.Instance:ChangeRedPoint(MainUIData.RemindingName.Advance, AdvanceData.Instance:GetCanUplevel()
			-- 	or AdvanceData.Instance:IsShowRedPoint())
			--RemindManager.Instance:Fire(RemindName.Advance)
			RemindManager.Instance:Fire(RemindName.AdvanceMount)
		elseif k == "multi_mount" then
			if self.multi_mount_view and self.tab_multi_mount.toggle.isOn then
				self.multi_mount_view:Flush(k)
			end
			self.show_red_point_list[9]:SetValue(AdvanceData.Instance:IsShowMultiMountRedPoint())
			--self.show_red_point_list[1]:SetValue(AdvanceData.Instance:IsShowMountRedPoint())
			-- MainUICtrl.Instance:ChangeRedPoint(MainUIData.RemindingName.Advance, AdvanceData.Instance:GetCanUplevel()
			-- 	or AdvanceData.Instance:IsShowRedPoint())
			--RemindManager.Instance:Fire(RemindName.Advance)
			--RemindManager.Instance:Fire(RemindName.AdvanceMount)
		elseif k == "wing" then
			if self.wing_view and self.tab_wing.toggle.isOn then
				self.wing_view:Flush()
			end
			self.show_red_point_list[2]:SetValue(AdvanceData.Instance:IsShowWingRedPoint())
			--RemindManager.Instance:Fire(RemindName.Advance)
			-- MainUICtrl.Instance:ChangeRedPoint(MainUIData.RemindingName.Advance, AdvanceData.Instance:GetCanUplevel()
			-- 	or AdvanceData.Instance:IsShowRedPoint())
			RemindManager.Instance:Fire(RemindName.AdvanceWing)
		elseif k == "halo" then
			if self.halo_view and self.tab_halo.toggle.isOn then
				self.halo_view:OnFlush(param_list)
			end
			self.show_red_point_list[3]:SetValue(AdvanceData.Instance:IsShowHaloRedPoint())
			--RemindManager.Instance:Fire(RemindName.Advance)

			-- MainUICtrl.Instance:ChangeRedPoint(MainUIData.RemindingName.Advance, AdvanceData.Instance:GetCanUplevel()
			-- 	or AdvanceData.Instance:IsShowRedPoint())
			RemindManager.Instance:Fire(RemindName.AdvanceHalo)
		elseif k == "meiren_guanghuan" then
			if self.beauty_halo_view and self.tab_beauty_halo.toggle.isOn then
				self.beauty_halo_view:Flush()
			end
			self.show_red_point_list[5]:SetValue(AdvanceData.Instance:IsShowBeautyHaloRedPoint())
			-- self.show_top_haushen_red_point:SetValue(AdvanceData.Instance:IsShowTopHuashenRedPoint())
		elseif k == "halidom" then
			if self.halidom_view and self.tab_halidom.toggle.isOn then
				self.halidom_view:Flush()
			end
			self.show_red_point_list[6]:SetValue(AdvanceData.Instance:IsShowHalidomRedPoint())
			-- self.show_huashen_protect_red_point:SetValue(AdvanceData.Instance:IsShowHuaShenProtectRedPoint())
		elseif k == "fazhen" then
			if self.fazhen_view and self.tab_fight_mount.toggle.isOn then
				self.fazhen_view:Flush(k)
			end
			self.show_red_point_list[4]:SetValue(AdvanceData.Instance:IsShowFightMountRedPoint())
			--RemindManager.Instance:Fire(RemindName.Advance)
			-- self.show_red_point_list[5]:SetValue(AdvanceData.Instance:IsShowHuaShenRedPoint())
			-- MainUICtrl.Instance:ChangeRedPoint(MainUIData.RemindingName.Advance, AdvanceData.Instance:GetCanUplevel()
			-- 	or AdvanceData.Instance:IsShowRedPoint())
		elseif k == "footmark" then
			if self.footmark_view and self.tab_footmark.toggle.isOn then
				self.footmark_view:Flush()
				self.footmark_view:FlushView()
			end
			self.show_red_point_list[7]:SetValue(AdvanceData.Instance:IsShowFootRedPoint())
			-- RemindManager.Instance:Fire(RemindName.Advance)
		elseif k == "mantle" then
			if self.mantle_view and self.tab_mantle.toggle.isOn then
				self.mantle_view:Flush()
				self.mantle_view:FlushView()
			end
			self.show_red_point_list[8]:SetValue(AdvanceData.Instance:IsShowMantleRedPoint())
			-- RemindManager.Instance:Fire(RemindName.Advance)
		elseif k == "all"then
			self.show_red_point_list[1]:SetValue(AdvanceData.Instance:IsShowMountRedPoint())
			self.show_red_point_list[2]:SetValue(AdvanceData.Instance:IsShowWingRedPoint())
			self.show_red_point_list[3]:SetValue(AdvanceData.Instance:IsShowHaloRedPoint())
			--RemindManager.Instance:Fire(RemindName.Advance)
			-- self.show_red_point_list[4]:SetValue(AdvanceData.Instance:IsShowHuaShenRedPoint())
			-- self.show_top_haushen_red_point:SetValue(AdvanceData.Instance:IsShowTopHuashenRedPoint())
			-- self.show_huashen_protect_red_point:SetValue(AdvanceData.Instance:IsShowHuaShenProtectRedPoint())
			self.show_red_point_list[4]:SetValue(AdvanceData.Instance:IsShowFightMountRedPoint())
			-- MainUICtrl.Instance:ChangeRedPoint(MainUIData.RemindingName.Advance, AdvanceData.Instance:GetCanUplevel()
			-- 	or AdvanceData.Instance:IsShowRedPoint())
			self.show_red_point_list[5]:SetValue(AdvanceData.Instance:IsShowBeautyHaloRedPoint())
			self.show_red_point_list[6]:SetValue(AdvanceData.Instance:IsShowHalidomRedPoint())
			self.show_red_point_list[7]:SetValue(AdvanceData.Instance:IsShowFootRedPoint())
			self.show_red_point_list[8]:SetValue(AdvanceData.Instance:IsShowMantleRedPoint())
			self.show_red_point_list[9]:SetValue(AdvanceData.Instance:IsShowMultiMountRedPoint())
			if cur_index == TabIndex.mount_jinjie then
				self:StopAutoAdvance(ViewState.MOUNT)
				self:ShowContent(ViewState.MOUNT)
				self:SetToggleHighLight(self.view_state)
				if self.mount_view then
					self.mount_view:ResetModleRotation()
				end
			elseif cur_index == TabIndex.multi_mount_jinjie then
				self:StopAutoAdvance(ViewState.MULTI_MOUNT)
				self:ShowContent(ViewState.MULTI_MOUNT)
				self:SetToggleHighLight(self.view_state)
				-- if self.multi_mount_view then
				-- 	self.multi_mount_view:ResetModleRotation()
				-- end
			elseif cur_index == TabIndex.wing_jinjie then
				self:OpenWing()
				self:ShowContent(ViewState.WING)
				self:SetToggleHighLight(self.view_state)
			elseif cur_index == TabIndex.halo_jinjie then
				self:OpenHalo()
				self:ShowContent(ViewState.HALO)
				self:SetToggleHighLight(self.view_state)
			elseif cur_index == TabIndex.meiren_guanghuan then
				self:OpenBeautyHalo()
				self:ShowContent(ViewState.HUASHEN)
				self:SetToggleHighLight(self.view_state)
			elseif cur_index == TabIndex.halidom_jinjie then
				self:OpenHalidom()
				self:ShowContent(ViewState.HALIDOM)
				self:SetToggleHighLight(self.view_state)
			elseif cur_index == TabIndex.fight_mount then
				self:OpenFightMount()
				self:ShowContent(ViewState.FIGHT_MOUNT)
				self:SetToggleHighLight(self.view_state)
			elseif cur_index == TabIndex.shengong_jinjie then
				self:OpenFootMark()
				self:ShowContent(ViewState.FOOTMARK)
				self:SetToggleHighLight(self.view_state)
			elseif cur_index == TabIndex.shenyi_jinjie then
				self:OpenMantle()
				self:ShowContent(ViewState.MANTLE)
				self:SetToggleHighLight(self.view_state)
			end
		end
	end
end

function AdvanceView:InitTab()
	if not self:IsOpen() then return end
	local count = 0
	local is_active = true

	if self.tab_mount then
		is_active = OpenFunData.Instance:CheckIsHide("mount_jinjie")
		self.tab_mount:SetActive(is_active)
		count = is_active and count + 1 or count
	end

	if self.tab_wing then
		is_active = OpenFunData.Instance:CheckIsHide("wing_jinjie")
		self.tab_wing:SetActive(is_active)
		count = is_active and count + 1 or count
	end
	if self.tab_halo then
		is_active = OpenFunData.Instance:CheckIsHide("halo_jinjie")
		self.tab_halo:SetActive(is_active)
		count = is_active and count + 1 or count
	end
	
	if self.tab_fight_mount then
		is_active = OpenFunData.Instance:CheckIsHide("fight_mount")
		self.tab_fight_mount:SetActive(is_active)
		count = is_active and count + 1 or count
	end
	
	if self.tab_beauty_halo then
		is_active = OpenFunData.Instance:CheckIsHide("meiren_guanghuan")
		self.tab_beauty_halo:SetActive(is_active)
		count = is_active and count + 1 or count
	end
	
	if self.tab_halidom then
		is_active = OpenFunData.Instance:CheckIsHide("halidom_jinjie")
		self.tab_halidom:SetActive(is_active)
		count = is_active and count + 1 or count
	end

	if self.tab_footmark then
		is_active = OpenFunData.Instance:CheckIsHide("shengong_jinjie")
		self.tab_footmark:SetActive(is_active)
		count = is_active and count + 1 or count
	end
	
	if self.tab_mantle then
		is_active = OpenFunData.Instance:CheckIsHide("shenyi_jinjie")
		self.tab_mantle:SetActive(is_active)
		count = is_active and count + 1 or count
	end

	if self.tab_multi_mount then
		is_active = OpenFunData.Instance:CheckIsHide("multi_mount")
		self.tab_multi_mount:SetActive(is_active)
		count = is_active and count + 1 or count
	end
	
	self.right_bar.scroll_rect.enabled = count > 6 and true or false
end

--引导用函数
function AdvanceView:OnChangeToggle(index)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if index == TabIndex.mount_jinjie then
		self:OpenMount()
		self.tab_mount.toggle.isOn = true
	elseif index == TabIndex.wing_jinjie then
		self:OpenWing()
		self.tab_wing.toggle.isOn = true
	elseif index == TabIndex.halo_jinjie then
		self:OpenHalo()
		self.tab_halo.toggle.isOn = true
	elseif index == TabIndex.fight_mount then
		self:OpenFightMount()
		self.tab_fight_mount.toggle.isOn = true
	end
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
		elseif index == TabIndex.fight_mount then
			if self.tab_fight_mount.gameObject.activeInHierarchy then
				local callback = BindTool.Bind(self.OnChangeToggle, self, TabIndex.fight_mount)
				return self.tab_fight_mount, callback
			end
		end
	elseif self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	end
end