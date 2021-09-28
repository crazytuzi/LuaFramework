--衣柜套装
ClothespressSuitView = ClothespressSuitView or BaseClass(BaseRender)

local MODLE_STATE = {
	NONE = 0,
	MOUNT_STATE = 1,
	FIGHT_MOUNT_STATE = 2,
	STAND_STATE = 3,
}

local DISPLAY_NAME = {
	[0] = "clothespress_suit_role_stand_panel",
	[1] = "clothespress_suit_role_mount_panel",
	[2] = "clothespress_suit_role_fight_mount_panel",
	[3] = "clothespress_suit_role_stand_panel",
}

function ClothespressSuitView:__init()
	self.suit_cell_list = {}
	self.suit_part_cell_list = {}
	self.suit_data_cfg_list = {}
	self.single_suit_all_part_cfg = {}
	self.single_suit_all_part_info = {}
	
	self.single_suit_desc = self:FindVariable("Single_Suit_Desc")
	
	self:InitModle()
	self:InitList()
	
	self:ListenEvent("ClickAttr", BindTool.Bind(self.ClickAttr, self))
	self:ListenEvent("ClickChangeRideState", BindTool.Bind(self.ClickChangeRideState, self))
end

function ClothespressSuitView:__delete()
	if self.role_model ~= nil then
		self.role_model:DeleteMe()
		self.role_model = nil
	end

	for k,v in pairs(self.suit_cell_list) do
		v:DeleteMe()
	end
	self.suit_cell_list = {}

	for k,v in pairs(self.suit_part_cell_list) do
		v:DeleteMe()
	end
	self.suit_part_cell_list = {}

	self.role_display = nil
	self.suit_list = nil
	self.suit_part_list = nil
	self.single_suit_desc = nil 

	self.suit_data_cfg_list = {}

end

function ClothespressSuitView:CloseCallBack()
	if self.switch_state and self.role_model and self.switch_state == MODLE_STATE.MOUNT_STATE then
		self.role_model:RemoveMount()
	end
end
	
function ClothespressSuitView:OpenCallBack()
	self.modle_info_list = {}
	self.suit_data_cfg_list = {}
	self.single_suit_all_part_cfg = {}
	self.single_suit_all_part_info = {}

	self.select_index = 1
	self:GetAllSuitDataList()
	self.suit_list.scroller:ReloadData(0)
	self:FlushRightContent()
end

--初始化模型
function ClothespressSuitView:InitModle()
	self.role_display = self:FindObj("RoleDisplay")
	self.role_model = RoleModel.New()
	self.role_model:SetDisplay(self.role_display.ui3d_display)
end

--初始化list
function ClothespressSuitView:InitList()
	self.suit_list = self:FindObj("SuitList")
	local suit_list_delegate = self.suit_list.list_simple_delegate
	suit_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetSuitNumberOfCells, self)
	suit_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshSuitCell, self)

	self.suit_part_list = self:FindObj("SuitPartList")
	local suit_part_list_delegate = self.suit_part_list.list_simple_delegate
	suit_part_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetSuitPartNumberOfCells, self)
	suit_part_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshSuitPartCell, self)
end

function ClothespressSuitView:GetSuitNumberOfCells()
	return #self.suit_data_cfg_list
end

--所有套装配置信息
function ClothespressSuitView:GetAllSuitDataList()
	self.suit_data_cfg_list = ClothespressData.Instance:GetAllSuitCfg() or {}
end

--单个套装的部位配置信息
function ClothespressSuitView:GetSingleSuitAllPartCfg()
	self.single_suit_all_part_cfg = ClothespressData.Instance:GetSingleSuitPartCfgBySuitIndex(self.select_index) or {}
end

--单个套装的激活信息
function ClothespressSuitView:GetSingleSuitAllPartActiveInfo()
	self.single_suit_all_part_info = ClothespressData.Instance:GetSingleSuitPartInfoBySuitIndex(self.select_index) or {}
end

function ClothespressSuitView:RefreshSuitCell(cell, cell_index)
	local suit_cell = self.suit_cell_list[cell]
	if nil == suit_cell then
		suit_cell = ClothespressSuitCell.New(cell.gameObject)
		suit_cell.root_node.toggle.group = self.suit_list.toggle_group
		suit_cell:SetClickCallBack(BindTool.Bind(self.OnClickCellCallBack, self))
		self.suit_cell_list[cell] = suit_cell
	end

	local data_index = cell_index + 1
	local data = self.suit_data_cfg_list[data_index]
	suit_cell:SetData(data)
	suit_cell:SetIndex(data_index)
	suit_cell:SetHighLight(data_index == self.select_index)
