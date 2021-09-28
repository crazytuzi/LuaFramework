require("game/player/player_info_view")
require("game/player/player_package_view")
require("game/player/player_title_view")
require("game/player/player_equip_view")
require("game/player/player_fashion_view")
require("game/player/player_skill_view")
require("game/player/player_zhuansheng_view")
require("game/player/player_shenbing_view")
require("game/player/player_shen_equip_view")
require("game/player/player_tulong_equip_view")
require("game/player/player_reincarnation_view")

local INFO_TOGGLE = 1
local PACK_TOGGLE = 2
local FASHION_TOGGLE = 3
local TITLE_TOGGLE = 4
local SKILL_TOGGLE = 5
local ZHUANSHENG_TOGGLE = 6
local TULONG_TOGGLE = 7
local REINCARNATION_TOGGLE = 8
PlayerView = PlayerView or BaseClass(BaseView)

function PlayerView:__init()
	self.ui_config = {"uis/views/player_prefab","PlayerView"}

	if not IsLowMemSystem then
		self.close_mode = CloseMode.CloseVisible
	end

	self.full_screen = true
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self.def_index = TabIndex.role_intro
	self.role_model = nil
	self.cur_toggle = INFO_TOGGLE
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	self.flush_callback = BindTool.Bind(self.FlushFashion, self)

	self.is_switch_to_shen_equip = false
	self.is_paly_role_ani = false 						--记录是否已经播放过人物动画
	self.hide_wing = false                              --是否隐藏翅膀
end

function PlayerView:__delete()
end

function PlayerView:ReleaseCallBack()
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.Player)
	end

	if FashionCtrl.Instance ~= nil then
		FashionCtrl.Instance:UnNotifyWhenFashionChange(self.flush_callback)
	end

	if nil ~= self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil
	end
	if self.info_view then
		self.info_view:DeleteMe()
		self.info_view = nil
	end
	if self.info_view2 then
		self.info_view2:DeleteMe()
		self.info_view2 = nil
	end

	if self.package_view then
		self.package_view:DeleteMe()
		self.package_view = nil
	end

	if self.shen_equip_view then
		self.shen_equip_view:DeleteMe()
		self.shen_equip_view = nil
	end

	if self.fashion_view then
		self.fashion_view:DeleteMe()
		self.fashion_view = nil
	end

	if self.title_view then
		self.title_view:DeleteMe()
		self.title_view = nil
	end

	if self.equip_view then
		self.equip_view:DeleteMe()
		self.equip_view = nil
	end

	if self.skill_view then
		self.skill_view:DeleteMe()
		self.skill_view = nil
	end

	if self.zhuansheng_view then
		self.zhuansheng_view:DeleteMe()
		self.zhuansheng_view = nil
	end

	if self.tulong_equip_view then
		self.tulong_equip_view:DeleteMe()
		self.tulong_equip_view = nil
	end

	if self.reincarnation_view then
		self.reincarnation_view:DeleteMe()
		self.reincarnation_view = nil
	end

	if nil ~= self.flush_bag_view then
		GlobalEventSystem:UnBind(self.flush_bag_view)
		self.flush_bag_view = nil
	end

	if nil ~= self.open_trigger_handle then
		GlobalEventSystem:UnBind(self.open_trigger_handle)
		self.open_trigger_handle = nil
	end


	if nil ~= self.role_dress_content then
		GlobalEventSystem:UnBind(self.role_dress_content)
		self.role_dress_content = nil
	end

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end

	if nil ~= self.avater_type_event then
		GlobalEventSystem:UnBind(self.avater_type_event)
		self.avater_type_event = nil
	end

	self.ui_title = nil
	self.ui_title_target = nil

	-- 清理变量和对象
	self.gold = nil
	self.bind_gold = nil
	self.toggle_info = nil
	self.toggle_package = nil
	self.toggle_fashion = nil
	self.toggle_title = nil
	self.toggle_skill = nil
	self.toggle_zhuanshen = nil
	self.shen_equip_view_obj = nil
	self.btn_close = nil
	self.red_point_list = nil
	self.ui_title_res = nil
	self.equip_view_obj = nil
	self.recycle_button = nil
	self.tab_equip = nil
	self.recycle_and_closebutton = nil
	self.role_rotate_area = nil
	self.role_display = nil
	self.title_parent = nil
	--self.role_ani = nil
	--self.role_dispaly_ani = nil
	self.fashion_content = nil
	self.package_content = nil
	self.title_content = nil
	self.skill_content = nil
	self.zhuansheng_content = nil
	self.reincarnation_content = nil
	self.info_content = nil
	self.toggle_tulong_equip = nil
	self.tulong_equip_content = nil
	self.toggle_reincarnation = nil
	self.show_blue_bg = nil
	self.zs_button = nil
