ActivityKuaFuBattleView = ActivityKuaFuBattleView or BaseClass(BaseRender)

local PAGE_CELL_NUM = 5		--一页的个数
local MAX_PAGE = 5

function ActivityKuaFuBattleView:__init(instance)
	if instance == nil then
		return
	end

	self.cur_page_index = 0

	-- self.page_toggle1 = self:FindObj("PageToggle1")

	-- self.page_count = self:FindVariable("PageCount")

	self.cell_list = {}
	self.act_info = ActivityData.Instance:GetClockActivityByType(ActivityData.Act_Type.kuafu_battle_field)
	self.act_count = ActivityData.Instance:GetClockActivityCountByType(ActivityData.Act_Type.kuafu_battle_field)

	self:InitScroller()
end

function ActivityKuaFuBattleView:__delete()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

--初始化滚动条
function ActivityKuaFuBattleView:InitScroller()
	self.scroller = self:FindObj("Scroller")

	self.list_view_delegate = self.scroller.list_simple_delegate

	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
end

--滚动条数量
function ActivityKuaFuBattleView:GetNumberOfCells()
	return ActivityData.Instance:GetClockActivityCountByType(ActivityData.Act_Type.kuafu_battle_field)
end

--滚动条刷新
function ActivityKuaFuBattleView:RefreshView(cell, data_index)
	data_index = data_index + 1
	local group_cell = self.cell_list[cell]
	if group_cell == nil then
		group_cell = ActivityItemCell.New(cell.gameObject)
		self.cell_list[cell] = group_cell
	end
	-- for i = 1, MAX_PAGE do
		-- local index = data_index * PAGE_CELL_NUM + i
		local data = self.act_info[data_index]
		if data then
			group_cell:SetActive(true)
			group_cell:SetIndex(data_index)
			group_cell:SetToggleGroup(self.scroller.toggle_group)
			-- group_cell:SetParent(self)
			group_cell:SetData(data)
		else
			group_cell:SetActive(false)
		end
	-- end
end

-- 点击参加
function ActivityKuaFuBattleView:OnClickJoin(act_id)

end

function ActivityKuaFuBattleView:FlushKuaFuBattle()
	GlobalTimerQuest:AddDelayTimer(function()
		-- local page_count = math.ceil(self.act_count / PAGE_CELL_NUM)
		-- self.page_count:SetValue(page_count)
		-- self.scroller.list_page_scroll:SetPageCount(page_count)

		self.scroller.scroller:ReloadData(0)
		-- self.page_toggle1.toggle.isOn = true
	end, 0)
end

--------------------------------------- 动态生成右侧活动info ----------------------------------------------
ActivityKuaFuBattleCell = ActivityKuaFuBattleCell or BaseClass(BaseRender)

function ActivityKuaFuBattleCell:__init()
	self.item_cell = {}
	for i = 1, 5 do
		local act_item = ActivityItemCell.New(self:FindObj("Act" .. i))
		table.insert(self.item_cell, act_item)
	end
end

function ActivityKuaFuBattleCell:__delete()
	for k, v in ipairs(self.item_cell) do
		v:DeleteMe()
	end
	self.item_cell = {}
end

function ActivityKuaFuBattleCell:SetData(i, data)
	self.item_cell[i]:SetData(data)
end

function ActivityKuaFuBattleCell:SetActive(i, state)
	self.item_cell[i]:SetActive(state)
end

function ActivityKuaFuBattleCell:SetToggleGroup(i, group)
	self.item_cell[i].root_node.toggle.group = group
end

function ActivityKuaFuBattleCell:SetParent(i, parent)
	self.item_cell[i].daily_view = parent
end

function ActivityKuaFuBattleCell:SetIndex(i, index)
	self.item_cell[i]:SetIndex(index)
end