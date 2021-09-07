HappyBargainPanelRebate = HappyBargainPanelRebate or BaseClass(BaseRender)

local RAND_ACTIVITY_REBATE_OPERATE = {
	REBATE_ACT_REQUEST_PROTOCOL = 0,
	REBATE_ACT_SEND_OPERATE = 1,
}

function HappyBargainPanelRebate:__init()
	self.contain_cell_list = {}
end

function HappyBargainPanelRebate:__delete()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end

	self.list_view = nil
	self.rest_time = nil
	self.draw_time = nil
	self.act_rest_time_text = nil
	self.draw_time_text = nil

	self.reward_list = nil
	self.contain_cell_list = {}
end

function HappyBargainPanelRebate:LoadCallBack()
	self.list_view = self:FindObj("ListView")
	self:SetRewardList()
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.rest_time = self:FindVariable("rest_time")
	self.act_rest_time_text = self:FindVariable("act_rest_time_text")
	self.draw_time = self:FindVariable("draw_time")
	self.draw_time_text = self:FindVariable("draw_time_text")

	self:ListenEvent("ClickToDraw", BindTool.Bind(self.ClickToDraw, self))
	
	local act_type = HappyBargainData.Instance:GetRebateActType()
	local act_type_str = Language.HappyBargain.RebateTypeText[act_type]
	self.act_rest_time_text:SetValue(Language.HappyBargain.RestTimeText)
	self.draw_time_text:SetValue(Language.HappyBargain.RebateTimesText)

	local stay_day = HappyBargainData.Instance:GetRebateActStayDay()
	local time_table = os.date('*t',TimeCtrl.Instance:GetServerTime())
	local cur_time = time_table.hour * 3600 + time_table.min * 60 + time_table.sec
	local rest_time = 24 * 3600 * stay_day - cur_time
	if nil == self.least_time_timer then
		self:SetTime(rest_time)
		self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
					rest_time = rest_time - 1
		            self:SetTime(rest_time)
		        end)
	end
	
	self:Flush()
end

local cur_day = 0
function HappyBargainPanelRebate:SetRewardList()
	local is_change = HappyBargainData.Instance:GetHappyBargainProtocolsIsChange()
	local server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if self.reward_list == nil then
		cur_day = server_day
		self.reward_list = HappyBargainData.Instance:GetRebateActCfgBySort()
	elseif is_change == true or cur_day ~= server_day then
		cur_day = server_day
		self.reward_list = HappyBargainData.Instance:GetRebateActCfgBySort()
		HappyBargainData.Instance:SetHappyBargainProtocolsIsChange(false)
	end
end

function HappyBargainPanelRebate:OnFlush()
	self:SetRewardList()
	if self.list_view then
		self.list_view.scroller:ReloadData(0)
	end
	self.draw_time:SetValue(HappyBargainData.Instance:GetRebateActDrawCount())
end

function HappyBargainPanelRebate:GetNumberOfCells()
	local _,num = HappyBargainData.Instance:GetRebateActCfgBySort()
	return num
end

function HappyBargainPanelRebate:RefreshCell(cell, cell_index)
	cell_index = cell_index + 1
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = RebateActivityItemCell.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end
	contain_cell:SetData(self.reward_list[cell_index])
end

function HappyBargainPanelRebate:SetTime(rest_time)
	local time_tab = TimeUtil.Format2TableDHMS(rest_time)
	local str = ""
	if time_tab.day > 0 then
		str = TimeUtil.FormatSecond2DHMS(rest_time, 1)
	else
		str = TimeUtil.FormatSecond(rest_time)
	end
	if self.rest_time ~= nil then
		self.rest_time:SetValue(str)
	end
end

function HappyBargainPanelRebate:ClickToDraw()
	local panel_list = HappyBargainData.Instance:GetDrawActPanel()
	if next(panel_list) == nil then return end
	ViewManager.Instance:Open(panel_list[1],TabIndex[panel_list[2]])
	ViewManager.Instance:Close(ViewName.HappyBargainView)
end

--------------------------RebateActivityItemCell-----------------------------
local ITEM_NUMBER = 4
RebateActivityItemCell = RebateActivityItemCell or BaseClass(BaseCell)

function RebateActivityItemCell:__init()
	self.item_cell_list = {}
	self.item_cell_obj_list = {}

	for i = 1, ITEM_NUMBER do
		self.item_cell_obj_list[i] = self:FindObj("item_"..i)
		local item_cell = ItemCell.New()
		self.item_cell_list[i] = item_cell
		item_cell:SetInstanceParent(self.item_cell_obj_list[i]) 
	end

	self.can_take = self:FindVariable("can_take")
	self.btn_text = self:FindVariable("btn_text")
	self.cumulative_text = self:FindVariable("cumulative_text")

	self:ListenEvent("OnClickGet", BindTool.Bind(self.OnClickGet, self))
end

function RebateActivityItemCell:__delete()
	self.can_take = nil
	self.btn_text = nil
	self.cumulative_text = nil

	self.item_cell_obj_list = {}

	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}
end

function RebateActivityItemCell:OnFlush()
	if nil == next(self.data) then return end
	--将礼包分解
	--local reward_list = ServerActivityData.Instance:GetCurrentRandActivityRewardCfg(self.data.reward_item, true)
	for i = 1, ITEM_NUMBER do
		if self.data.reward_item[i-1] then
			self.item_cell_list[i]:SetData(self.data.reward_item[i-1])
			self.item_cell_obj_list[i]:SetActive(true)
		else
			self.item_cell_obj_list[i]:SetActive(false)
		end
	end

	local flag = self.data.reward_has_fetch_flag
	self.btn_text:SetValue(Language.HappyBargain.RebateBtnText[flag])
	self.can_take:SetValue(flag == 0)

	local act_type = HappyBargainData.Instance:GetRebateActType()
	local act_type_str = Language.HappyBargain.RebateTypeText[act_type]
	self.cumulative_text:SetValue(string.format(Language.HappyBargain.RebateGoalText,act_type_str, self.data.require_hunting_count))
end

function RebateActivityItemCell:OnClickGet()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_REBATE_ACTIVITY,
			RAND_ACTIVITY_REBATE_OPERATE.REBATE_ACT_SEND_OPERATE, self.data.hunting_type, self.data.seq)
end

