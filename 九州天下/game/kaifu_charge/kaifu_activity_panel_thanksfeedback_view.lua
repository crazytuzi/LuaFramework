-- 感恩回馈活动
KaifuActivityPanelThanksFeedBack = KaifuActivityPanelThanksFeedBack or BaseClass(BaseRender)

local PAGE_ROW = 1					--行
local PAGE_COLUMN = 3				--列

function KaifuActivityPanelThanksFeedBack:__init()
	self.listview_cfg = {}
end

function KaifuActivityPanelThanksFeedBack:__delete()
end

function KaifuActivityPanelThanksFeedBack:LoadCallBack()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_APPRECIATION_REWARD,
													RA_APPRECIATION_REWARD_OPERA_TYPE.RA_APPRECIATION_REWARD_OPERA_TYPE_ALL_INFO)
	self.rest_time = self:FindVariable("rest_time")
	self.chongzhi_count = self:FindVariable("chongzhi_count")
	self.listview_cfg = KaifuActivityData.Instance:GetCurThaksConfig()
	local page = KaifuActivityData.Instance:GetThanksFeedBackPageCount(PAGE_COLUMN)
	self.page_num = self:FindVariable("PageNum")
	self.contain_cell_list = self:FindObj("ListView")
	self.toggle_1 = self:FindObj("Toggle1")
	self.page_num:SetValue(page)
	self.contain_cell_list.list_page_scroll:SetPageCount(page)
	self.toggle_1.toggle.isOn = true
	local contain_cell_list_delegate = self.contain_cell_list.list_simple_delegate
	contain_cell_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetCellNumber, self)
	contain_cell_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshDel, self)
	local rest_time = ActivityData.Instance:GetActivityResidueTime(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_APPRECIATION_REWARD)
	local opengameday = TimeCtrl.Instance:GetCurOpenServerDay()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
	end
	self:SetTime(rest_time)
	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
			rest_time = rest_time - 1
            self:SetTime(rest_time)
        end)
end

function KaifuActivityPanelThanksFeedBack:GetCellNumber()
	return KaifuActivityData.Instance:GetThanksFeedBackPageCount(PAGE_COLUMN)
end

function KaifuActivityPanelThanksFeedBack:RefreshDel(cell, data_index)
	local fetch_group_cell = self.contain_cell_list[cell]
	if not fetch_group_cell then
		fetch_group_cell = ThanksFeedBackItem.New(cell.gameObject)
		self.contain_cell_list[cell] = fetch_group_cell
	end
	self.listview_cfg = KaifuActivityData.Instance:GetThanksSortCfg()
	for i = 1, PAGE_COLUMN do
		local index = data_index * PAGE_COLUMN + i
		if next(self.listview_cfg) and self.listview_cfg[index] then
			local cfg = self.listview_cfg[index]
			local sort_index = self.listview_cfg[index].index
			if cfg then
				local state = KaifuActivityData.Instance:GetThanksFeedBackActive(sort_index)
				fetch_group_cell:SetActive(i, true)
				fetch_group_cell:SetData(i, cfg)
				fetch_group_cell:SetIndex(i, sort_index)
				fetch_group_cell:SetState(i,state)
			else
				fetch_group_cell:SetActive(i, false)
			end
		end
	end
end

function KaifuActivityPanelThanksFeedBack:CloseCallBack()
	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end
end

function KaifuActivityPanelThanksFeedBack:SetTime(rest_time)
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
	local str = string.format(Language.Activity.DanBiChongZhiRestTime, temp.day, temp.hour, temp.min)
	self.rest_time:SetValue(str)
end

function KaifuActivityPanelThanksFeedBack:OnFlush()
	if self.chongzhi_count then
		self.chongzhi_count:SetValue(KaifuActivityData.Instance:GetThanksFeedBackChongZhiCount())
	end

	if self.contain_cell_list.scroller.isActiveAndEnabled then
		self.contain_cell_list.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

---------------------------------------------------------------------------------------------------------
ThanksFeedBackItem = ThanksFeedBackItem or BaseClass(BaseRender)

function ThanksFeedBackItem:__init()
	self.reward_list = {}
	for i=1, PAGE_COLUMN do
		local reward_item = ThanksFeedBackItemCell.New(self:FindObj("ThanksFeedBackItem" .. i))
		table.insert(self.reward_list, reward_item)
	end
end

function ThanksFeedBackItem:__delete()
	for k, v in ipairs(self.reward_list) do
		v:DeleteMe()
	end
	self.reward_list = {}
