CombineServerLoginJiangLiView =  CombineServerLoginJiangLiView or BaseClass(BaseRender)

LOGIN_GIFT_OF_HEFU_OPERA = {
	CSA_LOGIN_GIFT_OPERA_FETCH_COMMON_REWARD = 0,
	CSA_LOGIN_GIFT_OPERA_FETCH_VIP_REWARD = 1,
	CSA_LOGIN_GIFT_OPERA_FETCH_ACCUMULATE_REWARD = 2,
	CSA_LOGIN_GIFT_OPERA_MAX = 3,
}

function CombineServerLoginJiangLiView:__init()
	self.contain_cell_list = {}
end

function CombineServerLoginJiangLiView:__delete()
	self.list_view = nil
	self.login_day = nil
	self.rest_time = nil
	self.act_rest_time_text = nil

	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end

	for k,v in pairs(self.contain_cell_list) do
		v:DeleteMe()
	end
	self.contain_cell_list = {}
end

function CombineServerLoginJiangLiView:LoadCallBack()
	HefuActivityCtrl.Instance:SendCSAQueryActivityInfo()
	HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_INVALID)

    self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	
	self.login_day = self:FindVariable("login_day")
	self:FlushLoginDayText()

	self.rest_time = self:FindVariable("rest_time")
	self.act_rest_time_text = self:FindVariable("act_rest_time_text")
end

function CombineServerLoginJiangLiView:OpenCallBack()
	if nil == self.least_time_timer then
		local rest_time = HefuActivityData.Instance:GetCombineActTimeLeft(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_LOGIN_Gift)
		self:SetTime(rest_time)
		self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
				rest_time = rest_time - 1
	            self:SetTime(rest_time)
	        end)
	end
end

--大view 强行调用
function CombineServerLoginJiangLiView:CloseCallBack()	
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
end

function CombineServerLoginJiangLiView:SetCurTyoe(cur_type)
	self.cur_type = cur_type
end

function CombineServerLoginJiangLiView:OnFlush()
	if self.list_view then
		self.list_view.scroller:ReloadData(0)
	end
	self.act_rest_time_text:SetValue(string.format(Language.HefuActivity.ActivityRestTime))
	self:FlushLoginDayText()	
end

function CombineServerLoginJiangLiView:FlushLoginDayText()
	local day = tostring(HefuActivityData.Instance:GetLoginDay())
	if nil ~= self.login_day then
		self.login_day:SetValue(string.format(Language.HefuActivity.LoginDay,day))
	end
end

function CombineServerLoginJiangLiView:SetTime(rest_time)
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

function CombineServerLoginJiangLiView:GetNumberOfCells()
	return 3
end

function CombineServerLoginJiangLiView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = LoginjiangLiViewCell.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end

	cell_index = cell_index + 1
	local data = HefuActivityData.Instance:GetLoginGiftCfg()
	contain_cell:SetData(data)
	contain_cell:SetIndex(cell_index)
	contain_cell:Flush()
end

----------------------------LoginjiangLiViewCell---------------------------------
LoginjiangLiViewCell = LoginjiangLiViewCell or BaseClass(BaseCell)

function LoginjiangLiViewCell:__init()
	self.item_cell_obj_list = {}
	self.item_cell_list = {}

	self.whole_item_list = {}
	self.reward_item_list = {}
	self.item_state_list = {}

	for i = 1, 4 do
		self.reward_item_list[i] = self:FindObj("item_"..i)
		self.item_state_list[i] = self:FindVariable("is_show_"..i)
		self.item_state_list[i]:SetValue(true)
		self.whole_item_list[i] = ItemCell.New()
		self.whole_item_list[i]:SetInstanceParent(self.reward_item_list[i])
	end

	self.tips = self:FindVariable("tips")
	self.is_show = self:FindVariable("is_show")
	self.btn_text = self:FindVariable("btn_text")
	self:ListenEvent("OnClickGet", BindTool.Bind(self.OnClickGet, self))
end

function LoginjiangLiViewCell:__delete()
	for k,v in pairs(self.whole_item_list) do
		v:DeleteMe()
	end
	self.whole_item_list = {}
	self.item_state_list = {}
	self.reward_item_list = {}
end

function LoginjiangLiViewCell:SetData(data)
	self.data = data
end

function LoginjiangLiViewCell:SetIndex(index)
	self.index = index
end

function LoginjiangLiViewCell:OnFlush()
	if self.data == nil then return end
	--根据id获取礼包列表
	local item_list = ItemData.Instance:GetGiftItemList(self.data.data_list[self.index].item_id)
	if #item_list == 0 then
		item_list[1] = self.data.data_list[self.index]
	end
	for i = 1, 4 do
		if item_list[i] then
			self.whole_item_list[i]:SetData(item_list[i])
		else
			self.item_state_list[i]:SetValue(false)
		end
	end
	self:ShowTipsAndBtn()
end

function LoginjiangLiViewCell:ShowTipsAndBtn()
	if self.data == nil or self.index == nil then return end

	local flag = HefuActivityData.Instance:GetLoginRewardFlag(self.index)
	self.btn_text:SetValue(Language.HefuActivity.LoginRewardBtnText[flag])
	self.is_show:SetValue(flag == 1)

	if nil ~= self.tips then
		if self.index ~= 3 then
			self.tips:SetValue(Language.HefuActivity.LoginReward[self.index])
		else
			self.tips:SetValue(string.format(Language.HefuActivity.LoginReward[self.index],self.data.need_accumulate_days))
		end
	end
end

function LoginjiangLiViewCell:OnClickGet()
	if self.index == 1 then
		HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_LOGIN_Gift, 
			LOGIN_GIFT_OF_HEFU_OPERA.CSA_LOGIN_GIFT_OPERA_FETCH_COMMON_REWARD, self.data.seq)
	elseif self.index == 2 then
		HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_LOGIN_Gift, 
			LOGIN_GIFT_OF_HEFU_OPERA.CSA_LOGIN_GIFT_OPERA_FETCH_VIP_REWARD, self.data.seq)
	elseif self.index == 3 then
		HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_LOGIN_Gift, 
			LOGIN_GIFT_OF_HEFU_OPERA.CSA_LOGIN_GIFT_OPERA_FETCH_ACCUMULATE_REWARD, 0)
	end
end