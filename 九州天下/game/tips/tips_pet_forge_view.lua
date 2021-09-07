TipsPetForgeView = TipsPetForgeView or BaseClass(BaseView)
function TipsPetForgeView:__init()
	self.ui_config = {"uis/views/tips/pettips", "ShowPetForgeTips"}
	self.view_layer = UiLayer.Pop
	self.contain_cell_list = {}
	self.star_index = 0
	self.select_grid_num = 0
	self.play_audio = true
end

function TipsPetForgeView:__delete()
end

function TipsPetForgeView:LoadCallBack()
	self:ListenEvent("close_click",BindTool.Bind(self.OnCloseClick, self))
	self:ListenEvent("forge_click",BindTool.Bind(self.OnForgeClick, self))
	self.item_cell = ItemCell.New(self:FindObj("item_cell"))
	self.bar_list = {}
	for i=1,5 do
		self.bar_list[i] = {}
		self.bar_list[i].progress_slider = self:FindVariable("progress_" .. i)
		self.bar_list[i].bar_text = self:FindVariable("text_" .. i)
		self:ListenEvent("toggle_" .. i, BindTool.Bind2(self.OnToggleClick, self, i))
	end
	self.show_progress_4 = self:FindVariable("show_progress_4")
	self.show_progress_5 = self:FindVariable("show_progress_5")
	self.best_desc = self:FindVariable("best_desc")
	self.num_text = self:FindVariable("num_text")
	self.power_text = self:FindVariable("power_text")
	self.name_text = self:FindVariable("name_text")

	local handler = function()
		local close_call_back = function()
			self.item_cell:SetToggle(false)
		end
		self.item_cell:SetToggle(true)
		TipsCtrl.Instance:OpenItem(self.item_cell:GetData(), nil, nil, close_call_back)
	end
	self.item_cell = ItemCell.New(self:FindObj("item_cell"))
	self.item_cell:ListenClick(handler)
end

function TipsPetForgeView:SetStarIndex(star_index)
	self.star_index = star_index
end

function TipsPetForgeView:OpenCallBack()
	local pat_forge_view = PetForgeView.Instance
	local pet_info = pat_forge_view:GetCurrentPetInfo()
	local star_name = PetData.Instance:GetStarName(self.star_index)
	local pet_data = PetData.Instance
	local quality_cfg = pet_data:GetSingleQuality(pet_info.id)
	self.name_text:SetValue(star_name)
	if self.star_index <= 7 then
		self.best_desc:SetValue(star_name.."为最优属性")
	else
		self.best_desc:SetValue("增加基础属性百分比")
	end
	local is_show_grid_list = pet_data:GetIsShowGrid(quality_cfg.grid_num)
	self.show_progress_4:SetValue(is_show_grid_list[1])
	self.show_progress_5:SetValue(is_show_grid_list[2])
	local cur_index = pat_forge_view:GetCurrentStartIndex()
	for i=1,5 do
		if pet_info.point_list[cur_index].gridvaluelist[i].attr_value == 0 then
			self.bar_list[i].bar_text:SetValue("暂无属性")
			self.bar_list[i].progress_slider:SetValue(0)
		else
			local list = pet_info.point_list[cur_index].gridvaluelist[i]
			if self.star_index <= 7 then
				local forge_list = pet_data:GetSingleQianghuaCfg(quality_cfg.quality_type, self.star_index - 1)
				local max_value = pet_data:GetPetForgeMax(forge_list, list.arrt_type)
				self.bar_list[i].progress_slider:SetValue(list.attr_value / max_value)
				self.bar_list[i].bar_text:SetValue(pet_data:GetSelectAttri(list.arrt_type).."+"..list.attr_value)
			else
				self.bar_list[i].progress_slider:SetValue(list.attr_value/100)
				self.bar_list[i].bar_text:SetValue(pet_data:GetSelectAttri(list.arrt_type).."+"..list.attr_value.."%")
			end
		end
	end
	local data = ItemData.Instance:GetItemConfig(quality_cfg.qianghua_need_item_id)
	data.item_id = quality_cfg.qianghua_need_item_id
	data.is_bind = 1
	data.num = 0
	self.item_cell:SetData(data)
	self.num_text:SetValue(ItemData.Instance:GetItemNumInBagById(quality_cfg.qianghua_need_item_id) .."/" ..quality_cfg.qianghua_need_item_num)
	self.power_text:SetValue(pet_data:GetStarPower(self.star_index - 1, pet_data:GetPetListIndex(pet_info.info_type, pet_info.index)))
end

function TipsPetForgeView:OnCloseClick()
	self:Close()
end

function TipsPetForgeView:OnForgeClick()
	local pet_forge_view = PetForgeView.Instance
	local pet_data = PetData.Instance
	local pet_info = pet_forge_view:GetCurrentPetInfo()
	local quality_cfg = pet_data:GetSingleQuality(pet_info.id)
	if ItemData.Instance:GetItemNumInBagById(quality_cfg.qianghua_need_item_id) < quality_cfg.qianghua_need_item_num then
		TipsCtrl.Instance:ShowSystemMsg("强化物品不足")
		return
	end
	local star_index = pet_data:GetStarCfgIndex(pet_forge_view:GetCurrentStartIndex())
	local info_type = 0
	if pet_info.info_type == 1 then
		info_type = LITTLE_PET_REQ_TYPE.LITTLE_PET_REQ_INTENSIFY_SELF
	else
		info_type = LITTLE_PET_REQ_TYPE.LITTLE_PET_REQ_INTENSIFY_LOVER
	end
	PetCtrl.Instance:SendLittlePetREQ(info_type, pet_info.index, star_index, self.select_grid_num)
end

function TipsPetForgeView:OnFlush()
	local pat_forge_view = PetForgeView.Instance
	local temp_pet_info = pat_forge_view:GetCurrentPetInfo()
	local pet_data = PetData.Instance
	local quality_cfg = pet_data:GetSingleQuality(temp_pet_info.id)
	local change_pet_info = {}
	change_pet_info = pet_data:GetMineOrLoverPet(temp_pet_info.info_type, temp_pet_info.index)
	local is_show_grid_list = pet_data:GetIsShowGrid(quality_cfg.grid_num)
	local attr = change_pet_info.point_list[self.star_index].gridvaluelist[self.select_grid_num + 1]
	if self.star_index <= 7 then
		local forge_list = pet_data:GetSingleQianghuaCfg(quality_cfg.quality_type, self.star_index - 1)
		local max_value = pet_data:GetPetForgeMax(forge_list, attr.arrt_type)
		self.bar_list[self.select_grid_num + 1].progress_slider:SetValue(attr.attr_value/max_value)
		self.bar_list[self.select_grid_num + 1].bar_text:SetValue(pet_data:GetSelectAttri(attr.arrt_type) .."+"..attr.attr_value)
	else
		self.bar_list[self.select_grid_num + 1].progress_slider:SetValue(attr.attr_value/100)
		self.bar_list[self.select_grid_num + 1].bar_text:SetValue(pet_data:GetSelectAttri(attr.arrt_type).."+"..attr.attr_value.."%")
	end

	local item_num = ItemData.Instance:GetItemNumInBagById(quality_cfg.qianghua_need_item_id)
	self.num_text:SetValue(item_num .."/" ..quality_cfg.qianghua_need_item_num)
	self.power_text:SetValue(pet_data:GetStarPower(self.star_index - 1, pet_data:GetPetListIndex(temp_pet_info.info_type, temp_pet_info.index)))
end

function TipsPetForgeView:OnToggleClick(i,is_click)
	if is_click then
		self.select_grid_num = i - 1
	end
end
