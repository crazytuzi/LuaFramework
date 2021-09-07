SuperChargeFeedbackView = SuperChargeFeedbackView or BaseClass(BaseRender)

function SuperChargeFeedbackView:__init()
	self.contain_cell_list = {}
	self.reward_list = {}
end  

function SuperChargeFeedbackView:__delete()
	self.list_view = nil
	self.rest_time = nil
	
	if self.contain_cell_list then
		for k, v in pairs(self.contain_cell_list) do
			v:DeleteMe()
		end
		self.contain_cell_list = {}
	end

	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

end

function SuperChargeFeedbackView:LoadCallBack()
	-- self.rest_time = self:FindVariable("rest_time")
	self.list_view = self:FindObj("ListView")
	self.rest_hour = self:FindVariable("RestHour")
	self.rest_min = self:FindVariable("RestMin")
	self.rest_sec = self:FindVariable("RestSecond")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	local time_table = os.date('*t',TimeCtrl.Instance:GetServerTime())
	local cur_time = time_table.hour * 3600 + time_table.min * 60 + time_table.sec
	local reset_time_s = 24 * 3600 - cur_time
	self:SetRestTime(reset_time_s)
end

function SuperChargeFeedbackView:SetRestTime(diff_time)
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

function SuperChargeFeedbackView:OnFlush()
	self.reward_list = KaiFuChargeData.Instance:GetShieldSuperChargeRewards()
	if self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:ReloadData(0)
	end 
end

function SuperChargeFeedbackView:GetNumberOfCells()
	return #self.reward_list
end

function SuperChargeFeedbackView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = SuperChargeFeedbackViewCell.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end

	cell_index = cell_index + 1
	contain_cell:SetData(self.reward_list[cell_index])
end

----------------------------SuperChargeFeedbackViewCell---------------------------------
SuperChargeFeedbackViewCell = SuperChargeFeedbackViewCell or BaseClass(BaseCell)

function SuperChargeFeedbackViewCell:__init()
	self.show_gray = self:FindVariable("show_interactable")
	self.btn_text = self:FindVariable("btn_text")
	self.btn_des = self:FindVariable("btn_des")
	self.show_red = self:FindVariable("show_red")
	self.need_money = self:FindVariable("need_money")
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

function SuperChargeFeedbackViewCell:__delete()
	self.show_gray = nil
	self.btn_text = nil
	self.btn_des = nil
	self.show_red = nil
	self.need_money = nil
	self.item_cell_obj_list = {}
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}
end

function SuperChargeFeedbackViewCell:OnFlush()
	local gift = ItemData.Instance:GetGiftItemList(self.data.reward_item.item_id)
	local join = false
	for i = 1, #self.item_cell_list do
		if #gift == 0 and (not join) then
			self.item_cell_list[i]:SetData(self.data.reward_item)
			self.item_cell_obj_list[i]:SetActive(true)
			join = true
		elseif i <= #gift then
			self.item_cell_list[i]:SetData(gift[i])
			self.item_cell_obj_list[i]:SetActive(true)
		else
			self.item_cell_obj_list[i]:SetActive(false)
		end
	end

	self:FlushOther()
end

function SuperChargeFeedbackViewCell:FlushOther()
	local btn_text_type = Language.SuperChargeFeedback.charge
	local btn_status = true
	local show_remind = false
	local can_get_count = string.format(Language.SuperChargeFeedback.btn_des, self.data.remainder_times)

	if self.data.remainder_times <= 0 then
		btn_status = false
		btn_text_type = Language.SuperChargeFeedback.get_later
	elseif self.data.run_out_flag == 0 then
		btn_text_type = Language.SuperChargeFeedback.can_get
		show_remind = true
	end

	self.show_gray:SetValue(btn_status)
	self.btn_text:SetValue(btn_text_type)
	self.btn_des:SetValue(can_get_count)
	self.show_red:SetValue(show_remind)
	self.need_money:SetValue(self.data.charge_count)
end

function SuperChargeFeedbackViewCell:OnClickGet()
	if self.data.remainder_times > 0 and self.data.run_out_flag == 0 then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SUPER_CARGE_FEEDBACK, RA_SUPER_CHARGE_FEEDBACK.RA_SINGLE_CHARGE_PRIZE_OPERA_TYPE_FETCH_REWARD, self.data.index)
	elseif self.data.remainder_times > 0 and self.data.run_out_flag == 1 then
		ViewManager.Instance:Open(ViewName.RechargeView)
		ViewManager.Instance:Close(ViewName.KaiFuChargeView)
	end
end 