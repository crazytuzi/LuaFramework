LittlPetPropTipView = LittlPetPropTipView or BaseClass(BaseView)

function LittlPetPropTipView:__init()
	self.ui_config = {"uis/views/littlepetview", "LittlePetShopPropTip"}
	self.view_layer = UiLayer.Pop
	self.close_call_back = nil
end

function LittlPetPropTipView:LoadCallBack()
	self.icon = self:FindVariable("Icon")
	self.detail = self:FindVariable("Detail")
	self.quality = self:FindVariable("Quality")
	self.pet_item_name = self:FindVariable("Name")
	self.fight_power = self:FindVariable("FightPower")
	self.is_show_power = self:FindVariable("IsShowPower")

	self.scroller_rect = self:FindObj("Scroller").scroll_rect

	self:ListenEvent("CloseButton", BindTool.Bind(self.CloseButton, self))
end

function LittlPetPropTipView:ReleaseCallBack()
	self.icon = nil
	self.detail = nil
	self.quality = nil
	self.fight_power = nil
	self.is_show_power = nil
	self.pet_item_name = nil
	self.scroller_rect = nil
end

function LittlPetPropTipView:OpenCallBack()
	self.scroller_rect.normalizedPosition = Vector2(0, 1)

	local name_str = "<color="..SOUL_NAME_COLOR[self.data.name_color]..">"..self.data.name.."</color>"
	local bundle, asset = ResPath.GetItemIcon(self.data.icon_pic)
	local bundle1, asset1 = ResPath.GetQualityIcon(self.data.name_color)

	self.icon:SetAsset(bundle, asset)
	self.quality:SetAsset(bundle1, asset1)
	self.pet_item_name:SetValue(name_str)
	self.detail:SetValue(self.data.detail)

	local is_pet = false
	local cfg, big_type = ItemData.Instance:GetItemConfig(self.data.icon_pic)
	if cfg and GameEnum.ITEM_BIGTYPE_EXPENSE == big_type and cfg.use_type == GameEnum.USE_TYPE_LITTLE_PET then
		is_pet = true
	end
	local power = is_pet and LittlePetData.Instance:CalPetBaseFightPower(false, self.data.icon_pic) or 0
	self.fight_power:SetValue(power)
	self.is_show_power:SetValue(is_pet)
end

function LittlPetPropTipView:CloseCallBack()
	if self.close_call_back ~= nil then
		self.close_call_back()
	end
	self.close_call_back = nil
end

function LittlPetPropTipView:CloseButton()
	self:Close()
end

function LittlPetPropTipView:SetData(data, close_call_back)
	self.data = data
	if close_call_back ~= nil then
		self.close_call_back = close_call_back
	end
	self:Open()
end