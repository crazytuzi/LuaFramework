PetForgeView = PetForgeView or BaseClass(BaseRender)

function PetForgeView:__init(instance)
	PetForgeView.Instance = self
	self.cell_list = {}
	self.cur_star = -1
	self.power_value_text = self:FindVariable("power_value_text")
	self.show_teshu_star = self:FindVariable("show_teshu_star")
	self.is_have_pet = self:FindVariable("is_have_pet")
	self.pet_name = self:FindVariable("pet_name")
	self.modle_display = self:FindObj("modle_display")
	self:ListenEvent("change_pet_click", BindTool.Bind(self.OnChangePetClick, self))
	self:ListenEvent("question_click", BindTool.Bind(self.OnQuestionClick, self))
	self:ListenEvent("rename_click", BindTool.Bind(self.ReNameClick, self))
	self:ListenEvent("free_pet_click", BindTool.Bind(self.FreePetClick, self))
	self:ListenEvent("go_achieve_content", BindTool.Bind(self.GoAchieveContent, self))
	for i=1,8 do
		self:ListenEvent("star_" .. i .. "_click", BindTool.Bind2(self.OnStartClick, self, i))
	end

	self.is_have_pet:SetValue(false)
	self.cur_pet_info = {}
	-- self:SetCurrentPetInfo(PetData.Instance:GetAllInfoList().pet_list[1])

	self.pet_modle = RoleModel.New()
	self.pet_modle:SetDisplay(self.modle_display.ui3d_display)

	self.my_pet_item_list = {}
	self.friend_pet_item_list = {}
	for i = 1, 5 do
		local my_pet_item = PetForgeItem.New(self:FindObj("my_pet_item_" .. i), self)
		self.my_pet_item_list[i] = my_pet_item

		local friend_pet_item = PetForgeItem.New(self:FindObj("friend_pet_item_" .. i), self)
		self.friend_pet_item_list[i] = friend_pet_item
	end


----------
	self.star_index = 1
	self:ListenEvent("forge_click",BindTool.Bind(self.OnForgeClick, self))
	self.item_cell = ItemCell.New(self:FindObj("item_cell"))
	self.bar_list = {}
	for i=1,5 do
		self.bar_list[i] = {}
		self.bar_list[i].progress_slider = self:FindVariable("progress_" .. i)
		self.bar_list[i].bar_text = self:FindVariable("text_" .. i)
		self.bar_list[i].check_box = self:FindObj("check_box_" .. i)
		self:ListenEvent("toggle_" .. i, BindTool.Bind2(self.OnToggleClick, self, i))
	end
	self.show_progress_4 = self:FindVariable("show_progress_4")
	self.show_progress_5 = self:FindVariable("show_progress_5")
	self.best_desc = self:FindVariable("best_desc")
	self.cur_num_text = self:FindVariable("cur_num_text")
	self.need_num_text = self:FindVariable("need_num_text")
	self.power_text = self:FindVariable("power_text")
	self.name_text = self:FindVariable("name_text")
	self.is_mine = self:FindVariable("is_mine")

	local handler = function()
		local close_call_back = function()
			self.item_cell:SetToggle(false)
		end
		self.item_cell:SetToggle(true)
		TipsCtrl.Instance:OpenItem(self.item_cell:GetData(), nil, nil, close_call_back)
	end
	self.item_cell:ListenClick(handler)
----------
	self.select_index_list = {}
	for i=1,5 do
		self.select_index_list[i] = false
	end

	self.star_effect_list = {}
	for i = 1, 7 do
		self.star_effect_list[i] = self:FindVariable("star_effect_" .. i)
	end
end

function PetForgeView:__delete()
	if self.pet_modle ~= nil then
		self.pet_modle:DeleteMe()
		self.pet_modle = nil
	end

	for _,v in pairs(self.my_pet_item_list) do
		v:DeleteMe()
	end
	self.my_pet_item_list = {}

	for _,v in pairs(self.friend_pet_item_list) do
		v:DeleteMe()
	end
	self.friend_pet_item_list = {}
end

function PetForgeView:SetShowFreeBtn(is_show)
	self.is_mine:SetValue(is_show)
end

function PetForgeView:SetCurPetName()
	self.pet_name:SetValue(self.cur_pet_info.pet_name)
end

function PetForgeView:OnChangePetClick()
	if not self:JudgePetCount() then return end
	if self.cur_pet_info.info_type == 0 then
		TipsCtrl.Instance:ShowSystemMsg(Language.Pet.NoCanHelpLove)
		return
	end
	TipsCtrl.Instance:ShowPetReplaceView()
end

