GoddessShengWuView = GoddessShengWuView or BaseClass(BaseRender)

function GoddessShengWuView:__init(instance)
	self.uicamera = GameObject.Find("GameRoot/UICamera"):GetComponent(typeof(UnityEngine.Camera))

	self.chou_exp_stuff1 = GoddessData.Instance:GetXianNvChouExpStuff(GODDESS_CHOUEXP_TYPE.COMMON)
	self.chou_exp_stuff2 = GoddessData.Instance:GetXianNvChouExpStuff(GODDESS_CHOUEXP_TYPE.PERFECT)

	self.shengwu_auto_vip_level = GoddessData.Instance:GetXianNvOtherCfg().shengwu_auto_vip_level
	self.shengwu_ten_vip_level = GoddessData.Instance:GetXianNvOtherCfg().shengwu_ten_vip_level

	self.is_can_conmmon_auto = 0
	self.is_can_perfect_auto = 0
	self.is_on_fly = false
	self.is_on_fly_index = 0
	self.is_on_fly_shengwu_id = -1
	self.is_on_fly_chou_list = {}
	self:InitView()
end

function GoddessShengWuView:InitView()
	self.power_value = self:FindVariable("PowerValue")
	self.huiyi_value = self:FindVariable("TextHuiYiShi")
	self.wangmei_value = self:FindVariable("TextWMHuiYiShi")
	self.red_point = self:FindVariable("ShowRedPoint")
	self.text_vip_0 = self:FindVariable("text_vip_0")
	self.text_vip_1 = self:FindVariable("text_vip_1")

	self.view_tip = self:FindVariable("ViewTip")
	self.view_tip:SetValue(Language.Goddess.GoddessShengWuTip)

	for i = 0, 3 do
		self["shengwu_icon" .. i] = GoddessShengWuIconItem.New(self:FindObj("ShengWuIcon" .. i))
		self["shengwu_icon" .. i]:SetShengWuId(i)
		self["fly_end_" .. i] = self:FindObj("fly_end_" .. i)
	end

	-- for i = 0, 5 do
	-- 	self["huiyi_icon" .. i] = GoddessHuiYiIconItem.New(self:FindObj("HuiYi" .. i))
	-- 	self["huiyi_icon" .. i]:SetShengWuId(-1)
	-- end

	self.perfect_button = self:FindObj("PerfectButton")
	self.common_button = self:FindObj("CommonButton")
	self.back_ground = self:FindObj("Background")
	self.fly_start = self.common_button

	self.quick_toggle = self:FindObj("QuickToggle")
	self.quick_toggle.toggle:AddValueChangedListener(BindTool.Bind(self.OnQuickToggleChange, self))

	self.auto_toggle = self:FindObj("AutoToggle")
	self.auto_toggle.toggle:AddValueChangedListener(BindTool.Bind(self.OnAutoToggleChange, self))

	self:ListenEvent("OnClickBtnCommon",BindTool.Bind(self.OnClickBtnCommon, self))
	self:ListenEvent("OnClickBtnPerfect",BindTool.Bind(self.OnClickBtnPerfect, self))
	self:ListenEvent("EventTip", BindTool.Bind(self.OnClickTip, self))
	self:ListenEvent("OnClickGongMingTip", BindTool.Bind(self.OnClickGongMingTip, self))

	-- for i = 0, 5 do
	-- 	self:ListenEvent("OnClickHuiYiIcon" .. i,BindTool.Bind(self.OnClickHuiYiIcon, self, i))
	-- end
	self.icon_image = self:FindVariable("icon_img")
	self.icon_image:SetAsset(ResPath.GetItemIcon(self.chou_exp_stuff1))

	self:Flush()
end

