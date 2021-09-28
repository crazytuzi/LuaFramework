VipPowerView = VipPowerView or BaseClass(BaseRender)

function VipPowerView:__init(instance)
	VipPowerView.Instance = self

	self.icon_cell_list = {}

	self:ListenEvent("BtClick", BindTool.Bind(self.OnBtClick,self))
	self.vip_level_list = {}
	for i=1,8 do
		self.vip_level_list[i] = VipLevelCell.New(self:FindObj("VipLevel"..i))
	end

	self.right_bt = self:FindObj("RightBt")
	self.cur_index = self.current_vip_id
	self.cur_page = 0
	self.is_go_right = true

	self:InitListView()
	self:SetVipLevelData()
end

function VipPowerView:__delete()
	for k, v in pairs(self.icon_cell_list) do
		v:DeleteMe()
	end
	self.icon_cell_list = {}

	for k, v in pairs(self.vip_level_list) do
		v:DeleteMe()
	end
	self.vip_level_list = {}
end

function VipPowerView:SetCurPage(page)
	self.cur_page = page
end

function VipPowerView:GetCurPage()
	return self.cur_page
end

function VipPowerView:SetCurIndex(index)
	self.cur_index = index
end

function VipPowerView:SetVipLevelData()
	for i=1,8 do
		local index = i + self.cur_page*8
		self.vip_level_list[index - self.cur_page*8]:SetData(index)
	end
end

function VipPowerView:GetCurIndex()
	return self.cur_index
end

function VipPowerView:OnBtClick()
	if self.is_go_right then
		self.right_bt.rect.localRotation = Quaternion.Euler(0, 180, 0)
		self.cur_page = 1
	else
		self.right_bt.rect.localRotation = Quaternion.Euler(0, 0, 0)
		self.cur_page = 0
	end
	self.scroller_list_view.scroller:RefreshActiveCellViews()
	self:SetVipLevelData()
	self.is_go_right = not self.is_go_right
end

function VipPowerView:InitListView()
	self.scroller_list_view = self:FindObj("icon_list_view")
	local list_delegate = self.scroller_list_view.list_simple_delegate
	-- 有有多少个cell
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	-- 更新cell
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function VipPowerView:GetNumberOfCells()
	return VipData.Instance:GetVipPowerListIsByIndex(true)
end

function VipPowerView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local icon_cell = self.icon_cell_list[cell]
	if icon_cell == nil then
		icon_cell = VipPowerViewCell.New(cell.gameObject)
		self.icon_cell_list[cell] = icon_cell
	end
	local data = {}
	data = VipData.Instance:GetVipPowerListIsByIndex()[data_index]
	icon_cell:SetIndex(data_index)
	icon_cell:SetData(data)
end

function VipPowerView:FlushInfo()

end

--------------------------------------------------------------------------
-- VipPowerViewCell 	vip权限格子
--------------------------------------------------------------------------
VipPowerViewCell = VipPowerViewCell or BaseClass(BaseCell)

function VipPowerViewCell:__init(instance)
	self:IconInit()
end

function VipPowerViewCell:__delete()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
end

function VipPowerViewCell:IconInit()
	self.is_have_bg = self:FindVariable("is_have_bg")
	self.power_des = self:FindVariable("power_des")

	self.cell_list = {}
	for i=1,8 do
		self.cell_list[i] = VipCell.New(self:FindObj("item"..i))
	end
end

function VipPowerViewCell:SetVipCellData()
	for i=1,8 do
		local page = VipPowerView.Instance:GetCurPage()
		local index = i + page*8
		local horizontal_data = VipData.Instance:GetVipPowerList(index)
		self.cell_list[index - page*8]:SetData(self.data,horizontal_data)
	end
end

function VipPowerViewCell:GetIsSelect()
	return self.root_node.toggle.isOn
end

function VipPowerViewCell:OnFlush()
	if not next(self.data) then return end
	local temp = self.index%2
	if temp == 0 then
		self.is_have_bg:SetValue(false)
	else
		self.is_have_bg:SetValue(true)
	end

	self.power_des:SetValue(self.data.power_desc)

	self:SetVipCellData()
end

--------------------------------------------------------------------------
-- VipCell 	格子
--------------------------------------------------------------------------
VipCell = VipCell or BaseClass(BaseRender)
function VipCell:__init(instance)
	self:IconInit()
end

function VipCell:IconInit()
	self.is_show_images = self:FindVariable("is_show_images")
	self.times = self:FindVariable("times")
	self.is_have = self:FindVariable("is_have")
end

function VipCell:SetData(vertical_data, horizontal_data)
	if not next(horizontal_data) then
		self.is_have:SetValue(true)
		return
	end

	self.is_have:SetValue(false)
	if vertical_data.show_type == 1 then
		if horizontal_data[vertical_data.auth_type] == 0 then
			self.is_show_images:SetValue(false)
			self.times:SetValue("")
		else
			self.is_show_images:SetValue(true)
		end
	elseif vertical_data.show_type == 2 then
		self.is_show_images:SetValue(false)
		self.times:SetValue(string.format("%s次",horizontal_data[vertical_data.auth_type]))
	else
		self.is_show_images:SetValue(false)
		if vertical_data.auth_type == 23 then
			local prcent = horizontal_data[vertical_data.auth_type]/100
			self.times:SetValue(prcent.."%")
		else
			self.times:SetValue(horizontal_data[vertical_data.auth_type].."%")
		end
	end
end

--------------------------------------------------------------------------
-- VipLevelCell 	vip等级格子
--------------------------------------------------------------------------
VipLevelCell = VipLevelCell or BaseClass(BaseRender)
function VipLevelCell:__init(instance)
	self:IconInit()
end

function VipLevelCell:IconInit()
	self.is_max_level = self:FindVariable("is_max_level")
	self.level = self:FindVariable("level")
end

function VipLevelCell:SetData(level)
	if level > 15 then
		self.is_max_level:SetValue(true)
		return
	else
		self.is_max_level:SetValue(false)
	end
	self.level:SetValue(level)
end