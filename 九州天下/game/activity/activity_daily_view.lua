ActivityDailyView = ActivityDailyView or BaseClass(BaseRender)

local PAGE_CELL_NUM = 5		--一页的个数
local MAX_PAGE = 5
local MAX_REWARD = 3

function ActivityDailyView:__init(instance)
	if instance == nil then
		return
	end

	self.cur_page_index = 0

	-- self.page_toggle1 = self:FindObj("PageToggle1")

	-- self.page_count = self:FindVariable("PageCount")

	self.cell_list = {}
	self.act_info = ActivityData.Instance:GetClockActivityByType(ActivityData.Act_Type.normal)
	self.act_count = ActivityData.Instance:GetClockActivityCountByType(ActivityData.Act_Type.normal)

	self:InitScroller()
end

function ActivityDailyView:__delete()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

--初始化滚动条
function ActivityDailyView:InitScroller()
	self.scroller = self:FindObj("Scroller")

	self.list_view_delegate = self.scroller.list_simple_delegate

	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
end

--滚动条数量
function ActivityDailyView:GetNumberOfCells()
	return ActivityData.Instance:GetClockActivityCountByType(ActivityData.Act_Type.normal)
end

--滚动条刷新
function ActivityDailyView:RefreshView(cell, data_index)
	data_index = data_index + 1
	local group_cell = self.cell_list[cell]
	if group_cell == nil then
		group_cell = ActivityItemCell.New(cell.gameObject)
		self.cell_list[cell] = group_cell
	end
	-- for i = 1, MAX_PAGE do
	-- 	local index = data_index * PAGE_CELL_NUM + i
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
function ActivityDailyView:OnClickJoin(act_id)

end

function ActivityDailyView:FlushDaily()
	GlobalTimerQuest:AddDelayTimer(function()
		-- local page_count = math.ceil(self.act_count / PAGE_CELL_NUM)
		-- self.page_count:SetValue(page_count)
		-- self.scroller.list_page_scroll:SetPageCount(page_count)

		self.scroller.scroller:ReloadData(0)
		-- self.page_toggle1.toggle.isOn = true
	end, 0)
end

--------------------------------------- 动态生成右侧活动info ----------------------------------------------
ActivityViewScrollCell = ActivityViewScrollCell or BaseClass(BaseRender)

function ActivityViewScrollCell:__init()
	self.item_cell = {}
	for i = 1, 5 do
		local act_item = ActivityItemCell.New(self:FindObj("Act" .. i))
		table.insert(self.item_cell, act_item)
	end
end

function ActivityViewScrollCell:__delete()
	for k, v in ipairs(self.item_cell) do
		v:DeleteMe()
	end
	self.item_cell = {}
end

function ActivityViewScrollCell:SetData(i, data)
	self.item_cell[i]:SetData(data)
end

function ActivityViewScrollCell:SetActive(i, state)
	self.item_cell[i]:SetActive(state)
end

function ActivityViewScrollCell:SetToggleGroup(i, group)
	self.item_cell[i].root_node.toggle.group = group
end

function ActivityViewScrollCell:SetParent(i, parent)
	self.item_cell[i].daily_view = parent
end

function ActivityViewScrollCell:SetIndex(i, index)
	self.item_cell[i]:SetIndex(index)
end


ActivityItemCell = ActivityItemCell or BaseClass(BaseCell)

function ActivityItemCell:__init()
	self.icon = self:FindVariable("Icon")
	self.count_down = self:FindVariable("CountDown")
	self.activity_name = self:FindVariable("ActivityName")
	self.des = self:FindVariable("Des")
	self.is_active = self:FindVariable("is_active")
	self.is_end = self:FindVariable("IsEnd")
	self.is_not_open = self:FindVariable("IsNotOpen")
	self.is_open = self:FindVariable("IsOpen")
	self.is_show_red = self:FindVariable("IsShowRed")

	self.show_red_point = self:FindVariable("ShowRedPoint")
	self.show_kaiqi_desc = self:FindVariable("ShowKaiqiDesc")

	self:ListenEvent("OnClick", BindTool.Bind(self.OnClick, self))

	self.item_cell = {}
	for i = 1, MAX_REWARD do
		local temp_list = {}
		temp_list.obj = self:FindObj("ItemCell_" .. i)
		temp_list.item = ItemCell.New()
		temp_list.item:SetInstanceParent(temp_list.obj)
		self.item_cell[i] = temp_list
	end
end