end

function PlayerView:LoadCallBack()
	-- 监听UI事件
	self:ListenEvent("Close",
		BindTool.Bind(self.HandleClose, self))
	self:ListenEvent("OpenInfo",
		BindTool.Bind(self.HandleOpenInfo, self))
	self:ListenEvent("OpenPackage",
		BindTool.Bind(self.HandleOpenPackage, self))
	self:ListenEvent("OpenFashion",
		BindTool.Bind(self.HandleOpenFashion, self))
	self:ListenEvent("OpenTitle",
		BindTool.Bind(self.HandleOpenTitle, self))
	self:ListenEvent("OpenSkill",
		BindTool.Bind(self.HandleOpenSkill, self))
	self:ListenEvent("OpenZhuanSheng",
		BindTool.Bind(self.HandleOpenZhuanSheng, self))
	self:ListenEvent("OpenShenBing",
		BindTool.Bind(self.HandleOpenShenBing, self))
	self:ListenEvent("AddGold",
		BindTool.Bind(self.HandleAddGold, self))
	self:ListenEvent("OpenTulongEquip",
		BindTool.Bind(self.OpenTulongEquip, self))
	self:ListenEvent("OpenReincarnation",
		BindTool.Bind(self.OpenReincarnation, self))

	-- 获取变量
	self.gold = self:FindVariable("Gold")
	self.bind_gold = self:FindVariable("BindGold")
	self.show_blue_bg = self:FindVariable("ShowBlueBg")
	self.show_blue_bg:SetValue(false)

	-- 页签
	self.toggle_info = self:FindObj("ToggleInfo")
	self.toggle_package = self:FindObj("TogglePackage")
	self.toggle_fashion = self:FindObj("ToggleFashion")
	self.toggle_title = self:FindObj("ToggleTitle")
	self.toggle_skill = self:FindObj("ToggleSkill")
	self.toggle_zhuanshen = self:FindObj("ToggleZhuanshen")
	self.toggle_tulong_equip = self:FindObj("ToggleTulongEquip")
	self.toggle_reincarnation = self:FindObj("ToggleCarnation")

	--引导用按钮
	self.btn_close = self:FindObj("BtnClose")										--关闭按钮

	-- 子面板
	self.info_content = self:FindObj("InfoContent")
	self.package_content = self:FindObj("PackageContent")
	self.equip_view_obj = self:FindObj("RoleEquipView")
	self.fashion_content = self:FindObj("FashionContent")
	self.title_content = self:FindObj("TitlePanel")
	self.skill_content = self:FindObj("SkillContent")
	self.zhuansheng_content = self:FindObj("ZhuanShengContent")
	self.reincarnation_content = self:FindObj("ReincarnationContent")				--转生角色
	self.shen_equip_view_obj = self:FindObj("RoleShenEquipView")  					--传世装备
	self.tulong_equip_content = self:FindObj("TulongEquipContent")

	-- 旋转区域
	self.role_rotate_area = self:FindObj("RoleRotateArea")
	local event_trigger = self.role_rotate_area:GetComponent(typeof(EventTriggerListener))
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDrag, self))

	local main_role = Scene.Instance:GetMainRole()
	local main_role_vo = main_role.vo
	-- 获取控件
	self.role_display = self:FindObj("RoleDisplay")
	self.title_parent = self:FindObj("title_parent")
	self.role_model = RoleModel.New("player_view_panel")
	self.role_model:SetDisplay(self.role_display.ui3d_display)

	self.role_model:SetRoleResid(main_role:GetRoleResId())
	self.role_model:SetWeaponResid(main_role:GetWeaponResId())
	self.role_model:SetWeapon2Resid(main_role:GetWeapon2ResId())
	self.role_model:SetWingResid(main_role:GetWingResId())
	self.role_model:SetWaistResid(main_role:GetWaistResId())
	self.role_model:SetTouShiResid(main_role:GetTouShiResId())
	self.role_model:SetQilinBiResid(main_role:GetQilinBiResId(), main_role_vo.sex)
	self.role_model:SetMaskResid(main_role:GetMaskResId())

	if main_role_vo.prof == ROLE_PROF.PROF_3 then
		--逍遥用idle_n2动作
		self.role_model:SetBool("idle_n2", true)
	else
		self.role_model:SetBool("idle_n2", false)
	end

	--self.role_ani = self:FindObj("RoleAnimator").animator
	--self.role_dispaly_ani = self:FindObj("RoleDisplay").animator

	--功能引导注册
	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.Player, BindTool.Bind(self.GetUiCallBack, self))

	self.open_trigger_handle = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.InitTab, self))

	self.red_point_list = {
		[RemindName.PlayerInfo] = self:FindVariable("ShowInfoRed"),
		[RemindName.PlayerTitle] = self:FindVariable("ShowTitleRed"),
		[RemindName.PlayerFashion] = self:FindVariable("ShowFashionRed"),
		[RemindName.PlayerSkill] = self:FindVariable("ShowSkillRed"),
		[RemindName.PlayerPackage] = self:FindVariable("ShowBagRed"),
		[RemindName.TulongEquipGroup] = self:FindVariable("ShowTulongEquipRed"),
		[RemindName.Reincarnation] = self:FindVariable("ShowZhuanShengRed"),
	}

	for k, _ in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end
