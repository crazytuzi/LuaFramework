require("game/player/player_info_view")
require("game/player/player_package_view")
require("game/player/player_title_view")
require("game/player/player_equip_view")
require("game/player/player_fashion_view")
require("game/player/player_skill_view")
require("game/player/player_zhuansheng_view")
require("game/player/player_shenbing_view")
require("game/player/player_forge_view")
require("game/player/player_deity_suit_view")
require("game/chat/cool_chat_view")

local INFO_TOGGLE = 1
local PACK_TOGGLE = 2
local FASHION_TOGGLE = 3
local TITLE_TOGGLE = 4
local SKILL_TOGGLE = 5
local ZHUANSHENG_TOGGLE = 6
local SHENBING_TOGGLE = 7
local FORGE_TOGGLE = 8
local COOL_CHAT = 9

local MOUNT_TYPE10 = 10
PlayerView = PlayerView or BaseClass(BaseView)

function PlayerView:__init()
	self.ui_config = {"uis/views/player","PlayerView"}
	self:SetMaskBg()
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self.def_index = TabIndex.role_intro
	self.role_model = nil
	self.cur_toggle = INFO_TOGGLE
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	self.open_callback_event = GlobalEventSystem:Bind(OtherEventType.OPEN_RECYCLE_VIEW, BindTool.Bind(self.OpenForgeView, self))
	self.is_switch_to_deity_suit = false
end

function PlayerView:__delete()
	if self.open_callback_event ~= nil then
		GlobalEventSystem:UnBind(self.open_callback_event)
		self.open_callback_event = nil
	end
end

function PlayerView:ReleaseCallBack()
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.Player)
	end
	PlayerData.Instance:SetFashionSelect(1)
	if self.info_view then
		self.info_view:DeleteMe()
		self.info_view = nil
	end

	if self.package_view then
		self.package_view:DeleteMe()
		self.package_view = nil
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

	if self.cool_chat_view then
		self.cool_chat_view:DeleteMe()
		self.cool_chat_view = nil
	end

	if self.zhuansheng_view then
		self.zhuansheng_view:DeleteMe()
		self.zhuansheng_view = nil
	end

	if self.shenbing_view then
		self.shenbing_view:DeleteMe()
		self.shenbing_view = nil
	end

	if self.forge_view then
		self.forge_view:DeleteMe()
		self.forge_view = nil
	end

	if self.deity_suit_view then
		self.deity_suit_view:DeleteMe()
		self.deity_suit_view = nil
	end

	if nil ~= self.flush_bag_view then
		GlobalEventSystem:UnBind(self.flush_bag_view)
		self.flush_bag_view = nil
	end

	if nil ~= self.role_dress_content then
		GlobalEventSystem:UnBind(self.role_dress_content)
		self.role_dress_content = nil
	end

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	if self.money then
		self.money:DeleteMe()
		self.money = nil
	end
	
	self.ui_title = nil
	self.ui_title_target = nil

	-- 清理变量和对象
	self.role_display = nil
	self.show_dizuo_bg = nil
	self.toggle_info = nil
	self.toggle_package = nil
	self.toggle_fashion = nil
	self.toggle_title = nil
	self.toggle_skill = nil
	self.toggle_zhuanshen = nil
	self.toggle_shenbing = nil
	self.toggle_forge = nil
	self.btn_close = nil
	self.red_point_list = nil
	self.ui_title_res = nil
	self.equip_view_obj = nil
	self.deity_suit_view_obj = nil
	self.package_content = nil
	self.recycle_button = nil
	self.tab_equip = nil
	self.recycle_and_closebutton = nil
	self.role_rotate_area = nil
	self.toggle_cool_chat = nil
	self.open_touxian = nil
	GlobalEventSystem:UnBind(self.open_trigger_handle)
end