function GoddessShengWuView:__delete()
	for i = 0,3 do
		if nil ~= self["shengwu_icon" .. i] then
			self["shengwu_icon" .. i]:DeleteMe()
			self["shengwu_icon" .. i] = nil
			self["fly_end_" .. i] = nil
		end
	end

	-- for i = 0,5 do
	-- 	if nil ~= self["huiyi_icon" .. i] then
	-- 		self["huiyi_icon" .. i]:DeleteMe()
	-- 		self["huiyi_icon" .. i] = nil
	-- 	end
	-- end
	self.chou_exp_stuff1 = 0
	self.chou_exp_stuff2 = 0
	self.shengwu_auto_vip_level = 0
	self.shengwu_ten_vip_level = 0
	self.power_value = nil
	self.back_ground = nil
	self.common_button = nil
	self.perfect_button = nil
	self.is_on_fly = false
	self.is_on_fly_index = 0
	self.is_on_fly_shengwu_id = -1
	self.is_on_fly_chou_list = {}
	self.red_point = nil
	self.text_vip_0 = nil
	self.text_vip_1 = nil

	self.is_can_conmmon_auto = 0
	self.is_can_perfect_auto = 0
	self:RemoveNotifyDataChangeCallBack()
	self.uicamera = nil
	self.fly_start = nil
end

function GoddessShengWuView:SetNotifyDataChangeCallBack()
	-- 监听系统事件
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
end

function GoddessShengWuView:RemoveNotifyDataChangeCallBack()
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
end

-- 物品不足，购买成功后刷新物品数量
function GoddessShengWuView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	self:UpdataStuffShow()
end

function GoddessShengWuView:OnQuickToggleChange(isOn)
	-- if isOn then
		-- local limit_level = VipPower.Instance:GetMinVipLevelLimit(VIPPOWER.AUTO_SHENGWU_TEN) or 0
		-- if PlayerData.Instance.role_vo.vip_level < limit_level then
		-- 	self.quick_toggle.toggle.isOn = false
		-- 	TipsCtrl.Instance:ShowLockVipView(VIPPOWER.AUTO_SHENGWU_TEN)
		-- end
	-- end
end

function GoddessShengWuView:OnAutoToggleChange(isOn)
	if isOn then
		local limit_level = VipPower.Instance:GetMinVipLevelLimit(VIPPOWER.AUTO_SHENGWU_CHOU) or 0
		if PlayerData.Instance.role_vo.vip_level < limit_level then
			self.auto_toggle.toggle.isOn = false
			TipsCtrl.Instance:ShowLockVipView(VIPPOWER.AUTO_SHENGWU_CHOU)
		end
	end
end

function GoddessShengWuView:OnClickTip()
	TipsCtrl.Instance:ShowHelpTipView(206)
end

function GoddessShengWuView:OnFlush()
	self:UpdataStuffShow()
	self:UpdataVipShow()
	self:UpdataPowerShow()
	self:UpdataShengWuIconShow()
	self:OnUpdataHuiYiIconShow()
	self:FlushRedPoint()
end

function GoddessShengWuView:FlushRedPoint()
	if self.red_point ~= nil then
		self.red_point:SetValue(GoddessData.Instance:GetFaZeRed())
	end
end

function GoddessShengWuView:UpdataShengWuIconShow()
	for i = 0, 3 do
		if self["shengwu_icon" .. i] then
			self["shengwu_icon" .. i]:SetShengWuId(i)
		end
	end
end

function GoddessShengWuView:UpdataVipShow()
	local limit_ten_level = VipPower.Instance:GetMinVipLevelLimit(VIPPOWER.AUTO_SHENGWU_TEN) or 0
	local limit_level = VipPower.Instance:GetMinVipLevelLimit(VIPPOWER.AUTO_SHENGWU_CHOU) or 0
	self.text_vip_1:SetValue(string.format(Language.Goddess.ShengwuVipTip, limit_level))
	-- self.text_vip_0:SetValue(string.format(Language.Goddess.ShengwuVipTip, limit_ten_level))
	self.text_vip_0:SetValue("")
end

function GoddessShengWuView:UpdataStuffShow()
	--self.wangmei_value:SetValue(ItemData.Instance:GetItemNumInBagById(self.chou_exp_stuff2))
	self.wangmei_value:SetValue(GoddessData.Instance:GetOtherByStr("chou_exp_gold"))

	self.chou_exp_stuff1 = GoddessData.Instance:GetXianNvChouExpStuff(GODDESS_CHOUEXP_TYPE.COMMON)

	self.icon_image:SetAsset(ResPath.GetItemIcon(self.chou_exp_stuff1))
	local need_item = ItemData.Instance:GetItemNumInBagById(self.chou_exp_stuff1)
	if need_item <= 0 then
		need_item = ToColorStr(need_item, TEXT_COLOR.RED) 
	end
	self.huiyi_value:SetValue(need_item .. " / 1")

	self:FlushRedPoint()

	GoddessCtrl.Instance:FlushShengWuRed()
