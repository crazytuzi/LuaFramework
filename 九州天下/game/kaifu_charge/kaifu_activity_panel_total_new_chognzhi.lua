OpenNewTotalChongZhi = OpenNewTotalChongZhi or BaseClass(BaseRender)

function OpenNewTotalChongZhi:__init()
	self.contain_cell_list = {}
end  

function OpenNewTotalChongZhi:__delete()
	self.list_view = nil
	self.rest_time = nil
	
	if self.contain_cell_list then
		for k, v in pairs(self.contain_cell_list) do
			v:DeleteMe()
		end
		self.contain_cell_list = {}
	end

	self.cur_type = nil
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
	end
end

function OpenNewTotalChongZhi:LoadCallBack()
	self.rest_hour = self:FindVariable("RestHour")
	self.rest_min = self:FindVariable("RestMin")
	self.rest_sec = self:FindVariable("RestSecond")
	self:OpenCallBack()
end

function OpenNewTotalChongZhi:SetRestTime(diff_time)
	if self.count_down == nil then
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
				return
			end
			local left_hour = math.floor(left_time / 3600)
			local left_min = math.floor((left_time - left_hour * 3600) / 60)
			local left_sec = math.floor(left_time - left_hour * 3600 - left_min * 60)
			self.rest_hour:SetValue(left_hour)
			self.rest_min:SetValue(left_min)
			self.rest_sec:SetValue(left_sec)
		end

		diff_time_func(0, diff_time)
		self.count_down = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end
end

function OpenNewTotalChongZhi:OpenCallBack()
    self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.rest_time = self:FindVariable("rest_time")
	self.chongzhi_count = self:FindVariable("chongzhi_count")
	
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
	end
	local rest_time, next_time = ActivityData.Instance:GetActivityResidueTime(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAILY_TOTAL_CHONGZHI)
	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
			rest_time = rest_time - 1
		self:SetTime(rest_time)
		end)

	self:ListenEvent("ClickReChange", BindTool.Bind(self.ClickReChange, self))
	self:Flush()

	local time_table = os.date('*t',TimeCtrl.Instance:GetServerTime())
	local cur_time = time_table.hour * 3600 + time_table.min * 60 + time_table.sec
	local reset_time_s = 24 * 3600 - cur_time
	self:SetRestTime(reset_time_s)
end

function OpenNewTotalChongZhi:CloseCallBack()
	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end
end

function OpenNewTotalChongZhi:ClickReChange()
	ViewManager.Instance:Open(ViewName.RechargeView)
end

function OpenNewTotalChongZhi:OnFlush()
	self.reward_list = KaiFuChargeData.Instance:GetOpenNewTotalChongZhiReward()
	if self.list_view then
		self.list_view.scroller:ReloadData(0)
	end
	local info = KaiFuChargeData.Instance:GetNewTotalChongZhiInfo()
	if self.chongzhi_count then
		self.chongzhi_count:SetValue(info.chongzhi_num or 0)
	end
end

function OpenNewTotalChongZhi:FlushTotalConsume()
	self:Flush()
end

function OpenNewTotalChongZhi:SetTime(rest_time)
	local time_tab = TimeUtil.Format2TableDHMS(rest_time)
	local str = ""
	if time_tab.day > 0 then
		str = TimeUtil.FormatSecond2DHMS(rest_time, 1)
	else
		str = TimeUtil.FormatSecond(rest_time)
	end
	self.rest_time:SetValue(str)
end

function OpenNewTotalChongZhi:GetNumberOfCells()
	if self.reward_list then
		return #self.reward_list or 0
	end
	return 0
end

function OpenNewTotalChongZhi:SetCurTyoe(cur_type)
	self.cur_type = cur_type
end

function OpenNewTotalChongZhi:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = OpenNewTotalChongZhiCell.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end

	cell_index = cell_index + 1
	contain_cell:SetData(self.reward_list[cell_index])
	contain_cell:Flush()
end

----------------------------OpenNewTotalChongZhiCell---------------------------------
OpenNewTotalChongZhiCell = OpenNewTotalChongZhiCell or BaseClass(BaseCell)

function OpenNewTotalChongZhiCell:__init()
	self.data = {}
	self.total_value = self:FindVariable("total_value")
	self.cur_value = self:FindVariable("cur_value")
	self.show_interactable = self:FindVariable("show_interactable")
	self.show_text = self:FindVariable("show_text")
	self.total_consume_tip = self:FindVariable("total_consume_tip")
	self.can_lingqu = self:FindVariable("can_lingqu")
	self.show_red = self:FindVariable("show_red")
	self.color = self:FindVariable("color")
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

function OpenNewTotalChongZhiCell:__delete()
	self.total_value = nil
	self.cur_value = nil
	self.show_text = nil
	self.show_interactable = nil
	self.total_consume_tip = nil
	self.can_lingqu = nil
	self.color = nil
	self.item_cell_obj_list = {}
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}
end

function OpenNewTotalChongZhiCell:SetData(data)
	self.data = data
end

function OpenNewTotalChongZhiCell:OnFlush()
	--local info = KaifuActivityData.Instance:GetRATotalChongZhiGoldInfo()
	local info = KaiFuChargeData.Instance:GetNewTotalChongZhiInfo()
	local cur_value = info.need_chongzhi or 0
	local color = cur_value >= self.data.need_chongzhi and COLOR.GREEN or COLOR.RED
	self.color:SetValue(color)
	self.total_value:SetValue(self.data.need_chongzhi)
	self.cur_value:SetValue(cur_value)
	self.total_consume_tip:SetValue(string.format(Language.Activity.TotalChongZhiTip, self.data.need_chongzhi))
	local reward_list = ServerActivityData.Instance:GetCurrentRandActivityRewardCfg(self.data.reward_item, true)

	for i = 1, 4 do
		if reward_list[i] then
			self.item_cell_list[i]:SetData(reward_list[i])
			self.item_cell_obj_list[i]:SetActive(true)
		else
			self.item_cell_obj_list[i]:SetActive(false)
		end
	end

	local reward_new_fetch_flag = self.data.reward_new_fetch_flag == 1
	local str = reward_new_fetch_flag and Language.Common.YiLingQu or (cur_value >= self.data.need_chongzhi and Language.Common.LingQu or Language.Common.WEIDACHENG)
	self.show_text:SetValue(str)
	self.show_interactable:SetValue(not reward_new_fetch_flag)
	--self.can_lingqu:SetValue(not reward_new_fetch_flag and cur_value >= self.data.need_chongzhi)
	self.can_lingqu:SetValue(reward_new_fetch_flag)

	local red_flag = false
	if info ~= nil and info.chongzhi_num ~= nil and self.data.need_chongzhi ~= nil then
		red_flag = info.chongzhi_num >= self.data.need_chongzhi
	end
	self.show_red:SetValue(not reward_new_fetch_flag and red_flag)

end

function OpenNewTotalChongZhiCell:OnClickGet()
	local info = KaiFuChargeData.Instance:GetNewTotalChongZhiInfo()
	local cur_value = info.chongzhi_num or 0
	if cur_value >= self.data.need_chongzhi then
		KaifuActivityCtrl.Instance:SendRandActivityOperaReq(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAILY_TOTAL_CHONGZHI, RA_DAILY_TOTAL_CHONGZHI_OPERA_TYPE.RA_DAILY_TOTAL_CHONGZHI_OPERA_TYPE_FETCH_REWARD, self.data.seq)
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Activity.NewTotalChongZhiTip)
	end
end