function PlayerView:LoadCallBack()
	-- 监听UI事件
	self:ListenEvent("Close", BindTool.Bind(self.HandleClose, self))
	self:ListenEvent("OpenInfo", BindTool.Bind(self.HandleOpenInfo, self))
	self:ListenEvent("OpenPackage", BindTool.Bind(self.HandleOpenPackage, self))
	self:ListenEvent("OpenFashion", BindTool.Bind(self.HandleOpenFashion, self))
	self:ListenEvent("OpenTitle", BindTool.Bind(self.HandleOpenTitle, self))
	self:ListenEvent("OpenSkill", BindTool.Bind(self.HandleOpenSkill, self))
	self:ListenEvent("OpenZhuanSheng", BindTool.Bind(self.HandleOpenZhuanSheng, self))
	self:ListenEvent("OpenShenBing", BindTool.Bind(self.HandleOpenShenBing, self))
	self:ListenEvent("OpenForge", BindTool.Bind(self.HandleOpenForge, self))
	self:ListenEvent("OpenCool", BindTool.Bind(self.HandleOpenCool, self))
	self:ListenEvent("close_all_attr_tips", BindTool.Bind(self.HandleCloseAttrTips, self))
	self:ListenEvent("AddGold", BindTool.Bind(self.HandleAddGold, self))

	-- 监听系统事件
	self.flush_bag_view = GlobalEventSystem:Bind(
		BagFlushEventType.BAG_FLUSH_CONTENT,
		BindTool.Bind(self.FlushRolePackageView,self))
	self.role_dress_content = GlobalEventSystem:Bind(
		WarehouseEventType.ROLE_DRESS_CONTENT,
		BindTool.Bind1(self.ShowOrHideRoleDress, self, isOrnot))

	self.money = MoneyBar.New()
	self.money:SetInstanceParent(self:FindObj("MoneyBar"))

	self.show_dizuo_bg = self:FindVariable("ShowDizuoBg")
	
	-- 页签
	self.toggle_info = self:FindObj("ToggleInfo")
	self.toggle_package = self:FindObj("TogglePackage")
	self.toggle_fashion = self:FindObj("ToggleFashion")
	self.toggle_title = self:FindObj("ToggleTitle")
	self.toggle_skill = self:FindObj("ToggleSkill")
	self.toggle_zhuanshen = self:FindObj("ToggleZhuanshen")
	self.toggle_shenbing = self:FindObj("ToggleShenBing")
	self.toggle_forge = self:FindObj("TabForge")
	self.toggle_cool_chat = self:FindObj("ToggleCoolChat")		-- 酷聊

	--引导用按钮
	self.btn_close = self:FindObj("BtnClose")										--关闭按钮

	-- 子面板
	self.info_view = PlayerInfoView.New()
	local info_content = self:FindObj("InfoContent")
	info_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.info_view:SetInstance(obj)
		self.open_touxian = self.info_view.open_touxian
	end)

	self.package_content = self:FindObj("PackageContent")
	self.package_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.package_view = PlayerPackageView.New(obj)
		--引导用按钮
		self.recycle_button = self.package_view.recycle_button							--装备回收按钮
		self.recycle_and_closebutton = self.package_view.recycle_and_closebutton		--立即回收按钮
		self.tab_equip = self.package_view.tab_equip									--装备标签
		self.package_view:FlushBagView()
		self.package_view:OpenCallBack()
	end)

	self.equip_view_obj = self:FindObj("RoleEquipView")
	self.equip_view_obj.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.equip_view = PlayerEquipView.New(obj)
		self.equip_view:OpenCallBack()
	end)

	self.fashion_view = PlayerFashionView.New()
	local fashion_content = self:FindObj("FashionContent")
	fashion_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.fashion_view:SetInstance(obj)
	end)

	local title_content = self:FindObj("TitlePanel")
	title_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.title_view = PlayerTitleView.New(obj)
		self.title_view:Flush()
		self.title_view:SetUiTitle(self.ui_title_res)
	end)

	local skill_content = self:FindObj("SkillContent")
	skill_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.skill_view = PlayerSkillView.New(obj, self)
	end)

	local zhuansheng_content = self:FindObj("ZhuanShengContent")
	zhuansheng_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.zhuansheng_view = PlayerZhuanShengView.New(obj, self)
	end)

	local shenbing_content = self:FindObj("ShenBingContent")
	shenbing_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.shenbing_view = PlayerShenBingView.New(obj, self)
		self.shenbing_view:Flush()
	end)

	self.forge_view = PlayerForgeView.New()
	local forge_content = self:FindObj("ForgeContent")
	forge_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.forge_view:SetInstance(obj)
	end)

	self.deity_suit_view_obj = self:FindObj("DeitySuitContent")
	self.deity_suit_view_obj.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.deity_suit_view = PlayerDeitySuitView.New(obj, self)
		self.deity_suit_view:Flush()
	end)

	self.cool_chat_view = CoolChatView.New(self:FindObj("ChatFunConent"), self)

	-- 旋转区域
	self.role_rotate_area = self:FindObj("RoleRotateArea")
	local event_trigger = self.role_rotate_area:GetComponent(typeof(EventTriggerListener))
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDrag, self))

	-- 获取控件
	self.role_display = self:FindObj("Display")
	-- self.role_display:SetActive(false)
	local main_role = Scene.Instance:GetMainRole()

	--功能引导注册
	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.Player, BindTool.Bind(self.GetUiCallBack, self))

	self.red_point_list = {
		[RemindName.PlayerInfo] = self:FindVariable("ShowInfoRed"),
		[RemindName.PlayerTitle] = self:FindVariable("ShowTitleRed"),
		[RemindName.PlayerFashion] = self:FindVariable("ShowFashionRed"),
		[RemindName.PlayerPackage] = self:FindVariable("ShowBagRed"),
		[RemindName.PlayerShenBing] = self:FindVariable("ShowShenBingRed"),
		[RemindName.PlayerChat] = self:FindVariable("ShowChatRed"),
		[RemindName.PlayerForge] = self:FindVariable("ShowForgeRed"),
	}

	for k, _ in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end

	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end

	self.open_trigger_handle = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.InitTab, self))
	self:Flush()
