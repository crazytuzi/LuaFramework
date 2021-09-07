GoddessShengWuView = GoddessShengWuView or BaseClass(BaseRender)
-- 兵道
function GoddessShengWuView:__init()
	
end

function GoddessShengWuView:LoadCallBack(instance)
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
	self.wangmei_value = self:FindVariable("TextWMHuiYiShi")
	self.red_point = self:FindVariable("ShowRedPoint")
	self.text_vip_0 = self:FindVariable("text_vip_0")

	for i = 0, 3 do
		self["shengwu_icon" .. i] = GoddessShengWuIconItem.New(self:FindObj("ShengWuIcon" .. i))
		self["shengwu_icon" .. i]:SetShengWuId(i)
	end

	self.perfect_button = self:FindObj("PerfectButton")
	self.back_ground = self:FindObj("Background")

	self.quick_toggle = self:FindObj("QuickToggle")
	self.quick_toggle.toggle:AddValueChangedListener(BindTool.Bind(self.OnQuickToggleChange, self))

	self:ListenEvent("OnClickBtnPerfect",BindTool.Bind(self.OnClickBtnPerfect, self))
	self:ListenEvent("EventTip", BindTool.Bind(self.OnClickTip, self))
	self:ListenEvent("OnClickGongMingTip", BindTool.Bind(self.OnClickGongMingTip, self))

	self.item_icon = self:FindVariable("ItemIcon")
	self.item_num = self:FindVariable("ItemNum")
	local item_id =GoddessData.Instance:GetXianNvChouExpStuff(0)
	self.item_icon:SetAsset(ResPath.GetItemIcon(item_id))
	self:SetNotifyDataChangeCallBack()
	self:FlushItemInfo()
	self:Flush()
end

function GoddessShengWuView:__delete()
	for i = 0,3 do
		if nil ~= self["shengwu_icon" .. i] then
			self["shengwu_icon" .. i]:DeleteMe()
			self["shengwu_icon" .. i] = nil
		end
	end

	self.chou_exp_stuff1 = 0
	self.chou_exp_stuff2 = 0
	self.shengwu_auto_vip_level = 0
	self.shengwu_ten_vip_level = 0
	self.power_value = nil
	self.back_ground = nil
	self.perfect_button = nil
	self.is_on_fly = false
	self.is_on_fly_index = 0
	self.is_on_fly_shengwu_id = -1
	self.is_on_fly_chou_list = {}
	self.red_point = nil
	self.text_vip_0 = nil

	self.is_can_conmmon_auto = 0
	self.is_can_perfect_auto = 0
	self:RemoveNotifyDataChangeCallBack()
	self.uicamera = nil

	self.item_icon = nil
	self.item_num = nil

	UnityEngine.PlayerPrefs.DeleteKey("not_enough_tips")
end

function GoddessShengWuView:FlushItemInfo()
	local item_id =GoddessData.Instance:GetXianNvChouExpStuff(0)
	local num = ItemData.Instance:GetItemNumInBagById(item_id)
	num = num < 1 and ToColorStr(num, TEXT_COLOR.RED) or ToColorStr(num, TEXT_COLOR.GREEN)
	self.item_num:SetValue(num)
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
	if item_id == GoddessData.Instance:GetXianNvChouExpStuff(0) then
		self:FlushItemInfo()
	end
end

function GoddessShengWuView:OnQuickToggleChange(isOn)
	if isOn then
		self.wangmei_value:SetValue(GoddessData.Instance:GetOtherByStr("chou_exp_gold") * 10)
		local limit_level = VipPower.Instance:GetMinVipLevelLimit(VIPPOWER.AUTO_SHENGWU_TEN) or 0
		if PlayerData.Instance.role_vo.vip_level < limit_level then
			self.quick_toggle.toggle.isOn = false
			TipsCtrl.Instance:ShowLockVipView(VIPPOWER.AUTO_SHENGWU_TEN)
		end
	else
		self.wangmei_value:SetValue(GoddessData.Instance:GetOtherByStr("chou_exp_gold"))
	end
end

function GoddessShengWuView:OnClickTip()
	TipsCtrl.Instance:ShowHelpTipView(208)
end

function GoddessShengWuView:OnFlush()
	self:UpdataStuffShow()
	self:UpdataVipShow()
	self:UpdataPowerShow()
	self:UpdataShengWuIconShow()
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
	self.text_vip_0:SetValue(string.format(Language.Goddess.ShengwuVipTip, limit_ten_level))
end

