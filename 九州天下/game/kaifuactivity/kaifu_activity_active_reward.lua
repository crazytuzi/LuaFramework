DailyActiveReward =  DailyActiveReward or BaseClass(BaseRender)

function DailyActiveReward:__init()
	self.contain_cell_list = {}
end

function DailyActiveReward:__delete()
	for k, v in pairs(self.contain_cell_list) do
		v:DeleteMe()
	end
	self.contain_cell_list = {}
end

function DailyActiveReward:LoadCallBack()
	self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_ACTIVIE_DEGREE, 
			RA_DAY_ACTIVE_DEGREE_OPERA_TYPE.RA_DAY_ACTIVE_DEGREE_OPERA_TYPE_QUERY_INFO)
	-- local rest_time, next_time = ActivityData.Instance:GetActivityResidueTime(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_ACTIVIE_DEGREE)
	
	self.current_active = KaifuActivityData.Instance:GetCurrentActive()
	-- self.rest_time = self:FindVariable("rest_time")
	-- self:SetTime(rest_time)
	-- self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
			-- rest_time = rest_time - 1
			-- self:SetTime(rest_time)
		-- end)
	self.activity_count = self:FindVariable("activity_count")
	self.activity_count:SetValue(self.current_active)

	self:ListenEvent("ClickGetActivity", BindTool.Bind(self.ClickGetActivity, self))

	self.list_view.scroller:ReloadData(0)
end

function DailyActiveReward:CloseCallBack()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
end

function DailyActiveReward:SetTime(rest_time)
	local time_tab = TimeUtil.Format2TableDHMS(rest_time)
	local temp = {}
	for k,v in pairs(time_tab) do
		if k ~= "day" then
			if v < 10 then
				v = tostring('0'..v)
			end
		end
		temp[k] = v
	end
	local str = string.format(Language.Activity.ChongZhiRankRestTime, temp.day, temp.hour, temp.min, temp.s)
	if self.rest_time ~= nil then
		self.rest_time:SetValue(str)
	end
end

function DailyActiveReward:GetNumberOfCells()
	local opengameday = TimeCtrl.Instance:GetCurOpenServerDay()
	return #KaifuActivityData.Instance:GetDayActiveDegreeInfoList(opengameday)
end

function DailyActiveReward:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = DailyActiveRewardCell.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end
	local opengameday = TimeCtrl.Instance:GetCurOpenServerDay()
	local reward_list, coset_list = KaifuActivityData.Instance:GetDayActiveDegreeInfoList(opengameday)
	cell_index = cell_index + 1
	contain_cell:SetNeedActive(coset_list[cell_index])
	contain_cell:SetCurrentActive(self.current_active)
	contain_cell:SetData(reward_list[cell_index])
end

function DailyActiveReward:SetCurTyoe(cur_type)
	self.cur_type = cur_type
end

function DailyActiveReward:OnFlush()
	if self.list_view then
		self.list_view.scroller:ReloadData(0)
	end
end

function DailyActiveReward:ClickGetActivity()
	KaifuActivityCtrl.Instance.view:Close()
	ViewManager.Instance:Open(ViewName.BaoJu)
end

----------------------------DailyActiveRewardCell---------------------------------
DailyActiveRewardCell = DailyActiveRewardCell or BaseClass(BaseCell)

function DailyActiveRewardCell:__init()
	self.reward_data = {}
	self.item_cell_obj_list = {}
	self.item_cell_list = {}
	self.item_state_list = {}
	for i = 1, 4 do
		self.item_state_list[i] = self:FindVariable("is_show_"..i)
		self.item_state_list[i]:SetValue(true)
		self.item_cell_obj_list[i] = self:FindObj("item_"..i)
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetInstanceParent(self.item_cell_obj_list[i])
	end

	self:ListenEvent("OnClickGet", BindTool.Bind(self.OnClickGet, self))
	self.tips = self:FindVariable("tips")
	self.is_take = self:FindVariable("is_take")
	self.is_able_get = self:FindVariable("is_able_get")
end

function DailyActiveRewardCell:__delete()
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}

	self.item_cell_obj_list = nil
	self.item_state_list = nil
	self.tips = nil
end

function DailyActiveRewardCell:SetNeedActive(need_active)
	self.need_active = need_active
end

function DailyActiveRewardCell:SetCurrentActive(current_active)
	self.current_active = current_active
end

function DailyActiveRewardCell:OnFlush()
	self.fetch_reward_flag =  KaifuActivityData.Instance:GetFetchRewardFlag()
	local reward_list = ItemData.Instance:GetItemConfig(self.data.reward_item.item_id)
	local reward_item_list = {}
	for i = 1, 4 do
		--self.item_state_list[i]:SetValue(true)
		reward_item_list[i] = {
		item_id = reward_list["item_"..i.."_id"],
		num = reward_list["item_"..i.."_num"],
		is_bind = reward_list["is_bind_"..i],}

		self.item_cell_list[i]:SetData(reward_item_list[i])

		if reward_item_list[i].item_id == 0 then
			self.item_state_list[i]:SetValue(false)
		end

	end
	local color = "ffffff"
	if self.need_active > self.current_active then
		color = "ffffff"
	end
	--是否能领取
	local str = string.format(Language.Activity.DayActiveRewardTips, self.need_active, color, self.current_active, self.need_active)
	self.tips:SetValue(str)
	--当前奖励等级 小于等于 已领取的奖励等级
	self.is_able_get:SetValue(self.current_active >= self.need_active)
	if self.data.data_index <= self.fetch_reward_flag then
		self.is_take:SetValue(true)
	else
		self.is_take:SetValue(false)
	end
end

function DailyActiveRewardCell:OnClickGet()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(
		RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_ACTIVIE_DEGREE,
		RA_DAY_ACTIVE_DEGREE_OPERA_TYPE.RA_DAY_ACTIVE_DEGREE_OPERA_TYPE_FETCH_REWARD, 
		self.data.data_index - 1 )
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_ACTIVIE_DEGREE, RA_DAY_ACTIVE_DEGREE_OPERA_TYPE.RA_DAY_ACTIVE_DEGREE_OPERA_TYPE_QUERY_INFO)
end