end

function PlayerView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetValue(num > 0)
	end
end

function PlayerView:GetTitleView()
	return self.title_view
end

function PlayerView:GetShenBingView()
	return self.shenbing_view
end

function PlayerView:OpenForgeView()
	self:ShowIndex(TabIndex.forge)
end

function PlayerView:Open(index)
	BaseView.Open(self, index)
end

function PlayerView:MainRoleApperanceChange()

end

function PlayerView:FlushModel(bool)
	if self.show_dizuo_bg then
		self.show_dizuo_bg:SetValue(bool)
	end

	if self.package_view then
		self.package_view:FlushModelShow(bool)
	end
end

function PlayerView:ShowIndexCallBack(index)
	local index = index or self:GetShowIndex()
	if index ~= TabIndex.role_shenbing then
		if self.shenbing_view then
			self.shenbing_view:SetAuto(false)
		end
	end
	if index == TabIndex.role_intro then
		self.toggle_info.toggle.isOn = true
		self.cur_toggle = INFO_TOGGLE
	elseif index == TabIndex.role_bag then
		self.toggle_package.toggle.isOn = true
		if self.package_view then
			self.package_view:FlushBagView()
			-- if self.package_view:GetRecycleViewState() then
			-- 	self.equip_view_obj:SetActive(false)
			-- end
			self.package_view:OpenCallBack()
			if self.package_view:GetWareHourseState() then
				self.package_view:CloseWareHouse()
				self.package_view:OpenCallBack()
			end
		end
		self.cur_toggle = PACK_TOGGLE
	elseif index == TabIndex.role_fashion then
		self.fashion_view:Flush("dismount")
		self.fashion_view:Flush("fashion_icon")
		self.fashion_view:FlushModel()
	elseif index == TabIndex.role_title then
		self.cur_toggle = TITLE_TOGGLE
		if self.title_view then
			self.title_view:SetAllAttributeFalse()
		end
		if self.title_view then
			self.title_view:SetAllAttributeFalse()
		end
	elseif index == TabIndex.role_shenbing then
		self.toggle_shenbing.toggle.isOn = true
		self.cur_toggle = SHENBING_TOGGLE
		if self.shenbing_view then
			self.shenbing_view:Flush()
		end
	elseif index == TabIndex.forge then
		self.toggle_forge.toggle.isOn = true
		self.cur_toggle = FORGE_TOGGLE
	elseif index == TabIndex.role_cool_chat then 	-- 酷聊
		self.toggle_cool_chat.toggle.isOn = true
		self.cur_toggle = COOL_CHAT
	end

	if index ~= TabIndex.role_bag then
		self.deity_suit_view_obj:SetActive(false)
	end

	if index == TabIndex.forge or index == TabIndex.role_cool_chat then
		self:FlushModel(false)
	else
		self:FlushModel(true)
	end