end

function GoddessShengWuView:UpdataPowerShow()
	self.cap_data = GoddessData.Instance:GetXiannvShengWuTotalAttr()
	local cap = CommonDataManager.GetCapability(self.cap_data)
	if cap and cap >= 0 then
		self.power_value:SetValue(cap)
	else
		self.power_value:SetValue(0)
	end
end

function GoddessShengWuView:OnClickBtnCommon()
	local param3 = self.quick_toggle.toggle.isOn and 1 or 0
	local param2 = 1--self.auto_toggle.toggle.isOn and 1 or 0

	self.chou_exp_stuff1 = GoddessData.Instance:GetXianNvChouExpStuff(GODDESS_CHOUEXP_TYPE.COMMON)
	--print_log(GoddessData.Instance:GetXianNvChouExpStuff(GODDESS_CHOUEXP_TYPE.COMMON))
	local item_num = ItemData.Instance:GetItemNumInBagById(self.chou_exp_stuff1)
	local has_item_num = false
	if param3 == 1 then
		has_item_num = item_num > 0
	else
		has_item_num = item_num > 0
	end
	self.icon_image:SetAsset(ResPath.GetItemIcon(self.chou_exp_stuff1))
	if has_item_num == false then
		-- 物品不足，弹出TIP框
		TipsCtrl.Instance:ShowItemGetWayView(self.chou_exp_stuff1)
		return
	end
	
	GoddessCtrl.Instance:SentCSXiannvShengwuReqReq(GODDESS_REQ_TYPE.NORMAL_CHOU_EXP, 0, 1, param3)
	self.fly_start = self.common_button
end

function GoddessShengWuView:OnClickBtnPerfect()
	local param3 = self.quick_toggle.toggle.isOn and 1 or 0
	local param2 = 1--self.auto_toggle.toggle.isOn and 1 or 0

	-- local item_num = ItemData.Instance:GetItemNumInBagById(self.chou_exp_stuff2)
	-- local has_item_num = false
	-- if param3 == 1 then
	-- 	has_item_num = item_num >= 10
	-- else
	-- 	has_item_num = item_num > 0
	-- end

	-- if self.is_can_perfect_auto == 0 and has_item_num == false then
	-- 	-- 物品不足，弹出TIP框
	-- 	local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[self.chou_exp_stuff2]
	-- 	if item_cfg == nil then
	-- 		TipsCtrl.Instance:ShowItemGetWayView(self.chou_exp_stuff2)
	-- 		return
	-- 	end

	-- 	if item_cfg.bind_gold == 0 then
	-- 		TipsCtrl.Instance:ShowShopView(self.chou_exp_stuff2, 2)
	-- 		return
	-- 	end

	-- 	local func = function(item_id, item_num, is_bind, is_use, is_buy_quick)
	-- 		MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
	-- 		if is_buy_quick then
	-- 			self.is_can_perfect_auto = 1
	-- 		end
	-- 	end

	-- 	TipsCtrl.Instance:ShowCommonBuyView(func, self.chou_exp_stuff2, nil, 1)
	-- 	return
	-- end

	GoddessCtrl.Instance:SentCSXiannvShengwuReqReq(GODDESS_REQ_TYPE.PERFECT_CHOU_EXP, self.is_can_perfect_auto, 1, param3)
	self.fly_start = self.perfect_button
end

function GoddessShengWuView:OnClickGongMingTip()
	self.cap_data = GoddessData.Instance:GetXiannvShengWuTotalAttr()
	TipsCtrl.Instance:ShowAttrAllView(self.cap_data)
end

function GoddessShengWuView:OnAutoFly(info_data)
	if info_data then
		local shengwu_id = info_data.shengwu_id or 0
		local add_exp = info_data.add_exp or 0
		self["shengwu_icon" .. shengwu_id]:SetBlessLockState(true)
		TipsCtrl.Instance:ShowFlyEffectManager(ViewName.Goddess, "effects2/prefab/ui/ui_huobanshengji_lizi_prefab", "UI_huobanshengji_lizi", 
			self.fly_start, self["fly_end_" .. shengwu_id], nil, 0.5,
			BindTool.Bind2(self.OnAutoFlyCallFun, self, info_data))
	end