function PetForgeView:OnQuestionClick()
	local tips_id = 91 -- 宠物强化帮助
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function PetForgeView:SetCurrentPetInfo(pet_info)
	if pet_info == nil or #pet_info.point_list == 0 then
		return
	end
	self.is_have_pet:SetValue(true)
	self.cur_pet_info = pet_info
	local res_id = PetData.Instance:GetSinglePetCfg(pet_info.id).using_img_id
	if self.pet_modle then
		self.pet_modle:SetMainAsset(ResPath.GetPetModel(res_id))
	end
	self.power_value_text:SetValue(self:GetPetTotlaPower())
	self.show_teshu_star:SetValue(PetData.Instance:GetSingleQuality(pet_info.id).is_specail == 1)
end

function PetForgeView:GetCurrentPetInfo()
	return self.cur_pet_info
end

function PetForgeView:GetCurrentStartIndex()
	return self.cur_star
end

function PetForgeView:OnStartClick(i)
	if not self:JudgePetCount() then return end
	self.cur_star = i
	self:SetStarIndex(i)
	self:InitAttPanle()
end

function PetForgeView:JudgePetCount()
	if PetData.Instance:GetAllInfoList().pet_count == 0 then
		TipsCtrl.Instance:ShowSystemMsg(Language.Pet.NoPet)
		self.is_have_pet:SetValue(false)
		return false
	end
	return true
end


function PetForgeView:FLushItemData()
	for i=1,5 do
		self.my_pet_item_list[i]:SetPetInfo(PetData.Instance:GetAllInfoList().pet_list_mine[i], i, true)
		if nil ~= PetData.Instance:GetAllInfoList().pet_list_lover then
			self.friend_pet_item_list[i]:SetPetInfo(PetData.Instance:GetAllInfoList().pet_list_lover[i],  i + 5, false)
		end
	end
end

function PetForgeView:Reload()
	--初始化信息面板
	local pet_count_mine = PetData.Instance:GetAllInfoList().pet_count_mine
	if pet_count_mine == 0 then
		self.is_mine:SetValue(false)
	end
	self:FLushItemData()
	local temp_info = PetData.Instance:GetAllInfoList().pet_list_mine[1]
	if temp_info then
		self.my_pet_item_list[1]:SetToggle(true)
		self:FlushAllHl()
	end
	if PetData.Instance:GetAllInfoList().pet_count == 0 then
		self.is_have_pet:SetValue(false)
		return
	end
	self.is_have_pet:SetValue(true)

	self:SetCurrentPetInfo(PetData.Instance:GetAllInfoList().pet_list[1])
	self:OnStartClick(1)
	-- self:InitAttPanle()
	-- local pet_res_id = "没有小宠物模型"
	-- self.pet_modle:SetMainAsset(ResPath.GetMountModel(pet_res_id))
	--设置宠物item信息

	self.power_value_text:SetValue(self:GetPetTotlaPower())
end

--修改宠物名字
function PetForgeView:ReNameClick()
	local callback = function(name)
		PetCtrl.Instance:SendLittlePetRename(self.cur_pet_info.index, name)
	end
	local text = string.format(Language.Common.PetRename1, PetData.Instance:GetOtherCfg()[1].rename_consume)
	TipsCtrl.Instance:ShowRename(callback, nil, nil, text, Language.Common.PetRename2)
end

--放生宠物
function PetForgeView:FreePetClick()
	local func = function()
		PetData.Instance:SetFreeOperation(true)
		PetCtrl.Instance:SendLittlePetREQ(LITTLE_PET_REQ_TYPE.LITTLE_PET_REQ_RELIVE, self.cur_pet_info.index, self.cur_pet_info.info_type, 0)
	end

	local num_text = string.format(Language.Mount.ShowGreenNum, PetData.Instance:GetReturnItemNum(self.cur_pet_info))
	local str = string.format(Language.Common.PetReliveTip, num_text)
	TipsCtrl.Instance:ShowCommonTip(func, nil, str, nil, nil, false, false)
end

function PetForgeView:GoAchieveContent()
	--跳转获取面板
	local pet_view = PetCtrl.Instance:GetView()
	pet_view:ChangeToIndex(TabIndex.pet_achieve)
end

------------------


function PetForgeView:SetStarIndex(star_index)
	self.star_index = star_index
	for i = 1 , 7 do
		if self.star_index == i then
			self.star_effect_list[i]:SetValue(true)
		else
			self.star_effect_list[i]:SetValue(false)
		end
	end
	self:OnFlush()
end

function PetForgeView:GetPetTotlaPower()
	local totla_power = 0
	local pet_index = PetData.Instance:GetPetListIndex(self.cur_pet_info.info_type, self.cur_pet_info.index)
	for i = 1, 8 do
		totla_power = totla_power + PetData.Instance:GetStarPower(i - 1, pet_index)
	end
	totla_power = totla_power + CommonDataManager.GetCapability(self.cur_pet_info)
	return totla_power