end


function PlayerView:OpenCallBack()
	PlayerForgeCtrl.Instance:SendRongluInfo()
	PlayerCtrl.Instance:SendServerLevelInfo()
	GuildCtrl.Instance:SendRiChangTaskRollReq(COMMON_OPERATE_TYPE.COT_MASTER_COLLECT_ITEM_INFO, 0)
	self:Flush()
	self:InitTab()

	if self.equip_view then
		self.equip_view:OpenCallBack()
	end
end

function PlayerView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	self:FlushRolePackageView(index)
end

function PlayerView:CloseCallBack()
	if self.equip_view then
		self:Flush("equip_view_close")
	end
	if self.info_view then
		self:Flush("info_view_close")
	end
	if self.package_view then
		self:Flush("package_view_close")
	end
	if self.data_listen then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end
	-- if self.skill_view then
	-- 	self.skill_view:StopLevelUp()
	-- end
	if self.fashion_view then
		self:Flush("fashion_view_close")
	end
	if self.equip_data_change then
		GlobalEventSystem:UnBind(self.equip_data_change)
		self.equip_data_change = nil
	end

	self:OnSwitchToShenEquip(false)
end

-- 操作物品tip回调
function PlayerView:HandleItemTipCallBack(item_data, handleType, handle_param_t, item_cfg)
	if item_data == nil then
		return
	end

	if handleType == TipsHandleDef.HANDLE_STORGE then			--存仓库
		print_log("HandleItemTip: HANDLE_STORGE")
	elseif handleType == TipsHandleDef.HANDLE_BACK_BAG then 	--从仓库中取回到背包
		print_log("HandleItemTip: HANDLE_BACK_BAG")
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
			if empty_nuhhm > 0 then
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
	-- self:ChangeNvwashiValue()
end

-----------------------------------
-- 关闭事件
function PlayerView:HandleClose()
	ViewManager.Instance:Close(ViewName.Warehouse)
	ViewManager.Instance:Close(ViewName.Player)
end

--点击信息按钮
function PlayerView:HandleOpenInfo()
	if INFO_TOGGLE == self.cur_toggle then
		return
	end

	ViewManager.Instance:Close(ViewName.Warehouse) --关闭仓库
	local table_index = self:GetShowIndex()
	-- 显示角色切换到非战斗状态
	self:ShowIndex(TabIndex.role_intro)

	if self.package_view then
		self.package_view:SetRecycleContentState(false)
	end
	self.cur_toggle = INFO_TOGGLE
end