end


function GoddessShengWuView:OnAutoFlyCallFun(info_data)
	if info_data then
		local shengwu_id = info_data.shengwu_id or 0
		local add_exp = info_data.add_exp or 0
		self:ShowFlyText(self["shengwu_icon" .. shengwu_id].root_node, "+" .. add_exp)
	end
end

function GoddessShengWuView:ShowShengWuViewFly()
	local chou_exp_is_auto_fetch, chou_exp_add_exp_list = GoddessData.Instance:GetXiannvShengwuChouExpResult()
	local shengwu_chou_id = GoddessData.Instance:GetXiannvShengwuChouExpList()
	if chou_exp_is_auto_fetch == 1 then
		for k,v in pairs(chou_exp_add_exp_list) do
			self:OnAutoFly(v)
		end
	else
		for k,v in pairs(chou_exp_add_exp_list) do
			self:OnNoAutoFly(v)
		end
	end
end

function GoddessShengWuView:OnNoAutoFly(v)
	local add_exp = 0
	-- for i = 0, 5 do
	-- 	-- if self["huiyi_icon" .. i] then
	-- 	-- 	self["huiyi_icon" .. i]:SetShengWuId(-1)
	-- 	-- end
	-- 	--add_exp = self.is_on_fly_chou_list[i] or 0
	-- 	-- if self.is_on_fly_index == i and self.is_on_fly_shengwu_id ~= -1 then
	-- 	-- 	self:ShowFlyText(self["shengwu_icon" .. self.is_on_fly_shengwu_id].root_node, "+" .. add_exp)
	-- 	-- else
	-- 	-- 	self:ShowFlyText(self["huiyi_icon" .. i].root_node, "+" .. add_exp)
	-- 	-- end
	-- 	self:OnAutoFlyCallFun(v)
	-- end

	self.is_on_fly = false
	self.is_on_fly_index = 0
	self.is_on_fly_shengwu_id = -1
	self.is_on_fly_chou_list = {}
end

function GoddessShengWuView:OnClickHuiYiIcon(index)
	-- local shengwu_id, chou_list = GoddessData.Instance:GetXiannvShengwuChouExpList()
	-- if self["huiyi_icon" .. index] == nil or shengwu_id == -1 or self.is_on_fly == true then
	-- 	return
	-- end

	-- self.is_on_fly = true
	-- self.is_on_fly_index = index
	-- self.is_on_fly_shengwu_id = shengwu_id
	-- self.is_on_fly_chou_list = chou_list

	-- if self["huiyi_icon" .. index] then
	-- 	self["huiyi_icon" .. index]:SetShengWuId(-1)
	-- end

	-- -- TipsCtrl.Instance:ShowFlyEffectManager(ViewName.Goddess, "uis/views/goddess", "ShenwuIcon", 
	-- -- 	self["huiyi_icon" .. index].root_node, self["shengwu_icon" .. shengwu_id].root_node, nil, 1,
	-- -- 	BindTool.Bind(self.OnClickHuiYiIconCallFun, self), nil, 1)

	-- for i = 0, 5 do
	-- 	self:ShowFlyIcon(self["huiyi_icon" .. i].root_node, self["shengwu_icon" .. shengwu_id].root_node, "chou_exp_icon_" .. shengwu_id, self["shengwu_icon" .. shengwu_id])
	-- end
	--self:ShowFlyIcon(self["huiyi_icon" .. index].root_node, self["shengwu_icon" .. shengwu_id].root_node, "chou_exp_icon_" .. shengwu_id)
end