end


function PetForgeView:InitAttPanle()
	local pet_info = self:GetCurrentPetInfo()
	local star_name = PetData.Instance:GetStarName(self.star_index)
	local pet_data = PetData.Instance
	local quality_cfg = pet_data:GetSingleQuality(pet_info.id)
	self.name_text:SetValue(star_name .. Language.Pet.Star)
	if self.star_index <= 7 then
		self.best_desc:SetValue(string.format("<color='#FEFE00FF'>%s</color>", star_name) .. Language.Pet.Best)
	else
		self.best_desc:SetValue(Language.Pet.PerAttr)
	end
	local is_show_grid_list = pet_data:GetIsShowGrid(quality_cfg.grid_num)
	self.show_progress_4:SetValue(is_show_grid_list[1])
	self.show_progress_5:SetValue(is_show_grid_list[2])
	local cur_index = self:GetCurrentStartIndex()
	local need_forge_num = 0
	for i=1,5 do
		if pet_info.point_list[cur_index].gridvaluelist[i].attr_value == 0 then
			self.bar_list[i].bar_text:SetValue(Language.Pet.NoAttr)
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

		if self.select_index_list[i] then
			need_forge_num = need_forge_num + quality_cfg.qianghua_need_item_num
		end
	end

	local data = ItemData.Instance:GetItemConfig(quality_cfg.qianghua_need_item_id)
	data.item_id = quality_cfg.qianghua_need_item_id
	data.is_bind = 1
	data.num = 0
	self.item_cell:SetData(data)
	local cur_num = ItemData.Instance:GetItemNumInBagById(quality_cfg.qianghua_need_item_id)
	local cur_text = string.format("<color='#00FF02FF'>%s</color>", cur_num) -- 绿色
	if cur_num < quality_cfg.qianghua_need_item_num then
		cur_text = string.format("<color='#FF0000FF'>%s</color>", cur_num) -- 红色
	end
	self.cur_num_text:SetValue(cur_text)
	self.need_num_text:SetValue(need_forge_num)
	self.power_text:SetValue(pet_data:GetStarPower(self.star_index - 1, pet_data:GetPetListIndex(pet_info.info_type, pet_info.index)))
	self.power_value_text:SetValue(self:GetPetTotlaPower())
end

function PetForgeView:OnForgeClick()

	if not self:IsSelectedAtLeastOne() then
		--未选择属性
		TipsCtrl.Instance:ShowSystemMsg(Language.Pet.PleaseSelectAtt)
		return
	end

	local pet_data = PetData.Instance
	local pet_info = self:GetCurrentPetInfo()
	local quality_cfg = pet_data:GetSingleQuality(pet_info.id)
	if ItemData.Instance:GetItemNumInBagById(quality_cfg.qianghua_need_item_id) < quality_cfg.qianghua_need_item_num then
		-- TipsCtrl.Instance:ShowSystemMsg("强化物品不足")
		local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[quality_cfg.qianghua_need_item_id]
		if item_cfg == nil then
			TipsCtrl.Instance:ShowItemGetWayView(quality_cfg.qianghua_need_item_id)
			return
		else
			TipsCtrl.Instance:ShowShopView(quality_cfg.qianghua_need_item_id, 2)
			return
		end
	end
	local star_index = pet_data:GetStarCfgIndex(self:GetCurrentStartIndex())
	local info_type = 0
	if pet_info.info_type == 1 then
		info_type = LITTLE_PET_REQ_TYPE.LITTLE_PET_REQ_INTENSIFY_SELF
	else
		info_type = LITTLE_PET_REQ_TYPE.LITTLE_PET_REQ_INTENSIFY_LOVER
	end

	for i=1,5 do
		if self.select_index_list[i] then
			PetCtrl.Instance:SendLittlePetREQ(info_type, pet_info.index, star_index, i - 1)
		end
	end

end

