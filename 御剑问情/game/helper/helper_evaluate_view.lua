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

function HelperEvaluateView:GetNumberOfCells()
	return HELPER_EVALUATE_TYPE_COUNT
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
	self.evaluate_icon = self:FindVariable("evaluate_icon")
	self.evaluate_score_icon = self:FindVariable("evaluate_score_icon")
	self.slider = self:FindVariable("slider")
	self.suggest_zhanli = self:FindVariable("suggest_zhanli")
	self.evaluate_name = self:FindVariable("evaluate_name")
	self.current_score_text = self:FindVariable("current_score_text")
	self.highest_score_text = self:FindVariable("highest_score_text")
	self:ListenEvent("promote_click", BindTool.Bind(self.OnPromoteClick, self))
	self.grid_index = 0
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
	-- cfg.icon_id
	local bundle, asset = ResPath.GetHelperIcon(cfg.icon_id)
	local current_score = HelperData.Instance:GetCurrentScore(self.grid_index)
	local helper_score = HelperData.Instance:GetHelperScore(current_score ,highest_cap)
	self.evaluate_icon:SetAsset(bundle, asset)
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
	self.slider:SetValue(current_score/highest_cap)
	self.current_score_text:SetValue(current_score)
	self.highest_score_text:SetValue(highest_cap)
end

function EvaluateItem:OnPromoteClick()
	PlayerCtrl.Instance.view:HandleClose()
	HelperCtrl.Instance:GetView():OnCloseBtnClick()
	if self.grid_index == HELPER_EVALUATE_TYPE.EQUIP then
		ViewManager.Instance:Open(ViewName.Forge, TabIndex.forge_strengthen)
	elseif self.grid_index == HELPER_EVALUATE_TYPE.SHENGONG then
		ViewManager.Instance:Open(ViewName.Goddess, TabIndex.goddess_shengong)
	elseif self.grid_index == HELPER_EVALUATE_TYPE.MOUNT then
		ViewManager.Instance:Open(ViewName.Advance, TabIndex.mount_jinjie)
		GlobalEventSystem:Fire(OtherEventType.MOUNT_INFO_CHANGE, "mount")
	elseif self.grid_index == HELPER_EVALUATE_TYPE.SPIRIT then
		ViewManager.Instance:Open(ViewName.SpiritView, TabIndex.spirit_spirit)
		SpiritCtrl.Instance:SendGetSpiritWarehouseItemListReq(CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_JINGLING)
		SpiritCtrl.Instance:SendGetSpiritScore()
	elseif self.grid_index == HELPER_EVALUATE_TYPE.GODDESS then
		ViewManager.Instance:Open(ViewName.Goddess, TabIndex.goddess_info)
	elseif self.grid_index == HELPER_EVALUATE_TYPE.ACHIEVE then
		ViewManager.Instance:Open(ViewName.BaoJu, TabIndex.baoju_achieve_title)
	elseif self.grid_index == HELPER_EVALUATE_TYPE.HALO then
		ViewManager.Instance:Open(ViewName.Advance, TabIndex.halo_jinjie)
	elseif self.grid_index == HELPER_EVALUATE_TYPE.WING then
		ViewManager.Instance:Open(ViewName.Advance, TabIndex.wing_jinjie)
	elseif self.grid_index == HELPER_EVALUATE_TYPE.SHENYI then
		ViewManager.Instance:Open(ViewName.Goddess, TabIndex.goddess_shenyi)
	elseif self.grid_index == HELPER_EVALUATE_TYPE.FIGHT_MOUNT then
		ViewManager.Instance:Open(ViewName.Advance, TabIndex.fight_mount)
	end
end