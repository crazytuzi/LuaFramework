--宠物喂养
LittlePetFeedView = LittlePetFeedView or BaseClass(BaseRender)

function LittlePetFeedView:__init()

	self.gongji = self:FindVariable("GongJi")
	self.fangyu = self:FindVariable("FangYu")
	self.maxhp = self:FindVariable("ShengMing")
	self.jichushuxing = self:FindVariable("JiChuShuXing")
	self.show_tip = self:FindVariable("Show_Tip")
	self.pet_name = self:FindVariable("PetName")
	self.pet_level = self:FindVariable("PetLevel")
	self.fight_power = self:FindVariable("Power")
	self.is_show_name = self:FindVariable("IsShowName")
	self.show_red_ponit = self:FindVariable("ShowRedPoint")
	self.is_can_feed = self:FindVariable("IsCanFeed")

	self.select_index = 1

	self.stuff_num_list = {}
	for i=1,4 do
		self.stuff_num_list[i] = self:FindVariable("Stuff"..i)
	end

	self.stuff_list = {}
	for i = 1, 4 do
		self.stuff_list[i] = ItemCell.New()
		self.stuff_list[i]:SetInstanceParent(self:FindObj("Item" .. i))
	end

	self.pet_cell_list = {}
    self.list_view = self:FindObj("ListView")
    local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetPetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshPetCell, self)

	self.pet_display = self:FindObj("Display")
	self.pet_model = RoleModel.New("little_pet_feed_panel")
	self.pet_model:SetDisplay(self.pet_display.ui3d_display)

	self:ListenEvent("ClickFeed", BindTool.Bind(self.ClickFeed, self))
	self:ListenEvent("ClickHelp", BindTool.Bind(self.ClickHelp, self))


end

function LittlePetFeedView:__delete()
	self.gongji = nil
	self.fangyu = nil
	self.maxhp = nil
	self.jichushuxing = nil
	self.show_tip = nil
	self.pet_name = nil
	self.pet_level = nil
	self.fight_power = nil
	self.is_show_name = nil
	self.pet_cell_list = {}

	if self.pet_model ~= nil then
		self.pet_model:DeleteMe()
		self.pet_model = nil
	end

	for k, v in pairs(self.pet_cell_list) do
		v:DeleteMe()
	end
	self.pet_cell_list = {}

	for k,v in pairs(self.stuff_list) do
		v:DeleteMe()
	end
	self.stuff_list = {}
end

function LittlePetFeedView:OpenCallBack()
	self.select_index = 1
	self.model_res_id = 0
	self:GetEquipLittlePetDataList()
	self.list_view.scroller:ReloadData(0)
	self:FlushModle()
	self:OnFlush()
end

function LittlePetFeedView:CloseCallBack()
	if self.ani_quest_time then
		GlobalTimerQuest:CancelQuest(self.ani_quest_time)
		self.ani_quest_time = nil
	end
end

--刷新宠物信息
function LittlePetFeedView:GetEquipLittlePetDataList()
	self.pet_data_list = self:GetSortEquipDataList()
end

--左边宠物列表
function LittlePetFeedView:GetPetNumberOfCells()
	local count = #self.pet_data_list
	if count == 0 then
		self.show_tip:SetValue(true)
		self.is_show_name:SetValue(false)
	else
		self.show_tip:SetValue(false)
		self.is_show_name:SetValue(true)
	end
	return count
end

function LittlePetFeedView:RefreshPetCell(cell, data_index)
	data_index = data_index + 1
	local all_equip_list = self:GetSortEquipDataList()
	local pet_cell = self.pet_cell_list[cell]
	if nil == pet_cell then
		pet_cell = LittlePetFeedCell.New(cell.gameObject)
		pet_cell:SetToggleGroup(self.list_view.toggle_group)
		pet_cell:SetClickCallBack(BindTool.Bind(self.OnClickCellCallBack, self))
		self.pet_cell_list[cell] = pet_cell
	end
	local data = all_equip_list[data_index]
	pet_cell:SetIndex(data_index)
	pet_cell:SetData(data)
	pet_cell:SetHighLight(data_index == self.select_index)