end

function PlayerView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetValue(num > 0)
	end
	if remind_name == RemindName.TulongEquipGroup and self.tulong_equip_view then
		self.tulong_equip_view:FlushRemind()
	end
end

function PlayerView:GetRoleModel()
	return self.role_model
end

function PlayerView:GetTitleView()
	return self.title_view
end

function PlayerView:MainRoleApperanceChange()

end

function PlayerView:AsyncLoadView(index)
	if index == TabIndex.role_intro and self.info_content.transform.childCount == 0 then
		UtilU3d.PrefabLoad("uis/views/player_prefab", "InfoContent",
			function(obj)
				obj.transform:SetParent(self.info_content.transform, false)
				obj = U3DObject(obj)
				self.info_view = PlayerInfoView.New(obj)
			end)
	end

	if index == TabIndex.role_bag then
		if self.package_content.transform.childCount == 0 then
			UtilU3d.PrefabLoad("uis/views/player_prefab", "PackageContent",
				function(obj)
					obj.transform:SetParent(self.package_content.transform, false)
					obj = U3DObject(obj)
					self.package_view = PlayerPackageView.New(obj)
					self.recycle_button = self.package_view.recycle_button							--装备回收按钮
					self.recycle_and_closebutton = self.package_view.recycle_and_closebutton		--立即回收按钮
					self.tab_equip = self.package_view.tab_equip									--装备标签
					self:FlushPackageViewInActive()
				end)
		end

		if self.equip_view_obj.transform.childCount == 0 then
			UtilU3d.PrefabLoad("uis/views/player_prefab", "RoleEquipView",
				function(obj)
					obj.transform:SetParent(self.equip_view_obj.transform, false)
					obj = U3DObject(obj)
					self.equip_view = PlayerEquipView.New(obj, self)
					self.equip_view:OpenCallBack()
				end)
		end

		if self.shen_equip_view_obj.transform.childCount == 0 then
			UtilU3d.PrefabLoad("uis/views/player_prefab", "RoleShenEquipView",
				function(obj)
					obj.transform:SetParent(self.shen_equip_view_obj.transform, false)
					obj = U3DObject(obj)
					self.shen_equip_view = PlayerShenEquipView.New(obj, self)
					self.shen_equip_view:OpenCallBack()
				end)
		end
	end

	if index == TabIndex.role_fashion and self.fashion_content.transform.childCount == 0 then
		UtilU3d.PrefabLoad("uis/views/player_prefab", "FashionContent",
			function(obj)
				obj.transform:SetParent(self.fashion_content.transform, false)
				obj = U3DObject(obj)
				self.fashion_view = PlayerFashionView.New(obj)
				self.fashion_view:OpenCallBack()
			end)
	end

	if index == TabIndex.role_skill and self.skill_content.transform.childCount == 0 then
		UtilU3d.PrefabLoad("uis/views/player_prefab", "SkillContent",
			function(obj)
				obj.transform:SetParent(self.skill_content.transform, false)
				obj = U3DObject(obj)
				self.skill_view = PlayerSkillView.New(obj, self)
				self.skill_view:FlushSkillInfo()
				self.skill_view:OnClickPassiveButton()
			end)
	end

	if index == TabIndex.role_title and self.title_content.transform.childCount == 0 then
		UtilU3d.PrefabLoad("uis/views/player_prefab", "TitlePanel",
			function(obj)
				obj.transform:SetParent(self.title_content.transform, false)
				obj = U3DObject(obj)
				self.title_view = PlayerTitleView.New(obj)
				self.title_view:Flush()
				self.title_view:SetUiTitle(self.ui_title_res)
			end)
	end

	if index == TabIndex.role_rebirth and self.zhuansheng_content.transform.childCount == 0 then
		UtilU3d.PrefabLoad("uis/views/player_prefab", "ZhuanShengContent",
			function(obj)
				obj.transform:SetParent(self.zhuansheng_content.transform, false)
				obj = U3DObject(obj)
				self.zhuansheng_view = PlayerZhuanShengView.New(obj, self)
				self:Flush()
			end)
	end
	if index == TabIndex.role_reincarnation and self.reincarnation_content.transform.childCount == 0 then
		UtilU3d.PrefabLoad("uis/views/player_prefab", "ReincarnationView",
			function(obj)
				obj.transform:SetParent(self.reincarnation_content.transform, false)
				obj = U3DObject(obj)
				self.reincarnation_view = ReincarnationView.New(obj, self)
				self.zs_button = self.reincarnation_view:GetZsButton()
				self.reincarnation_view:OpenCallBack()
				self.reincarnation_view:Flush()
			end)
	end
	if (index == TabIndex.role_tulong_equip or index == TabIndex.role_chuanshi_equip) and self.tulong_equip_content.transform.childCount == 0 then
		UtilU3d.PrefabLoad("uis/views/player_prefab", "TulongEquipView",
			function(obj)
				obj.transform:SetParent(self.tulong_equip_content.transform, false)
				obj = U3DObject(obj)
				self.tulong_equip_view = TulongEquipView.New(obj, self)
				self.tulong_equip_view:OpenCallBack(self.show_index)
				self.tulong_equip_view:Flush()
				self:Flush()
			end)
	end