function GoddessShengWuView:UpdataStuffShow()
	self.wangmei_value:SetValue(GoddessData.Instance:GetOtherByStr("chou_exp_gold"))

	local item_id = GoddessData.Instance:GetXianNvChouExpStuff(0)
	local num = ItemData.Instance:GetItemNumInBagById(item_id)
	self.red_point:SetValue(num > 0)
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

function GoddessShengWuView:OnClickBtnPerfect()
	local param3 = self.quick_toggle.toggle.isOn and 1 or 0
	local param2 = 1
	local item_id = GoddessData.Instance:GetXianNvChouExpStuff(0)
	local item_num = ItemData.Instance:GetItemNumInBagById(item_id)
	if item_num > 0 and (param3 == 0 or item_num >= 10) then
		GoddessCtrl.Instance:SentCSXiannvShengwuReqReq(GODDESS_REQ_TYPE.NORMAL_CHOU_EXP, self.is_can_perfect_auto, 1, param3)
	else
		local item_name = ItemData.Instance:GetItemName(item_id)
		local item_price =GoddessData.Instance:GetXianNvChouExpStuff(1)
		 if self.quick_toggle.toggle.isOn == true then
		 	item_price = item_price * 10
		 end
		 local str = string.format(Language.Goddess.NotEnough, ToColorStr(item_name, TEXT_COLOR.RED),ToColorStr(item_price, TEXT_COLOR.RED))
		
		local click_func = function ()
			GoddessCtrl.Instance:SentCSXiannvShengwuReqReq(GODDESS_REQ_TYPE.PERFECT_CHOU_EXP, self.is_can_perfect_auto, 1, param3)
		end

		if UnityEngine.PlayerPrefs.GetInt("not_enough_tips") == 1 then
			click_func()
		else
			TipsCtrl.Instance:ShowCommonTip(click_func, nil, str, nil, nil, true, false, "not_enough_tips")
		end
	end
end

function GoddessShengWuView:OnClickGongMingTip()
	self.cap_data = GoddessData.Instance:GetXiannvShengWuTotalAttr()
	--TipsCtrl.Instance:ShowAttrView(self.cap_data, "bao_ji", "jian_ren")
	TipsCtrl.Instance:OpenGeneralView(self.cap_data)
end

function GoddessShengWuView:OnAutoFly(info_data)
	if info_data then
		local shengwu_id = info_data.shengwu_id or 0
		local add_exp = info_data.add_exp or 0
		self["shengwu_icon" .. shengwu_id]:SetBlessLockState(true)
		TipsCtrl.Instance:ShowFlyEffectManager(ViewName.Goddess, "effects2/prefab/ui/ui_guangdian1_prefab", "UI_guangdian1", 
			self.perfect_button, self["shengwu_icon" .. shengwu_id].root_node, nil, 0.5,
			BindTool.Bind2(self.OnAutoFlyCallFun, self))
	end
end


function GoddessShengWuView:OnAutoFlyCallFun()
	for i = 0, 3 do
		if self["shengwu_icon" .. i] then
			self["shengwu_icon" .. i]:SetBlessValue()
		end
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

	self.is_on_fly = false
	self.is_on_fly_index = 0
	self.is_on_fly_shengwu_id = -1
	self.is_on_fly_chou_list = {}
end

----------------------------------------圣物icon
GoddessShengWuIconItem = GoddessShengWuIconItem or BaseClass(BaseRender)
function GoddessShengWuIconItem:__init()
	self.shengwu_id = 0
	self.shengwu_level = 0
	self.icon_level = self:FindVariable("IconLevel")
	self.text_power = self:FindVariable("TextPower")
	self.skill_icon = self:FindObj("SkillIcon")

	for i = 0, 1 do
		self["info_text_" .. i] = self:FindVariable("InfoText" .. i)
	end
	self.text_skill_level = self:FindVariable("TextSkillLevel")
	self.exp_radio = self:FindVariable("ExpRadio")

	self.exp_start = self:FindVariable("ExpStar")

	self:ListenEvent("SkillOnClick",BindTool.Bind(self.SkillOnClick, self))
	-- self.display = self:FindObj("display")
	-- self.model = RoleModel.New()
	-- self.model:SetDisplay(self.display.ui3d_display)

	-- self.model_id = nil
	self.is_lock_bless = false
end