end

function LittlePetFeedView:GetSortEquipDataList()
	self.equip_pet_cfg_list = LittlePetData.Instance:GetAllEquipPetCfgDataList()
	local all_equip_list = LittlePetData.Instance:GetSortAllPetList()
	local final_all_equip_list = {}
	if all_equip_list == nil or nil == next(all_equip_list) then return final_all_equip_list end
	for i=1, #all_equip_list do
		local data = all_equip_list[i]
		for k,v in pairs(self.equip_pet_cfg_list) do
			if data.index == v.index and data.id == v.id and data.info_type == v.info_type then
				data = v
				table.insert(final_all_equip_list, data)
			end
		end
	end
	return final_all_equip_list
end

function LittlePetFeedView:OnClickCellCallBack(cell)
	if cell == nil then
		return
	end
	local index = cell:GetIndex()
	if self.select_index == index then
		return
	end
	self.select_index = index
	self:FlushAllHightLight()
	self:ChangeRemindPoint()
	self:FlushView()
end

function LittlePetFeedView:FlushAllHightLight()
	for k,v in pairs(self.pet_cell_list) do
		local index = v:GetIndex()
		v:SetHighLight(index == self.select_index)
	end
end


function LittlePetFeedView:OnFlush()
	self:FlushView()
	self.list_view.scroller:RefreshAndReloadActiveCellViews(false)
end

--数据刷新
function LittlePetFeedView:FlushView()
	self:GetEquipLittlePetDataList()
	self:OnFlushStuffList()
	self:FlushLittlePetAttr()
	self:FlushModle(true)
	self:ChangeRemindPoint()
end

--喂养材料
function LittlePetFeedView:OnFlushStuffList()
	local pet_level = self.pet_data_list[self.select_index] and self.pet_data_list[self.select_index].feed_level or 0
	local name = self.pet_data_list[self.select_index] and self.pet_data_list[self.select_index].name or ""
	self.pet_level:SetValue(pet_level)
	self.pet_name:SetValue(name)
	local stuff_data = LittlePetData.Instance:GetGridUpgradeStuffDataListByLevel(pet_level) or {}
	for i=1,4 do
		if stuff_data[i - 1] then
			local data = stuff_data[i - 1]
			self.stuff_list[i]:SetData(data)
			local stuff_num = ItemData.Instance:GetItemNumInBagById(data.item_id)

			local color = stuff_num >= data.need_stuff_num and "#ffe500" or "#ff0000"
			self.stuff_num_list[i]:SetValue("<color="..color..">"..stuff_num.."</color>".." / "..data.need_stuff_num)
		end
	end
end

--模型刷新
function LittlePetFeedView:FlushModle(flag)
	local data = self.pet_data_list[self.select_index]
	if data == nil then
		return
	end

	local model_flush_falg = flag
	if flag and data.res_id == self.model_res_id then return end
	local bundle, asset = ResPath.GetLittlePetModel(data.res_id)
	self.model_res_id = data.res_id
	self.pet_model:SetMainAsset(bundle, asset)
	self.pet_model:SetTrigger("Relax")
	if self.ani_quest_time then
		GlobalTimerQuest:CancelQuest(self.ani_quest_time)
		self.ani_quest_time = nil
	end
	self.ani_quest_time = GlobalTimerQuest:AddRunQuest(function ()
		self.pet_model:SetTrigger("Relax")
	end, 15)
end

