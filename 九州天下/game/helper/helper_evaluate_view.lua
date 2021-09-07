HelperEvaluateView = HelperEvaluateView or BaseClass(BaseRender)

function HelperEvaluateView:__init(instance)
	HelperEvaluateView.Instance = self
	self.evaluate_cell_list = {}
	self:InitListView()
end

function HelperEvaluateView:InitListView()
	self.list_view = self:FindObj("list_view")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function HelperEvaluateView:__delete()
	for k,v in pairs(self.evaluate_cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	HelperEvaluateView.Instance = nil
end

function HelperEvaluateView:GetNumberOfCells()
	return HelperData.Instance:GetTypeCount()
end

function HelperEvaluateView:RefreshCell(cell, cell_index)
	local evaluate_cell = self.evaluate_cell_list[cell]
	if evaluate_cell == nil then
		evaluate_cell = EvaluateItem.New(cell.gameObject, self)
		self.evaluate_cell_list[cell] = evaluate_cell
	end
	cell_index = cell_index + 1
	evaluate_cell:SetGridIndex(cell_index)
end

---------------------------------------------------------------
EvaluateItem = EvaluateItem or BaseClass(BaseCell)

function EvaluateItem:__init()
	self.icon_image = self:FindVariable("icon_image")
	self.evaluate_icon = self:FindVariable("evaluate_icon")									--图标
	self.evaluate_score_icon = self:FindVariable("evaluate_score_icon")						--评价
	self.slider = self:FindVariable("slider")												--进度条
	self.suggest_zhanli = self:FindVariable("suggest_zhanli")								--推荐战力
	self.evaluate_name = self:FindVariable("evaluate_name")									--名字
	self.current_score_text = self:FindVariable("current_score_text")						--当前分数	
	self.highest_score_text = self:FindVariable("highest_score_text")						--满分分数
	self:ListenEvent("promote_click", BindTool.Bind(self.OnPromoteClick, self))
	self.grid_index = 0
end

function EvaluateItem:__delete()

end
function EvaluateItem:SetGridIndex(grid_index)
	self.grid_index = grid_index
	self:OnFlush()
end

function EvaluateItem:OnFlush()
	local cfg = HelperData.Instance:GetHelperModule(self.grid_index)
	local list = HelperData.Instance:GetSuggestCapList()
	local sugget_cap = list.suggest_cap_list[self.grid_index]
	local highest_cap = list.highest_cap_list[self.grid_index]
	local bundle, asset = ResPath.GetHelperIcon(cfg.icon_id)
	local current_score = HelperData.Instance:GetCurrentScore(self.grid_index)
	local helper_score = HelperData.Instance:GetHelperScore(current_score ,highest_cap)
	self.icon_image:SetAsset(bundle, asset)
	self.suggest_zhanli:SetValue(sugget_cap)
	self.evaluate_name:SetValue(cfg.title)
	local bundle2, asset2 = nil, nil
	if helper_score == HELPER_SCORE.PERFECT then
		bundle2, asset2 = ResPath.GetHelper("img_perfect")
	elseif helper_score == HELPER_SCORE.GOOD then
		bundle2, asset2 = ResPath.GetHelper("img_good")
	elseif helper_score == HELPER_SCORE.PASS then
		bundle2, asset2 = ResPath.GetHelper("img_pass")
	elseif helper_score == HELPER_SCORE.NO_PASS then
		bundle2, asset2 = ResPath.GetHelper("img_not_pass")
	end
	self.evaluate_score_icon:SetAsset(bundle2, asset2)
	self.slider:SetValue(current_score / highest_cap)
	self.current_score_text:SetValue(current_score)
	self.highest_score_text:SetValue(highest_cap)	
end

function EvaluateItem:OnPromoteClick()	
	local cfg = HelperData.Instance:GetHelperModule(self.grid_index)
	local the_list = Split(cfg.open_param, "#")
	local name = ""
	local index_name = ""
	if #the_list == 2 then
		name = the_list[1]
		index_name = the_list[2]
	else
		name = cfg.open_param
	end
	ViewManager.Instance:Open(ViewName[name], TabIndex[index_name])
	HelperCtrl.Instance.view:Close()
end
