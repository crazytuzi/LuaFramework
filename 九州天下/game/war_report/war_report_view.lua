WarReportView = WarReportView or BaseClass(BaseView)
function WarReportView:__init()
	self.ui_config = {"uis/views/warreport","WarReportView"}
	self:SetMaskBg()
	self.rank_cell = {}
	self.honor_cell = {}
	self.normal_cell = {}
	self.cur_select_index = 1
end

function WarReportView:ReleaseCallBack()
	for k,v in pairs(self.rank_cell) do
		v:DeleteMe()
	end
	self.rank_cell = {}

	for k,v in pairs(self.honor_cell) do
		v:DeleteMe()
	end
	self.honor_cell = {}

	for k,v in pairs(self.normal_cell) do
		v:DeleteMe()
	end
	self.normal_cell = {}

	if self.chat_measuring then
		GameObject.Destroy(self.chat_measuring.root_node.gameObject)
		self.chat_measuring:DeleteMe()
		self.chat_measuring = nil
	end
	
	self.normal_desc = nil
	self.my_rank = nil
	self.my_num = nil
	self.rank_list = nil
	self.honor_list = nil
	self.normal_list = nil
	self.show_honor = nil
	self.show_front = nil
end

function WarReportView:LoadCallBack()
	self:ListenEvent("Close", BindTool.Bind(self.Close, self))

	self.normal_desc = self:FindVariable("NormalDesc")    

	self.my_rank = self:FindVariable("MyRank")
	self.my_num = self:FindVariable("MyNum")

	self.show_honor = self:FindVariable("ShowHonor")
	self.show_front = self:FindVariable("ShowFront")

	self.rank_list = self:FindObj("RankList")
	local rank_delegate = self.rank_list.list_simple_delegate
	rank_delegate.NumberOfCellsDel = BindTool.Bind(self.GetRankCount, self)
	rank_delegate.CellRefreshDel = BindTool.Bind(self.RefreshRankCell, self)

	self.honor_list = self:FindObj("HonorList")
	local honor_delegate = self.honor_list.list_simple_delegate
	honor_delegate.CellSizeDel = BindTool.Bind(self.GetCellSizeDel, self)
	honor_delegate.NumberOfCellsDel = BindTool.Bind(self.GetHonorReportCount, self)
	honor_delegate.CellRefreshDel = BindTool.Bind(self.RefreshHonorCell, self)

	self.normal_list = self:FindObj("NormalList")
	local normal_delegate = self.normal_list.list_simple_delegate
	normal_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNormalReportCount, self)
	normal_delegate.CellRefreshDel = BindTool.Bind(self.RefreshNormalCell, self)

	self.normal_desc:SetValue(Language.WarReport.NormalDesc)
end

function WarReportView:OpenCallBack()
	RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAMP_KILL_NUM)
	WarReportCtrl.Instance:SendBattleReportList()
end

function WarReportView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "all" then
			if self.rank_list.scroller then
				self.rank_list.scroller:ReloadData(0)
			end

			if self.honor_list.scroller then
				self.honor_list.scroller:ReloadData(0)
			end

			if self.normal_list.scroller then
				self.normal_list.scroller:ReloadData(0)
			end

			local rank, kill = WarReportData.Instance:GetMyRankAndNum()
			local rank_str = Language.WarReport.NoRank
			if rank > 0 then
				rank_str = string.format(Language.WarReport.MyRank, rank)
			end
			self.my_rank:SetValue(rank_str)
			self.my_num:SetValue(string.format(Language.WarReport.MyKill, kill))
		end
	end
	
end

function WarReportView:GetRankCount()
	return #RankData.Instance:GetRankList()
end

function WarReportView:GetHonorReportCount()
	local num = WarReportData.Instance:GetHonorCount()
	self.show_honor:SetValue(num > 0)
	return num
end

function WarReportView:GetNormalReportCount()
	local num = WarReportData.Instance:GetNormalCount()
	self.show_front:SetValue(num > 0)
	return num
end

function WarReportView:RefreshRankCell(cell, cell_index)
	local cur_cell = self.rank_cell[cell]
	local rank_data = RankData.Instance:GetRankList()
	if cur_cell == nil then
		cur_cell = WarRankItem.New(cell.gameObject, self)
		self.rank_cell[cell] = cur_cell
		self.rank_cell[cell]:SetClickCallBack(BindTool.Bind(self.OnClickItemCallBack, self))
	end
	cell_index = cell_index + 1
	cur_cell:SetIndex(cell_index)
	self.rank_cell[cell]:SetSelect(self.cur_select_index)
	cur_cell:SetData(rank_data[cell_index])
end

function WarReportView:OnClickItemCallBack(cell)
	if nil == cell or nil == cell.data then return end
	self.cur_select_index = cell.index
 		
	local rank_info = RankData.Instance:GetRankList()[self.cur_select_index]
	if rank_info.user_id ~= GameVoManager.Instance:GetMainRoleVo().role_id then
		ScoietyCtrl.Instance:ShowOperateList(ScoietyData.DetailType.Default, rank_info.user_name)
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.WarReport.ConnotMy)
	end
	self.rank_list.scroller:RefreshAndReloadActiveCellViews(true)
end

function WarReportView:GetCellSizeDel(cell_index)
	local data_index = 0
	data_index = data_index + 1
	local honor_report = WarReportData.Instance:GetNonorList()
	local scroller_delegate = self.honor_list.list_simple_delegate

	local item_measuring = self:GetChatMeasuring(scroller_delegate)
	item_measuring:SetData(honor_report[data_index])
	height = item_measuring:GetContentHeight()
	return height
end

function WarReportView:RefreshHonorCell(cell, cell_index)
	local cur_cell = self.honor_cell[cell]
	local honor_report = WarReportData.Instance:GetNonorList()
	if cur_cell == nil then
		cur_cell = WarReportItem.New(cell.gameObject, self)
		self.honor_cell[cell] = cur_cell
		-- cur_cell:SetToggleGroup(self.honor_list.toggle_group)
	end
	cell_index = cell_index + 1
	cur_cell:SetIndex(cell_index)
	cur_cell:SetReportType(WAR_REPORT_TYPE.HONOR_REPORT)
	cur_cell:SetData(honor_report[cell_index])
end

function WarReportView:RefreshNormalCell(cell, cell_index)
	local cur_cell = self.normal_cell[cell]
	local normal_report = WarReportData.Instance:GetNormalList()
	if cur_cell == nil then
		cur_cell = WarReportItem.New(cell.gameObject, self)
		self.normal_cell[cell] = cur_cell
		-- cur_cell:SetToggleGroup(self.normal_list.toggle_group)
	end
	cell_index = cell_index + 1
	cur_cell:SetIndex(cell_index)
	cur_cell:SetReportType(WAR_REPORT_TYPE.NORMAL_REPORT)
	cur_cell:SetData(normal_report[cell_index])
end

function WarReportView:GetChatMeasuring(delegate)
	if not delegate then
		return
	end
	if not self.chat_measuring then
		local cell = delegate:CreateCell()
		cell.transform:SetParent(UIRoot, false)
		cell.transform.localPosition = Vector3(9999, 0, 0)          --直接放在界面外
		GameObject.DontDestroyOnLoad(cell.gameObject)
		self.chat_measuring = WarReportItem.New(cell.gameObject)
	end
	return self.chat_measuring
end