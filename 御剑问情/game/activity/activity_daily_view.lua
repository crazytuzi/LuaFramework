ActivityDailyView = ActivityDailyView or BaseClass(BaseRender)

local PAGE_CELL_NUM = 5		--一页的个数
local MAX_PAGE = 5

function ActivityDailyView:__init(instance)
	if instance == nil then
		return
	end

	self.cell_list = {}
	self.act_info = ActivityData.Instance:GetClockActivityByType(ActivityData.Act_Type.normal)
	self.act_count = ActivityData.Instance:GetClockActivityCountByType(ActivityData.Act_Type.normal)

	self:InitScroller()
	self.cur_sel_index = -1
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

	local list_view_delegate = self.scroller.list_simple_delegate

	list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
end

--滚动条数量
function ActivityDailyView:GetNumberOfCells()
	return self.act_count
end

--滚动条刷新
function ActivityDailyView:RefreshView(cell, data_index)
	local group_cell = self.cell_list[cell]
	if group_cell == nil then
		group_cell = ActivityViewScrollCell.New(cell.gameObject)
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

function ActivityDailyView:OnClickCallBack(cell)
	if nil == cell then
		return
	end

	self.cur_sel_index = cell:GetIndex()
	local data = cell:GetData()
	local act_id = data.act_id
	ActivityCtrl.Instance:ShowDetailView(act_id)
end


-- 点击参加
function ActivityDailyView:OnClickJoin(act_id)

end

function ActivityDailyView:FlushDaily()
	GlobalTimerQuest:AddDelayTimer(function()
		self.scroller.scroller:ReloadData(0)
	end, 0)
end

--------------------------------------- 动态生成右侧活动info ----------------------------------------------
ActivityViewScrollCell = ActivityViewScrollCell or BaseClass(BaseRender)

function ActivityViewScrollCell:__init()
	self.item_cell = ActivityItemCell.New(self:FindObj("Act"))
end

function ActivityViewScrollCell:__delete()
	self.item_cell:DeleteMe()
end

function ActivityViewScrollCell:SetData(data)
	self.item_cell:SetData(data)
end

function ActivityViewScrollCell:SetActive(state)
	self.item_cell:SetActive(state)
end

function ActivityViewScrollCell:SetToggleGroup(group)
	self.item_cell.root_node.toggle.group = group
end

function ActivityViewScrollCell:SetParent(parent)
	self.item_cell.daily_view = parent
end

function ActivityViewScrollCell:SetIndex(index)
	self.item_cell:SetIndex(index)
end

function ActivityViewScrollCell:SetClickCallBack(callback)
	self.item_cell:SetClickCallBack(callback)
end

function ActivityViewScrollCell:SetHighLight(value)
	self.item_cell.root_node.toggle.isOn = value
end

ActivityItemCell = ActivityItemCell or BaseClass(BaseCell)

function ActivityItemCell:__init()
	self.icon = self:FindVariable("Icon")
	self.count_down = self:FindVariable("CountDown")
	self.activity_name = self:FindVariable("ActivityName")
	self.des = self:FindVariable("Des")
	self.is_active = self:FindVariable("is_active")
	self.is_icon_gray = self:FindVariable("is_icon_gray")
	self.is_end = self:FindVariable("IsEnd")
	self.is_not_open = self:FindVariable("IsNotOpen")
	self.is_open = self:FindVariable("IsOpen")
	self.is_select = self:FindVariable("IsSelect")
	self.show_red_point = self:FindVariable("ShowRedPoint")
	self.open_time = self:FindVariable("open_time")
	self.is_today = self:FindVariable("is_today")

	--文字
	self.text_table = {}
	for i=1,3 do
		self.text_table[i] =  self:FindVariable("Text"..i)
	end
	self.show_text_panel = self:FindVariable("ShowTextPanel")
	self.show_text_panel:SetValue(false)


	-- self.select_bg = self:FindObj("SelectBg")
	self.cover_bg = self:FindObj("CoverBg")

	self:ListenEvent("OnClick", BindTool.Bind(self.OnClick, self))
end

function ActivityItemCell:__delete()

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
	self.is_icon_gray:SetValue(false)
	self.cover_bg:SetActive(false)
	-- self.select_bg:SetActive(false)
	-- self.root_node.transform.localScale = Vector3(0.9, 0.9, 0.9)
	local is_today_open = false
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local show_desc = false
	if self.data.min_level > role_level then
		self.is_active:SetValue(false)
		local temp = self.data.min_level/100
		local value = math.floor(temp)
		local temp_val = value
		if 0 == temp_val then
			temp_val = 1
		end
		local temp_level = 100
		if temp > value then
			temp_level = self.data.min_level%(temp_val*100)
		else
			value = value - 1
		end
		self.is_not_open:SetValue(true)
		self.cover_bg:SetActive(true)
		self.is_icon_gray:SetValue(true)	
		time_str = string.format(Language.Activity.LevelOpen,temp_level,value)
		self.count_down:SetValue(time_str)
		show_desc = true
	else
		self.is_active:SetValue(true)
		local though_time = true
		is_today_open = false
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
				self.count_down:SetValue(time_str)
				break
			end
		end

		local is_opening = false
		local cfg = ActivityData.Instance:GetActivityConfig(self.data.act_id) or {}
		if ActivityData.Instance:GetActivityIsOpen(self.data.act_id) or cfg.is_allday == 1 then
			self.is_open:SetValue(true)
			-- self.select_bg:SetActive(true)
			-- self.root_node.transform.localScale = Vector3(1, 1, 1)
		elseif not is_today_open or (is_today_open and not though_time) then
			self.is_not_open:SetValue(true)
			self.cover_bg:SetActive(true)
		else
			self.is_end:SetValue(true)
			self.cover_bg:SetActive(true)
			self.is_icon_gray:SetValue(true)
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
			time_str = ToColorStr(str .. Language.Common.Open, TEXT_COLOR.GREEN)
			self.open_time:SetValue(time_str)
		end
	end
	self.is_today:SetValue(is_today_open or show_desc)
	-- if time_str ~= "" then
	-- 	self.count_down:SetValue(time_str)
	-- end

	self.activity_name:SetValue(self.data.act_name)
	self.des:SetValue(self.data.comment)

	--是否是精华护送
	if self.data.act_id == ACTIVITY_TYPE.JINGHUA_HUSONG then
		self.show_text_panel:SetValue(true)
		self:SetJingHuaHuSongText()
	else
		self:ClearText()
	end
end

function ActivityItemCell:SetJingHuaHuSongText()
	self.text_table[1]:SetValue(string.format(Language.JingHuaHuSong.CommitTimes, JingHuaHuSongData.Instance:GetCurCommitTimes()))	  --当天提交次数
	self.text_table[2]:SetValue(string.format(Language.JingHuaHuSong.CanGatherTimes, JingHuaHuSongData.Instance:GetGatherTimes()))	  --采集次数
	self.text_table[3]:SetValue(string.format(Language.JingHuaHuSong.NextConvoyReward, JingHuaHuSongData.Instance:GetRewardPercent()))--衰减百分比
end

function ActivityItemCell:ClearText()
	self.text_table[1]:SetValue("")
	self.text_table[2]:SetValue("")
	self.text_table[3]:SetValue("")
end