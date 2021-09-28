TianshenhutiEquipTips = TianshenhutiEquipTips or BaseClass(BaseView)
TianshenhutiEquipTips.FromView = {
	Normal = 1,
	EquipView = 2,
	BagView = 3,
}
function TianshenhutiEquipTips:__init()
	self.ui_config = {"uis/views/tianshenhutiview_prefab","TianshenhutiEquipTip"}
	self.view_layer = UiLayer.Pop

	self.base_attr_list = {}
	self.data = nil
	self.from_view = nil
	self.handle_param_t = {}
	self.buttons = {}
	self.button_label = Language.Tip.ButtonLabel
	self.button_handle = {}
	self.show_cast = false
	self.show_legend = false
	self.effect_obj = nil
	self.is_load_effect = false
	self.play_audio = true
	self.is_show_eternity = false
	self.from_view = TianshenhutiEquipTips.FromView.Normal
end

function TianshenhutiEquipTips:__delete()
	self.button_label = {}
	self.base_attr_list = {}
	self.button_handle = {}
	self.buttons = {}

	if self.effect_obj then
		GameObject.Destroy(self.effect_obj)
		self.effect_obj = nil
	end
	self.is_load_effect = nil

	if self.equip_item then
		self.equip_item:DeleteMe()
		self.equip_item = nil
	end
end

function TianshenhutiEquipTips:ReleaseCallBack()
	self.base_attr_list = {}
	self.tz_attr_list = {}

	self.data = nil
	self.from_view = nil
	self.handle_param_t = nil
	self.show_cast = nil
	self.show_legend = nil
	self.gift_id = nil
	self.is_data_param_nil = false

	if self.equip_item then
		self.equip_item:DeleteMe()
		self.equip_item = nil
	end

	-- 清理变量和对象
	self.button_root = nil
	self.buttons = {}
	self.wear_icon = nil
	self.equip_name = nil
	self.equip_type = nil
	self.equip_prof = nil
	self.quality = nil
	self.level = nil
	self.fight_power = nil
	self.color_1 = nil
	self.color_2 = nil
	self.type = nil
	self.scroller_rect = nil
	self.grade = nil

	self.show_effe = nil

	self.tz_cur_has = nil
	self.skill_txt_color = {}
	self.skill_per = {}
	self.skill_name = {}
	self.tz_cur_need = {}
	self.tz_cur_color = {}
	self.tz_name_t = {}
end

function TianshenhutiEquipTips:CloseCallBack()
	self.data = nil
	self.from_view = nil
	self.handle_param_t = {}
	self.show_cast = false
	self.show_legend = false
	if self.close_call_back ~= nil then
		self.close_call_back()
		self.close_call_back = nil
	end
	for _, v in pairs(self.button_handle) do
		v:Dispose()
	end
	self.button_handle = {}

	self.gift_id = nil
	self.is_data_param_nil = false
end

function TianshenhutiEquipTips:OpenCallBack()
	self.show_cast = false
	self.show_legend = false
end

