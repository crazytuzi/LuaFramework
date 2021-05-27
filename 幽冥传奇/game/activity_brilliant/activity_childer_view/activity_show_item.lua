ActivityShowItem = ActivityShowItem or BaseClass(XuiBaseView)

function ActivityShowItem:__init()
	self.is_any_click_close = true
	self.config_tab = {{"show_award_ui_cfg", 1, {0}}}
	self.selcetec_index = 1
	self:SetRootNodeOffPos({x = 130, y = -46})
end

function ActivityShowItem:__delete()
	if nil ~= self.award_grid then
		self.award_grid:DeleteMe()
		self.award_grid = nil
	end
end

function ActivityShowItem:LoadCallBack()
	self:InitChatItem()
end

function ActivityShowItem:InitChatItem()
	local bag_cells = 15
	--创建格子
	self.award_grid = BaseGrid.New()
	local grid_node = self.award_grid:CreateCells{w = 430, h = 280 , cell_count = bag_cells, col = 5, row = 3, is_show_tips = false, itemRender = ActBaseCell}
	self.node_t_list.layout_award_list.node:addChild(grid_node,1000, 1000)  				--将网格实体添加显示	
	grid_node:setPosition(10, 10)
	self.award_grid:SetSelectCallBack(BindTool.Bind(self.SelectCellCallBack, self))
end

function ActivityShowItem:OpenCallBack()

end

function ActivityShowItem:SetDataList(show_list)
	if nil == show_list then return end
	local award_list = {}
	for i,v in ipairs(show_list) do
		local vo = {}
		vo.item_id = v.id
		vo.num = v.count
		vo.is_bind = v.bind
		table.insert(award_list, vo);
	end
	award_list[0] = table.remove(award_list, 1)
	if self.award_grid then
		self.award_grid:SetDataList(award_list)
	end 
end

function ActivityShowItem:OnFlush(param_t)
	if param_t.all then
		self:SetDataList(param_t.all.show_list)
	end
end

function ActivityShowItem:SelectCellCallBack(cell)
	if nil == cell then
		return
	end
	
	local cell_data = cell:GetData()
	if nil == cell_data then
		return
	end
	local item_data = ItemData.Instance:GetItemConfig(cell_data.item_id)
	if nil == item_data then
		return
	end
	TipCtrl.Instance:OpenItem(cell_data)
end

function ActivityShowItem:SetPosition(x, y)
	if nil ~= self.root_node then
		self.root_node:setPosition(x, y)
	end
end
