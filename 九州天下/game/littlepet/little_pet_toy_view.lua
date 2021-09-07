--宠物玩具
LittlePetToyView = LittlePetToyView or BaseClass(BaseRender)

local EQUIP_NUM = 4

function LittlePetToyView:__init()
	self.pet_cell_list = {}
	self.pet_data_list = {}
	self.equip_item_list = {}
	self.equip_pet_cfg_list = {}
	self.equip_item_toggle_list = {}
	self.equip_change_remind_list = {}
	self.equip_up_level_remind_list = {}

	self.equip_power = self:FindVariable("Power")
	self.pet_name = self:FindVariable("PetName")
	self.need_num = self:FindVariable("NeedNum")
	self.has_num = self:FindVariable("HasNum")
	self.next_level_up_num = self:FindVariable("NextUpNum")
	self.gong_ji = self:FindVariable("GongJi")
	self.fang_yu = self:FindVariable("FangYu")
	self.sheng_ming = self:FindVariable("ShengMing")
	self.is_has_equip_pet = self:FindVariable("IsHasEquipPet")
	self.is_active_max_level = self:FindVariable("IsAchieveMaxLevel")
	self.toy_name = self:FindVariable("ToyName")
	self.toy_level = self:FindVariable("ToyLevel")
	self.percent = self:FindVariable("Percent")
	self.is_lover = self:FindVariable("IsLover")
	self.is_toy_equip = self:FindVariable("IsToyEquip")
	self.show_up_level_remind = self:FindVariable("ShowUpLevelRemind")

	self.up_grade_item = ItemCell.New()
	self.up_grade_item:SetInstanceParent(self:FindObj("Item"))
	self.exchange = self:FindObj("Exchange")

	self.model = self:FindObj("Display")
	self.pet_model = RoleModel.New("little_pet_feed_panel")
	self.pet_model:SetDisplay(self.model.ui3d_display)

	self.list_view = self:FindObj("List")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshLittleToyPetCell, self)

	self:ListenEvent("OnClickHelp", BindTool.Bind(self.OnClickHelp, self))
	self:ListenEvent("OnClickUpGrade", BindTool.Bind(self.OnClickUpGrade, self))

	for i=1, EQUIP_NUM do
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self:FindObj("Item" .. i))
		item_cell:SetData(nil)
		-- item_cell:SetDefualtBgState(false)
		table.insert(self.equip_item_list, item_cell)

		self.equip_item_toggle_list[i] = self:FindObj("ItemClick" .. i)
		self.equip_change_remind_list[i] = self:FindVariable("ShowEquipChangeRemind" .. i)
		self.equip_up_level_remind_list[i] = self:FindVariable("ShowUpEquipRemind" .. i)
		self:ListenEvent("OnClickItem" .. i, BindTool.Bind(self.OnClickItem, self, i))
		self:ListenEvent("OnClickChange" .. i, BindTool.Bind(self.OnClickChange, self, i))
	end

end

function LittlePetToyView:__delete()
	if self.pet_model ~= nil then
		self.pet_model:DeleteMe()
		self.pet_model = nil
	end

	if self.up_grade_item ~= nil then
		self.up_grade_item:DeleteMe()
		self.up_grade_item = nil
	end

	for k,v in pairs(self.equip_item_list) do
		v:DeleteMe()
	end
	self.equip_item_list = {}

	for k, v in pairs(self.equip_item_toggle_list) do
		v = nil
	end
	self.equip_item_toggle_list = {}

	for k, v in pairs(self.pet_cell_list) do
		v:DeleteMe()
	end
	self.pet_cell_list = {}

	self.model = nil
	self.exchange = nil
	self.list_view = nil
end

function LittlePetToyView:CloseCallBack()
	self:CancelAniQuest()
end
	
function LittlePetToyView:OpenCallBack()
	self.select_index = 1
	self.cur_toy_index = 1
	self.cur_toy_level = 0
	self.cur_pet_index = -1
	self.cur_pet_info_type = -1
	self.model_res_id = 0
	self.can_up_level_list = {}
	
	self:GetPetDataList()
	self:GetEquipPetDataList()
	self.list_view.scroller:ReloadData(0)
	self:AutoClick()
