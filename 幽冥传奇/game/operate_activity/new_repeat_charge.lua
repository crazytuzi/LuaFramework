-- 新重复充值界面
OperateActNewRepeatChargePage = OperateActNewRepeatChargePage or BaseClass()

function OperateActNewRepeatChargePage:__init()
	self.view = nil

end

function OperateActNewRepeatChargePage:__delete()
	self:RemoveEvent()
	if self.rest_count_numBar then
		self.rest_count_numBar:DeleteMe()
		self.rest_count_numBar = nil
	end

	if self.rest_count_numBar2 then
		self.rest_count_numBar2:DeleteMe()
		self.rest_count_numBar2 = nil
	end

	if self.show_items_list then
		self.show_items_list:DeleteMe()
		self.show_items_list = nil
	end

	self.view = nil
end



function OperateActNewRepeatChargePage:InitPage(view)
	self.view = view
	self:CreateNumBar()
	self:CreateShowItemsList()
	self:InitEvent()
	self:OnTimeLimitedGoodsEvt()
	self.view.node_t_list.rich_new_repeat_used_cnt.node:setHorizontalAlignment(RichHAlignment.HA_RIGHT)
	-- LimitedActivityCtrl.Instance:TimeLimitedGoodsDataReq()
end



function OperateActNewRepeatChargePage:InitEvent()
	self.evt_handle = GlobalEventSystem:Bind(OperateActivityEventType.NEW_REPEAT_CHARGE_DATA, BindTool.Bind(self.OnTimeLimitedGoodsEvt, self))
	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushRemainTime, self), 1)
end

function OperateActNewRepeatChargePage:RemoveEvent()
	if self.evt_handle then
		GlobalEventSystem:UnBind(self.evt_handle)
		self.evt_handle = nil
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end


function OperateActNewRepeatChargePage:UpdateData()
	
end

function OperateActNewRepeatChargePage:CreateShowItemsList()
	if not self.show_items_list then
		local ph = self.view.ph_list.ph_new_repeat_c_list
		self.show_items_list = ListView.New()
		self.show_items_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, OperateActNewRepeatChargeRender, gravity, is_bounce, self.view.ph_list.ph_new_repeat_c_item)
		local margin = 1
		local gap = (ph.w - 2 * margin - 3 * self.view.ph_list.ph_new_repeat_c_item.w) / 3
		self.show_items_list:SetItemsInterval(gap)
		self.show_items_list:SetMargin(margin)
		self.show_items_list:SetJumpDirection(ListView.Left)
		self.view.node_t_list.layout_new_repeat_charge.node:addChild(self.show_items_list:GetView(), 90)
	end	
end

function OperateActNewRepeatChargePage:CreateNumBar()
	if not self.rest_count_numBar then
		local ph = self.view.ph_list.ph_new_repeat_c_num_1
		self.rest_count_numBar = NumberBar.New()
		self.rest_count_numBar:SetRootPath(ResPath.GetCommon("num_100_"))
		self.rest_count_numBar:SetPosition(ph.x, ph.y)
		self.rest_count_numBar:SetGravity(NumberBarGravity.Center)
		self.rest_count_numBar:SetSpace(-5)
		self.view.node_t_list.layout_new_repeat_charge.node:addChild(self.rest_count_numBar:GetView(), 90)
		local data = OperateActivityData.Instance:GetNewRepeatChargeData()
		self.rest_count_numBar:SetNumber(data.need_money)
	end

	if not self.rest_count_numBar2 then
		local ph = self.view.ph_list.ph_new_repeat_c_num_2
		self.rest_count_numBar2 = NumberBar.New()
		self.rest_count_numBar2:SetRootPath(ResPath.GetCommon("num_100_"))
		self.rest_count_numBar2:SetPosition(ph.x, ph.y)
		self.rest_count_numBar2:SetGravity(NumberBarGravity.Center)
		self.rest_count_numBar2:SetSpace(-5)
		self.view.node_t_list.layout_new_repeat_charge.node:addChild(self.rest_count_numBar2:GetView(), 90)
		local data = OperateActivityData.Instance:GetNewRepeatChargeData()
		self.rest_count_numBar2:SetNumber(data.max_cnt)
	end
end

function OperateActNewRepeatChargePage:OnTimeLimitedGoodsEvt()
	local data = OperateActivityData.Instance:GetNewRepeatChargeData()
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_new_repeat_c_cnt.node, string.format(Language.OperateActivity.NewRepeatChargeTxts[1], data.own_cnt), 22)
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_new_repeat_used_cnt.node, string.format(Language.OperateActivity.NewRepeatChargeTxts[2], data.used_cnt), 22)
	self.rest_count_numBar2:SetNumber(data.max_cnt-data.own_cnt)
	self:FlushRemainTime()
	data = OperateActivityData.Instance:GetNewRepeatChargeAwards()
	self.show_items_list:SetDataList(data)
end

function OperateActNewRepeatChargePage:FlushRemainTime()
	local time = OperateActivityData.Instance:GetActRemainTimeStrByActId(OPERATE_ACTIVITY_ID.NEW_REPEAT_CHARGE)
	if time == "" then
		if self.timer then
			GlobalTimerQuest:CancelQuest(self.timer)
			self.timer = nil
		end
		return
	end

	if self.view.node_t_list.text_new_repeat_c_time then
		self.view.node_t_list.text_new_repeat_c_time.node:setString(time)
	end
end