--点击背包按钮
function PlayerView:HandleOpenPackage()
	self:OnSwitchToShenEquip(false)
	if PACK_TOGGLE == self.cur_toggle then
		if self.package_view and (self.package_view:GetRecycleViewState() or self.package_view:GetWareHourseState()) then
			if self.equip_view_obj then
				self.equip_view_obj:SetActive(false)
			end
			if self.deity_suit_view_obj then
				self.deity_suit_view_obj:SetActive(false)
			end
		end
		return
	end

	local table_index = self:GetShowIndex()
	ViewManager.Instance:Close(ViewName.Warehouse)--关闭仓库
	self:ShowIndex(TabIndex.role_bag)
	if self.package_view then
		self.package_view:SetDefualtShowState()
		self.package_view:OpenCallBack()
	end
	self:Flush()

	self.cur_toggle = PACK_TOGGLE
end

--点击时装按钮
function PlayerView:HandleOpenFashion()
	if FASHION_TOGGLE == self.cur_toggle then
		return
	end

	local table_index = self:GetShowIndex()
	ViewManager.Instance:Close(ViewName.Warehouse)--关闭仓库
	if self.fashion_view then
		self.fashion_view:OpenCallBack()
	end
	self:ShowIndex(TabIndex.role_fashion)
	if self.package_view then
		self.package_view:SetRecycleContentState(false)
	end

	self.cur_toggle = FASHION_TOGGLE
end

--点击称号按钮
function PlayerView:HandleOpenTitle()
	if TITLE_TOGGLE == self.cur_toggle then
		return
	end
	ViewManager.Instance:Close(ViewName.Warehouse)--关闭仓库
	if self.title_view then
		self.title_view:Flush()
	end
	self:ShowIndex(TabIndex.role_title)
	if self.package_view then
		self.package_view:SetRecycleContentState(false)
	end

	self.cur_toggle = TITLE_TOGGLE

end

function PlayerView:HandleCloseAttrTips()
	if self.title_view then
		self.title_view:SetAllAttributeFalse()
	end
end

function PlayerView:HandleAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

--点击技能按钮
function PlayerView:HandleOpenSkill()
	if SKILL_TOGGLE == self.cur_toggle then
		return
	end
	ViewManager.Instance:Close(ViewName.Warehouse)--关闭仓库
	if self.package_view then
		self.package_view:SetRecycleContentState(false)
	end

	self.cur_toggle = SKILL_TOGGLE
end

--点击转生按钮
function PlayerView:HandleOpenZhuanSheng()
	if ZHUANSHENG_TOGGLE == self.cur_toggle then
		return
	end

	local table_index = self:GetShowIndex()
	-- self:SetSceneMaskState(table_index == TabIndex.role_skill)

	ViewManager.Instance:Close(ViewName.Warehouse)--关闭仓库
	if self.zhuansheng_view then
		self.zhuansheng_view:SetDefultToggle()
		self.zhuansheng_view:FlushWeaponViewInfo()
	end
	ZhuanShengData.Instance:ResetRecoveryEquipList()
	self:ShowIndex(TabIndex.role_rebirth)
	-- if self.skill_view then
	-- 	self.skill_view:StopLevelUp()
	-- end

	if self.package_view then
		self.package_view:SetRecycleContentState(false)
	end
	local call_back = function(model, obj)
		local main_role = Scene.Instance:GetMainRole()
		local res_id = main_role and main_role:GetRoleResId() or 0
		local cfg = model:GetModelDisplayParameterCfg(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.ROLE], 001001)
		if obj then
			if cfg then
				obj.transform.localPosition = cfg.position
				obj.transform.localRotation = Quaternion.Euler(cfg.rotation.x, cfg.rotation.y, cfg.rotation.z)
				obj.transform.localScale = cfg.scale
			else
				obj.transform.localPosition = Vector3(0, 0, 0)
				obj.transform.localRotation = Quaternion.Euler(0, 0, 0)
				obj.transform.localScale = Vector3(1, 1, 1)
			end
		end
		model:SetTrigger("rest")
	end

	self.cur_toggle = ZHUANSHENG_TOGGLE
end

