-- 宠物图鉴
LittlePetHandleBookView = LittlePetHandleBookView or BaseClass(BaseView)

local PET_GROUP_ROW = 3
local PET_GROUP_COLUMN = 4

function LittlePetHandleBookView:__init()
	self.ui_config = {"uis/views/littlepetview_prefab","LittlePetHandleBookView"}
end

function LittlePetHandleBookView:__delete()

end

function LittlePetHandleBookView:LoadCallBack()
	self.pet_name = self:FindVariable("PetName")
	self.fight_power = self:FindVariable("Power")
	self.pet_des = self:FindVariable("PetDes")
	self.page_count = self:FindVariable("PageCount")

	self.item_group_list = self:FindObj("ListView")
	local list_simple_delegate = self.item_group_list.list_simple_delegate
	list_simple_delegate.NumberOfCellsDel = BindTool.Bind(self.GetItemGroupNumOfCell, self)
	list_simple_delegate.CellRefreshDel = BindTool.Bind(self.RefreshItemGroupCell, self)
	self.item_display_group = {}

	self.model_display = self:FindObj("Display")
	self.model = RoleModel.New("little_pet_handle_book_panel")
	self.model:SetDisplay(self.model_display.ui3d_display)

	self:ListenEvent("OnClickClose", BindTool.Bind(self.Close, self))
end

function LittlePetHandleBookView:ReleaseCallBack()
	self.pet_name = nil
	self.fight_power = nil
	self.pet_des = nil
	self.page_count = nil

	for k,v in pairs(self.item_display_group) do
		v:DeleteMe()
	end
	self.item_display_group = {}
	self.item_group_list = nil

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
	self.model_display = nil
end

function LittlePetHandleBookView:OpenCallBack()
	-- 计算页数
	local page_grid_num = PET_GROUP_ROW * PET_GROUP_COLUMN
	local total_grid_num = #LittlePetData.Instance:GetLittlePetCfg()
	local total_page_count = math.ceil(total_grid_num / page_grid_num)
	self.item_group_list.list_page_scroll:SetPageCount(total_page_count)
	-- 只有1页的情况下不显示toggle
	total_page_count = total_page_count == 1 and 0 or total_page_count
	self.page_count:SetValue(total_page_count)

	self.cur_index = 1
	local pet_cfg = LittlePetData.Instance:GetLittlePetCfg()[self.cur_index]
	local item_cfg = ItemData.Instance:GetItemConfig(pet_cfg.active_item_id)
	if item_cfg then
		self.pet_name:SetValue(item_cfg.name)
		local power = LittlePetData.Instance:CalPetBaseFightPower(false, pet_cfg.active_item_id)
		self.fight_power:SetValue(power)
	end
 	self:SetModel(self.cur_index)

	self:Flush()
end

function LittlePetHandleBookView:CloseCallBack()
	if self.ani_quest_time then
		GlobalTimerQuest:CancelQuest(self.ani_quest_time)
		self.ani_quest_time = nil
	end
end

function LittlePetHandleBookView:GetItemGroupNumOfCell()
	local page_grid_num = PET_GROUP_ROW * PET_GROUP_COLUMN
	local total_grid_num = #LittlePetData.Instance:GetLittlePetCfg()
	local page_count = total_grid_num - page_grid_num

	page_count = (page_count > 0) and page_count or 0
	local page = 0
	if page_count > 0 then
		page = math.floor(page_count / PET_GROUP_ROW / PET_GROUP_COLUMN) + 1
	end

	return (page_grid_num + page * PET_GROUP_ROW * PET_GROUP_COLUMN) / PET_GROUP_ROW
end

