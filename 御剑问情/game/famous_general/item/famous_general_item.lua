
--------------------------- 名将头像Item------------------
GeneralHeadRender = GeneralHeadRender or BaseClass(BaseCell)
function GeneralHeadRender:__init()
	self.head_icon = self:FindVariable("Head")
	self.show_hl = self:FindVariable("ShowHl")
	self.view_flag = self:FindVariable("view_flag")
	self.red_flag = self:FindVariable("red_flag")
	self.quality = self:FindVariable("quality")
	self.show_active = self:FindVariable("active")
	self.show_red = self:FindVariable("red")
	self.show_up = self:FindVariable("up")

	self:ListenEvent("OnClickUpLevel", BindTool.Bind(self.OnClickUpLevel, self))
	self:ListenEvent("OnClick", BindTool.Bind(self.OnClick,self))
end

function GeneralHeadRender:SetParent(parent)
	self.parent = parent
end

function GeneralHeadRender:OnFlush()
	if CheckInvalid(self.data) then
		return
	end
	self:ConstructData()
	self:SetFlag()
	self:SetHeadIInfo()
end

function GeneralHeadRender:ConstructData()
	self.item_id = self.data.item_id
	self.seq = self.data.seq
	self.color = self.data.color
	if self.tab_index == TabIndex.famous_general_info then
		self.can_up = FamousGeneralData.Instance:IsCanUpGeneral(self.index)
		self.can_guangwu_image_up = FamousGeneralData.Instance:IsCanUpGuangwuImage()
		self.can_fazhen_image_up = FamousGeneralData.Instance:IsCanUpFaZhenImage()
	elseif self.tab_index == TabIndex.famous_general_potential then
		self.can_up = FamousGeneralData.Instance:IsCanUpPotential(self.index)
	end
	self.is_actived = FamousGeneralData.Instance:IsActiveGeneral(self.index)
end

function GeneralHeadRender:SetFlag()
	self.show_active:SetValue(self.is_actived)
	if self.tab_index == TabIndex.famous_general_info then
		self.show_red:SetValue(self.can_guangwu_image_up or self.can_fazhen_image_up)
		self.show_up:SetValue(self.can_up)
	elseif self.tab_index == TabIndex.famous_general_potential then
		self.show_red:SetValue(self.can_up)
	end

end

function GeneralHeadRender:SetHeadIInfo()
	-- local item_cfg = ItemData.Instance:GetItemConfig(self.item_id) or {}
	local bundle, asset = ResPath.GetItemIcon(self.item_id or 0)
	self.head_icon:SetAsset(bundle, asset)
	self.quality:SetAsset(ResPath.GetQualityIcon(self.color))
end

function GeneralHeadRender:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function GeneralHeadRender:FlushHL(cur_select)
	self.show_hl:SetValue(cur_select == self.index)
end

function GeneralHeadRender:OnClickUpLevel()
	if self.can_up and self.tab_index == TabIndex.famous_general_info then
		FamousGeneralCtrl.Instance:SendRequest(GREATE_SOLDIER_REQ_TYPE.GREATE_SOLDIER_REQ_TYPE_LEVEL_UP, self.seq)
	end
	if self.click_callback then
		self.click_callback(self.index)
	end
end

function GeneralHeadRender:OnClick()
	if self.click_callback then
		self.click_callback(self.index)
	end
end

function GeneralHeadRender:SetClickCallBAck(callback)
	self.click_callback = callback
end

function GeneralHeadRender:SetTabIndex(tab_index)
	self.tab_index = tab_index
end