end

--flag为是否通过刷新方法调用标志
function LittlePetToyView:AutoClick(flag)
	local res_id = 0
	local pet_name = ""
	local num = self:GetNumberOfCells()
	local data = self:SingleItemDataByIndex(self.select_index)

	if flag and num > 0 and self.select_index > 1 and (nil == data or nil == data.pet_index) then
		self.select_index = self.select_index - 1
		data = self:SingleItemDataByIndex(self.select_index)
	end

	if data and data.pet_index then
		self.cur_pet_index = data.pet_index
		self.cur_pet_info_type = data.info_type
		res_id = data.res_id
		pet_name = data.name
	end

	self.cur_pet_info_type = num > 0 and self.cur_pet_info_type or LITTLE_PET_TYPE.MINE_PET
	self.is_has_equip_pet:SetValue(num > 0)
	self.pet_name:SetValue(pet_name)
	self.is_lover:SetValue(self.cur_pet_info_type == LITTLE_PET_TYPE.LOVER_PET)

	self:FlushAllHighLight()
	self:FlushPetModle(res_id, flag)
	self:FlushFourEquipItem()
	self:ShowRemindRelated()
	self:OnClickItem(self.cur_toy_index)
end

--宠物Item数据
function LittlePetToyView:GetPetDataList()
	self.pet_data_list = LittlePetData.Instance:GetSortAllPetList()
end

--相关配置数据
function LittlePetToyView:GetEquipPetDataList()
	self.equip_pet_cfg_list = LittlePetData.Instance:GetAllEquipPetCfgDataList()
end

function LittlePetToyView:GetNumberOfCells()
	local num = self.pet_data_list and #self.pet_data_list or 0
	return num
end

function LittlePetToyView:RefreshLittleToyPetCell(cell, cell_index)
	local pet_cell = self.pet_cell_list[cell]
	if nil == pet_cell then
		pet_cell = LittleToyPetCell.New(cell.gameObject)
		pet_cell.root_node.toggle.group = self.list_view.toggle_group
		pet_cell:SetClickCallBack(BindTool.Bind(self.OnClickCellCallBack, self))
		self.pet_cell_list[cell] = pet_cell
	end

	local data_index = cell_index + 1 
	local data = self:SingleItemDataByIndex(data_index)
	pet_cell:SetData(data)
	pet_cell:SetIndex(data_index)
	pet_cell:SetHighLight(data_index == self.select_index)
end

function LittlePetToyView:SingleItemDataByIndex(data_index)
	local data = {}
	local data_list = self.pet_data_list and self.pet_data_list[data_index]
	if nil == data_list or nil == next(data_list) then return data end

	local id = data_list.id
	local info_type = data_list.info_type
	local attr_list = data_list.attr_list
	local cur_index = data_list.index
	for k,v in pairs(self.equip_pet_cfg_list) do
		if cur_index == v.index and id == v.id and info_type == v.info_type then
			data = v
			data.attr_list = attr_list
			data.pet_index = cur_index
			break
		end
	end

	return data
end

--宠物Item点击回调
function LittlePetToyView:OnClickCellCallBack(cell)
	if nil == cell then return end
	local index = cell:GetIndex()
	local data = cell:GetData()
	if self.select_index == index or nil == data or nil == data.pet_index then return end

	self.cur_pet_index = data.pet_index
	self.cur_pet_info_type = data.info_type
	self.select_index = index

	self:FlushAllHighLight()
	self:FlushCenterByPetIndex(data)
	self:ShowRemindRelated()
	self:OnClickItem(self.cur_toy_index)
end

--刷新高亮
function LittlePetToyView:FlushAllHighLight()
	if nil == self.select_index then return end

	for k,v in pairs(self.pet_cell_list) do
		local index = v:GetIndex()
		v:SetHighLight(index == self.select_index)
	end
end