function LittlePetFeedView:FlushLittlePetAttr()
	local data = self.pet_data_list[self.select_index]
	local feed_level = self.pet_data_list[self.select_index] and self.pet_data_list[self.select_index].feed_level or 0
	local attr_cfg = LittlePetData.Instance:GetFeedAttrCfgByLevel(feed_level)
	local base_add_power = 0

	local attr_precent = 0
	local base_attr = 0
	if attr_cfg ~= nil then
		base_attr = attr_cfg.base_attr_add_per
	end
	attr_precent = base_attr / 10000
	local show_per = attr_precent * 100
	local attr_list = CommonDataManager.GetAttributteNoUnderline(attr_cfg, true)
	--小宠物基础属性加成
	if data ~= nil then
		base_add_power = LittlePetData.Instance:GetSinglePetFeedBaseAddPower(data.item_id, attr_precent)
	end
	--喂养加成
	local feed_power = CommonDataManager.GetCapability(attr_list)
	self.fight_power:SetValue(feed_power + base_add_power)
	self.gongji:SetValue(attr_list.gongji)
	self.fangyu:SetValue(attr_list.fangyu)
	self.maxhp:SetValue(attr_list.maxhp)
	self.jichushuxing:SetValue(show_per.."%")

	local max_feed_level = LittlePetData.Instance:GetMaxFeedLevel()
	if feed_level >= max_feed_level then
		self.is_can_feed:SetValue(true)
	else
		self.is_can_feed:SetValue(false)
	end
end

--点击喂养
function LittlePetFeedView:ClickFeed()
	local count = self:GetPetNumberOfCells()
	if count > 0 then
		local data_list = self:GetSortEquipDataList()
		local select_index = data_list[self.select_index].index
		local param = data_list[self.select_index] or 0
		LittlePetCtrl.Instance:SendLittlePetREQ(LITTLE_PET_REQ_TYPE.LITTLE_PET_REQ_FEED, select_index, param.info_type or 0)
	else	
		SysMsgCtrl.Instance:ErrorRemind(Language.LittlePet.NoEquipPetTip)
	end
end

function LittlePetFeedView:ClickHelp()
	local tip_id = 277
	TipsCtrl.Instance:ShowHelpTipView(tip_id)
end

--红点
function LittlePetFeedView:ChangeRemindPoint()
	local pet_level = self.pet_data_list[self.select_index] and self.pet_data_list[self.select_index].feed_level or 0
	local is_show = false
	local count = self:GetPetNumberOfCells()
	if count > 0 then
		local feed_flag = LittlePetData.Instance:CanFeedPetByFeedLevel(pet_level) or 0
		if feed_flag == 1 then
			is_show = true
		end
	end
	self.show_red_ponit:SetValue(is_show)
end
--------------------------------------------LittlePetCell---------------------------------------------------------------
LittlePetFeedCell = LittlePetFeedCell or BaseClass(BaseCell)

function LittlePetFeedCell:__init()
	self.name = self:FindVariable("Name")
	self.show_red_ponit = self:FindVariable("ShowRedPoint")
	self.is_lover = self:FindVariable("IsLover")
	self.power = self:FindVariable("Power")

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))
	self.item_cell:ShowHighLight(false)

	self:ListenEvent("Click", BindTool.Bind(self.OnClick, self))
end

function LittlePetFeedCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function LittlePetFeedCell:SetData(data)
	if data == nil then
		return
	end
	--计算战力
	local feed_power = LittlePetData.Instance:GetFeedAttrCfgByIndex(data.index, data.info_type, data.item_id) or 0
	local base_power = LittlePetData.Instance:CalPetBaseFightPower(false, data.item_id) or 0
	local toy_power = LittlePetData.Instance:GetSinglePetToyPower(data.index, data.info_type) or 0
	local power = feed_power + base_power + toy_power

	--是否显示红点
	local feed_level = data.feed_level
	local feed_flag = LittlePetData.Instance:CanFeedPetByFeedLevel(feed_level) 
	if feed_flag == 1 then
		is_show = true
	else
		is_show =false
	end
	self.item_cell:SetData(data)
	self.name:SetValue(data.name)
	self.is_lover:SetValue(data.lover_flag)
	self.power:SetValue(power)
	self.show_red_ponit:SetValue(is_show)
	self:OnFlush()
end

function LittlePetFeedCell:OnFlush()

end

function LittlePetFeedCell:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function LittlePetFeedCell:SetHighLight(enable)
	self.root_node.toggle.isOn = enable
end

function LittlePetFeedCell:OnClick()
	if nil ~= self.click_callback then
		self.click_callback(self)
	end
end