end

function PlayerView:FlushPackageViewInActive()
	if self.package_view then
		self.package_view:OpenCallBack()
		self.package_view:Flush()
		if self.package_view:GetRecycleViewState() then
			self.equip_view_obj:SetActive(false)
		end
		if self.package_view:GetWareHourseState() then
			self.package_view:CloseWareHouse()
		end
	end
end

function PlayerView:CloseChild()
	if self.equip_view then
		self.equip_view:CloseCallBack()
	end

	if self.info_view then
		self.info_view:CloseCallBack()
	end

	if self.info_view2 then
		self.info_view2:CloseCallBack()
	end

	if self.skill_view then
		self.skill_view:CloseCallBack()
	end

	if self.package_view then
		self.package_view:CloseCallBack()
	end

	if self.fashion_view then
		self.fashion_view:CloseCallBack()
	end

	if self.shen_equip_view then
		self.shen_equip_view:CloseCallBack()
	end

end

HIDEWINGSVIEW = {
	[TabIndex.role_fashion] = true,
	[TabIndex.role_title] = true,
	[TabIndex.role_skill] = true,
}

--由于unity源码的原因，在标签不可见的状态下去设置多个toggle的isOn为true时会出现多个标签被选中的情况，因此每次设置toggle之前先统一设为false
function PlayerView:InitAllToggleIsOn()
	self.toggle_info.toggle.isOn = false
	self.toggle_package.toggle.isOn = false
	self.toggle_skill.toggle.isOn = false
	self.toggle_reincarnation.toggle.isOn = false
	self.toggle_title.toggle.isOn = false
	self.toggle_zhuanshen.toggle.isOn = false
	self.toggle_tulong_equip.toggle.isOn = false
	self.toggle_fashion.toggle.isOn = false
end

