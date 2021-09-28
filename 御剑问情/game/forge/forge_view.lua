require("game/forge/forge_role_equip_bar")
require("game/forge/forge_strengthen_view")
require("game/forge/forge_gem_view")
-- require("game/forge/forge_quality_view")
require("game/forge/forge_cast_view")
require("game/forge/forge_upstar_view")
require("game/forge/forge_suit_view")
require("game/forge/forge_red_equip_view")
require("game/forge/forge_yongheng_view")

ForgeView = ForgeView or BaseClass(BaseView)

function ForgeView:__init()
	self.ui_config = {"uis/views/forgeview_prefab", "ForgeView"}
	self.full_screen = true
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true

	if self.audio_config then
		self.open_audio_id = AssetID("audios/sfxs/uis", self.audio_config.other[1].OpenDuanzao)
	end

	self.role_equip_bar = nil
	self.strengthen_view = nil
	self.gem_view = nil
	self.cast_view = nil

	self.def_index = TabIndex.forge_strengthen

	self.money_change_callback = BindTool.Bind(self.PlayerDataChangeCallback, self)
	self.equip_change_callback = BindTool.Bind(self.OnEquipDataChange, self)
	self.item_change_callback = BindTool.Bind(self.OnItemDataChange, self)
end

function ForgeView:__delete()
	if self.global_event ~= nil then
		GlobalEventSystem:UnBind(self.global_event)
		self.global_event = nil
	end
end

function ForgeView:OpenTrigger()
	if self:IsOpen() then
		local is_open_strengthen = OpenFunData.Instance:CheckIsHide("forge_strengthen")
		local is_open_baoshi = OpenFunData.Instance:CheckIsHide("forge_baoshi")
		local is_open_cast = OpenFunData.Instance:CheckIsHide("forge_cast")
		local is_open_up_star = OpenFunData.Instance:CheckIsHide("forge_up_star")
		local is_open_suit = OpenFunData.Instance:CheckIsHide("forge_suit")
		local is_open_compose = OpenFunData.Instance:CheckIsHide("forge_compose")
		local is_open_yongheng = OpenFunData.Instance:CheckIsHide("forge_yongheng")
		local is_open_red_equip = OpenFunData.Instance:CheckIsHide("forge_red_equip")

		if not is_open_strengthen then
			print_error("强化功能未开启")
			self.is_open_strengthen:SetValue(true)
			return
		end

		self.is_open_strengthen:SetValue(is_open_strengthen)
		self.is_open_baoshi:SetValue(is_open_baoshi)
		self.is_open_cast:SetValue(is_open_cast)
		self.is_open_up_star:SetValue(is_open_up_star)
		self.is_open_suit:SetValue(is_open_suit)
		self.is_open_compose:SetValue(false)
		self.is_open_yongheng:SetValue(is_open_yongheng)
		self.is_open_red_equip:SetValue(is_open_red_equip)
	end
end

-- function ForgeView:OnClose()
-- 	if self.global_event ~= nil then
-- 		GlobalEventSystem:UnBind(self.global_event)
-- 		self.global_event = nil
-- 	end
-- 	self:Close()
-- end

function ForgeView:OnItemDataChange()
	if self:IsLoaded() and self.gem_view and self.now_view then
		self.role_equip_bar:OnEquipDataChange()
		if self.now_view == self.gem_view then
			self.gem_view:Flush()
		elseif self.now_view == self.strengthen_view or self.now_view == self.cast_view then
			self.now_view:StuffCommonFlush()
		end
	end
	if self:IsLoaded() and self.now_view and self.now_view == self.strengthen_view then
		self.role_equip_bar:OnEquipDataChange()
		self.strengthen_view:Flush()
	end

	if self:IsLoaded() and self.now_view and self.now_view == self.red_equip_view then
		self.role_equip_bar:OnEquipDataChange()
		self.red_equip_view:Flush()
	end

	if self:IsLoaded() and self.now_view and self.now_view == self.yongheng_view then
		self.role_equip_bar:OnEquipDataChange()
		self.yongheng_view:Flush()
	end
end

