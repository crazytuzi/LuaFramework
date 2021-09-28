ActivityPanelLogicRewardView =  ActivityPanelLogicRewardView or BaseClass(BaseRender)

function ActivityPanelLogicRewardView:__init()
	self.contain_cell_list = {}
end

function ActivityPanelLogicRewardView:__delete()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
	end
	
	self.list_view = nil
	self.contain_cell_list = nil
	self.login_day = nil
end

function ActivityPanelLogicRewardView:OpenCallBack()
	--奖励列表
    self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	--登录天数
	self.login_day = self:FindVariable("login_day")
	self.login_day:SetValue(string.format(Language.HefuActivity.LoginDay, ActivityPanelLoginRewardData.Instance:GetCurLoginDays(self.act_id)))

	--活动剩余时间
	self.rest_time = self:FindVariable("rest_time")
	local end_time = ActivityOnLineData.Instance:GetRestTime(self.act_id)
	end_time = end_time - TimeCtrl.Instance:GetServerTime() 
	self:SetTime(end_time)
	self.least_time_timer = CountDown.Instance:AddCountDown(end_time, 1, function ()
			end_time = end_time - 1
            self:SetTime(end_time)
        end)
end

function ActivityPanelLogicRewardView:CloseCallBack()
	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end
end

function ActivityPanelLogicRewardView:SetActId(act_id)
	self.act_id = act_id
end

function ActivityPanelLogicRewardView:OnFlush()
	if self.list_view then
		self.list_view.scroller:ReloadData(0)
	end
	self.login_day:SetValue(string.format(Language.HefuActivity.LoginDay, ActivityPanelLoginRewardData.Instance:GetCurLoginDays(self.act_id)))
end

function ActivityPanelLogicRewardView:GetNumberOfCells()
	return ActivityPanelLoginRewardData.Instance:GetRewardNum(self.act_id)
end

function ActivityPanelLogicRewardView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = LogicRewardItemCell.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end

	cell_index = cell_index + 1
	local reward_cfg = ActivityPanelLoginRewardData.Instance:GetRewardCfg(self.act_id, cell_index)
	if not reward_cfg then
		return
	end

	local data = {}
	data.reward_item = reward_cfg.reward_item
	data.can_get = ActivityPanelLoginRewardData.Instance:CanGetReward(self.act_id, cell_index)
	data.is_overdue = ActivityPanelLoginRewardData.Instance:IsOverdue(self.act_id, cell_index)
	data.is_get = ActivityPanelLoginRewardData.Instance:IsGet(self.act_id, cell_index)
	data.seq = reward_cfg.seq
	data.need_login_days = reward_cfg.need_login_days
	data.act_id = self.act_id

	contain_cell:SetIndex(cell_index)
	contain_cell:SetData(data)
	contain_cell:Flush()
end

function ActivityPanelLogicRewardView:SetTime(rest_time)
	local time_str = ""
	local left_day = math.floor(rest_time / 86400)
	if left_day > 0 then
		time_str = TimeUtil.FormatSecond(rest_time, 8)
	else
		time_str = TimeUtil.FormatSecond(rest_time)
	end
	self.rest_time:SetValue(time_str)
end


----------------------------LogicRewardItemCell---------------------------------
LogicRewardItemCell = LogicRewardItemCell or BaseClass(BaseCell)

function LogicRewardItemCell:__init()
	self.show_interactable = self:FindVariable("show_interactable")
	self.total_consume_tip = self:FindVariable("total_consume_tip")
	self.can_lingqu = self:FindVariable("can_lingqu")
	self.is_overdue = self:FindVariable("is_overdue")
	self.is_get = self:FindVariable("is_get")
	self.item_cell_obj_list = {}
	self.item_cell_list = {}

	self:ListenEvent("OnClickGet", BindTool.Bind(self.OnClickGet, self))

	for i = 1, 4 do
		self.item_cell_obj_list[i] = self:FindObj("item_"..i)
		local item_cell = ItemCell.New()
		self.item_cell_list[i] = item_cell
		item_cell:SetInstanceParent(self.item_cell_obj_list[i])
	end
end

function LogicRewardItemCell:__delete()
	self.show_interactable = nil
	self.total_consume_tip = nil
	self.can_lingqu = nil
	self.item_cell_obj_list = {}
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}
end

function LogicRewardItemCell:SetData(data)
	self.data = data
end

function LogicRewardItemCell:SetIndex(index)
	self.index = index
end

function LogicRewardItemCell:OnFlush()
	if self.data == nil then return end
	self.total_consume_tip:SetValue(string.format(Language.LoginReward.RewardTips, self.data.need_login_days))
	local item_list = ItemData.Instance:GetGiftItemList(self.data.reward_item.item_id)
	if #item_list == 0 then
		item_list[1] = self.data.reward_item
	end
	for i = 1, 4 do
		if item_list[i] then
			self.item_cell_list[i]:SetData(item_list[i])
			self.item_cell_obj_list[i]:SetActive(true)
		else
			self.item_cell_obj_list[i]:SetActive(false)
		end
	end
	self.show_interactable:SetValue(self.data.can_get)
	self.can_lingqu:SetValue(self.data.can_get)
	self.is_overdue:SetValue(self.data.is_overdue)
	self.is_get:SetValue(self.data.is_get)
end

function LogicRewardItemCell:OnClickGet()
	ActivityPanelLoginRewardCtrl.Instance:SendGetReward(self.data.act_id, RA_LOGIN_GIFT_OPERA_TYPE.RA_LOGIN_GIFT_OPERA_TYPE_FETCH_COMMON_REWARD, self.data.seq)
end