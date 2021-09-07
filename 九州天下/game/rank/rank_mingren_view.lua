RankMingRenView = RankMingRenView or BaseClass(BaseRender)

function RankMingRenView:__init(instance)
	self.cell_list = {}
	self.toggle_list = {}
	self.toggle_list[1] = self:FindObj("toggle_" .. 1)
	self:ListenEvent("toggle_" .. 1 ,BindTool.Bind2(self.OnToggleClick, self, 1))
	self.list_view = self:FindObj("list_view")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function RankMingRenView:__delete()
	for _, v in pairs(self.cell_list) do
		v:DeleteMe()
		v = nil
	end
	self.cell_list = {}
end

function RankMingRenView:GetNumberOfCells()
	return #RankData.Instance:GetMingrenListData()
end

function RankMingRenView:OnToggleClick()
	if is_click then
		self.list_view.scroller:ReloadData(0)
	end
end

function RankMingRenView:RefreshCell(cell, cell_index)
	local the_cell = self.cell_list[cell]
	if the_cell == nil then
		the_cell = RankMingRenItem.New(cell.gameObject, self)
		self.cell_list[cell] = the_cell
	end
	local data = RankData.Instance:GetIdByIndex(cell_index)
	cell_index = cell_index + 1
	the_cell:SetIndex(cell_index)
	the_cell:SetData(data)
end

-----------------------------------------------------
RankMingRenItem = RankMingRenItem or BaseClass(BaseCell)

function RankMingRenItem:__init(instance)
	self.title = self:FindVariable("title")
	self.name = self:FindVariable("name")
	self.desc = self:FindVariable("desc")
	self.show_shadow = self:FindVariable("show_shadow")
	self.show_display = self:FindVariable("show_display")
	self.display = self:FindObj("Display")
	self.model_view = RoleModel.New("ming_ren_view",400)
	self.model_view:SetDisplay(self.display.ui3d_display)
end

function RankMingRenItem:__delete()
	if self.model_view then
		self.model_view:DeleteMe()
		self.model_view = nil
	end

	self:UnBindQuery()
end

function RankMingRenItem:RoleInfoReturn(role_id, info)
	if self.index == 0 then
		return
	end
	
	local minren_id = RankData.Instance:GetIdByIndex(self.index)
	if minren_id == role_id then
		self:UnBindQuery()
		self:FlushItemCell(info)
	end
end

function RankMingRenItem:UnBindQuery()
	if self.role_event_system then
		GlobalEventSystem:UnBind(self.role_event_system)
		self.role_event_system = nil
	end
end

function RankMingRenItem:OnFlush()
	local minren_id = RankData.Instance:GetIdByIndex(self.index)
	if not minren_id or minren_id == 0 then
		self:FlushItemCell()
	else
		self:UnBindQuery()
		self.role_event_system = GlobalEventSystem:Bind(OtherEventType.RoleInfo, BindTool.Bind(self.RoleInfoReturn, self))
		CheckCtrl.Instance:SendQueryRoleInfoReq(minren_id)
	end
end

function RankMingRenItem:FlushItemCell(info)
	if not self.display or IsNil(self.display.gameObject) then
		return
	end
	local mingren_cfg = ConfigManager.Instance:GetAutoConfig("rankconfig_auto").mingrentang_coordinates
	local title = mingren_cfg[self.index].title_id
	local bundle, asset = ResPath.GetTitleIcon(title)
	self.title:SetAsset(bundle, asset)
	self.desc:SetValue(mingren_cfg[self.index].desc)
	self.show_display:SetValue(info ~= nil)
	self.show_shadow:SetValue(info == nil)
	if info then
		local name = info.role_name
		self.model_view:SetModelResInfo(info, nil, true, true)
		self.name:SetValue(name)
	else
		self.name:SetValue("")
	end
end