function ForgeView:HandleAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function ForgeView:ReleaseCallBack()
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.Forge)
	end

	if self.role_equip_bar then
		self.role_equip_bar:DeleteMe()
		self.role_equip_bar = nil
	end

	if self.strengthen_view then
		self.strengthen_view:DeleteMe()
		self.strengthen_view = nil
	end

	if self.gem_view then
		self.gem_view:DeleteMe()
		self.gem_view = nil
	end

	if self.cast_view then
		self.cast_view:DeleteMe()
		self.cast_view = nil
	end

	if self.up_star_view then
		self.up_star_view:DeleteMe()
		self.up_star_view = nil
	end

	if self.suit_view then
		self.suit_view:DeleteMe()
		self.suit_view = nil
	end

	if self.compose_view then
		self.compose_view:DeleteMe()
		self.compose_view = nil
	end

	if self.yongheng_view then
		self.yongheng_view:DeleteMe()
		self.yongheng_view = nil
	end

	if self.red_equip_view then
		self.red_equip_view:DeleteMe()
		self.red_equip_view = nil
	end

	if nil ~= self.delay_flush then
   		GlobalTimerQuest:CancelQuest(self.delay_flush)
   		self.delay_flush = nil
	end

	-- EquipData.Instance:UnNotifyDataChangeCallBack(self.equip_change_callback)
	PlayerData.Instance:UnlistenerAttrChange(self.money_change_callback)
	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_change_callback)

	-- 清理变量和对象
	self.equip_bar_obj = nil
	self.tab_strengthen = nil
	self.strengthen_toggle = nil
	self.tab_gems = nil
	self.gems_toggle = nil
	self.tab_cast = nil
	self.cast_toggle = nil
	self.tab_up_star = nil
	self.up_star_toggle = nil
	self.suit_toggle = nil
	self.compose_toggle = nil
	self.toggle_list = nil
	self.diamond = nil
	self.bind_gold = nil
	self.red_point_list = nil
	self.btn_close = nil
	self.is_open_strengthen = nil
	self.is_open_baoshi = nil
	self.is_open_cast = nil
	self.is_open_up_star = nil
	self.is_open_suit = nil
	self.is_open_compose = nil
	self.equip_bar = nil
	self.btn_strength = nil
	self.now_view = nil
	self.up_star_btn = nil
	self.bipin_icon_list = nil
	self.is_open_yongheng = nil
	self.is_open_red_equip = nil
	self.red_equip_toggle = nil
	self.yongheng_toggle = nil
	self.yongheng_content = nil

	self.list = nil

	self.strengthen_content = nil

	self.gem_content = nil

	self.cast_content = nil

	self.up_star_content = nil

	self.suit_content = nil

	self.red_equip_content = nil

	if self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end
end

function ForgeView:OpenCallBack()
	self.time_bipin_quest = GlobalEventSystem:Bind(OtherEventType.PASS_DAY, BindTool.Bind(self.SetBiPinIcon, self))
	self.auto_select = true
	self:OpenTrigger()
	ForgeCtrl.Instance:SendStoneInfo()
	EquipData.Instance:NotifyDataChangeCallBack(self.equip_change_callback)

	self:SetBiPinIcon()
end

function ForgeView:OnClickBiPin()
	ViewManager.Instance:Open(ViewName.CompetitionActivity)
	self:Close()
end

function ForgeView:SetBiPinIcon()
	-- for k, v in pairs(COMPETITION_ACTIVITY_TYPE) do
	-- 	if self.bipin_icon_list[k] then
	-- 		self.bipin_icon_list[k]:SetValue(ActivityData.Instance:GetActivityIsOpen(v))
	-- 	end
	-- end
end

function ForgeView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "after_compose" and self.compose_view then
			self.compose_view:AfterComposeResult()
		elseif k == "shen_zhu_star" and self.show_index == TabIndex.forge_cast and self.cast_view then
			self.cast_view:Flush()
		elseif k == "shen_fly_effect" and self.show_index == TabIndex.forge_cast and self.cast_view then
			self.cast_view:Flush("shen_fly_effect")
		end
	end
	if self.show_index == TabIndex.forge_compose and self.compose_view then
		self.compose_view:FlushRightView()
	end

	if self.show_index == TabIndex.forge_suit and self.forge_suit_view then
		self.forge_suit_view:FlushEquiCell()
	end
end