function PlayerView:ShowIndexCallBack(index)
	local index = index or self:GetShowIndex()

	self:InitAllToggleIsOn()

	self:CloseChild()

	if index ~= TabIndex.role_bag then
		self.shen_equip_view_obj:SetActive(false)
	end

	self:AsyncLoadView(index)
	self:FlushFashion()
	if index == TabIndex.role_intro then
		self.toggle_info.toggle.isOn = true
		if self.info_view then
			self.info_view:OpenCallBack()
		end
	elseif index == TabIndex.role_bag then
		self.toggle_package.toggle.isOn = true
		self:FlushPackageViewInActive()
		if self.equip_view then
			self.equip_view:OpenCallBack()
		end
		if self.shen_equip_view then
			self.shen_equip_view:OpenCallBack()
		end

	elseif index == TabIndex.role_skill then
		self.toggle_skill.toggle.isOn = true
		if self.skill_view then
			self.skill_view:FlushSkillInfo()
			self.skill_view:OnClickPassiveButton()
		end

	elseif index == TabIndex.role_reincarnation then
		self.toggle_reincarnation.toggle.isOn = true
		if self.reincarnation_view then
			self.reincarnation_view:OpenCallBack()
			self.reincarnation_view:Flush()
		end

	elseif index == TabIndex.role_title then
		self.toggle_title.toggle.isOn = true
		if self.title_view then
			self.title_view:Flush()
		end

	elseif index == TabIndex.role_rebirth then
		self.toggle_zhuanshen.toggle.isOn = true
		if self.zhuansheng_view then
			self.zhuansheng_view:SetDefultToggle()
			self.zhuansheng_view:FlushWeaponViewInfo()
		end
		ZhuanShengData.Instance:ResetRecoveryEquipList()

	elseif index == TabIndex.role_tulong_equip or index == TabIndex.role_chuanshi_equip then
		self.toggle_tulong_equip.toggle.isOn = true
		if self.tulong_equip_view then
			self.tulong_equip_view:OpenCallBack(self.show_index)
			self.tulong_equip_view:Flush()
		end

	elseif index == TabIndex.role_fashion then
		self.toggle_fashion.toggle.isOn = true
		if self.fashion_view then
			self.fashion_view:OpenCallBack()
		end
	else
		self:ShowIndex(TabIndex.role_intro)
	end

	-- 根据不同界面分别处理逻辑
	-- 翅膀处理
	if HIDEWINGSVIEW[index] then
		self:HideWings()
	else
		self:ShowWings()
	end

	--if index == TabIndex.role_rebirth then
		--self.role_ani:SetBool("right", true)
		--self.role_dispaly_ani:SetBool("right", true)
	--else
		--self.role_ani:SetBool("right", false)
		--self.role_dispaly_ani:SetBool("right", false)
	--end
end

function PlayerView:HideWings()
	self.hide_wing = true
	self:FlushFashion()
end

function PlayerView:ShowWings()
	self.hide_wing = false
	self:FlushFashion()
end

function PlayerView:DestroyTitle()
	if nil ~= self.ui_title then
		GameObject.Destroy(self.ui_title)
		self.ui_title = nil
		self.ui_title_target = nil
	end
end

function PlayerView:OpenCallBack()
	-- 监听系统事件
	self.data_listen = BindTool.Bind(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)
	-- 首次刷新数据
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])
	self:InitTab()

	if not self.equip_data_change then
		self.equip_data_change = GlobalEventSystem:Bind(OtherEventType.EQUIP_DATA_CHANGE, BindTool.Bind(self.EquipDataChangeListen, self))
	end

	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end

	-- 监听系统事件
	self.flush_bag_view = GlobalEventSystem:Bind(
		BagFlushEventType.BAG_FLUSH_CONTENT,
		BindTool.Bind(self.FlushRolePackageView, self))
	self.role_dress_content = GlobalEventSystem:Bind(
		WarehouseEventType.ROLE_DRESS_CONTENT,
		BindTool.Bind(self.ShowOrHideRoleDress, self))
	self.avater_type_event = GlobalEventSystem:Bind(
		AvaterType.FORBID_AVATER_CHANGE,
		BindTool.Bind(self.FlushForbidAvaterChange, self))
	FashionCtrl.Instance:NotifyWhenFashionChange(self.flush_callback)
end


--数据改变时刷新
function PlayerView:FlushFashion(role_res_id, weapon_res_id)
	local main_role = Scene.Instance:GetMainRole()
	self.role_model:SetRoleResid(role_res_id or main_role:GetRoleResId())
	if main_role.vo.prof == ROLE_PROF.PROF_3 then
		--逍遥用idle_n2动作
		self.role_model:SetBool("idle_n2", true)
	else
		self.role_model:SetBool("idle_n2", false)
	end
	self.role_model:SetWeaponResid(weapon_res_id or main_role:GetWeaponResId())
	self.role_model:SetWeapon2Resid(main_role:GetWeapon2ResId())
	if not self.hide_wing then
		self.role_model:SetWingResid(main_role:GetWingResId())
		self.role_model:SetWaistResid(main_role:GetWaistResId())
		self.role_model:SetTouShiResid(main_role:GetTouShiResId())
		self.role_model:SetQilinBiResid(main_role:GetQilinBiResId(), main_role.vo.sex)
		self.role_model:SetMaskResid(main_role:GetMaskResId())
	else
		self.role_model:SetWingResid(0)
		self.role_model:SetWaistResid(0)
		self.role_model:SetTouShiResid(0)
		self.role_model:SetQilinBiResid(0)
		self.role_model:SetMaskResid(0)
	end
