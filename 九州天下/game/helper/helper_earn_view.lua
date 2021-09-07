HelperEarnView = HelperEarnView or BaseClass(BaseRender)

function HelperEarnView:__init(instance)
	HelperEarnView.Instance = self
	self.list_view = self:FindObj("list_view")
	self:InitListView()
end

function HelperEarnView:InitListView()
	self.list_view = self:FindObj("list_view")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function HelperEarnView:GetNumberOfCells()
	return 10
end

function HelperEarnView:RefreshCell(cell, cell_index)
	local helper_earn_cell = self.helper_earn_cell_list[cell]
	if helper_upgrade_cell == nil then
		helper_earn_cell = HelperEarnItem.New(cell.gameObject, self)
		self.helper_earn_cell_list[cell] = helper_earn_cell
	end
	cell_index = cell_index + 1
	helper_earn_cell:SetGridIndex(cell_index)
end
--------------------------------------------------------------------
HelperEarnItem = HelperEarnItem or BaseClass(BaseCell)

function HelperEarnItem:__init()
	self.challenge_count_text = self:FindVariable("challenge_count")
	self.challenge_name_text = self:FindVariable("challenge_name")
	self.slider = self:FindVariable("slider")
	self.btn_text = self:FindVariable("btn_text")
	self.show_btn = self:FindVariable("show_btn")
	self.show_text = self:FindVariable("show_text")
	self.reward_text_1 = self:FindVariable("reward_text_1")
	self.reward_text_2 = self:FindVariable("reward_text_2")
	self.show_reward_2 = self:FindVariable("show_reward_2")
	self.show_star_list = {}
	for i=1,10 do
		self.show_star_list[i] = self:FindVariable("show_start" .. i)
	end
	self:ListenEvent("go_to_click", BindTool.Bind(self.OnGoToClick, self))
	self.grid_index = 0
end

function HelperEarnItem:SetGridIndex(grid_index)
	self.grid_index = grid_index
	self:OnFlush()
end

function HelperEarnItem:OnFlush()
	local cfg = HelperData.Instance:GetHelperListByType(HELPER_TYPE.UPGRADE)[self.grid_index]
	local challenge_count = 5
	local start_count_1 = cfg.star_num1
	local start_count_2 = cfg.star_num2
	if start_count_2 == "" then
		start_count_2 = 0
	end

	for i=1,5 do
		if i <= start_count_1 then
			self.show_star_list[i]:SetValue(true)
		else
			self.show_star_list[i]:SetValue(false)
		end
	end

	for i=6,10 do
		if i - 5 <= start_count_2 then
			self.show_star_list[i]:SetValue(true)
		else
			self.show_star_list[i]:SetValue(false)
		end
	end
	self.reward_text_1:SetValue(cfg.res_name1 ..":")
	if start_count_2 == 0 then
		self.reward_text_2:SetValue("")
	else
		self.reward_text_2:SetValue(cfg.res_name2 ..":")
	end
	self.challenge_name_text:SetValue(cfg.title)
	self.challenge_count_text:SetValue(challenge_count)
	self.btn_text:SetValue(cfg.btn_name)
end

function HelperEarnItem:OnGoToClick()
	print("前往")
end