-- 刷新中间部分
function LittlePetToyView:FlushCenterByPetIndex(data)
	self:FlushFourEquipItem()

	if nil == data or nil == data.pet_index then return end

	local res_id = data.res_id or 0
	local name = data.name or ""
	local info_type = data.info_type or -1

	self:FlushPetModle(res_id)
	self.pet_name:SetValue(name)
	self.is_lover:SetValue(info_type == LITTLE_PET_TYPE.LOVER_PET)
end

--当前装备列表
function LittlePetToyView:GetCurPetToyListByInfo()
	local toy_equip_list = {}
	local pet_index = self.select_index
	local data_list = self.pet_data_list and self.pet_data_list[pet_index]
	if nil == data_list or nil == data_list.equipment_llist then return toy_equip_list end 

	toy_equip_list = data_list.equipment_llist
	return toy_equip_list
end

--刷新四个装备格子
function LittlePetToyView:FlushFourEquipItem()
	local toy_equip_list = self:GetCurPetToyListByInfo()

	for i=1, EQUIP_NUM do
		if self.equip_item_list[i] then
			local data = {}
			local item_id = 0
			local level = 0

			if toy_equip_list and toy_equip_list[i] then
				item_id = toy_equip_list[i].equipment_id or 0
				level = toy_equip_list[i].level or 0
			end
			data.item_id = item_id

			self.equip_item_list[i]:SetData(data)
			-- self.equip_item_list[i]:SetDefualtBgState(false)
			self.equip_item_list[i]:ShowStrengthLable(item_id ~= 0 and level ~= 0)
			self.equip_item_list[i]:SetStrength(level)
		end
	end
end

--刷新模型 flag为通过刷新方法调用时判断是否需要刷新模型
function LittlePetToyView:FlushPetModle(res_id, flag)
	if nil == res_id then return end

	local model_flush_flag = flag or false
	if model_flush_flag and res_id == self.model_res_id then return end

	local bundle, asset = ResPath.GetLittlePetModel(res_id)
	self.pet_model:SetMainAsset(bundle, asset)
	self.model_res_id = res_id

	self:CancelAniQuest()
	if res_id == 0 then return end
	
	self.pet_model:SetTrigger("rest")
	self.ani_quest_time = GlobalTimerQuest:AddRunQuest(function ()
		self.pet_model:SetTrigger("rest")
	end, 15)
end

function LittlePetToyView:CancelAniQuest()
	if self.ani_quest_time then
		GlobalTimerQuest:CancelQuest(self.ani_quest_time)
		self.ani_quest_time = nil
	end
end

--当前是否装备了宠物
function LittlePetToyView:IsEquipPet()
	local is_equip = true
	if #self.pet_data_list == 0 then
		is_equip = false
		TipsCtrl.Instance:ShowSystemMsg(Language.LittlePet.NoEquipPet)
	end

	return is_equip
end

--玩具格子是否装备玩具
function LittlePetToyView:IsEquipPetToy()
	local is_equip_toy = true
	local toy_equip_list = self:GetCurPetToyListByInfo()
	local index = self.cur_toy_index
	if toy_equip_list[index] and toy_equip_list[index].equipment_id and toy_equip_list[index].equipment_id == 0 then
		local str = self.cur_pet_info_type == LITTLE_PET_TYPE.LOVER_PET and Language.LittlePet.LoverNoEquipPetToy or Language.LittlePet.NoEquipPetToy
		TipsCtrl.Instance:ShowSystemMsg(str)
		is_equip_toy = false
	end

	return is_equip_toy
end

--玩具装备更换
function LittlePetToyView:OnClickChange(index)
	if not self:IsEquipPet() or self.cur_pet_index == -1 then return end

	local data = {}
	data.pet_index = self.cur_pet_index
	data.toy_index = index
	LittlePetCtrl.Instance:ShowToyBagView(data)
end

