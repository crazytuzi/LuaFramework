MilitaryHallView = MilitaryHallView or BaseClass(BaseView)

local milit_aryhall_list = {
	[1] = {{"camp_team", ViewName.CampTeamView}, {"dimai", ViewName.DiMai, TabIndex.dimai_renmai}, {"royal_tomb", ViewName.RoyalTombView},},
	[2] = {{"kf_battle", ViewName.KuaFuBattle}, {"span_battle", ViewName.SpanBattleView}, {"kf_1v1", ViewName.KuaFu1v1},},
}

function MilitaryHallView:__init()
	self.ui_config = {"uis/views/militaryhallactivityview","MilitaryHallActivityView"}
	self:SetMaskBg()
	self.cur_index = 1
	self.cell_list = {}
	self.hall_list = {}
end

function MilitaryHallView:LoadCallBack()
	self:ListenEvent("Close", BindTool.Bind(self.CloseView, self))
	self.scroller = self:FindObj("Scroller")
	self.title_name = self:FindVariable("TitleName")

	local list_view_delegate = self.scroller.list_simple_delegate
	list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
end

function MilitaryHallView:ShowIndexCallBack(index)
	self.cur_index = index - 1000
	self.hall_list = self:GetMilitaryHallList()
end

function MilitaryHallView:GetMilitaryHallList()
	local hall_list = {}
	for i,v in ipairs(milit_aryhall_list[self.cur_index]) do
		if v[1] and OpenFunData.Instance:CheckIsHide(v[1]) then
			table.insert(hall_list, v)
		end
	end
	return hall_list
end

function MilitaryHallView:ReleaseCallBack()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	self.hall_list = {}
	self.scroller = nil
	self.title_name = nil
end

function MilitaryHallView:CloseView()
	self:Close()
end

function MilitaryHallView:GetNumberOfCells()
	return #self.hall_list
end

function MilitaryHallView:RefreshView(cell, data_index)
	data_index = data_index + 1
	local group_cell = self.cell_list[cell]
	if group_cell == nil then
		group_cell = MilitaryHallCell.New(cell.gameObject)
		self.cell_list[cell] = group_cell
	end
	local data = self.hall_list[data_index]
	if data then
		group_cell:SetActive(true)
		group_cell:SetData(data)
	else
		group_cell:SetActive(false)
	end
end

function MilitaryHallView:OpenCallBack()
	self:Flush()
end

function MilitaryHallView:OnFlush()
	if self.scroller and self.scroller.scroller then
		self.scroller.scroller:ReloadData(0)
	end
	self.title_name:SetValue(Language.MilitaryHall["title_name_" .. self.cur_index])
end

MilitaryHallCell = MilitaryHallCell or BaseClass(BaseCell)

function MilitaryHallCell:__init()
	self.icon = self:FindVariable("Icon")
	self.activity_name = self:FindVariable("ActivityName")
	self:ListenEvent("OnClick", BindTool.Bind(self.OnClick, self))
end

function MilitaryHallCell:__delete()
end

function MilitaryHallCell:OnClick()
	if self.data[2] then
		if nil ~= self.data[3] then
			ViewManager.Instance:Open(self.data[2], self.data[3])
		else
			ViewManager.Instance:Open(self.data[2])
		end
	end
end

function MilitaryHallCell:OnFlush()
	if not self.data then return end
	if self.data[1] then
		self.activity_name:SetValue(Language.MilitaryHall[self.data[1]])
		local bundle, asset = ResPath.GetActivityBigIcon(self.data[1])
		self.icon:SetAsset(bundle, asset)
	end
end 