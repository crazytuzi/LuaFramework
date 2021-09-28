PreRewardView = PreRewardView or BaseClass(BaseView)

local BAG_PAGE_COUNT = 15				-- 每页个数

function PreRewardView:__init()
	self.ui_config = {"uis/views/tips/prerewardview_prefab", "PreRewardView"}
	self.view_layer = UiLayer.Pop
	self.cell_list = {}
	self.real_reward_list = {}
	self.reward_list = {}
end

function PreRewardView:ReleaseCallBack()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	-- 清理变量和对象
	self.list_view = nil
	self.toggle_1 = nil
	self.page_count = nil
end

function PreRewardView:LoadCallBack()
	self.cell_list = {}
	self.list_view = self:FindObj("ListView")
	local page_simple_delegate = self.list_view.page_simple_delegate
	page_simple_delegate.NumberOfCellsDel = BindTool.Bind(self.NumberOfCellsDel, self)
	page_simple_delegate.CellRefreshDel = BindTool.Bind(self.CellRefreshDel, self)

	self.toggle_1 = self:FindObj("Toggle1")

	self.page_count = self:FindVariable("PageCount")

	self:ListenEvent("CloseWindow",BindTool.Bind(self.CloseWindow, self))
end

function PreRewardView:CloseWindow()
	self:Close()
end

function PreRewardView:NumberOfCellsDel()
	return #self.reward_list
end

function PreRewardView:CellRefreshDel(data_index, cell)
	data_index = data_index + 1
	local item_cell = self.cell_list[cell]
	if not item_cell then
		item_cell = ItemCell.New()
		item_cell:SetInstanceParent(cell.gameObject)
		self.cell_list[cell] = item_cell
	end
	item_cell:SetData(self.reward_list[data_index])
end

function PreRewardView:SetRewardList(reward_list)
	self.reward_list = reward_list
end

function PreRewardView:OpenCallBack()
	-- self.real_reward_list = {}
	-- for _, v in ipairs(self.reward_list) do
	-- 	table.insert(self.real_reward_list, v)
	-- end
	-- local page = math.ceil(#self.reward_list/BAG_PAGE_COUNT)
	-- for i = 1, page*BAG_PAGE_COUNT do
	-- 	if nil == self.real_reward_list[i] then
	-- 		self.real_reward_list[i] = {}
	-- 	end
	-- end
	-- self.page_count:SetValue(page)

	-- self.list_view.list_page_scroll2:SetPageCount(page)
	-- self.list_view.list_page_scroll2:JumpToPageImmidate(0)
	self.list_view.list_view:Reload()
	self.list_view.list_view:JumpToIndex(0)
end

function PreRewardView:CloseCallBack()

end