ExpenseRewardPoolKaifuPanel = ExpenseRewardPoolKaifuPanel or BaseClass(BaseView)

function ExpenseRewardPoolKaifuPanel:__init()
	self.ui_config = {"uis/views/kaifuactivity_prefab", "ExpenseRewardPoolKaifuPanel"}
	self.play_audio = true
end

function ExpenseRewardPoolKaifuPanel:__delete()

end

function ExpenseRewardPoolKaifuPanel:ReleaseCallBack()
	if self.cell_list then
		for k, v in pairs(self.cell_list) do
			v:DeleteMe()
			v = nil
		end
		self.cell_list = nil
	end

	self.toggle_obj = nil
	self.toggle_list = nil
	self.list_view = nil
	self.list_view_delegate = nil
end

function ExpenseRewardPoolKaifuPanel:CloseCallBack()

end

function ExpenseRewardPoolKaifuPanel:LoadCallBack()
	self.cell_list = {}

	self.toggle_list = {}
	self.toggle_obj = self:FindObj("ToggleList")
	for i = 1, 5 do
		self.toggle_list[i] = self.toggle_obj:FindObj("Toggle"..i)
	end

	local page_count = self:GetNumberOfCells()
	self.list_view = self:FindObj("ListView")
	self.list_view.list_page_scroll:SetPageCount(page_count)

	self.list_view_delegate = self.list_view.list_simple_delegate
	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)

	self:ListenEvent("CloseClick", BindTool.Bind(self.CloseClick, self))

	self:InitToggles()
end

function ExpenseRewardPoolKaifuPanel:OpenCallBack()
	if self.list_view and self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:ReloadData(0)
	end
end

function ExpenseRewardPoolKaifuPanel:OnFlush()

end

function ExpenseRewardPoolKaifuPanel:InitToggles()
	if self.toggle_list then
		local page_count = self:GetNumberOfCells()
		for i = 1, 5 do
			self.toggle_list[i]:SetActive(i <= page_count)
		end
		self.toggle_list[1].toggle.isOn = true
	end
end

function ExpenseRewardPoolKaifuPanel:GetNumberOfCells()
	return KaifuActivityData.Instance:GetExpenseNiceGiftPageCount()
end

function ExpenseRewardPoolKaifuPanel:RefreshView(cell, data_index)
	data_index = data_index + 1
	local cfg
	if self.page_cfg_callback then
		cfg = self.page_cfg_callback(data_index)
	else
		cfg = KaifuActivityData.Instance:GetExpenseNiceGiftPageCfgByIndex(data_index)
	end
	local the_cell = self.cell_list[cell]

	if cfg then
		if the_cell == nil then
			the_cell = ExpenseRewardPage.New(cell.gameObject)
			self.cell_list[cell] = the_cell
		end
		the_cell:SetIndex(data_index)
		the_cell:SetData(cfg)
	end
end

function ExpenseRewardPoolKaifuPanel:CloseClick()
	self:Close()
end

----------------------------------------------------------------------------
-------------------------------奖励池页数-----------------------------------
----------------------------------------------------------------------------
ExpenseRewardPage = ExpenseRewardPage or BaseClass(BaseCell)

function ExpenseRewardPage:__init()
	self.cell_list = {}
	self.item_cell_list = {}

	for i = 1, 9 do
		self.cell_list[i] = self:FindObj("Cell" .. i)
	end
end

function ExpenseRewardPage:__delete()
	if self.item_cell_list then
		for k, v in pairs(self.item_cell_list) do
			if v then
				v:DeleteMe()
				v = nil
			end
		end

		self.item_cell_list = nil
	end
end

function ExpenseRewardPage:OnFlush()
	if not self.data then return end

	cell_count = #self.data

	for i = 1, cell_count do
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetInstanceParent(self.cell_list[i])

		if self.data[i] and self.data[i].reward_item then
			self.item_cell_list[i]:SetData(self.data[i].reward_item)
		end
	end
end