function TianshenhutiEquipTips:LoadCallBack()
	-- 功能按钮
	self.equip_item = TianshenhutiEquipItemCell.New()
	self.equip_item:SetInstanceParent(self:FindObj("EquipItem"))
	self.button_root = self:FindObj("RightBtn")
	for i =1 ,5 do
		local button = self.button_root:FindObj("Btn"..i)
		local btn_text = button:FindObj("Text")
		self.buttons[i] = {btn = button, text = btn_text}
	end

	local base_attrs = self:FindObj("BaseAttrs")
	for i = 1, base_attrs.transform.childCount do
		self.base_attr_list[#self.base_attr_list + 1] = base_attrs:FindObj("BaseAttr"..i)
	end
	self.tz_attr_list = {}
	self.tz_cur_has = self:FindVariable("TzCurHas")
	self.skill_txt_color = {}
	self.skill_per = {}
	self.skill_name = {}
	self.tz_cur_need = {}
	self.tz_cur_color = {}
	self.tz_name_t = {}
	for i=1,3 do
		self.skill_txt_color[i] = self:FindVariable("SkillTxtColor" .. i)
		self.skill_per[i] = self:FindVariable("SkillPer" .. i)
		self.skill_name[i] = self:FindVariable("SkillName" .. i)
		self.tz_cur_need[i] = self:FindVariable("TzCurNeed" .. i)
		self.tz_cur_color[i] = self:FindVariable("TzCurColor" .. i)
		self.tz_name_t[i] = self:FindVariable("TzName" .. i)
		self.tz_attr_list[i] = {}
		local tz_attrs = self:FindObj("TzAttrs" .. i)
		for j = 1, tz_attrs.transform.childCount do
			self.tz_attr_list[i][#self.tz_attr_list[i] + 1] = tz_attrs:FindObj("TzAttr"..j)
		end
	end

	self.wear_icon = self:FindVariable("IsShowWearIcon")

	self.equip_name = self:FindVariable("EquipName")
	self.equip_type = self:FindVariable("EquipType")
	self.equip_prof = self:FindVariable("EquipProf")
	self.quality = self:FindVariable("Quality")
	self.level = self:FindVariable("Level")
	self.fight_power = self:FindVariable("FightPower")
	self.color_1 = self:FindVariable("Color1")
	self.color_2 = self:FindVariable("Color2")
	self.type = self:FindVariable("Type")


	self:ListenEvent("Close",
		BindTool.Bind(self.OnClickCloseButton, self))

	self.scroller_rect = self:FindObj("Scroller").scroll_rect

	self.grade = self:FindVariable("Grade")
end

--获得当前人物可穿的装备的最高阶数
function TianshenhutiEquipTips:CalculateMaxOrder()
	local main_role_lv = GameVoManager.Instance:GetMainRoleVo().level
	local max_order = ItemData.Instance:GetItemMaxOrder(main_role_lv)
	return max_order
end

function TianshenhutiEquipTips:ShowTipContent()
	local tianshenhutidata = TianshenhutiData.Instance
	local item_cfg = tianshenhutidata:GetEquipCfg(self.data.item_id)
	if item_cfg == nil or nil == self.equip_item then
		return
	end
	self.wear_icon:SetValue(self.from_view == TianshenhutiEquipTips.FromView.EquipView)
	local name_str = "<color="..ITEM_TIP_NAME_COLOR[item_cfg.color]..">"..item_cfg.name.."</color>"
	-- local color_1 = EquipData.Instance:GetTextColor1(item_cfg.color)
	-- local color_2 = EquipData.Instance:GetTextColor2(item_cfg.color)
	-- self.color_1:SetValue(color_1)
	-- self.color_2:SetValue(color_2)

	self.equip_name:SetValue(name_str)
	self.equip_type:SetValue("")
	self.grade:SetValue(item_cfg.level)

	local bundle, sprite = nil, nil
	local color = nil
	bundle, sprite = ResPath.GetQualityBgIcon(item_cfg.color)
	self.quality:SetAsset(bundle, sprite)

	self.equip_prof:SetValue(tianshenhutidata:GetTaozhuangTypeName(item_cfg.taozhuang_type))


	self.equip_item:SetData(self.data)
	self.equip_item:SetInteractable(false)

	local base_attr_list = CommonDataManager.GetAttributteNoUnderline(item_cfg, true)
	local base_attr_count = 1
	local base_attr_name = CommonStruct.AttributeName()
	for k, v in ipairs(base_attr_name) do
		local value = base_attr_list[v] or 0
		if value > 0 then
			local obj = U3DObject(self.base_attr_list[base_attr_count].gameObject)
			local image_obj = U3DObject(obj.transform:GetChild(0).gameObject)
			self.base_attr_list[base_attr_count].gameObject:SetActive(true)
			self.base_attr_list[base_attr_count].text.text = Language.Common.AttrNameNoUnderline[v]..": "..ToColorStr(value, TEXT_COLOR.BLACK_1)
			base_attr_count = base_attr_count + 1
			local asset, name = ResPath.GetBaseAttrIcon(Language.Common.AttrNameNoUnderline[v])
			image_obj.image:LoadSprite(asset, name, function()
				image_obj.image:SetNativeSize()
			end)
		else
			self.base_attr_list[base_attr_count].gameObject:SetActive(false)
		end
	end

	for i = base_attr_count, #self.base_attr_list do
		self.base_attr_list[i].gameObject:SetActive(false)
	end
	local tz_cfg = tianshenhutidata:GetTaozhuangLevelTypeCfg(item_cfg.level_taozhuang_type)
	local cur_has = tianshenhutidata:GetTaozhuangLevelTypeHas(item_cfg.level_taozhuang_type)
	self.tz_cur_has:SetValue(cur_has)
	for index, note_list in pairs(self.tz_attr_list) do
		local one_tz_cfg = tz_cfg and tz_cfg[index] or {}
		self.tz_name_t[index]:SetValue(one_tz_cfg.taozhuang_effect_name or "")
		self.tz_cur_need[index]:SetValue(one_tz_cfg.level_taozhuang_num or 0)
		local is_act = cur_has >= one_tz_cfg.level_taozhuang_num
		self.tz_cur_color[index]:SetValue(is_act and TEXT_COLOR.BLUE1 or TEXT_COLOR.RED)
		base_attr_list = CommonDataManager.GetAttributteNoUnderline(one_tz_cfg, true)
		base_attr_count = 1
		for k, v in ipairs(base_attr_name) do
			local value = base_attr_list[v] or 0
			if value > 0 and note_list[base_attr_count] then
				local obj = U3DObject(note_list[base_attr_count].gameObject)
				local image_obj = U3DObject(obj.transform:GetChild(0).gameObject)
				note_list[base_attr_count].gameObject:SetActive(true)
				note_list[base_attr_count].text.text = Language.Common.AttrNameNoUnderline[v]..": "..ToColorStr(value, is_act and TEXT_COLOR.BLACK_1 or TEXT_COLOR.GRAY)
				base_attr_count = base_attr_count + 1
				local asset, name = ResPath.GetBaseAttrIcon(Language.Common.AttrNameNoUnderline[v])
				image_obj.image:LoadSprite(asset, name, function()
					image_obj.image:SetNativeSize()
				end)
			elseif note_list[base_attr_count] then
				note_list[base_attr_count].gameObject:SetActive(false)
			end
		end

		for i = base_attr_count, #note_list do
			note_list[i].gameObject:SetActive(false)
		end
		if one_tz_cfg.skill_num then
			local skill_cfg = TianshenhutiData.Instance:GetSkillByIndex(one_tz_cfg.skill_num)
			if skill_cfg then
				self.skill_txt_color[index]:SetValue(is_act and TEXT_COLOR.BLACK_1 or TEXT_COLOR.GRAY)
				self.skill_per[index]:SetValue(one_tz_cfg.rate_injure/100)
				self.skill_name[index]:SetValue(skill_cfg.skill_name)
			end
		end
	end

	local capability = CommonDataManager.GetCapability(item_cfg)
	self.fight_power:SetValue(capability)
end

function TianshenhutiEquipTips:OnFlush(param_t)
	if self.data == nil then
		return
	end
	self.scroller_rect.normalizedPosition = Vector2(0, 1)
	self:ShowTipContent()
	self:ShowHandlerBtn()
end

-- 根据不同情况，显示和隐藏按钮
function TianshenhutiEquipTips:ShowHandlerBtn()
	if self.from_view == nil or self.from_view == TianshenhutiEquipTips.FromView.Normal then
		for k,v in pairs(self.buttons) do
			v.btn:SetActive(false)
		end
		return
	end
	local handler_types = self:GetOperationState()
	for k ,v in pairs(self.buttons) do
		local handler_type = handler_types[k]
		local tx = self.button_label[handler_type]
		if tx ~= nil then
			v.btn:SetActive(true)
			v.text.text.text = tx
			if self.button_handle[k] ~= nil then
				self.button_handle[k]:Dispose()
			end
			self.button_handle[k] = self:ListenEvent("Button"..k,
				BindTool.Bind(self.OnClickHandle, self, handler_type))
		else
			v.btn:SetActive(false)
		end
	end
end

function TianshenhutiEquipTips:GetOperationState()
	local t = {}
	if self.from_view == TianshenhutiEquipTips.FromView.EquipView then
		t[#t+1] = TipsHandleDef.HANDLE_TAKEOFF
	elseif self.from_view == TianshenhutiEquipTips.FromView.BagView then
		t[#t+1] = TipsHandleDef.HANDLE_EQUIP
	end

	return t
end

function TianshenhutiEquipTips:OnClickHandle(handler_type)
	if self.data == nil then
		return
	end

	if handler_type == TipsHandleDef.HANDLE_EQUIP then --装备
		TianshenhutiCtrl.SendTianshenhutiPutOn(self.data.index)
	elseif handler_type == TipsHandleDef.HANDLE_TAKEOFF then --脱下
		TianshenhutiCtrl.SendTianshenhutiTakeOff(self.data.index)
	end
	self:Close()
end

--关闭装备Tip
function TianshenhutiEquipTips:OnClickCloseButton()
	self:Close()
end

--设置显示弹出Tip的相关属性显示
function TianshenhutiEquipTips:SetData(data, from_view, close_callback)
	if not data then
		return
	end
	self.from_view = from_view or TianshenhutiEquipTips.FromView.Normal
	self.close_call_back = close_callback
	self.data = data
	self:Open()
	self:Flush()
end