function GoddessShengWuView:ShowFlyIcon(begin_obj, end_obj, name, eff_obj)
	-- for i = 0, 5 do
	-- 	if self["huiyi_icon" .. i] then
	-- 		self["huiyi_icon" .. i]:SetShengWuId(-1)
	-- 	end
	-- end

	GameObjectPool.Instance:SpawnAsset("uis/views/goddess_prefab", "ShenwuIcon", function(obj)
			local variable_table = obj:GetComponent(typeof(UIVariableTable))
			if variable_table then
				local image = variable_table:FindVariable("Image")
				image:SetAsset("uis/views/goddess/images_atlas", name)
			end
			obj.transform:SetParent(begin_obj.transform, false)
			local obj_rect = end_obj:GetComponent(typeof(UnityEngine.RectTransform))
			--获取指引按钮的屏幕坐标
			local screen_pos_tbl = UnityEngine.RectTransformUtility.WorldToScreenPoint(self.uicamera, obj_rect.position)

			--转换屏幕坐标为本地坐标
			local _, local_pos_tbl = UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(begin_obj.rect, screen_pos_tbl, self.uicamera, Vector2(0, 0))

			local end_position = Vector3(local_pos_tbl.x, local_pos_tbl.y, 0)
			local tween = obj.transform:DOLocalMove(end_position, 0.5)
			tween:SetEase(DG.Tweening.Ease.Linear)
			tween:OnComplete(BindTool.Bind3(self.OnMoveChouEnd, self, obj, eff_obj))
		end)
end

function GoddessShengWuView:OnMoveChouEnd(obj, eff_obj)
	if not IsNil(obj) then
		GameObject.Destroy(obj)
	end
	self:OnClickHuiYiIconCallFun()
	eff_obj:ShowEffect(true)
end

function GoddessShengWuView:OnClickHuiYiIconCallFun()
	GoddessCtrl.Instance:SentCSXiannvShengwuReqReq(GODDESS_REQ_TYPE.FETCH_EXP)
end

function GoddessShengWuView:OnUpdataHuiYiIconShow()
	-- local shengwu_chou_id = GoddessData.Instance:GetXiannvShengwuChouExpList()
	-- for i = 0, 5 do
	-- 	if self["huiyi_icon" .. i] then
	-- 		self["huiyi_icon" .. i]:SetShengWuId(shengwu_chou_id)
	-- 	end
	-- end
end

function GoddessShengWuView:OnMoveEnd(obj)
	if not IsNil(obj) then
		GameObject.Destroy(obj)
	end

	for i = 0, 3 do
		if self["shengwu_icon" .. i] then
			self["shengwu_icon" .. i]:SetBlessValue()
		end
	end
end

function GoddessShengWuView:ShowFlyText(begin_obj, value)
	GameObjectPool.Instance:SpawnAsset("uis/views/goddess_prefab", "ShenwuText", function(obj)
			local variable_table = obj:GetComponent(typeof(UIVariableTable))
			if variable_table then
				local text = variable_table:FindVariable("Text")
				text:SetValue(value)
			end
			obj.transform:SetParent(begin_obj.transform, false)
			local tween = obj.transform:DOLocalMoveY(110, 0.5)
			tween:SetEase(DG.Tweening.Ease.Linear)
			tween:OnComplete(BindTool.Bind(self.OnMoveEnd, self, obj))
			-- GlobalTimerQuest:AddDelayTimer(function() TipsCtrl.Instance:DestroyFlyEffectByViewName(ViewName.Goddess) end,1)
		end)
end


----------------------------------------圣物icon
GoddessShengWuIconItem = GoddessShengWuIconItem or BaseClass(BaseRender)
function GoddessShengWuIconItem:__init()
	self.shengwu_id = 0
	self.shengwu_level = 0
	self.icon_level = self:FindVariable("IconLevel")
	self.text_power = self:FindVariable("TextPower")
	self.skill_icon = self:FindObj("SkillIcon")

	for i = 0, 2 do
		self["info_text_" .. i] = self:FindVariable("InfoText" .. i)
	end
	self.text_skill_level = self:FindVariable("TextSkillLevel")
	self.exp_radio = self:FindVariable("ExpRadio")
	self.cur_bless = self:FindVariable("CurBless")
	self:ListenEvent("SkillOnClick",BindTool.Bind(self.SkillOnClick, self))
	self.display = self:FindObj("display")
	self.model = RoleModel.New("goddess_gongming_panel")
	self.model:SetDisplay(self.display.ui3d_display)

	self.model_id = nil
	self.is_lock_bless = false
end

function GoddessShengWuIconItem:__delete()
	self.icon_level = nil
	self.text_power = nil
	for i = 0, 2 do
		self["info_text_" .. i] = nil
	end
	self.text_skill_level = nil
	self.exp_radio = nil
	self.cur_bless = nil
	self.skill_icon = nil
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
	self.model_id = nil

	self.is_lock_bless = false

	--self.effect = nil
end