end

function ThanksFeedBackItem:SetActive(i, enable)
	if self.reward_list[i] then
		self.reward_list[i]:SetActive(enable)
	end
end

function ThanksFeedBackItem:SetData(i, data)
	if self.reward_list[i] then
		self.reward_list[i]:SetData(data)
	end
end

function ThanksFeedBackItem:SetState(i, state)
	if self.reward_list[i] then
		self.reward_list[i]:SetState(state)
	end
end

function ThanksFeedBackItem:SetIndex(i,index)
	if self.reward_list[i] then
		self.reward_list[i]:SetIndex(index)
	end
end

----------------------------------------------------------------------------------------------------
ThanksFeedBackItemCell = ThanksFeedBackItemCell or BaseClass(BaseRender)

function ThanksFeedBackItemCell:__init()
	self.data = {}

	self.fanli_num = self:FindVariable("fanli_num")
	self.fanli_min = self:FindVariable("fanli_min")
	self.fanli_max = self:FindVariable("fanli_max")
	self.fetch_num = self:FindVariable("fetch_num")
	self.fetch_time = self:FindVariable("fetch_time")
	self.can_fetch = self:FindVariable("can_fetch")
	self.btn_fetch = self:FindObj("btn_fetch")
	self.gold = self:FindObj("gold")
	self.btn_recharge = self:FindObj("btn_recharge")
	self.btn_fetch = self:FindObj("btn_fetch")
	self.data_index = 0
	self.state = 2

	self:ListenEvent("ClickReChange", BindTool.Bind(self.ClickReChange, self))
	self:ListenEvent("ClickFetch", BindTool.Bind(self.ClickFetch, self))
end

function ThanksFeedBackItemCell:__delete()
	self.data = nil
end

function ThanksFeedBackItemCell:SetData(data)
	if not data or not next(data) then return end
	self.data = data
	self:Flush()
end

function ThanksFeedBackItemCell:SetIndex(index)
	if not index then return end
	self.data_index = index
end

function ThanksFeedBackItemCell:SetState(state)
	if state ~= nil then
		self.state = state
	end
end

function ThanksFeedBackItemCell:FlushState()
	if self.state == nil or self.gold == nil or self.btn_fetch == nil or self.btn_recharge == nil then return end
	if self.state == THANKS_FEED_BACK_BUTTON_STATE.CAN_FETCH then
		self.gold:SetActive(false)
		self.btn_recharge:SetActive(false)
		self.btn_fetch:SetActive(true)
	elseif self.state == THANKS_FEED_BACK_BUTTON_STATE.CAN_NOT_FETCH then
		self.gold:SetActive(false)
		self.btn_recharge:SetActive(true)
		self.btn_fetch:SetActive(false)
	elseif self.state == THANKS_FEED_BACK_BUTTON_STATE.HAS_FETCH then
		self.gold:SetActive(true)
		self.btn_recharge:SetActive(false)
		self.btn_fetch:SetActive(false)
	end
end

function ThanksFeedBackItemCell:OnFlush()
	if not self.data or not next(self.data) then return end
	if self.fanli_num ~= nil then
		self.fanli_num:SetValue(self.data.reward_percent or 0)
	end
	if self.fanli_min ~= nil then
		self.fanli_min:SetValue(self.data.charge_lower or 0)
	end
	if self.fanli_max ~= nil then
		self.fanli_max:SetValue(self.data.charge_upper or 1)
	end
	if self.fetch_time ~= nil then
		self.fetch_time:SetValue(KaifuActivityData.Instance:GetThanksFeedBackCurLimitTimeByIndex(self.data_index) or 1)
	end
	if self.can_fetch ~= nil then
		self.can_fetch:SetValue(KaifuActivityData.Instance:GetThanksIsUsedByIndex(self.data_index))
	end
	local fetch_num = KaifuActivityData.Instance:GetThanksFeedBackDataByIndex(self.data_index + 1) or 0
	if self.fetch_num ~= nil then
		self.fetch_num:SetValue(fetch_num)
	end
	self:FlushState()
end

function ThanksFeedBackItemCell:ClickReChange()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function ThanksFeedBackItemCell:ClickFetch()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_APPRECIATION_REWARD,
													RA_APPRECIATION_REWARD_OPERA_TYPE.RA_APPRECIATION_REWARD_OPERA_TYPE_FETCH,self.data_index)
end
