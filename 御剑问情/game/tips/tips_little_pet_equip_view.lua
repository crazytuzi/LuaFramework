local CommonFunc = require("game/tips/tips_common_func")
TipsLittlePetEquipView = TipsLittlePetEquipView or BaseClass(BaseView)

local QUALITY_TEXT = {
	[2] = Language.LittlePet.QualityText2,
	[3] = Language.LittlePet.QualityText3,
	[4] = Language.LittlePet.QualityText4,
	[5] = Language.LittlePet.QualityText5,
}

function TipsLittlePetEquipView:__init()
	self.ui_config = {"uis/views/tips/equiptips_prefab","LittlePetTip"}
	self.view_layer = UiLayer.Pop
	self.close_call_back = nil
	self.base_attr_list = {}
	self.special_attr_list = {}
	self.random_attr_list = {}
	self.data = nil
	self.from_view = nil
	self.handle_param_t = {}
	self.buttons = {}
	self.button_label = Language.Tip.ButtonLabel
	self.button_handle = {}
	self.fix_show_time = 8
	self.play_audio = true
	self.total_attr_list = CommonStruct.AttributeNoUnderline()
end

function TipsLittlePetEquipView:LoadCallBack()
	-- 功能按钮
	self.equip_item = ItemCell.New()
	self.equip_item:SetInstanceParent(self:FindObj("EquipItem"))
	self.button_root = self:FindObj("RightBtn")
	for i =1 ,4 do
		local button = self.button_root:FindObj("Btn"..i)
		local btn_text = self.button_root:FindObj("Btn"..i.."/Text")
		self.buttons[i] = {btn = button, text = btn_text}
	end

	-- 属性显示
	for i = 1, 4 do
		self.base_attr_list[i] = {
			attr_name = self:FindVariable("BaseAttrName"..i),
			attr_value = self:FindVariable("BaseAttrValue"..i),
			is_show = self:FindVariable("ShowBaseAttr"..i), 
			attr_icon = self:FindVariable("Icon_base"..i)
		}
	end

	self.equip_name = self:FindVariable("EquipName")
	self.equip_type = self:FindVariable("EquipType")
	self.quality_text = self:FindVariable("QualityText")
	self.tab_images = self:FindVariable("tab_images")
	self.quality = self:FindVariable("Quality")
	self.fight_power = self:FindVariable("FightPower")
	self.sale_price = self:FindVariable("SalePrice")

	self.extra_attr_name=self:FindVariable("ExtraAttrName")
	self.extra_attr_value=self:FindVariable("ExtraAttrValue")
	self.show_extra_attr=self:FindVariable("ShowExtraAttr")

	self:ListenEvent("Close", BindTool.Bind(self.OnClickCloseButton, self))

	-- 模型
	self.scroller_rect = self:FindObj("Scroller").scroll_rect
	self.display = self:FindObj("Display")
	self.model = RoleModel.New("little_pet_item_tips_panel")
	self.model:SetDisplay(self.display.ui3d_display)
end

function TipsLittlePetEquipView:__delete()
	CommonFunc.DeleteMe()
	self.button_label = nil
	self.base_attr_list = nil
	self.special_attr_list = nil
	self.random_attr_list = nil
	self.buttons = nil
	self.fix_show_time = nil
	self.button_handle = nil
	
end

function TipsLittlePetEquipView:ReleaseCallBack()
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	if self.equip_item then
		self.equip_item:DeleteMe()
		self.equip_item = nil
	end

	if self.ani_quest_time then
		GlobalTimerQuest:CancelQuest(self.ani_quest_time)
		self.ani_quest_time = nil
	end

	-- 清理变量
	self.button_root = nil
	self.equip_name = nil
	self.equip_type = nil
	self.quality_text = nil
	self.tab_images = nil
	self.quality = nil
	self.fight_power = nil
	self.sale_price = nil
	self.extra_attr_name = nil
	self.extra_attr_value = nil
	self.show_extra_attr = nil
	self.display = nil
	self.scroller_rect = nil

end

function TipsLittlePetEquipView:CloseCallBack()
	GlobalTimerQuest:CancelQuest(self.time_quest)
	self.time_quest = nil
	if self.close_call_back ~= nil then
		self.close_call_back()
		self.close_call_back = nil
	end

	for k, v in pairs(self.button_handle) do
		v:Dispose()
	end
	self.button_handle = {}
end

-- 根据不同情况，显示和隐藏按钮
local function ShowHandlerBtn(self)
	if self.from_view == nil then
		return
	end
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg == nil then
		return
	end
	local handler_types = CommonFunc.GetOperationState(self.from_view, self.data, item_cfg, big_type)
	for k ,v in pairs(self.buttons) do
		local handler_type = handler_types[k]
		-- 按钮文字显示将出战改为使用
		-- local cur_type = handler_type == 30 and 2 or handler_type 
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

