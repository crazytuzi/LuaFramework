LianhunEquipTips = LianhunEquipTips or BaseClass(BaseView)

function LianhunEquipTips:__init()
	self.ui_config = {"uis/views/lianhun_prefab","LianhunEquipTip"}
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
end

function LianhunEquipTips:__delete()
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

function LianhunEquipTips:ReleaseCallBack()
	for k, v in pairs(self.base_attr_list) do
		GameObject.Destroy(v.gameObject)
	end
	self.base_attr_list = {}

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
	self.show_storge_score = nil
	self.storge_score = nil
	self.recycle_value = nil
	self.show_recycle = nil

	self.show_effe = nil
	self.cast_shuxing_text = nil
	self.show_cast_shuxing = nil
	self.orange_crystal = nil
	self.show_orange_crystal = nil
	self.red_crystal = nil
	self.show_red_crystal = nil
end

function LianhunEquipTips:CloseCallBack()
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

function LianhunEquipTips:OpenCallBack()
	self.show_cast = false
	self.show_legend = false
end

function LianhunEquipTips:LoadCallBack()
	-- 功能按钮
	UtilU3d.PrefabLoad("uis/views/lianhun_prefab","LianhunEquip",
		function(obj)
			obj.transform:SetParent(self:FindObj("EquipItem").transform, false)
			obj = U3DObject(obj)
			self.equip_item = LianhunEquipItemCell.New(obj)
			self:Flush()
		end)
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

	self.orange_crystal = self:FindVariable("OrangeCrystal")
	self.show_orange_crystal = self:FindVariable("ShowOrangeCrystal")
	self.red_crystal = self:FindVariable("RedCrystal")
	self.show_red_crystal = self:FindVariable("ShowRedCrystal")

	self:ListenEvent("Close",
		BindTool.Bind(self.OnClickCloseButton, self))

	self.scroller_rect = self:FindObj("Scroller").scroll_rect

	self.grade = self:FindVariable("Grade")

	self.show_storge_score = self:FindVariable("ShowStorgeScore")
	self.show_storge_score:SetValue(false)
	self.storge_score = self:FindVariable("StorgeScore")
	self.recycle_value = self:FindVariable("RecycleValue")
	self.show_recycle = self:FindVariable("ShowRecycle")
	self.show_recycle:SetValue(false)

	self.show_recycle:SetValue(false)

	self.cast_shuxing_text = self:FindVariable("CastShuXingText")
	self.show_cast_shuxing = self:FindVariable("ShowCastShuXing")
end

--获得当前人物可穿的装备的最高阶数
function LianhunEquipTips:CalculateMaxOrder()
	local main_role_lv = GameVoManager.Instance:GetMainRoleVo().level
	local max_order = ItemData.Instance:GetItemMaxOrder(main_role_lv)
	return max_order
end

function LianhunEquipTips:ShowTipContent()
	local item_cfg = LianhunData.Instance:GetEquipLianhuncfg(self.data.index, self.data.lianhun_level)
	if item_cfg == nil or nil == self.equip_item then
		return
	end
	self.wear_icon:SetValue(true)
	local name_str = "<color="..ITEM_TIP_NAME_COLOR[self.data.lianhun_level]..">"..item_cfg.name.."</color>"
	-- local color_1 = EquipData.Instance:GetTextColor1(item_cfg.color)
	-- local color_2 = EquipData.Instance:GetTextColor2(item_cfg.color)
	-- self.color_1:SetValue(color_1)
	-- self.color_2:SetValue(color_2)

	self.equip_name:SetValue(name_str)
	self.equip_type:SetValue(Language.EquipTypeToName[GameEnum.EQUIP_INDEX_TOUKUI])
	self.grade:SetValue(self.data.lianhun_level)

	local bundle, sprite = nil, nil
	local color = nil
	bundle, sprite = ResPath.GetQualityBgIcon(self.data.lianhun_level)
	self.quality:SetAsset(bundle, sprite)

	self.equip_prof:SetValue(Language.Common.ProfName[5])


	self.equip_item:SetData(self.data)
	self.equip_item:SetInteractable(false)
	if self.data.lianhun_level > 0 then
		self.equip_item:SetColorLabel(ResPath.GetLianhunRes("colorlabel_" .. self.data.lianhun_level))
	else
		self.equip_item:SetColorLabel("", "")
	end

	local base_attr_list = CommonDataManager.GetAttributteNoUnderline(item_cfg, true)
	local base_attr_count = 1
	local base_attr_name = CommonStruct.AttributeName()
	for k, v in ipairs(base_attr_name) do
		local value = base_attr_list[v] or 0
		if value > 0 then
			local obj = self.base_attr_list[base_attr_count].gameObject
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

	local capability = CommonDataManager.GetCapability(item_cfg)
	self.fight_power:SetValue(capability)
end

function LianhunEquipTips:OnFlush(param_t)
	if self.data == nil then
		return
	end
	self.scroller_rect.normalizedPosition = Vector2(0, 1)
	self:ShowTipContent()
end

--关闭装备Tip
function LianhunEquipTips:OnClickCloseButton()
	self:Close()
end

--设置显示弹出Tip的相关属性显示
function LianhunEquipTips:SetData(data)
	if not data then
		return
	end
	self.data = data
	self:Open()
	self:Flush()
end