end

--套装Item点击回调
function ClothespressSuitView:OnClickCellCallBack(cell)
	if nil == cell then return end
	local index = cell:GetIndex()
	if self.select_index == index then return end
	self.select_index = index

	self:FlushAllHighLight()
	self:FlushRightContent()
end

--刷新高亮
function ClothespressSuitView:FlushAllHighLight()
	if nil == self.select_index then return end

	for k,v in pairs(self.suit_cell_list) do
		local index = v:GetIndex()
		v:SetHighLight(index == self.select_index)
	end
end

--刷新右侧
function ClothespressSuitView:FlushRightContent()
	self.switch_state = MODLE_STATE.NONE
	self:GetModleDataList()
	self:FlushSuitPartList()
	self:FlushSuitDesc()
end

--刷新套装描述
function ClothespressSuitView:FlushSuitDesc()
	local str = self.suit_data_cfg_list[self.select_index] and self.suit_data_cfg_list[self.select_index].suit_effect or ""
	self.single_suit_desc:SetValue(str)
end

--刷新套装部位显示
function ClothespressSuitView:FlushSuitPartList()
	self:GetSingleSuitAllPartCfg()
	self:GetSingleSuitAllPartActiveInfo()
	self.suit_part_list.scroller:ReloadData(0)
end

--单个套装的模型信息
function ClothespressSuitView:GetModleDataList()
	self.modle_info_list = ClothespressData.Instance:GetCurSuitNeedShowModelInfo(self.select_index)
	self:FlushModle()
end

--刷新模型
function ClothespressSuitView:FlushModle()
	local role_info = self.modle_info_list.role_info
	local sprit_res_id = self.modle_info_list.sprit_res_id
	local goddess_res_id = self.modle_info_list.goddess_res_id
	local is_flush = self:IsFlushModle(self.modle_info_list.mount_res_id, self.modle_info_list.fight_mount_res_id)
	if not is_flush then return end

	local mount_res_id = self.switch_state == MODLE_STATE.MOUNT_STATE and self.modle_info_list.mount_res_id or nil
	local fight_mount_id = self.switch_state == MODLE_STATE.FIGHT_MOUNT_STATE and self.modle_info_list.fight_mount_res_id or nil
	
	local sprite_info = nil
	local goddess_info = nil
	local display_name = DISPLAY_NAME[self.switch_state]
	local show_footprint = false

	if self.switch_state == MODLE_STATE.STAND_STATE then
		local sprite_info_list, goddess_info_list = self:GetSpritAndGoddessInfo(sprit_res_id, goddess_res_id)
		sprite_info = sprit_res_id ~= 0 and sprite_info_list or nil
		goddess_info = goddess_res_id ~= 0 and goddess_info_list or nil
		if role_info.appearance.footprint_used_imageid then
			show_footprint = true
		end
	end

	self.role_model:ResetRotation()
	self.role_model:SetPanelName(display_name)
	self.role_model:SetClosetInfo(role_info, sprite_info, goddess_info, mount_res_id, fight_mount_id, show_footprint)

	local state = show_footprint and 1 or 0
	local rotation = show_footprint and -15 or 0
	self.role_model:SetInteger(ANIMATOR_PARAM.STATUS, state)
	self.role_model.display:SetRotation(Vector3(0, rotation, 0))
end

--仙宠和伙伴模型信息
function ClothespressSuitView:GetSpritAndGoddessInfo(sprit_res_id, goddess_res_id)
	local sprite_info = {}
	local goddess_info = {}
	local sprite_offset = 1
	local goddess_offset = 1

	if sprit_res_id ~= 0 and goddess_res_id ~= 0 then
		sprite_offset = 1.5
		goddess_offset = -1.5
	elseif sprit_res_id == 0 then
		goddess_offset = -1.5
	else
		sprite_offset = -1.5
	end

	sprite_info.res_id = sprit_res_id
	sprite_info.offset = sprite_offset 
	goddess_info.res_id = goddess_res_id
	goddess_info.offset = goddess_offset

	return sprite_info, goddess_info
end