end

function PlayerView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	if self.package_view then
		self.package_view:Flush()
	end
end

function PlayerView:CloseCallBack()
	self:CloseChild()

	if self.data_listen then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end

	if self.equip_data_change then
		GlobalEventSystem:UnBind(self.equip_data_change)
		self.equip_data_change = nil
	end

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	if nil ~= self.flush_bag_view then
		GlobalEventSystem:UnBind(self.flush_bag_view)
		self.flush_bag_view = nil
	end

	if nil ~= self.role_dress_content then
		GlobalEventSystem:UnBind(self.role_dress_content)
		self.role_dress_content = nil
	end

	if nil ~= self.avater_type_event then
		GlobalEventSystem:UnBind(self.avater_type_event)
		self.avater_type_event = nil
	end

	if FashionCtrl.Instance ~= nil then
		FashionCtrl.Instance:UnNotifyWhenFashionChange(self.flush_callback)
	end

	self:OnSwitchToShenEquip(false)
	Scene.Instance:GetMainRole():FixMeshRendererBug()
end

function PlayerView:EquipDataChangeListen()
	if self.role_model~=nil then
		local main_role = Scene.Instance:GetMainRole()
		self.role_model:SetWeaponResid(main_role:GetWeaponResId())
		self.role_model:SetWeapon2Resid(main_role:GetWeapon2ResId())
	end
end

function PlayerView:PlayerDataChangeCallback(attr_name, value, old_value)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local count = vo.gold
	if attr_name == "bind_gold" then
		count = vo.bind_gold
	end
	if count > 99999 and count <= 99999999 then
		count = count / 10000
		count = math.floor(count)
		count = count .. "万"
	elseif count > 99999999 then
		count = count / 100000000
		count = math.floor(count)
		count = count .. "亿"
	end
	if attr_name == "bind_gold" then
		self.bind_gold:SetValue(count)
	else
		self.gold:SetValue(count)
	end
	if attr_name == "used_title_list" then
		self:Flush("title_change")
	end
end

-- 操作物品tip回调
function PlayerView:HandleItemTipCallBack(item_data, handleType, handle_param_t, item_cfg)
	if item_data == nil then
		return
	end

	if handleType == TipsHandleDef.HANDLE_STORGE then			--存仓库
		-- print_log("HandleItemTip: HANDLE_STORGE")
	elseif handleType == TipsHandleDef.HANDLE_BACK_BAG then 	--从仓库中取回到背包
		-- print_log("HandleItemTip: HANDLE_BACK_BAG")
	elseif handleType == TipsHandleDef.HANDLE_RECOVER then		--从背包到售卖(回收)
		PackageCtrl.Instance:AddRecycleItem(item_data)
	elseif handleType == TipsHandleDef.HANDLE_TAKEOFF then		--取下装备
		-- 转生装备
		if item_cfg.sub_type and item_cfg.sub_type >= GameEnum.ZHUANSHENG_SUB_TYPE_MIN
			and item_cfg.sub_type <= GameEnum.ZHUANSHENG_SUB_TYPE_MAX then
			local zs_dess_index = ZhuanShengData.Instance:GetZhuanShengEquipIndex(item_cfg.sub_type)
			ZhuanShengCtrl.Instance:SendRoleZhuanSheng(ZHUANSHENG_REQ_TYPE.ZHUANSHENG_REQ_TYPE_TAKE_OFF_EQUIP, zs_dess_index, param2, param3)
			return
		end

		local yes_func = function()
			PlayerCtrl.Instance:CSTakeOffEquip(item_data.index)
			local empty_num = ItemData.Instance:GetEmptyNum()
			if empty_num > 0 then
				EquipData.Instance:SetTakeOffFlag(true)
			end
		end
		local equip_suit_type = ForgeData.Instance:GetCurEquipSuitType(item_data.index)
		if equip_suit_type ~= 0 then
			TipsCtrl.Instance:ShowCommonAutoView("", Language.Forge.ReturnSuitRock, yes_func)
		else
			PlayerCtrl.Instance:CSTakeOffEquip(item_data.index)
			local empty_num = ItemData.Instance:GetEmptyNum()
			if empty_num > 0 then
				EquipData.Instance:SetTakeOffFlag(true)
			end
		end
	end
end

-----------------------------------
-- 关闭事件
function PlayerView:HandleClose()
	ViewManager.Instance:Close(ViewName.Player)
end