function ForgeView:CloseCallBack()
	self.auto_select = true
	if self.up_star_view then
		self.up_star_view:CloseUpStarView()
	end
	if self.strengthen_view then
		self.strengthen_view:CloseUpStarView()
	end
	if self.cast_view then
		self.cast_view:CloseUpStarView()
	end
	if self.gem_view then
		self.gem_view:CloseUpStarView()
	end

	if self.time_bipin_quest ~= nil then
		GlobalEventSystem:UnBind(self.time_bipin_quest)
		self.time_bipin_quest = nil
	end

	if nil ~= self.red_equip_view then
		self.red_equip_view:CloseCallBack()
	end

	EquipData.Instance:UnNotifyDataChangeCallBack(self.equip_change_callback)
end

--得到滚动条中选中装备
function ForgeView:GetSelectData()
	return self.role_equip_bar:GetSelectData()
end

function ForgeView:SetClickCallBack(index, func)
	self.role_equip_bar:SetClickCallBack(index, func)
end

function ForgeView:LoadCallBack(index)
	--监听关闭按钮
	self:ListenEvent("CloseForgeView", BindTool.Bind(self.Close, self))
	self:ListenEvent("AddGold", BindTool.Bind(self.HandleAddGold, self))
	self:ListenEvent("OnClickBiPin", BindTool.Bind(self.OnClickBiPin, self))

	--角色装备条
	self.equip_bar_obj = self:FindObj("RoleEquipBar")
	self.role_equip_bar = RoleEquipBar.New(self.equip_bar_obj)

	self.list = self:FindObj("List")

	self.bipin_icon_list = {}
	self.bipin_icon_list[6] = self:FindVariable("ShowStrengthBiPin")
	self.bipin_icon_list[7] = self:FindVariable("ShowGemstonBiPin")

	--强化面板
	self.strengthen_content = self:FindObj("StrengthenContent")

	--宝石面板
	self.gem_content = self:FindObj("GemContent")

	--神铸面板
	self.cast_content = self:FindObj("CastContent")

	--升星面板
	self.up_star_content = self:FindObj("UpStarContent")

	--套装面板
	self.suit_content = self:FindObj("SuitContent")

	-- 永恒面板
	self.yongheng_content = self:FindObj("YongHengContent")

	-- 红装面板
	self.red_equip_content = self:FindObj("RedEquipContent")

	--强化Toggle
	self.tab_strengthen = self:FindObj("TabStrengthen")
	self.strengthen_toggle = self.tab_strengthen.toggle
	self.strengthen_toggle:AddValueChangedListener(
	BindTool.Bind(self.OnClickTab, self, TabIndex.forge_strengthen))
	self.strengthen_toggle.isOn = false
	--宝石Toggle
	self.tab_gems = self:FindObj("TabGem")
	self.gems_toggle = self.tab_gems.toggle
	self.gems_toggle:AddValueChangedListener(
	BindTool.Bind(self.OnClickTab, self, TabIndex.forge_baoshi))
	self.gems_toggle.isOn = false
	--神铸Toggle
	self.tab_cast = self:FindObj("TabCast")
	self.cast_toggle = self.tab_cast.toggle
	self.cast_toggle:AddValueChangedListener(
	BindTool.Bind(self.OnClickTab, self, TabIndex.forge_cast))
	self.cast_toggle.isOn = false

	--升星
	self.tab_up_star = self:FindObj("TabUpStar")
	self.up_star_toggle = self.tab_up_star.toggle
	self.up_star_toggle:AddValueChangedListener(
	BindTool.Bind(self.OnClickTab, self, TabIndex.forge_up_star))
	self.up_star_toggle.isOn = false

	--套装
	self.suit_toggle = self:FindObj("TabSuit").toggle
	self.suit_toggle:AddValueChangedListener(
	BindTool.Bind(self.OnClickTab, self, TabIndex.forge_suit))
	self.suit_toggle.isOn = false

	--合成
	self.compose_toggle = self:FindObj("TabCompose").toggle
	self.compose_toggle:AddValueChangedListener(
	BindTool.Bind(self.OnClickTab, self, TabIndex.forge_compose))
	self.compose_toggle.isOn = false

	-- 永恒
	self.yongheng_toggle = self:FindObj("TabYongHeng").toggle
	self.yongheng_toggle:AddValueChangedListener(
	BindTool.Bind(self.OnClickTab, self, TabIndex.forge_yongheng))
	self.yongheng_toggle.isOn = false

	-- 红装
	self.red_equip_toggle = self:FindObj("TabRedEquip").toggle
	self.red_equip_toggle:AddValueChangedListener(
	BindTool.Bind(self.OnClickTab, self, TabIndex.forge_red_equip))
	self.red_equip_toggle.isOn = false

	self.toggle_list = {
		[TabIndex.forge_strengthen] = self.strengthen_toggle,
		[TabIndex.forge_baoshi] = self.gems_toggle,
		[TabIndex.forge_cast] = self.cast_toggle,
		[TabIndex.forge_up_star] = self.up_star_toggle,
		[TabIndex.forge_suit] = self.suit_toggle,
		[TabIndex.forge_compose] = self.compose_toggle,
		[TabIndex.forge_yongheng] = self.yongheng_toggle,
		[TabIndex.forge_red_equip] = self.red_equip_toggle,
	}

	-- 钻石
	self.diamond = self:FindVariable("Diamond")
	self.bind_gold = self:FindVariable("bind_gold")
	-- 首次执行时读取一次
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])

	-- EquipData.Instance:NotifyDataChangeCallBack(self.equip_change_callback)
	PlayerData.Instance:ListenerAttrChange(self.money_change_callback)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_change_callback)

	-- self.frist_equip_item = self:FindObj("FristEquipItem")				--第一个装备按钮
	self.btn_close = self:FindObj("BtnClose")								--关闭按钮

	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.Forge, BindTool.Bind(self.GetUiCallBack, self))

	self.is_open_strengthen = self:FindVariable("is_open_strengthen")
	self.is_open_baoshi = self:FindVariable("is_open_baoshi")
	self.is_open_cast = self:FindVariable("is_open_cast")
	self.is_open_up_star = self:FindVariable("is_open_up_star")
	self.is_open_suit = self:FindVariable("is_open_suit")
	self.is_open_compose = self:FindVariable("is_open_compose")
	self.is_open_yongheng = self:FindVariable("is_open_yongheng")
	self.is_open_red_equip = self:FindVariable("is_open_red_equip")

	-- self.equip_bar = self:FindObj("EquipBar")
	-- self.equip_bar_pos = self.equip_bar.rect.localPosition

	self.red_point_list = {
		[RemindName.ForgeStrengthen] = self:FindVariable("StrengthenRedPoint"),
		[RemindName.ForgeBaoshi] = self:FindVariable("BaoShiRedPoint"),
		[RemindName.ForgeCast] = self:FindVariable("CastRedPoint"),
		[RemindName.ForgeUpStar] = self:FindVariable("UpStarRedPoint"),
		[RemindName.ForgeSuit] = self:FindVariable("SuitRedPoint"),
		[RemindName.ForgeYongheng] = self:FindVariable("ShowYongHengRedPoint"),
		[RemindName.ForgeRedEquip] = self:FindVariable("RedEquipRedPoint"),
	}

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	for k, _ in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end
end