function GoddessShengWuIconItem:SkillOnClick()
	GoddessCtrl.Instance:OpenGoddessSkillTipView(self.shengwu_id)
end

function GoddessShengWuIconItem:OnFlush()
	local sc_info_data = GoddessData.Instance:GetXiannvScShengWuIconAttr(self.shengwu_id)
	self.shengwu_level = sc_info_data.level
	local info_data = GoddessData.Instance:GetXianNvShengWuCfg(self.shengwu_id, self.shengwu_level)
	local next_info_data = GoddessData.Instance:GetXianNvShengWuCfg(self.shengwu_id, self.shengwu_level + 1)
	if info_data == nil then
		return
	end

	if self.model then
		local need_change = false
		if self.model_id == nil then
			self.model_id = info_data.display_id
			need_change = true
		else
			if self.model_id ~= info_data.display_id then
				need_change = true
				self.model_id = info_data.display_id
			end
		end

		if need_change then
			local asset, bundle = ResPath.GetHunQiModel(info_data.display_id)
			self.model:SetMainAsset(asset, bundle)
			self.model_id  = info_data.display_id
		end
	end
	-- 属性显示设置
	local now_attr = CommonDataManager.GetGoddessAttributteNoUnderline(info_data)
	local had_base_attr = {}

	local cap = CommonDataManager.GetCapability(now_attr)
	if cap and cap >= 0 then
		self.text_power:SetValue(cap)
	else
		self.text_power:SetValue(0)
	end

	local had_base_attr_gj = {}
	if self.shengwu_level == 0 then
		local next_attr = CommonDataManager.GetGoddessAttributteNoUnderline(next_info_data, true)
		for k, v in pairs(next_attr) do
			if v > 0 then
				if now_attr[k] and now_attr[k] > 0 then
					if k == "goddess_gongji" then 
						table.insert(had_base_attr_gj,{key = k, value = now_attr[k]})
					else
						table.insert(had_base_attr,{key = k, value = now_attr[k]})
					end
				else
					if k == "goddess_gongji" then 
						table.insert(had_base_attr_gj,{key = k, value = 0})
					else
						table.insert(had_base_attr,{key = k, value = 0})
					end
				end
			end
		end
	else
		for k, v in pairs(now_attr) do
			if v > 0 then
				if k == "goddess_gongji" then 
					table.insert(had_base_attr_gj,{key = k, value = v})
				else
					table.insert(had_base_attr,{key = k, value = v})
				end
			end
		end
	end

	local attr_index = 0
	for k, v in pairs(had_base_attr) do
		if attr_index < 3 then
			local sttr_name = Language.Common.AttrNameNoUnderlineGoddess[v.key]
			local sttr_value = v.value
			local sttr_str = string.format(Language.Goddess.GoddessShuXing, sttr_name, sttr_value)
			self["info_text_" .. attr_index]:SetValue(sttr_str)
			attr_index = attr_index + 1
		end
	end
	for k, v in pairs(had_base_attr_gj) do
		local sttr_name = Language.Common.AttrNameNoUnderlineGoddess[v.key]
		local sttr_value = v.value
		local sttr_str = string.format(Language.Goddess.GoddessShuXing, sttr_name, sttr_value)
		self["info_text_" .. attr_index]:SetValue(sttr_str)
		attr_index = attr_index + 1
	end

	self.icon_level:SetValue(string.format(Language.Goddess.GoddessShengWuName, info_data.name, info_data.level))
	self.text_skill_level:SetValue("Lv."..info_data.skill_level)
	if self.skill_icon ~= nil and self.skill_icon.grayscale ~= nil then
		self.skill_icon.grayscale.GrayScale = info_data.skill_level == 0 and 255 or 0
	end

	--经验设置
	if next_info_data == nil then
		self.cur_bless:SetValue("- / -")
	elseif not self.is_lock_bless then
		local show_exp_radio = string.format("%.2f", sc_info_data.exp / info_data.upgrade_need_exp)
		self.cur_bless:SetValue(sc_info_data.exp.." / "..info_data.upgrade_need_exp)
		self.exp_radio:InitValue(show_exp_radio)
	end
end

function GoddessShengWuIconItem:SetShengWuId(index)
	self.shengwu_id = index
	self:Flush()
end