--玩具装备升级
function LittlePetToyView:OnClickUpGrade()
	if not self:IsEquipPet() then return end
	if not self:IsEquipPetToy() then return end
	
	local cfg = LittlePetData.Instance:GetSingleEquipToyCfgByIndexAndLevel(self.cur_toy_index - 1, self.cur_toy_level + 1)
	if nil == next(cfg) then return end

	local need_num = cfg.stuff_num
	local stuff_item_id = cfg.stuff_id
	local has_num = ItemData.Instance:GetItemNumInBagById(stuff_item_id)
	local auto_buy = LittlePetData.Instance:GetToyUpLevelAutoBuyFlag()
	if has_num < need_num and not auto_buy then
		local func = function(item_id, item_num, is_bind, is_use, is_buy_quick)
			MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
			if is_buy_quick then
				LittlePetData.Instance:SetToyUpLevelAutoBuyFlag(is_buy_quick)
			end
		end
		TipsCtrl.Instance:ShowCommonBuyView(func, stuff_item_id, nofunc, 1)
		return
	end

	local is_lover = self.is_lover:GetBoolean()
	local opera_type = not is_lover and LITTLE_PET_REQ_TYPE.LITTLE_PET_REQ_EQUIPMENT_UPLEVEL_SELF or LITTLE_PET_REQ_TYPE.LITTLE_PET_REQ_EQUIPMENT_UPLEVEL_LOVER
	local param1 = self.cur_pet_index
	local param2 = self.cur_toy_index - 1
	local param3 = auto_buy

	LittlePetCtrl.Instance:SendLittlePetREQ(opera_type, param1, param2, param3)
end

--属性加成显示
function LittlePetToyView:EquipPetAttrShow(pet_cfg)
	local attr_list = LittlePetData.Instance:GetSinglePetToyPartAttr(pet_cfg)
	self.gong_ji:SetValue(attr_list.gong_ji or 0)
	self.fang_yu:SetValue(attr_list.fang_yu or 0)
	self.sheng_ming:SetValue(attr_list.max_hp or 0)
	self.percent:SetValue(attr_list.per or 0)
end

--右侧属性加成更新
function LittlePetToyView:FlushLeftDataByToyIndex(toy_index)
	self.exchange:SetActive(false)
	local toy_equip_list = self:GetCurPetToyListByInfo()
	self.cur_toy_index = toy_index
	self.cur_toy_level = toy_equip_list[toy_index] and toy_equip_list[toy_index].level or 0

	local cfg = LittlePetData.Instance:GetSingleEquipToyCfgByIndexAndLevel(self.cur_toy_index - 1, self.cur_toy_level + 1)
	self.exchange:SetActive(true)
	if nil == next(cfg) then return end

	local need_num = cfg.stuff_num
	local stuff_item_id = cfg.stuff_id
	local equipment_id = toy_equip_list[toy_index] and toy_equip_list[toy_index].equipment_id or 0
	local has_num = ItemData.Instance:GetItemNumInBagById(stuff_item_id)
	local has_num_color = has_num >= need_num and TEXT_COLOR.GREEN or TEXT_COLOR.RED
	local has_num_str = ToColorStr(has_num, has_num_color)
	local max_level = LittlePetData.Instance:GetToySinglePartMaxLevelByIndex(self.cur_toy_index)
	local is_max_leve = max_level ~= 0 and self.cur_toy_level >= max_level 
	
	self.need_num:SetValue(need_num)
	self.has_num:SetValue(has_num_str)
	self.is_active_max_level:SetValue(is_max_leve)
	self:EquipPetAttrShow(cfg)

	local cur_power = LittlePetData.Instance:GetSinglePetToyPartPower(self.cur_pet_index, self.cur_pet_info_type, toy_index)
	local next_power = LittlePetData.Instance:GetSinglePetToyPartPower(self.cur_pet_index, self.cur_pet_info_type, toy_index, true)
	local next_up = next_power - cur_power
	self.equip_power:SetValue(cur_power)
	self.next_level_up_num:SetValue(next_up)

	local item_cfg = ItemData.Instance:GetItemConfig(equipment_id)
	local toy_name = item_cfg and item_cfg.name or ""
	local toy_level = self.cur_toy_level
	self.is_toy_equip:SetValue(equipment_id ~= 0)
	self.toy_level:SetValue(self.cur_toy_level)
	self.toy_name:SetValue(toy_name)

	local data = {}
	data.item_id = stuff_item_id
	self.up_grade_item:SetData(data)
end