function ForgeView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetValue(num > 0)
	end
end

-- 玩家钻石改变时
function ForgeView:PlayerDataChangeCallback(attr_name, value)
	if attr_name == "gold" then
		self.diamond:SetValue(CommonDataManager.ConverMoney(value))
	end

	if attr_name == "bind_gold" then
		self.bind_gold:SetValue(CommonDataManager.ConverMoney(value))
	end
end

--装备强化后回调函数
function ForgeView:OnAfterStrengthen(result)
	if self.strengthen_view then
		self.strengthen_view:OnAfterStrengthen(result)
	end
end

--套装强化后回调
function ForgeView:OnSuitStrengthenCallBack()
	if self.suit_view then
		self.suit_view:StrengthEndCallBack()
	end
end

--实际刷新的函数
local doFlushView =
{
	[TabIndex.forge_strengthen] = function(self)
		--在这里初始化强化
		ForgeData.Instance:SetCurOpenViewIndex(1)
		self.now_view = self.strengthen_view
		if self.strengthen_view then
			self.strengthen_view:OpenCallback()
			self:AutoSelect(true)
		end
		self.strengthen_toggle.isOn = true

	end,
	[TabIndex.forge_baoshi] = function(self)
		--在这里初始化宝石
		ForgeData.Instance:SetCurOpenViewIndex(2)
		self.now_view = self.gem_view
		if self.gem_view then
			self.gem_view:OpenCallback()
			self.gem_view:Flush()
			self:AutoSelect(true)
		end
		self.gems_toggle.isOn = true
	end,
		[TabIndex.forge_cast] = function(self)
		--在这里初始化神铸
		ForgeData.Instance:SetCurOpenViewIndex(3)
		self.cast_toggle.isOn = true
		self.now_view = self.cast_view
		if self.cast_view then
			self.cast_view:Flush()
			self:AutoSelect(true)
		end
	end,
	[TabIndex.forge_up_star] = function(self)
		ForgeData.Instance:SetCurOpenViewIndex(4)
		--在这里初始化升星
		self.up_star_toggle.isOn = true
		self.now_view = self.up_star_view
		if self.up_star_view then
			self.up_star_view:FristFlushView()
		end
	end,

	[TabIndex.forge_suit] = function(self)
		ForgeData.Instance:SetCurOpenViewIndex(5)
		--在这里初始化套装
		self.suit_toggle.isOn = true
		self.now_view = self.suit_view
		if self.suit_view then
			self.suit_view:FristFlushView()
		end
	end,

	[TabIndex.forge_compose] = function(self)
		ForgeData.Instance:SetCurOpenViewIndex(6)
		--在这里初始化套装
		self.compose_toggle.isOn = true
		self.now_view = self.compose_view
		if self.compose_view then
			self.compose_view:FlushRightView()
		end
	end,

	[TabIndex.forge_red_equip] = function(self)
		ForgeData.Instance:SetCurOpenViewIndex(7)
		--在这里初始化
		self.red_equip_toggle.isOn = true
		self.now_view = self.red_equip_view
		if self.red_equip_view then
			self:AutoSelect(true)
			self:AutoScroll()
			self.red_equip_view:Flush()
		end
	end,

	[TabIndex.forge_yongheng] = function(self)
		ForgeData.Instance:SetCurOpenViewIndex(8)
		--在这里初始化
		self.yongheng_toggle.isOn = true
		self.now_view = self.yongheng_view
		if self.yongheng_view then
			self.yongheng_view:Flush()
		end
	end,
}