--点击信息按钮
function PlayerView:HandleOpenInfo()
	if TabIndex.role_intro == self.show_index then
		return
	end

	self:ShowIndex(TabIndex.role_intro)
end

--点击背包按钮
function PlayerView:HandleOpenPackage()
	if TabIndex.role_bag == self.show_index then
		if self.package_view then
		   self.package_view:SetRecycleContentState(false)
	    end

	    if self.package_view and self.package_view:GetWareHourseState() then
			self.package_view:CloseWareHouse()
		end
		self:OnSwitchToShenEquip(false)
		return
	end
	self:ShowIndex(TabIndex.role_bag)
end

--点击时装按钮
function PlayerView:HandleOpenFashion()
	if TabIndex.role_fashion == self.show_index then
		return
	end

	self:ShowIndex(TabIndex.role_fashion)
end

--点击称号按钮
function PlayerView:HandleOpenTitle()
	if TabIndex.role_title == self.show_index then
		return
	end

	self:ShowIndex(TabIndex.role_title)
end

function PlayerView:HandleAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

--点击技能按钮
function PlayerView:HandleOpenSkill()
	if TabIndex.role_skill == self.show_index then
		return
	end

	self:ShowIndex(TabIndex.role_skill)
end

function PlayerView:OpenReincarnation()
	if TabIndex.role_reincarnation == self.show_index then
		return
	end

	self:ShowIndex(TabIndex.role_reincarnation)
end

--点击转生按钮
function PlayerView:HandleOpenZhuanSheng()
	if TabIndex.role_rebirth == self.show_index then
		return
	end

	self:ShowIndex(TabIndex.role_rebirth)
end


function PlayerView:OpenTulongEquip()
	if TabIndex.role_tulong_equip == self.show_index then
		return
	end

	self:ShowIndex(TabIndex.role_tulong_equip)
end

function PlayerView:HandleOpenShenBing()
	if TabIndex.role_shenbing == self.show_index then
		return
	end

	self:ShowIndex(TabIndex.role_shenbing)
end

-- 角色被拖转动事件
function PlayerView:OnRoleDrag(data)
end

function PlayerView:FlushRolePackageView(item_index, is_jump)
	item_index = item_index or -1
	if self.package_view then
		if item_index > -1 then
			self.package_view:Flush("index", {["index" .. item_index] = item_index, is_jump = is_jump})
		else
			self.package_view:Flush()
		end
	end
end

function PlayerView:ShowOrHideRoleDress(isOrnot)
	self.equip_view_obj:SetActive(isOrnot)
end

function PlayerView:FlushForbidAvaterChange()
	self:Flush("forbid_avater_change")
end

function PlayerView:OnSwitchToShenEquip(is_switch)
	if self.equip_view_obj then
		if self.package_view and (self.package_view:GetWareHourseState() or self.package_view:GetRecycleViewState())then
			self.equip_view_obj:SetActive(false)
		else
			self.equip_view_obj:SetActive(not is_switch)
		end
	end
	self.package_content:SetActive(not is_switch)
	self.equip_view_obj:SetActive(not is_switch)
	self.shen_equip_view_obj:SetActive(is_switch)

	if is_switch and self.shen_equip_view then
		self.shen_equip_view:Flush()
	elseif self.package_view then
		self.package_view:Flush()
	end
	self.is_switch_to_shen_equip = is_switch
end

function PlayerView:InitTab()
	if not self:IsOpen() then return end
	local open_fun_data = OpenFunData.Instance
	self.toggle_info:SetActive(open_fun_data:CheckIsHide("InfoContent"))
	self.toggle_package:SetActive(open_fun_data:CheckIsHide("PackageContent"))
	self.toggle_fashion:SetActive(open_fun_data:CheckIsHide("FashionContent"))
	self.toggle_title:SetActive(open_fun_data:CheckIsHide("TitlePanel"))
	self.toggle_skill:SetActive(open_fun_data:CheckIsHide("SkillContent"))
	self.toggle_zhuanshen:SetActive(open_fun_data:CheckIsHide("role_rebirth"))
	--self.toggle_zhuanshen:SetActive(open_fun_data:CheckIsHide("role_rebirth")) --屏蔽天神
	self.toggle_tulong_equip:SetActive(open_fun_data:CheckIsHide("tulong_equip"))
	self.toggle_reincarnation:SetActive(open_fun_data:CheckIsHide("reincarnation"))
end

function PlayerView:FlushSkillView()
	if self.skill_view then
		self.skill_view:FlushSkillExpInfo()
	end