function ActivityItemCell:__delete()
	for k,v in pairs(self.item_cell) do
		v.item:DeleteMe()
		v.item = nil
	end
	self.item_cell = {}
end

function ActivityItemCell:OnClick()
	local act_id = self.data.act_id
	ActivityCtrl.Instance:ShowDetailView(act_id)
end

function ActivityItemCell:OnFlush()
	if not self.data then return end

	local bundle, asset = ResPath.GetActivityBigIcon(self.data.act_id)
	self.icon:SetAsset(bundle, asset)

	local open_day_list = Split(self.data.open_day, ":")
	local server_time = TimeCtrl.Instance:GetServerTime()
	local now_weekday = tonumber(os.date("%w", server_time))
	local server_time_str = os.date("%H:%M", server_time)
	if now_weekday == 0 then now_weekday = 7 end
	local time_str = ""

	self.is_end:SetValue(false)
	self.is_not_open:SetValue(false)
	self.is_open:SetValue(false)
	self.is_show_red:SetValue(false)
	self.show_kaiqi_desc:SetValue(self.data.act_id == ACTIVITY_TYPE.HUSONG)

	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	if self.data.min_level > role_level then
		self.is_active:SetValue(false)
		-- 屏蔽转生显示
		-- local temp = self.data.min_level/100
		-- local value = math.floor(temp)
		-- local temp_val = value
		-- if 0 == temp_val then
		-- 	temp_val = 1
		-- end
		-- local temp_level = 100
		-- if temp > value then
		-- 	temp_level = self.data.min_level%(temp_val*100)
		-- else
		-- 	value = value - 1
		-- end
		-- time_str = string.format(Language.Activity.LevelOpen,temp_level,value)
		
		time_str = string.format(Language.Activity.LevelOpen, self.data.min_level)
	else
		self.is_active:SetValue(true)
		local though_time = true
		local is_today_open = false
		for _, v in ipairs(open_day_list) do
			if tonumber(v) == now_weekday then
				is_today_open = true
				local open_time_tbl = Split(self.data.open_time, "|")
				local open_time_str = open_time_tbl[1]
				local end_time_tbl = Split(self.data.end_time, "|")
				local end_time_str = end_time_tbl[1]

				for k2, v2 in ipairs(end_time_tbl) do
					if v2 > server_time_str then
						though_time = false
						open_time_str = open_time_tbl[k2]
						end_time_str = v2
						break
					end
				end
				time_str = open_time_str .. "-" .. end_time_str
				if tonumber(end_time_str) == 0 then
					time_str = open_time_str
				end
				break
			end
		end
		local cfg = ActivityData.Instance:GetActivityConfig(self.data.act_id) or {}

		if ActivityData.Instance:GetActivityIsOpen(self.data.act_id) or cfg.is_allday == 1 then
			self.is_open:SetValue(true)
			if self.data.act_id == ACTIVITY_TYPE.HUSONG then
				local can_husong_num = YunbiaoData.Instance and YunbiaoData.Instance:GetHusongRemainTimes()
				if can_husong_num and can_husong_num > 0 then
					self.is_show_red:SetValue(true)
				end
			else
				self.is_show_red:SetValue(true)
			end
		elseif not is_today_open or (is_today_open and not though_time) then
			self.is_not_open:SetValue(true)
		else
			self.is_end:SetValue(true)
		end

		if self.data.act_id == ACTIVITY_ACT_TYPE_BATTLE.ACT_ID_BATTLE_FORD then
			self.is_show_red:SetValue(ActivityData.Instance:GetActivityIsOpen(self.data.act_id))
		end

		if not is_today_open then
			local str = Language.Common.Week
			for i = 1, #open_day_list do
				local day = tonumber(open_day_list[i])
				day = Language.Common.DayToChs[day] or ""
				str = str .. day
				if i ~= #open_day_list then
					str = str .. "、"
				end
			end
			time_str = ToColorStr(str .. Language.Common.Open, TEXT_COLOR.RED)
		end
	end
	if time_str ~= "" then
		self.count_down:SetValue(time_str)
	end

	self.activity_name:SetValue(self.data.act_name)
	self.des:SetValue(self.data.comment)

	for i = 1, MAX_REWARD do
		if self.data["reward_item" .. i] and next(self.data["reward_item" .. i]) then
			self.item_cell[i].item:SetData(self.data["reward_item" .. i])
			self.item_cell[i].obj:SetActive(true)
		else
			self.item_cell[i].obj:SetActive(false)
		end
	end
end

function ActivityItemCell:SetToggleGroup(group)
	self.root_node.toggle.group = group
end