--自动选择
function ForgeView:SetTargetEquipIndex(index)
	self.target_equip_index = index
end

--自动选择
function ForgeView:AutoSelect(select_first)
	if self.target_equip_index ~= nil then
		self.role_equip_bar:SetToggle(self.target_equip_index)
		self.target_equip_index = nil
		return
	end
	if select_first then
		if self.auto_select then
			local can_improve_equip = ForgeData.Instance:GetCanImproveEquip(self.show_index)
			if can_improve_equip ~= nil then
				self.role_equip_bar:SetToggle(can_improve_equip.index)
			else
				self.role_equip_bar:SelectFirst()
			end
			self.auto_select = false
		end

		if self.show_index == TabIndex.forge_red_equip then
			self.role_equip_bar:SelectFirst()
		else
			local cur_index = self.role_equip_bar:GetCurSelectIndex()
			self.role_equip_bar:SetToggle(cur_index)
		end
	else
		local data = self:GetSelectData()
		if data.item_id == nil then
			return
		end
		if not (ForgeData.Instance:CheckIsCanImprove(data, self.show_index) == 0) then
			local can_improve_equip = ForgeData.Instance:GetCanImproveEquip(self.show_index)
			if can_improve_equip ~= nil then
				self.role_equip_bar:SetToggle(can_improve_equip.index)
			end
		end
	end
end