--玩具装备格子点击事件
function LittlePetToyView:OnClickItem(index)
	self:FlushLeftDataByToyIndex(index)
	self:ShowLevelRemind()
	if self.equip_item_toggle_list[index] then
		self.equip_item_toggle_list[index].toggle.isOn = true
	end
end

--红点相关
function LittlePetToyView:ShowRemindRelated()
	local is_remind, remind_list = LittlePetData.Instance:SinglePetToyRemind(self.cur_pet_index, self.cur_pet_info_type)
	local can_equip_part_list = remind_list.can_equip_part_list
	local can_replace_list = remind_list.can_replace_list
	self.can_up_level_list = remind_list.can_up_level_list
	--“替换”按钮红点
	for k,v in pairs(self.equip_change_remind_list) do
		local show_red_ponit = is_remind
		if show_red_ponit then
			if (nil == can_equip_part_list or nil == can_equip_part_list[k]) and (nil == can_replace_list or nil == can_replace_list[k]) then
				show_red_ponit = false
			end
		end
		v:SetValue(show_red_ponit)
	end
	--玩具装备格子红点
	for k,v in pairs(self.equip_up_level_remind_list) do
		local show_red_ponit = is_remind
		if show_red_ponit then
			if nil == self.can_up_level_list or nil == self.can_up_level_list[k] then
				show_red_ponit = false
			end
		end
		v:SetValue(show_red_ponit)
	end
end

--升级按钮红点
function LittlePetToyView:ShowLevelRemind()
	local state = false
	if self.can_up_level_list and self.can_up_level_list[self.cur_toy_index] then
		state = true
	end
	self.show_up_level_remind:SetValue(state)
end

function LittlePetToyView:OnFlush()
	self:GetPetDataList()
	self:GetEquipPetDataList()
	local num = self:GetNumberOfCells()
	if num <= 0 then
		self.list_view.scroller:ReloadData(0)
	else
		self.list_view.scroller:RefreshAndReloadActiveCellViews(false)
	end

	self:AutoClick(true)
end

function LittlePetToyView:OnClickHelp()
	local tip_id = 266
	TipsCtrl.Instance:ShowHelpTipView(tip_id)
end

------------------------------------------------------------------------------------------
LittleToyPetCell = LittleToyPetCell or BaseClass(BaseCell)

function LittleToyPetCell:__init()
	self.name = self:FindVariable("Name")
	self.show_red_ponit = self:FindVariable("ShowRedPoint")
	self.is_lover = self:FindVariable("IsLover")
	self.power = self:FindVariable("Power")

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))
	self.item_cell:ShowHighLight(false)

	self:ListenEvent("Click", BindTool.Bind(self.OnClick, self))
end

function LittleToyPetCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function LittleToyPetCell:SetData(data)
	self.data = data
	self:OnFlush()
end

function LittleToyPetCell:SetHighLight(enable)
	self.root_node.toggle.isOn = enable
end

function LittleToyPetCell:OnClick()
	if nil ~= self.click_callback then
		self.click_callback(self)
	end
end

function LittleToyPetCell:OnFlush()
	if nil == self.data or nil == self.data.index then return end

	local pet_index = self.data.index
	local pet_info_type = self.data.info_type
	local item_id = self.data.item_id or 0
	local is_lover = pet_info_type == LITTLE_PET_TYPE.LOVER_PET
	local base_power = LittlePetData.Instance:CalPetBaseFightPower(false, self.data.item_id)
	local feed_power = LittlePetData.Instance:GetFeedAttrCfgByIndex(pet_index, pet_info_type, self.data.item_id)
	local toy_power = LittlePetData.Instance:GetSinglePetToyPower(pet_index, pet_info_type)
	local power = base_power + toy_power + feed_power
	local state = LittlePetData.Instance:SinglePetToyRemind(pet_index, pet_info_type)

	self.power:SetValue(power)
	self.name:SetValue(self.data.name)
	self.is_lover:SetValue(is_lover)
	self.show_red_ponit:SetValue(state)

	local data = {}
	data.item_id = self.data.item_id or 0
	self.item_cell:SetData(data)
end