function PlayerView:HandleOpenShenBing()
	if SHENBING_TOGGLE == self.cur_toggle then
		return
	end

	ViewManager.Instance:Close(ViewName.Warehouse)--关闭仓库
	self:ShowIndex(TabIndex.role_shenbing)
	if self.shenbing_view then
		self.shenbing_view:Flush()
	end

	if self.package_view then
		self.package_view:SetRecycleContentState(false)
	end

	self.cur_toggle = SHENBING_TOGGLE
end

function PlayerView:HandleOpenCool()
	if COOL_CHAT == self.cur_toggle then
		return
	end
	self.cur_toggle = COOL_CHAT
	self:ShowIndex(TabIndex.role_cool_chat)
	self.cool_chat_view:Flush()
end

function PlayerView:HandleOpenForge()
	if FORGE_TOGGLE == self.cur_toggle then
		return
	end
	self:ShowIndex(TabIndex.forge)
	self.forge_view:Flush()
	self.cur_toggle = FORGE_TOGGLE
end

function PlayerView:OnSwitchToShenEquip(is_switch)
	if self.package_content ~= nil then
		self.package_content:SetActive(not is_switch)
	end

	if self.deity_suit_view_obj ~= nil then
		self.deity_suit_view_obj:SetActive(is_switch)
	end

	if self.package_view and (self.package_view:GetWareHourseState() or self.package_view:GetRecycleViewState())then
		if self.equip_view_obj ~= nil then
			self.equip_view_obj:SetActive(false)
		end
	else
		if self.equip_view_obj ~= nil then
			self.equip_view_obj:SetActive(not is_switch)
		end
	end

	if is_switch and self.deity_suit_view then
		self.deity_suit_view:Flush()
	elseif self.package_view then
		self.package_view:FlushBagView()
	end
	self.is_switch_to_deity_suit = is_switch
end

-- 角色被拖转动事件
function PlayerView:OnRoleDrag(data)

end

function PlayerView:SetRoleFight(enable)
	-- UIScene:SetFightBool(enable)
end

function PlayerView:FlushRolePackageView(item_index)
	--self:Flush("all", {index = item_index or -1})
	item_index = item_index or -1
	self:Flush("all", {["index" .. item_index] = item_index})
end

function PlayerView:ShowOrHideRoleDress(isOrnot)
	self.equip_view_obj:SetActive(isOrnot)
end

function PlayerView:InitTab()
	if not self:IsOpen() then return end
	local open_fun_data = OpenFunData.Instance
	self.toggle_info:SetActive(open_fun_data:CheckIsHide("InfoContent"))
	self.toggle_package:SetActive(open_fun_data:CheckIsHide("PackageContent"))
	self.toggle_fashion:SetActive(open_fun_data:CheckIsHide("FashionContent"))
	self.toggle_title:SetActive(open_fun_data:CheckIsHide("TitlePanel"))
	self.toggle_cool_chat:SetActive(open_fun_data:CheckIsHide("ChatFunConent"))
	self.toggle_skill:SetActive(false)
	self.toggle_zhuanshen:SetActive(false)
	self.toggle_shenbing:SetActive(false)
end

function PlayerView:FlushSkillView()
	-- if self.skill_view then
	-- 	self.skill_view:FlushSkillExpInfo()
	-- end
end