function GoddessShengWuIconItem:__delete()
	self.icon_level = nil
	self.text_power = nil
	for i = 0, 1 do
		self["info_text_" .. i] = nil
	end
	self.exp_start = nil
	self.text_skill_level = nil
	self.skill_icon = nil
	-- if self.model then
	-- 	self.model:DeleteMe()
	-- 	self.model = nil
	-- end
	-- self.model_id = nil

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
	-- 属性显示设置
	local now_attr = CommonDataManager.GetAttributteNoUnderline(info_data)
	local had_base_attr = {}

	local cap = CommonDataManager.GetCapability(now_attr)
	if cap and cap >= 0 then
		self.text_power:SetValue(cap)
	else
		self.text_power:SetValue(0)
	end

	local had_base_attr_gj = {}
	if self.shengwu_level == 0 then
		local next_attr = CommonDataManager.GetAttributteNoUnderline(next_info_data, true)
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
		if attr_index < 2 then
			local sttr_name = Language.Common.AttrNameNoUnderline[v.key]
			local sttr_value = v.value
			local sttr_str = string.format(Language.Goddess.GoddessShuXing, sttr_name, sttr_value)
			self["info_text_" .. attr_index]:SetValue(sttr_str)
			attr_index = attr_index + 1
		end
	end
	for k, v in pairs(had_base_attr_gj) do
		local sttr_name = Language.Common.AttrNameNoUnderline[v.key]
		local sttr_value = v.value
		local sttr_str = string.format(Language.Goddess.GoddessShuXing, sttr_name, sttr_value)
		self["info_text_" .. attr_index]:SetValue(sttr_str)
		attr_index = attr_index + 1
	end

	local color = TEXT_COLOR.RED
	if sc_info_data.exp < info_data.upgrade_need_exp then
		color = TEXT_COLOR.RED
	else
		color = TEXT_COLOR.GREEN
	end
	local icon_level = string.format(Language.Goddess.Level, info_data.level, color, sc_info_data.exp, info_data.upgrade_need_exp)
	self.icon_level:SetValue(icon_level)

	self.text_skill_level:SetValue("Lv."..info_data.skill_level)
	if self.skill_icon ~= nil and self.skill_icon.grayscale ~= nil then
		self.skill_icon.grayscale.GrayScale = info_data.skill_level == 0 and 255 or 0
	end

	--经验设置
	if next_info_data == nil then
		self.exp_start:InitValue(1)
	elseif not self.is_lock_bless then
		self.exp_start:SetValue(sc_info_data.exp / info_data.upgrade_need_exp)
	end
end

function GoddessShengWuIconItem:SetExpStart(now_exp, totle_exp)
	local start_exp = string.format("%.2f", totle_exp / 5)
	for i = 1, 5 do
		local show_exp = now_exp - (start_exp * (i -1)) 
		local show_exp_start = 0
		if show_exp > 0 then
		 	show_exp_start = show_exp / start_exp
		end
		if show_exp_start > 1 then
			show_exp_start = 1
		end
		if self["exp_start" .. i] ~= nil then
			self["exp_start" .. i]:SetValue(show_exp_start)
		end
	end
end

-- type 1为满，0 为无
function GoddessShengWuIconItem:SetExpStartType(type)
	for i = 1, 5 do
		if self["exp_start" .. i] ~= nil then
			self["exp_start" .. i]:InitValue(type)
		end
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

	local color = TEXT_COLOR.RED
	if sc_info_data.exp < info_data.upgrade_need_exp then
		color = TEXT_COLOR.RED
	else
		color = TEXT_COLOR.GREEN
	end
	local icon_level = string.format(Language.Goddess.Level, info_data.level, color, sc_info_data.exp, info_data.upgrade_need_exp)
	self.icon_level:SetValue(icon_level)
	
	self.exp_start:SetValue(sc_info_data.exp / info_data.upgrade_need_exp)

	self.is_lock_bless = false
end

function GoddessShengWuIconItem:SetBlessLockState(state)
	self.is_lock_bless = state
end

function GoddessShengWuIconItem:ShowEffect(flag)
	EffectManager.Instance:PlayAtTransform("effects2/prefab/misc/effect_baodian_prefab", "Effect_baodian", self.root_node.transform, 1.0, nil, nil, Vector3(1.5, 1.5, 1.5))
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
	  		PrefabPool.Instance:Load(AssetID("effects2/prefab/ui/ui_fuwenchoujiangxuanzhong_huangse_prefab", "UI_fuwenchoujiangxuanzhong_huangse"), function (prefab)
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
	  		PrefabPool.Instance:Load(AssetID("effects2/prefab/ui/ui_fuwenchoujiangxuanzhong_lanse_prefab", "UI_fuwenchoujiangxuanzhong_lanse"), function (prefab)
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
