CombineServerChongzhiTotal = CombineServerChongzhiTotal or BaseClass(BaseRender)

function CombineServerChongzhiTotal:__init()
	self.contain_cell_list = {}
end

function CombineServerChongzhiTotal:__delete()
	self.list_view = nil
	self.rest_time = nil

	if self.contain_cell_list then
		for k,v in pairs(self.contain_cell_list) do
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

function CombineServerChongzhiTotal:OpenCallBack()
	if nil == self.least_time_timer then
		local rest_time = HefuActivityData.Instance:GetCombineActTimeLeft(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CAS_SUB_TYPE_TIANTIANFANLI)
		self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
				rest_time = rest_time - 1
			self:SetTime(rest_time)
			end)
	end
end

function CombineServerChongzhiTotal:CloseCallBack()
	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end
end

function CombineServerChongzhiTotal:LoadCallBack()
	HefuActivityCtrl.Instance:SendCSAQueryActivityInfo()
	HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_INVALID)

    self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.rest_time = self:FindVariable("rest_time")
	self.chongzhi_count = self:FindVariable("chongzhi_count")
	self:ListenEvent("ClickReChange", BindTool.Bind(self.ClickReChange, self))
	self:Flush()
end

function CombineServerChongzhiTotal:ClickReChange()
	ViewManager.Instance:Open(ViewName.RechargeView)
end

function CombineServerChongzhiTotal:OnFlush()
	self.reward_list = HefuActivityData.Instance:GetCombineServerTotalConfig()
	if self.list_view then
		self.list_view.scroller:ReloadData(0)
	end
	local chongzhi_total = HefuActivityData.Instance:GetCombineServerTotalChongzhi()
	if self.chongzhi_count then
		self.chongzhi_count:SetValue(chongzhi_total or 0)
	end
end

function CombineServerChongzhiTotal:FlushTotalConsume()
	self:Flush()
end

function CombineServerChongzhiTotal:SetTime(rest_time)

	local time_tab = TimeUtil.Format2TableDHMS(rest_time)
	local str = ""
	if time_tab.day > 0 then
		str = TimeUtil.FormatSecond2DHMS(rest_time, 1)
	else
		str = TimeUtil.FormatSecond(rest_time)
	end

	if self.rest_time then
		self.rest_time:SetValue(str)
	end
end

function CombineServerChongzhiTotal:GetNumberOfCells()
	return #self.reward_list or 0
end

function CombineServerChongzhiTotal:SetCurTyoe(cur_type)
	self.cur_type = cur_type
end

function CombineServerChongzhiTotal:RefreshCell(cell, cell_index)
	local reward_flag = HefuActivityData.Instance:GetCombineServerTotalFlag()

	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = CombineServerChongzhiTotalCell.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end

	cell_index = cell_index + 1
	contain_cell:SetData(self.reward_list[cell_index], reward_flag[cell_index])
	contain_cell:Flush()
end

----------------------------CombineServerChongzhiTotalCell---------------------------------
CombineServerChongzhiTotalCell = CombineServerChongzhiTotalCell or BaseClass(BaseCell)

function CombineServerChongzhiTotalCell:__init()
	self.data = {}
	self.total_value = self:FindVariable("total_value")
	self.cur_value = self:FindVariable("cur_value")
	self.show_interactable = self:FindVariable("show_interactable")
	self.show_text = self:FindVariable("show_text")
	self.total_consume_tip = self:FindVariable("total_consume_tip")
	self.can_lingqu = self:FindVariable("can_lingqu")
	self.show_red = self:FindVariable("show_red")
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

function CombineServerChongzhiTotalCell:__delete()
	self.total_value = nil
	self.cur_value = nil
	self.show_text = nil
	self.show_interactable = nil
	self.total_consume_tip = nil
	self.can_lingqu = nil
	self.show_red = nil
	self.item_cell_obj_list = {}
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end

	self.item_cell_list = {}
	self.data = {}
end

function CombineServerChongzhiTotalCell:SetData(data, flag)
	self.data = data
	self.reward_flag = flag
end

function CombineServerChongzhiTotalCell:OnFlush()
	local chongzhi_total = HefuActivityData.Instance:GetCombineServerTotalChongzhi()
	local reward_list = self.data.reward_item
	local days = self.data.combine_days + 1
	local now_day = HefuActivityData.Instance:GetCombineDays() + 1
	local gifts = ItemData.Instance:GetGiftItemList(reward_list.item_id)
	for i,v in ipairs(self.item_cell_list) do
		if i == 0 then
			self.item_cell_list[i]:SetData(reward_list)
			self.item_cell_obj_list[i]:SetActive(true)
		elseif i <= #gifts then
			self.item_cell_list[i]:SetData(gifts[i])
			self.item_cell_obj_list[i]:SetActive(true)
		else
			self.item_cell_obj_list[i]:SetActive(false)
		end
	end

	self.total_consume_tip:SetValue(string.format(Language.Activity.HefuTotalChongZhiTip, days, self.data.need_chongzhi_gold_num))

	if self.reward_flag then
		local str = Language.Common.LingQu
		self.show_text:SetValue(str)
	else
		local str = Language.Common.YiLingQu
		self.show_text:SetValue(str)
	end

	if self.reward_flag and (now_day == days) then
		self.show_red:SetValue(chongzhi_total >= self.data.need_chongzhi_gold_num)
		self.show_interactable:SetValue(true)
		self.can_lingqu:SetValue(false)
	else
		self.show_interactable:SetValue(false)
		self.can_lingqu:SetValue(true)
	end
end

function CombineServerChongzhiTotalCell:OnClickGet()
	HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CAS_SUB_TYPE_TIANTIANFANLI)
end