function GoddessShengWuIconItem:SetBlessValue()
	if self.shengwu_id == nil then
		return
	end

	if not self.is_lock_bless then
		return
	end

	local sc_info_data = GoddessData.Instance:GetXiannvScShengWuIconAttr(self.shengwu_id)
	self.shengwu_level = sc_info_data.level
	local info_data = GoddessData.Instance:GetXianNvShengWuCfg(self.shengwu_id, self.shengwu_level)
	local next_info_data = GoddessData.Instance:GetXianNvShengWuCfg(self.shengwu_id, self.shengwu_level + 1)
	if info_data == nil then
		return
	end
	local show_exp_radio = string.format("%.2f", sc_info_data.exp / info_data.upgrade_need_exp)
	self.cur_bless:SetValue(sc_info_data.exp.."/"..info_data.upgrade_need_exp)
	self.exp_radio:InitValue(show_exp_radio)	
	self.is_lock_bless = false
end

function GoddessShengWuIconItem:SetBlessLockState(state)
	self.is_lock_bless = state
end

function GoddessShengWuIconItem:ShowEffect(flag)
	EffectManager.Instance:PlayAtTransform("effects2/prefab/ui/ui_huoban_jinjiechenggong_prefab", "UI_huoban_jinjiechenggong", self.root_node.transform, 1.0, nil, nil, Vector3(1.5, 1.5, 1.5))
end

-------------------------------------------回忆icon
GoddessHuiYiIconItem = GoddessHuiYiIconItem or BaseClass(BaseRender)
function GoddessHuiYiIconItem:__init()
	self.img_icon = self:FindVariable("Icon")
	self.huiyi_add_text = self:FindVariable("HuiYiAddText")
	self.shengwu_id = -1
	self:Flush()
end

function GoddessHuiYiIconItem:__delete()
	self.effect = nil
	self.effect_2 = nil
end

function GoddessHuiYiIconItem:OnFlush()
	self:UpdataIconShow()
end

function GoddessHuiYiIconItem:SetShengWuId(num)
	self.shengwu_id = num
	self:UpdataIconShow()
end

function GoddessHuiYiIconItem:UpdataIconShow()
	if self.shengwu_id == -1 then
		self.img_icon:SetAsset(nil, nil)
		self:ShowEffect(false)
	else
		self.img_icon:SetAsset(ResPath.GetGoddessRes("chou_exp_icon_" .. self.shengwu_id))
		self:ShowEffect(true)
	end
end

function GoddessHuiYiIconItem:ShowEffect(flag)

	local cur_type = GoddessData.Instance:GetXiannvShengwuChouType()
	if cur_type == 1 then
		if self.effect ~= nil then
			self.effect:SetActive(false)
		end

		if self.effect_2 == nil and flag then
	  		PrefabPool.Instance:Load(AssetID("effects/prefabs", "UI_fuwenchoujiangxuanzhong_huangse"), function (prefab)
				if not prefab or self.effect_2 then return end
				local obj = GameObject.Instantiate(prefab)
				PrefabPool.Instance:Free(prefab)
				local transform = obj.transform
				transform:SetParent(self.root_node.transform, false)
				transform:SetSiblingIndex(0)
				transform.localScale = Vector3(0.85, 0.85, 0.85)
				self.effect_2 = obj.gameObject
				--self.is_loading = false
				self.effect_2:SetActive(flag)
			end)		
		end

		if self.effect_2 ~= nil then
			self.effect_2:SetActive(flag)
		end
	else
		if self.effect_2 ~= nil then
			self.effect_2:SetActive(false)
		end
		if self.effect == nil and flag then
	  		PrefabPool.Instance:Load(AssetID("effects/prefabs", "UI_fuwenchoujiangxuanzhong_lanse"), function (prefab)
				if not prefab or self.effect then return end
				local obj = GameObject.Instantiate(prefab)
				PrefabPool.Instance:Free(prefab)
				local transform = obj.transform
				transform:SetParent(self.root_node.transform, false)
				transform:SetSiblingIndex(0)
				transform.localScale = Vector3(0.85, 0.85, 0.85)
				self.effect = obj.gameObject
				--self.is_loading = false
				self.effect:SetActive(flag)
			end)		
		end

		if self.effect ~= nil then
			self.effect:SetActive(flag)
		end
	end
end