-- 没办法，方法执行时，还未生成格子，只能预定义
local element_height = 107
function ForgeView:AutoScroll()
	local number = 0
	for i=0,COMMON_CONSTS.MAX_CAN_FORGE_EQUIP_NUM - 1 do
		local id = self.role_equip_bar.equip_data[i].item_id
		if self.show_index == TabIndex.forge_red_equip then
			if ForgeData.Instance:CheckEquipCanSelect(self.role_equip_bar.equip_data[i]) then
				number = i
			end
		else
			if id ~= nil and id ~= 0 then
				number = i
			end
		end
	end
	-- 格子大小为 单个元素的大小加上间距
	local cell_height = element_height + self.equip_bar_obj:GetComponent(typeof(UnityEngine.UI.LayoutGroup)).spacing
	-- 总大小为 所有格子个数*格子大小 - 一个间距
	local total = (#self.role_equip_bar.equip_data + 1) * cell_height - self.equip_bar_obj:GetComponent(typeof(UnityEngine.UI.LayoutGroup)).spacing
	-- 页面大小
	local page_height = self.list.rect.rect.height
	local value = number * cell_height / (total - page_height)
	if value > 1 then
		value = 1
	end
	self.list.scroll_rect.verticalNormalizedPosition = 1 - value
end

--身上装备改变后的回调函数
function ForgeView:OnEquipDataChange()
	if not self:IsLoaded() then
		return
	end
	if self.now_view == self.gem_view then
		return
	end
	if self.equip_bar_obj.gameObject.activeInHierarchy then
		self.role_equip_bar:OnEquipDataChange()
	end
	if self.now_view ~= nil then
		if self.now_view ~= self.up_star_view and self.now_view ~= self.compose_view then
			self.now_view:Flush()
		end
	end
	-- self:AutoSelect()
end

--Toggle按下后
function ForgeView:OnClickTab(index, is_on)
	if is_on then
		self:HandleToggleChangeIndex(index)
	end
end

--处理Toggle的点击事件
function ForgeView:HandleToggleChangeIndex(index)
	self:ChangeToIndex(index)
	--之后会调用ShowIndexCallBack
end

--决定显示那个界面
function ForgeView:ShowIndexCallBack(index)
	-- 加载界面
	if index == TabIndex.forge_strengthen then
		if self.strengthen_content.transform.childCount == 0 then
			UtilU3d.PrefabLoad(
				"uis/views/forgeview_prefab",
				"StrengthContent",
				function(obj)
					obj.transform:SetParent(self.strengthen_content.transform, false)
					obj = U3DObject(obj)
					self.strengthen_view = ForgeStrengthen.New(obj, self)
					self.now_view = self.strengthen_view
					self.btn_strength = self.strengthen_view.btn_strength					--强化按钮
					self:AutoSelect(true)
					doFlushView[index](self)
				end)
		end
	elseif index == TabIndex.forge_baoshi then
		if self.gem_content.transform.childCount == 0 then
			UtilU3d.PrefabLoad(
				"uis/views/forgeview_prefab",
				"GemContent",
				function(obj)
					obj.transform:SetParent(self.gem_content.transform, false)
					obj = U3DObject(obj)
					self.gem_view = ForgeGem.New(obj, self)
					self.now_view = self.gem_view
					self.gem_view:OpenCallback()
					self.gem_view:Flush()
					self:AutoSelect(true)
					doFlushView[index](self)
				end)
		end
	elseif index == TabIndex.forge_cast then
		if self.cast_content.transform.childCount == 0 then
			UtilU3d.PrefabLoad(
				"uis/views/forgeview_prefab",
				"CastContent",
				function(obj)
					obj.transform:SetParent(self.cast_content.transform, false)
					obj = U3DObject(obj)
					self.cast_view = ForgeCast.New(obj, self)
					self.now_view = self.cast_view
					self.cast_view:OpenCallback()
					self.cast_view:Flush()
					self:AutoSelect(true)
					doFlushView[index](self)
				end)
		end
	elseif index == TabIndex.forge_up_star then
		if self.up_star_content.transform.childCount == 0 then
			UtilU3d.PrefabLoad(
				"uis/views/forgeview_prefab",
				"UpStarContent",
				function(obj)
					obj.transform:SetParent(self.up_star_content.transform, false)
					obj = U3DObject(obj)
					self.up_star_view = ForgeUpStarView.New(obj, self)
					self.up_star_btn = self.up_star_view.up_star_btn	--升星按钮
					doFlushView[index](self)
					-- self.now_view = self.up_star_view
				end)
		end
	elseif index == TabIndex.forge_suit then
		if self.suit_content.transform.childCount == 0 then
			UtilU3d.PrefabLoad(
				"uis/views/forgeview_prefab",
				"SuitContent",
				function(obj)
					obj.transform:SetParent(self.suit_content.transform, false)
					obj = U3DObject(obj)
					self.suit_view = ForgeSuitView.New(obj, self)
					doFlushView[index](self)
					-- self.now_view = self.suit_view
				end)
		end
	elseif index == TabIndex.forge_yongheng then
		if self.yongheng_content.transform.childCount == 0 then
			UtilU3d.PrefabLoad(
				"uis/views/forgeview_prefab",
				"YongHengContent",
				function(obj)
					obj.transform:SetParent(self.yongheng_content.transform, false)
					obj = U3DObject(obj)
					self.yongheng_view = ForgeYongHengView.New(obj, self)
					self.yongheng_view:Flush()
					doFlushView[index](self)
				end)
		end
	elseif index == TabIndex.forge_red_equip then
		if self.red_equip_content.transform.childCount == 0 then
			UtilU3d.PrefabLoad(
				"uis/views/forgeview_prefab",
				"RedEquipContent",
				function(obj)
					obj.transform:SetParent(self.red_equip_content.transform, false)
					obj = U3DObject(obj)
					self.red_equip_view = ForgeRedEquipView.New(obj, self)
					doFlushView[index](self)
				end)
		end
		RemindManager.Instance:Fire(RemindName.ForgeRedEquip, true)
	end


	if self.up_star_view then
		self.up_star_view:InitProgess()
	end
	if index == 0 or index == nil then
		index = TabIndex.forge_strengthen
	end
	if index == TabIndex.forge_strengthen or TabIndex.forge_baoshi or TabIndex.forge_cast then
		if not self.role_equip_bar then
			self.equip_bar_obj = self:FindObj("RoleEquipBar")
			self.role_equip_bar = RoleEquipBar.New(self.equip_bar_obj)
		end
		self.role_equip_bar:SetViewIndex(index)
	end

	if index ~= TabIndex.forge_up_star then
		if self.up_star_view then
			self.up_star_view:CloseUpStarView()
		end
	end

	if index ~= TabIndex.forge_red_equip then
		if self.red_equip_view then
			self.red_equip_view:ResetEffect()
		end
	end

	if nil ~= self.delay_flush then
   		GlobalTimerQuest:CancelQuest(self.delay_flush)
   		self.delay_flush = nil
	end
	self.delay_flush = GlobalTimerQuest:AddDelayTimer(function() self.toggle_list[index].gameObject:SetActive(false)
	self.toggle_list[index].gameObject:SetActive(true) end, 0.01)

	local func = doFlushView[index]
	if func ~= nil then
		self.delay_flush = GlobalTimerQuest:AddDelayTimer(function()
			func(self)
		end, 0.01)
	end
	self:Flush()
end

--宝石改变回调
function ForgeView:OnGemChange()
	if self.gem_view ~= nil then
		if self.equip_bar_obj.gameObject.activeInHierarchy then
			self.role_equip_bar:OnEquipDataChange()
		end
		self.gem_view:Flush()
		-- self:AutoSelect()
	end
end

--引导用函数
function ForgeView:SelectFristEquip()
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if self.strengthen_toggle.isOn then
		if self.role_equip_bar.equip_list[0] then
			self.role_equip_bar.equip_list[0].toggle.isOn = true
		end
	end
end

function ForgeView:OnChangeToggle(index)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if index == TabIndex.forge_strengthen then
		self.strengthen_toggle.isOn = true
	elseif index == TabIndex.forge_up_star then
		self.up_star_toggle.isOn = true
	end
end

function ForgeView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if ui_name == GuideUIName.Tab then
		local index = TabIndex[ui_param]
		if index == self.show_index then
			return NextGuideStepFlag
		end
		if index == TabIndex.forge_up_star then
			if self.tab_up_star.gameObject.activeInHierarchy then
				local callback = BindTool.Bind(self.OnChangeToggle, self, TabIndex.forge_up_star)
				return self.tab_up_star, callback
			end
		elseif index == TabIndex.forge_strengthen then
			if self.tab_strengthen.gameObject.activeInHierarchy then
				local callback = BindTool.Bind(self.OnChangeToggle, self, TabIndex.forge_strengthen)
				return self.tab_strengthen, callback
			end
		end
	elseif ui_name == GuideUIName.ForgeFristEquipItem then
		if self[ui_name].gameObject.activeInHierarchy then
			local callback = BindTool.Bind(self.SelectFristEquip, self)
			return self[ui_name], callback
		end
	elseif self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	end
end

function ForgeView:PlaySuccedEffet()
	if nil ~= self.red_equip_view then
		self.red_equip_view:PlaySuccedEffet()
	end
end