ActivityBattleView = ActivityBattleView or BaseClass(BaseRender)

local PAGE_CELL_NUM = 5		--一页的个数
local MAX_PAGE = 5

function ActivityBattleView:__init(instance)
	if instance == nil then
		return
	end

	self.cell_list = {}
	self.act_info = ActivityData.Instance:GetClockActivityByType(ActivityData.Act_Type.battle_field)
	self.act_count = ActivityData.Instance:GetClockActivityCountByType(ActivityData.Act_Type.battle_field)

	self:InitScroller()
	self.cur_sel_index = -1
end

function ActivityBattleView:__delete()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

--初始化滚动条
function ActivityBattleView:InitScroller()
	self.scroller = self:FindObj("Scroller")

	local list_view_delegate = self.scroller.list_simple_delegate

	list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
end

--滚动条数量
function ActivityBattleView:GetNumberOfCells()
	return self.act_count
end

--滚动条刷新
function ActivityBattleView:RefreshView(cell, data_index)
	local group_cell = self.cell_list[cell]
	if group_cell == nil then
		group_cell = ActivityBattleCell.New(cell.gameObject)
		group_cell:SetToggleGroup(self.scroller.toggle_group)
		group_cell:SetParent(self)
		group_cell:SetClickCallBack(BindTool.Bind(self.OnClickCallBack, self))
		self.cell_list[cell] = group_cell
	end

	local data = self.act_info[data_index + 1]
	group_cell:SetActive(true)
	group_cell:SetIndex(data_index)
	group_cell:SetData(data)
	group_cell:SetHighLight(self.cur_sel_index == data_index)
end

function ActivityBattleView:OnClickCallBack(cell)
	if nil == cell then
		return
	end
	self.cur_sel_index = cell:GetIndex()
	local data = cell:GetData()
	local act_id = data.act_id

	ActivityCtrl.Instance:ShowDetailView(act_id)
end


-- 点击参加
function ActivityBattleView:OnClickJoin(act_id)

end

function ActivityBattleView:FlushBattle()
	GlobalTimerQuest:AddDelayTimer(function()
		self.scroller.scroller:ReloadData(0)
	end, 0)
end

--------------------------------------- 动态生成右侧活动info ----------------------------------------------
ActivityBattleCell = ActivityBattleCell or BaseClass(BaseRender)

function ActivityBattleCell:__init()
	self.item_cell = ActivityItemCell.New(self:FindObj("Act"))
end

function ActivityBattleCell:__delete()
	self.item_cell:DeleteMe()
end

function ActivityBattleCell:SetData(data)
	self.item_cell:SetData(data)
end

function ActivityBattleCell:SetActive(state)
	self.item_cell:SetActive(state)
end

function ActivityBattleCell:SetToggleGroup(group)
	self.item_cell.root_node.toggle.group = group
end

function ActivityBattleCell:SetParent(parent)
	self.item_cell.daily_view = parent
end

function ActivityBattleCell:SetIndex(index)
	self.item_cell:SetIndex(index)
end

function ActivityBattleCell:SetClickCallBack(callback)
	self.item_cell:SetClickCallBack(callback)
end

function ActivityBattleCell:SetHighLight(value)
	self.item_cell.root_node.toggle.isOn = value
end
