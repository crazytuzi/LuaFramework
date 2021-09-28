DailyActiveReward =  DailyActiveReward or BaseClass(BaseRender)

function DailyActiveReward:__init()
	self.contain_cell_list = {}
end

function DailyActiveReward:__delete()

end

function DailyActiveReward:OpenCallBack()
    self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_ACTIVIE_DEGREE, 
	 		RA_DAY_ACTIVE_DEGREE_OPERA_TYPE.RA_DAY_ACTIVE_DEGREE_OPERA_TYPE_QUERY_INFO)
	local rest_time, next_time = ActivityData.Instance:GetActivityResidueTime(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_ACTIVIE_DEGREE)
	local opengameday = TimeCtrl.Instance:GetCurOpenServerDay()
	self.reward_list, self.coset_list = KaifuActivityData.Instance:GetDayActiveDegreeInfoList(opengameday)
	self.current_active = KaifuActivityData.Instance:GetCurrentActive()

	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end
	self.rest_time = self:FindVariable("rest_time")
	self:SetTime(rest_time)
	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
			rest_time = rest_time - 1
            self:SetTime(rest_time)
        end)

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
	self.rest_time:SetValue(str)
end

function DailyActiveReward:GetNumberOfCells()
	return #self.reward_list
end

function DailyActiveReward:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = DailyActiveRewardCell.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
		--contain_cell.view = self
	end
	cell_index = cell_index + 1
	contain_cell:SetItemData(self.reward_list[cell_index])
	contain_cell:SetNeedActive(self.reward_list[cell_index].need_active)
	contain_cell:SetCurrentActive(self.current_active)

	local index = 1
	for k,v in pairs(self.coset_list) do
		if self.reward_list[cell_index].need_active == self.coset_list[k] then
			index = k
			break
		end
	end
	contain_cell:SetCurrentRewardLevel(index)
	contain_cell:Flush()
end

function DailyActiveReward:OnFlush()
	self.reward_list, self.coset_list = KaifuActivityData.Instance:GetDayActiveDegreeInfoList(opengameday)

	if self.list_view then
		self.list_view.scroller:ReloadData(0)
	end
end

function DailyActiveReward:ClickGetActivity()
	KaifuActivityCtrl.Instance.view:Close()
	ViewManager.Instance:Open(ViewName.BaoJu,1)
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

function DailyActiveRewardCell:SetItemData(data)
	self.reward_data = data
end

function DailyActiveRewardCell:SetNeedActive(need_active)
	self.need_active = need_active
end

function DailyActiveRewardCell:SetCurrentActive(current_active)
	self.current_active = current_active
end

function DailyActiveRewardCell:OnFlush()
	self.fetch_reward_flag =  KaifuActivityData.Instance:GetFetchRewardFlag()
	local reward_list = ItemData.Instance:GetItemConfig(self.reward_data.item_id)
	local reward_item_list = {}
	for i = 1, 4 do
		self.item_state_list[i]:SetValue(true)
		reward_item_list[i] = {
		item_id = reward_list["item_"..i.."_id"],
		num = reward_list["item_"..i.."_num"],
		is_bind = reward_list["is_bind_"..i],}
		self.item_cell_list[i]:SetData(reward_item_list[i])
	end
	local color = "00ff00"
	if self.need_active > self.current_active then
		color = "ffffff"
	end
	--是否能领取
	local str
	if self.current_active >= self.need_active then
		str = string.format(Language.Activity.DayActiveRewardTips2, self.need_active, self.current_active, self.need_active)
	else
		str = string.format(Language.Activity.DayActiveRewardTips, self.need_active, self.current_active, self.need_active)
	end 
	self.tips:SetValue(str)
	--当前奖励等级 小于等于 已领取的奖励等级
	self.is_able_get:SetValue(self.current_active >= self.need_active)
	if self.reward_data.fetch == 1 then
		self.is_take:SetValue(true)
	else
		self.is_take:SetValue(false)
	end
	-- if self.current_reward_level <= self.fetch_reward_flag then
	-- 	self.is_take:SetValue(true)
	-- else
	-- 	self.is_take:SetValue(false)
	-- end
end

function DailyActiveRewardCell:SetCurrentRewardLevel(current_reward_level)
	self.current_reward_level = current_reward_level
end

function DailyActiveRewardCell:OnClickGet()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(
		RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_ACTIVIE_DEGREE,
		RA_DAY_ACTIVE_DEGREE_OPERA_TYPE.RA_DAY_ACTIVE_DEGREE_OPERA_TYPE_FETCH_REWARD, 
		self.current_reward_level-1)
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_ACTIVIE_DEGREE, RA_DAY_ACTIVE_DEGREE_OPERA_TYPE.RA_DAY_ACTIVE_DEGREE_OPERA_TYPE_QUERY_INFO)
end