function TipsLittlePetEquipView:OnClickHandle(handler_type)
	if self.data == nil then
		return
	end

	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg == nil then
		return
	end

	if not CommonFunc.DoClickHandler(self.data, item_cfg, handler_type, self.from_view, self.handle_param_t) then
	 	return 
	end
	self:Close()
end

function TipsLittlePetEquipView:OnFlush(param_t)
	if self.data == nil then
		return
	end
	self.scroller_rect.normalizedPosition = Vector2(0, 1)
	-- self:ShowTipContent()
	ShowHandlerBtn(self)

	self:FlushTitle()
	self:FlushAttr()
	self:FlushRecycle()
	self:FlushPower()
	self:FlushModel()
end

--设置显示弹出Tip的相关属性显示
function TipsLittlePetEquipView:SetData(data, from_view, param_t, close_call_back)
	if not data then
		return
	end
	if type(data) == "string" then
		self.data = CommonStruct.ItemDataWrapper()
		self.data.item_id = data
	else
		self.data = data
	end
	self:Open()
	self.from_view = from_view or TipsFormDef.FROM_NORMAL
	self.handle_param_t = param_t or {}
	self.close_call_back = close_call_back
	self:Flush()
end

-- 刷新标题框
function TipsLittlePetEquipView:FlushTitle()
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_id)
	local spirit_level = nil ~= self.data.param and self.data.param.strengthen_level or 0
	local spirit_cfg = SpiritData.Instance:GetSpiritLevelCfgById(self.data.item_id, spirit_level)

	if nil == item_cfg then
		return
	end

	local quality = item_cfg.color
	self.equip_name:SetValue(ToColorStr(item_cfg.name, ITEM_TIP_NAME_COLOR[quality]))
	self.equip_type:SetValue(Language.LittlePet.LittlePetType)
	self.quality_text:SetValue(ToColorStr(QUALITY_TEXT[quality], SOUL_NAME_COLOR[quality]))
	local bundle, asset = ResPath.GetTipsImageByIndex(item_cfg.color)
	self.tab_images:SetAsset(bundle, asset)
	self.equip_item:SetData(self.data)
	self.equip_item:SetInteractable(false)

end

-- 刷新基础属性
function TipsLittlePetEquipView:FlushAttr()
	local base_attr_data_list = LittlePetData.Instance:GetLittlePetBaseAttr(self.data.item_id)
	local had_base_attr = {}

	for k, v in pairs(base_attr_data_list) do
		if v > 0 then
			table.insert(had_base_attr, {key = k, value = v})
		end
	end

	-- 基础属性
	if #had_base_attr > 0 then
		for k, v in pairs(self.base_attr_list) do
			v.is_show:SetValue(had_base_attr[k] ~= nil)
			if had_base_attr[k] ~= nil then
				v.attr_name:SetValue(Language.Common.AttrNameNoUnderline[had_base_attr[k].key])
				v.attr_value:SetValue(had_base_attr[k].value)
				local bundle,asset = ResPath.GetBaseAttrIcon(had_base_attr[k].key)
				v.attr_icon:SetAsset(bundle, asset)
			end
		end
	end
end

-- 刷新回收积分
function TipsLittlePetEquipView:FlushRecycle()
	local recycle_score, recycle_type = LittlePetData.Instance:GetRecycleDataByItemID(self.data.item_id)
	self.sale_price:SetValue(recycle_score)
end

-- 刷新战力
function TipsLittlePetEquipView:FlushPower()
	local power = LittlePetData.Instance:CalPetBaseFightPower(false, self.data.item_id)
	self.fight_power:SetValue(power)
end

-- 刷新模型
function TipsLittlePetEquipView:FlushModel()
	if self.display ~= nil then
		self.display.ui3d_display:ResetRotation()
	end

	local res_id = LittlePetData.Instance:GetLittlePetResIDByItemID(self.data.item_id)
	local asset, bundle = ResPath.GetLittlePetModel(res_id)
	self.model:SetMainAsset(asset, bundle)

	self.model:SetTrigger("Relax")
	if self.ani_quest_time then
		GlobalTimerQuest:CancelQuest(self.ani_quest_time)
		self.ani_quest_time = nil
	end
	self.ani_quest_time = GlobalTimerQuest:AddRunQuest(function ()
		self.model:SetTrigger("Relax")
		end, 10)
end

--关闭装备Tip
function TipsLittlePetEquipView:OnClickCloseButton()
	self:Close()
end