end

function PlayerView:FlushMieShiSkillView()
	if self.skill_view then
		self.skill_view:FlushMieShiSkillView()
	end
end

function PlayerView:OnFlush(param_t)
	local cur_index = self:GetShowIndex()
	for k, v in pairs(param_t) do
		if k == "all" then
			if cur_index == TabIndex.role_bag then
				if self.package_view then
					self.package_view:Flush("all", v)
				end
				self.toggle_package.toggle.isOn = true
			elseif cur_index == TabIndex.role_skill then
				if self.skill_view then
					self.skill_view:FlushSkillInfo()
				end
			elseif cur_index == TabIndex.role_rebirth then
				if self.zhuansheng_view ~= nil then
					self.zhuansheng_view:FlushWeaponViewInfo()
					-- self.zhuansheng_view:FlushResolveViewInfo()
				end
			elseif cur_index == TabIndex.role_title then
				if self.title_view then
					self.title_view:Flush()
				end
			elseif cur_index == TabIndex.role_tulong_equip or cur_index == TabIndex.role_chuanshi_equip then
				if self.tulong_equip_view then
					self.tulong_equip_view:Flush()
				end
			end

			if self.shen_equip_view and self.shen_equip_view_obj.gameObject.activeSelf then
				self.shen_equip_view:Flush()
			end
		elseif k == "bag" then
			if self.package_view then
				self.package_view:Flush("bag", v)
			end
		elseif k == "shen_equip_change" then
			if self.shen_equip_view and self.shen_equip_view_obj.gameObject.activeSelf then
				self.shen_equip_view:Flush()
			end
		elseif k == "shenzhuang_view" then
			if cur_index == TabIndex.role_bag then
				if v.item_id ~= nil then
					EquipmentShenData.Instance:SetSelectedIndex(v.item_id)
				end
				GlobalTimerQuest:AddDelayTimer(function ()
					self:OnSwitchToShenEquip(true)
				end, 0)
			end
		elseif k == "bag_recycle" then
			GlobalTimerQuest:AddDelayTimer(function()
				if self.package_view then
					self.package_view:Flush()
					self.package_view:HandleOpenRecycle()
				end
			end, 0)
		elseif k == "title_change" then
			if self.title_view then
				self.title_view:Flush()
			end
		elseif k == "reincarnation" then
			if self.reincarnation_view and self.toggle_reincarnation.toggle.isOn then
				self.reincarnation_view:Flush()
			end
		elseif k == "tulong_equip" then
			if self.tulong_equip_view and self.toggle_tulong_equip.toggle.isOn then
				self.tulong_equip_view:Flush()
			end
		elseif k == "imp_guard" then
			if self.equip_view and self.toggle_package.toggle.isOn then
				self.equip_view:Flush(k)
			end
		elseif k == "forbid_avater_change" then
			if self.info_view and self.toggle_info.toggle.isOn then
				self.info_view:FlushForbidAvaterChange()
			end
		end
	end
end

function PlayerView:OnChangeToggle(index)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if index == TabIndex.role_bag then
		self:ShowIndex(TabIndex.role_bag)
	elseif index == TabIndex.role_reincarnation then
		self:ShowIndex(TabIndex.role_reincarnation)
	end
end

function PlayerView:PackBagEquipClick()
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if self.tab_equip then
		self.tab_equip.toggle.isOn = true
	end
end

function PlayerView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if ui_name == GuideUIName.Tab then
		local index = TabIndex[ui_param]
		if index == self:GetShowIndex() then
			return NextGuideStepFlag
		end
		if index == TabIndex.role_bag then
			if self.toggle_package.gameObject.activeInHierarchy then
				local callback = BindTool.Bind(self.OnChangeToggle, self, TabIndex.role_bag)
				return self.toggle_package, callback
			end
		elseif index == TabIndex.role_reincarnation then
			if self.toggle_reincarnation.gameObject.activeInHierarchy then
				local callback = BindTool.Bind(self.OnChangeToggle, self, TabIndex.role_reincarnation)
				return self.toggle_reincarnation, callback
			end
		end
	elseif ui_name == GuideUIName.TabEquip then
		if self.tab_equip and self.tab_equip.gameObject.activeInHierarchy then
			if self.tab_equip.toggle.isOn then
				return NextGuideStepFlag
			end
			local callback = BindTool.Bind(self.PackBagEquipClick, self)
			return self.tab_equip, callback
		end
	elseif self[ui_name] and not IsNil(self[ui_name].gameObject) then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	end
end
