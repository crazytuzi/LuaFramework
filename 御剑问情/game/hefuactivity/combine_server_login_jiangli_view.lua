LoginjiangLiView =  LoginjiangLiView or BaseClass(BaseRender)

function LoginjiangLiView:__init()
	self.contain_cell_list = {}
end

function LoginjiangLiView:__delete()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
	end
	
	self.list_view = nil
	self.rest_time = nil
	self.contain_cell_list = nil
	self.login_day = nil
end

function LoginjiangLiView:OpenCallBack()
	HefuActivityCtrl.Instance:SendCSAQueryActivityInfo()
	HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_INVALID)

    self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	
	self.login_day = self:FindVariable("login_day")

	self.rest_time = self:FindVariable("rest_time")
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
	end
	local rest_time = HefuActivityData.Instance:GetCombineActTimeLeft(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_LOGIN_Gift)
	self:SetTime(rest_time)
	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
			rest_time = rest_time - 1
            self:SetTime(rest_time)
        end)

	self.login_day:SetValue(string.format(Language.HefuActivity.LoginDay,HefuActivityData.Instance:GetLoginDay()))
end

function LoginjiangLiView:CloseCallBack()
	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end
end

function LoginjiangLiView:OnFlush()
	if self.list_view then
		self.list_view.scroller:ReloadData(0)
	end
	self.login_day:SetValue(string.format(Language.HefuActivity.LoginDay,HefuActivityData.Instance:GetLoginDay()))
end

function LoginjiangLiView:SetTime(rest_time)
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

function LoginjiangLiView:GetNumberOfCells()
	return 3
end

function LoginjiangLiView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = LoginjiangLiViewCell.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end

	cell_index = cell_index + 1
	local data = HefuActivityData.Instance:GetLoginGiftCfgByDay(HefuActivityData.Instance:GetLoginDay())
	if not data then
		return
	end
	contain_cell:SetIndex(cell_index)
	contain_cell:SetData(data)
	contain_cell:Flush()
end

----------------------------LoginjiangLiViewCell---------------------------------
LoginjiangLiViewCell = LoginjiangLiViewCell or BaseClass(BaseCell)

function LoginjiangLiViewCell:__init()
	self.show_interactable = self:FindVariable("show_interactable")
	self.total_consume_tip = self:FindVariable("total_consume_tip")
	self.can_lingqu = self:FindVariable("can_lingqu")
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

function LoginjiangLiViewCell:__delete()
	self.show_interactable = nil
	self.total_consume_tip = nil
	self.can_lingqu = nil
	self.item_cell_obj_list = {}
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}
end

function LoginjiangLiViewCell:SetData(data)
	self.data = data
end

function LoginjiangLiViewCell:SetIndex(index)
	self.index = index
end

function LoginjiangLiViewCell:OnFlush()
	if self.data == nil then return end
	if self.index ~= 3 then
		self.total_consume_tip:SetValue(Language.HefuActivity.LoginReward[self.index])
	else
		self.total_consume_tip:SetValue(string.format(Language.HefuActivity.LoginReward[self.index],self.data.need_accumulate_days))
	end

	local item_list = ItemData.Instance:GetGiftItemList(self.data.data_list[self.index].item_id)
	if #item_list == 0 then
		item_list[1] = self.data.data_list[self.index]
	end
	
	for i = 1, 4 do
		if item_list[i] then
			self.item_cell_list[i]:SetData(item_list[i])
			self.item_cell_obj_list[i]:SetActive(true)
		else
			self.item_cell_obj_list[i]:SetActive(false)
		end
	end
	
	self.show_interactable:SetValue(self.data.flag[self.index])
	self.can_lingqu:SetValue(self.data.flag[self.index])


end

function LoginjiangLiViewCell:OnClickGet()
	if self.index == 1 then
		HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_LOGIN_Gift, CSA_LOGIN_GIFT_OPERA.CSA_LOGIN_GIFT_OPERA_FETCH_COMMON_REWARD, self.data.seq)
	elseif self.index == 2 then
		HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_LOGIN_Gift, CSA_LOGIN_GIFT_OPERA.CSA_LOGIN_GIFT_OPERA_FETCH_VIP_REWARD, self.data.seq)
	elseif self.index == 3 then
		HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_LOGIN_Gift, CSA_LOGIN_GIFT_OPERA.CSA_LOGIN_GIFT_OPERA_FETCH_ACCUMULATE_REWARD, self.data.seq)
	end
end