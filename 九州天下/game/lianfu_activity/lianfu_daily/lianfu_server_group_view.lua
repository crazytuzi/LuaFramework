LianFuServerGroupView = LianFuServerGroupView or BaseClass(BaseView)

function LianFuServerGroupView:__init()
	self.ui_config = {"uis/views/lianfuactivity/lianfudaily", "ServerGroupTips"}
	self.play_audio = true
	self.is_async_load = false
	self.active_close = false
	self:SetMaskBg(true)

	self.gongzu_cell_list = {}
	self.shizu_cell_list = {}
end

function LianFuServerGroupView:__delete()
end

function LianFuServerGroupView:ReleaseCallBack()
	self.server_group = {}

	for _,v in pairs(self.gongzu_cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.gongzu_cell_list = {}

	for _,v in pairs(self.shizu_cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.shizu_cell_list = {}
end

function LianFuServerGroupView:OpenCallBack()
	LianFuDailyCtrl.Instance:SendCampBattleServerGroupInfoReq()
end

function LianFuServerGroupView:LoadCallBack()
	self.server_group = {}
	for i = 1, 2 do
		self.server_group[i] = self:FindObj("ServerGroup" .. i)
	end

	local list_view_delegate = self.server_group[1].list_simple_delegate
	list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetGongZuNumberOfCells, self)
	list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshGongZuView, self)

	local list_view_delegate = self.server_group[2].list_simple_delegate
	list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetShiZuNumberOfCells, self)
	list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshShiZuView, self)

	self:ListenEvent("OnClickClose", BindTool.Bind(self.Close, self))
	self:ListenEvent("OnClickEnter", BindTool.Bind(self.OnEnter, self))
end

function LianFuServerGroupView:GetGongZuNumberOfCells()
	local data = LianFuDailyData.Instance:GetCampBattleServerGroupInfo()
	if nil ~= next(data) then
		return data[1].count
	end

	return 0
end

function LianFuServerGroupView:RefreshGongZuView(cell, data_index)
	data_index = data_index + 1

	local gongzu_cell = self.gongzu_cell_list[cell]
	if gongzu_cell == nil then
		gongzu_cell = LianFuServerItemCell.New(cell.gameObject)
		self.gongzu_cell_list[cell] = gongzu_cell
	end
	gongzu_cell:SetIndex(data_index)
	local data = LianFuDailyData.Instance:GetCampBattleServerGroupInfo()
	if nil ~= next(data) then
		gongzu_cell:SetData(data[1].server_id_list[data_index])
	end
end

function LianFuServerGroupView:GetShiZuNumberOfCells()
	local data = LianFuDailyData.Instance:GetCampBattleServerGroupInfo()
	if nil ~= next(data) then
		return data[2].count
	end

	return 0
end

function LianFuServerGroupView:RefreshShiZuView(cell, data_index)
	data_index = data_index + 1

	local shizu_cell = self.shizu_cell_list[cell]
	if shizu_cell == nil then
		shizu_cell = LianFuServerItemCell.New(cell.gameObject)
		self.shizu_cell_list[cell] = shizu_cell
	end
	shizu_cell:SetIndex(data_index)
	local data = LianFuDailyData.Instance:GetCampBattleServerGroupInfo()
	if nil ~= next(data) then
		shizu_cell:SetData(data[2].server_id_list[data_index])
	end
end

function LianFuServerGroupView:OnEnter()
	CrossServerCtrl.Instance:SendCrossStartReq(ACTIVITY_TYPE.KF_XY_CITY)
	self:Close()
end

function LianFuServerGroupView:OnFlush(param_t)
	for i = 1, 2 do
		if self.server_group[i] then
			self.server_group[i].scroller:ReloadData(0)
		end
	end
end

------------------------LianFuServerItemCell------------------------------
LianFuServerItemCell = LianFuServerItemCell or BaseClass(BaseCell)

function LianFuServerItemCell:__init()
	self.server_name = self:FindVariable("ServerName")
end

function LianFuServerItemCell:__delete()
	
end

function LianFuServerItemCell:OnFlush()
	if nil == self.data then return end

	local server_name = LoginData.Instance:GetShowServerNameById(self.data)
	self.server_name:SetValue(server_name)
end