--是否刷新模型
function ClothespressSuitView:IsFlushModle(mount_res_id, fight_mount_res_id)
	local is_flush = true

	if mount_res_id == 0 and fight_mount_res_id == 0 then
		is_flush = self.switch_state == MODLE_STATE.NONE
		self.switch_state = MODLE_STATE.STAND_STATE
	elseif mount_res_id == 0 and fight_mount_res_id ~= 0 then
		self.switch_state = self.switch_state == MODLE_STATE.FIGHT_MOUNT_STATE and MODLE_STATE.STAND_STATE or MODLE_STATE.FIGHT_MOUNT_STATE
	elseif mount_res_id ~= 0 and fight_mount_res_id == 0 then
		self.switch_state = self.switch_state == MODLE_STATE.MOUNT_STATE and MODLE_STATE.STAND_STATE or MODLE_STATE.MOUNT_STATE
	else
		self.switch_state = self.switch_state == MODLE_STATE.STAND_STATE and MODLE_STATE.MOUNT_STATE or (self.switch_state + 1)
	end

	if not is_flush then
		TipsCtrl.Instance:ShowSystemMsg(Language.Clothespress.NotHaveMount)
	end

	return is_flush
end

function ClothespressSuitView:GetSuitPartNumberOfCells()
	return #self.single_suit_all_part_cfg
end

function ClothespressSuitView:RefreshSuitPartCell(cell, cell_index)
	local suit_part_cell = self.suit_part_cell_list[cell]
	if nil == suit_part_cell then
		suit_part_cell = ClothespressSuitPartCell.New(cell.gameObject)
		self.suit_part_cell_list[cell] = suit_part_cell
	end

	local data_index = cell_index + 1 
	local data = self:GetSingleSuitPartData(data_index)
	suit_part_cell:SetData(data)
	suit_part_cell:SetIndex(data_index)
end

--单个套装部位数据
function ClothespressSuitView:GetSingleSuitPartData(data_index)
	local data = {} 
	local list = self.single_suit_all_part_cfg and self.single_suit_all_part_cfg[data_index]
	local active_flag = self.single_suit_all_part_info and self.single_suit_all_part_info[data_index]
	data.list = list or {}
	data.active_flag = active_flag or 0

	return data
end

--套装属性
function ClothespressSuitView:ClickAttr()
	ClothespressCtrl.Instance:ShowSuitAttrTipView(self.select_index)
end

-- 更换模型状态
function ClothespressSuitView:ClickChangeRideState()
	self:FlushModle()
end

function ClothespressSuitView:OnFlush()
	self:FlushSuitPartList()
end

-----------------------------------套装Item----------------------------------
ClothespressSuitCell = ClothespressSuitCell or BaseClass(BaseCell)

function ClothespressSuitCell:__init()
	self.name = self:FindVariable("Name")
	self.show_red_ponit = self:FindVariable("ShowRedPoint")

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))
	self.item_cell:ShowHighLight(false)

	self:ListenEvent("Click", BindTool.Bind(self.OnClick, self))
end

function ClothespressSuitCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function ClothespressSuitCell:SetData(data)
	self.data = data
	self:OnFlush()
end

function ClothespressSuitCell:SetHighLight(enable)
	self.root_node.toggle.isOn = enable
end

function ClothespressSuitCell:OnClick()
	if nil ~= self.click_callback then
		self.click_callback(self)
	end
end

function ClothespressSuitCell:OnFlush()
	if nil == self.data or nil == self.data.suit_index then return end

	local name = self.data.suit_name or ""
	self.name:SetValue(name)

	local data = {}
	data.item_id = self.data.suit_image_id or 0
	self.item_cell:SetData(data)
end
--------------------------------套装cell结束-------------------------------------

---------------------------------套装部位cell------------------------------------
ClothespressSuitPartCell = ClothespressSuitPartCell or BaseClass(BaseCell)

function ClothespressSuitPartCell:__init()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))
	self.item_cell:ShowQuality(false)
	self.item_cell:SetIconGrayScale(true)
	self.item_cell:SetDefualtBgState(false)
end

function ClothespressSuitPartCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function ClothespressSuitPartCell:SetData(data)
	self.data = data
	self:OnFlush()
end

function ClothespressSuitPartCell:OnFlush()
	if nil == next(self.data.list)then return end
	local data_list = self.data.list
	local active_flag = self.data.active_flag or false

	local data = {}
	data.item_id = data_list.img_item_id or 0
	data.is_bind = 0
	
	self.item_cell:SetData(data)
	self.item_cell:ShowQuality(active_flag ~= 0)
	self.item_cell:SetIconGrayScale(active_flag == 0)
	self.item_cell:SetDefualtBgState(false)
end

--------------------------------套装部位cell结束----------------------------------