function PetForgeView:OnFlush()
	local temp_pet_info = self:GetCurrentPetInfo()

	self.pet_name:SetValue(temp_pet_info.pet_name)
	local quality_cfg = PetData.Instance:GetSingleQuality(temp_pet_info.id)
	local change_pet_info = {}
	change_pet_info = PetData.Instance:GetMineOrLoverPet(temp_pet_info.info_type, temp_pet_info.index)
	local is_show_grid_list = PetData.Instance:GetIsShowGrid(quality_cfg.grid_num)
	local need_forge_num = 0

	for i=1,5 do
		if self.select_index_list[i] then
			local attr = change_pet_info.point_list[self.star_index].gridvaluelist[i]
			if self.star_index <= 7 then
				local forge_list = PetData.Instance:GetSingleQianghuaCfg(quality_cfg.quality_type, self.star_index - 1)
				local max_value = PetData.Instance:GetPetForgeMax(forge_list, attr.arrt_type)
				self.bar_list[i].progress_slider:SetValue(attr.attr_value/max_value)
				self.bar_list[i].bar_text:SetValue(PetData.Instance:GetSelectAttri(attr.arrt_type) .."+"..attr.attr_value)
			else
				self.bar_list[i].progress_slider:SetValue(attr.attr_value/100)
				self.bar_list[i].bar_text:SetValue(PetData.Instance:GetSelectAttri(attr.arrt_type).."+"..attr.attr_value.."%")
			end
			need_forge_num = need_forge_num + quality_cfg.qianghua_need_item_num
		end
	end

	local cur_num = ItemData.Instance:GetItemNumInBagById(quality_cfg.qianghua_need_item_id)

	local cur_text = string.format("<color='#00FF02FF'>%s</color>", cur_num) -- 绿色
	if cur_num < quality_cfg.qianghua_need_item_num then
		cur_text = string.format("<color='#FF0000FF'>%s</color>", cur_num) -- 红色
	end
	self.cur_num_text:SetValue(cur_text)
	self.need_num_text:SetValue(need_forge_num)
	self.power_text:SetValue(PetData.Instance:GetStarPower(self.star_index - 1, PetData.Instance:GetPetListIndex(temp_pet_info.info_type, temp_pet_info.index)))
	self.power_value_text:SetValue(self:GetPetTotlaPower())
end

function PetForgeView:OnToggleClick(i,is_click)
	self.select_index_list[i] = is_click
	self:SetNeedForgeNum()
end

function PetForgeView:SetNeedForgeNum()
	local need_forge_num = 0
	local quality_cfg = PetData.Instance:GetSingleQuality(self.cur_pet_info.id)
	for i=1,5 do
		if self.select_index_list[i] then
			need_forge_num = need_forge_num + quality_cfg.qianghua_need_item_num
		end
	end
	self.need_num_text:SetValue(need_forge_num)
end

function PetForgeView:ClearSelectList()
	for i=1,5 do
		self.select_index_list[i] = false
		self.bar_list[i].check_box.toggle.isOn = false
	end
end

--是否至少选择了一项属性
function PetForgeView:IsSelectedAtLeastOne()
	for i=1,5 do
		if self.select_index_list[i] then
			return true
		end
	end
	return false
end

function PetForgeView:FlushAllHl()
	for i = 1, 5 do
		self.my_pet_item_list[i]:FlushHl()
		self.friend_pet_item_list[i]:FlushHl()
	end
end

----------------------------------------------------------
PetForgeItem = PetForgeItem  or BaseClass(BaseCell)

function PetForgeItem:__init()
	self.pet_info = {}
	self:ListenEvent("Click",BindTool.Bind(self.OnItemClick, self))
	self.icon = self:FindVariable("Icon")
	self.name = self:FindVariable("Name")
	self.showRedPoint = self:FindVariable("ShowRedPoint")
	self.show_hl = self:FindVariable("ShowHL")
	self.is_mine = true -- 是否是自己的
	self.index = nil
end

function PetForgeItem:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function PetForgeItem:SetPetInfo(pet_info, index, is_mine)
	self.pet_info = pet_info
	self.is_mine = is_mine
	self.index = index
	self:OnFlush()
end

function PetForgeItem:OnFlush()
	if nil == self.pet_info then
		self.name:SetValue("")
		self.icon:SetAsset("", "")
		return
	end
	self.name:SetValue(PetData.Instance:GetPetQualityName(self.pet_info))
	local res_id = self.pet_info.id
	local bundle, asset = ResPath.GetGoddessIcon(res_id)
	self.icon:SetAsset(bundle, asset)
	if PetForgeView.Instance:GetCurrentPetInfo() == self.pet_info then
		self.root_node.toggle.isOn = true
	end
end

function PetForgeItem:OnItemClick()
	if nil == self.pet_info then
		self.show_hl:SetValue(false)
		self:SetToggle(false)
		return
	end
	local pet_forge_view = PetForgeView.Instance
	if pet_forge_view:GetCurrentPetInfo() == self.pet_info then
		return
	end

	pet_forge_view:SetShowFreeBtn(self.is_mine)
	pet_forge_view:SetCurrentPetInfo(self.pet_info)
	pet_forge_view:OnFlush()
	pet_forge_view:InitAttPanle()
	pet_forge_view:ClearSelectList()
	pet_forge_view:FlushAllHl()
end

function PetForgeItem:SetToggle(is_on)
	self.root_node.toggle.isOn = is_on
end

function PetForgeItem:FlushHl()
	self.show_hl:SetValue(self.root_node.toggle.isOn)
end