function LittlePetHandleBookView:RefreshItemGroupCell(cell, data_index)
	local group = self.item_display_group[cell]
	if nil == group then
		group = LittlePetHandleBookGroup.New(cell)
		group:SetToggleGroup(self.item_group_list.toggle_group)
		self.item_display_group[cell] = group
	end

	-- 计算索引
	local page = math.floor(data_index / PET_GROUP_COLUMN)
	local column = data_index - page * PET_GROUP_COLUMN
	local grid_count = PET_GROUP_COLUMN * PET_GROUP_ROW
	for i = 1, PET_GROUP_ROW do
		-- 获取竖列索引
		local index = (i - 1) * PET_GROUP_COLUMN  + column + (page * grid_count)

		-- 获取数据信息
		local cfg_data = LittlePetData.Instance:GetLittlePetCfg()[index + 1]
		local data = {}
		if cfg_data then
			data.item_id = cfg_data.active_item_id
			data.is_null = false
		else
			data.is_null = true
		end

		if data.index == nil then
			data.index = index + 1
		end
		if data.index==1 then
			self.temp_cell=group
		end
		group:SetData(i, data)
		group:SetHighLight(i, ((self.cur_index - 1) == index and nil ~= data.item_id))
		group:ListenClick(i, BindTool.Bind(self.HandleItemOnClick, self, data, group, i, index))
	end
end

function LittlePetHandleBookView:OnFlush()

end

function LittlePetHandleBookView:SetModel(index)
	local pet_cfg = LittlePetData.Instance:GetLittlePetCfg()[index]
	if pet_cfg == nil then
		return
	end
	local res_id = pet_cfg.using_img_id or 0
	local bundle, asset = ResPath.GetLittlePetModel(res_id)
	self.model:SetMainAsset(bundle, asset)
	self.pet_des:SetValue(pet_cfg.pet_description)

	self.model:SetTrigger("Relax")
	if self.ani_quest_time then
		GlobalTimerQuest:CancelQuest(self.ani_quest_time)
		self.ani_quest_time = nil
	end
	self.ani_quest_time = GlobalTimerQuest:AddRunQuest(function ()
		self.model:SetTrigger("Relax")
		end, 10)
end

function LittlePetHandleBookView:HandleItemOnClick(data, group, i, index)
	if data == nil or data.item_id == nil then
		return
	end
	if self.cur_index == data.index then
		return
	end
	self.cur_index = data.index
	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	if item_cfg then
		self.pet_name:SetValue(item_cfg.name)
		local power = LittlePetData.Instance:CalPetBaseFightPower(false, data.item_id)
		self.fight_power:SetValue(power)
	end
 	self:SetModel(data.index)
end

---------------------- 小宠物图鉴组 ----------------------
LittlePetHandleBookGroup = LittlePetHandleBookGroup or BaseClass(BaseCell)

function LittlePetHandleBookGroup:__init(instance)
	self.cells = {}
	self.lock_list = {}
	for i = 1, 3 do
		local item = ItemCell.New()
		item:SetInstanceParent(self:FindObj("Item"..i))
		self.cells[i] = item
		self.lock_list[i] = self:FindVariable("Lock"..i)
	end

	self:ListenEvent("OnClickLock", BindTool.Bind(self.OnClickLock, self))
end

function LittlePetHandleBookGroup:__delete()
	for k, v in pairs(self.cells) do
		v:DeleteMe()
	end
	self.cells = {}
end

function LittlePetHandleBookGroup:SetData(i, data)
	if data.is_null then
		self.lock_list[i]:SetValue(true)
	else
		self.lock_list[i]:SetValue(false)
		self.cells[i]:SetData({item_id = data.item_id})
	end
end

function LittlePetHandleBookGroup:ListenClick(i, handler)
	self.cells[i]:ListenClick(handler)
end

function LittlePetHandleBookGroup:SetToggleGroup(toggle_group)
	self.cells[1]:SetToggleGroup(toggle_group)
	self.cells[2]:SetToggleGroup(toggle_group)
	self.cells[3]:SetToggleGroup(toggle_group)
end

function LittlePetHandleBookGroup:SetHighLight(i, enable)
	self.cells[i]:SetHighLight(enable)
end

function LittlePetHandleBookGroup:OnClickLock(i, enable)
	TipsCtrl.Instance:ShowSystemMsg(Language.LittlePet.BookItemLockTips)
end


----------------------------------------------------------------