function PlayerView:OnFlush(param_t)
	local cur_index = self:GetShowIndex()
	for k, v in pairs(param_t) do
		if k == "all" then
			if cur_index == TabIndex.role_bag and not v.to_ui_name then
				if self.package_view then
					self.package_view:FlushBagView(v)
				end
				self.toggle_package.toggle.isOn = true
			elseif cur_index == TabIndex.role_skill then

			elseif cur_index == TabIndex.role_cool_chat then 	-- 酷聊
				self.cool_chat_view:Flush()
			elseif cur_index == TabIndex.role_rebirth then
				if self.zhuansheng_view ~= nil then
					self.zhuansheng_view:FlushWeaponViewInfo()
					-- self.zhuansheng_view:FlushResolveViewInfo()
				end
			elseif cur_index == TabIndex.role_title then
				if self.title_view then
					self.title_view:Flush()
				end
			elseif cur_index == TabIndex.role_fashion then
				self.fashion_view:Flush()
			elseif cur_index == TabIndex.forge then
				if self.forge_view then
					self.forge_view:Flush()
				end
			elseif v.to_ui_name and "shenzhuang_view" == v.to_ui_name then
				if cur_index == TabIndex.role_bag then
					self:OnSwitchToShenEquip(true)
				end
			end

			if self.deity_suit_view and self.deity_suit_view_obj.gameObject.activeSelf then
				self.deity_suit_view:Flush()
			end
		elseif k == "bag" then
			if self.package_view then
				self.package_view:FlushBagView(v)
			end
		elseif k == "bag_recycle" then
			GlobalTimerQuest:AddDelayTimer(function()
				if self.package_view then
					self.package_view:FlushBagView()
					self.package_view:HandleOpenRecycle()
				end
			end, 0)
		elseif k == "title_change" then
			if self.title_view then
				self.title_view:Flush()
			end
		elseif k == "shen_bing" then
			if self.shenbing_view then
				self.shenbing_view:Flush()
			end
		elseif k == "cool_chat" then
			-- if self.cool_chat_view then
				self.cool_chat_view:Flush(v[1])
			-- end
		elseif k == "big_face" then
			if self.cool_chat_view then
				self.cool_chat_view:Flush(v[1])
			end
		elseif k == "bubble" then
			if self.cool_chat_view then
				self.cool_chat_view:Flush(v[1])
			end
		elseif k == "info_view_close" then
			if self.info_view then
				self.info_view:Flush("info_view_close")
			end
		elseif k == "equip_view_close" then
			if self.equip_view then
				self.equip_view:CloseCallBack()
			end
		elseif k == "package_view_close" then
			if self.package_view then
				self.package_view:CloseCallBack()
			end
		elseif k == "fashion_view_close" then
			if self.fashion_view then
				self.fashion_view:Flush("fashion_view_close")
			end
		elseif k == "fashion_icon" then
			if self.fashion_view then
				self.fashion_view:Flush("fashion_icon")
			end
		elseif k == "fashion_data" then
			if self.fashion_view then
				self.fashion_view:Flush("fashion_data")
			end
		elseif k == "cur_fashion" then
			if self.fashion_view then
				self.fashion_view:Flush("cur_fashion")
			end
		elseif k == "forge_item" then
			if self.forge_view then
				self.forge_view:UpItemCellData()
			end
		elseif k == "forge_exp" then
			if self.forge_view then
				self.forge_view:ShowaddExp(v)
			end
		elseif k == "equip_Change" then
			if self.equip_view then
				self.equip_view:OnEquipDataListChange()
			end
		elseif k == "deity_suit_change" then
			if self.deity_suit_view and self.deity_suit_view_obj.gameObject.activeSelf then
				self.deity_suit_view:Flush()
			end
		end
	end
end

function PlayerView:OnChangeToggle(index)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if index == TabIndex.role_bag then
		self.toggle_package.toggle.isOn = true
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
		end
	elseif ui_name == GuideUIName.TabEquip then
		if self.tab_equip and self.tab_equip.gameObject.activeInHierarchy then
			if self.tab_equip.toggle.isOn then
				return NextGuideStepFlag
			end
			local callback = BindTool.Bind(self.PackBagEquipClick, self)
			return self.tab_equip, callback
		end
	elseif ui_name == GuideUIName.TouXianUp then
		local tou_xian_up = TouXianCtrl.Instance:GetUpButton()
		local callback = TouXianCtrl.Instance:GetClick()
		if tou_xian_up and callback then
			return tou_xian_up, callback
		end
	elseif ui_name == GuideUIName.TouXianClose then
		local close_btn = TouXianCtrl.Instance:GetCloseBtn()
		local callback = TouXianCtrl.Instance:GetCloseClick()
		if close_btn and callback then
			return close_btn, callback
		end
	elseif self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	end
end