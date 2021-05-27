-- 限时优惠界面2
ConvertAwardPage = ConvertAwardPage or BaseClass()

function ConvertAwardPage:__init()
	self.view = nil

end

function ConvertAwardPage:__delete()
	self:RemoveEvent()
	if self.show_items_list then
		self.show_items_list:DeleteMe()
		self.show_items_list = nil
	end

	self.view = nil
end



function ConvertAwardPage:InitPage(view)
	self.view = view
	self:CreateShowItemsList()
	self:InitEvent()
	self:OnHandleEvt()
end



function ConvertAwardPage:InitEvent()
	self.handle_data_evt = GlobalEventSystem:Bind(OperateActivityEventType.CONVERT_AWARD_DATA, BindTool.Bind(self.OnHandleEvt, self))
	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushRemainTime, self), 1)
end

function ConvertAwardPage:RemoveEvent()
	if self.handle_data_evt then
		GlobalEventSystem:UnBind(self.handle_data_evt)
		self.handle_data_evt = nil
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end


function ConvertAwardPage:UpdateData()
	local act_id = OPERATE_ACTIVITY_ID.CONVERT_AWARD
	local des = OperateActivityData.Instance:GetActCfgByActID(act_id).act_desc or ""
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_convert_awar_des.node, des, 24, COLOR3B.YELLOW)
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(act_id)
	if cmd_id then
		OperateActivityCtrl.Instance:ReqOperateActData(cmd_id, act_id)
	end
end

function ConvertAwardPage:CreateShowItemsList()
	if not self.show_items_list then
		local ph = self.view.ph_list.ph_convert_awar_list
		self.show_items_list = ListView.New()
		self.show_items_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, OperateActConvertAwarItem, gravity, is_bounce, self.view.ph_list.ph_convert_awar_item)
		self.show_items_list:SetItemsInterval(10)
		self.show_items_list:SetJumpDirection(ListView.Top)
		self.view.node_t_list.layout_convert_award.node:addChild(self.show_items_list:GetView(), 90)
	end
end

function ConvertAwardPage:OnHandleEvt()
	self:FlushRemainTime()
	local data_list = OperateActivityData.Instance:GetConvertAwardData()
	self.show_items_list:SetDataList(data_list)
end

function ConvertAwardPage:FlushRemainTime()
	local time = OperateActivityData.Instance:GetActRemainTimeStrByActId(OPERATE_ACTIVITY_ID.CONVERT_AWARD)
	if time == "" then
		if self.timer then
			GlobalTimerQuest:CancelQuest(self.timer)
			self.timer = nil
		end
		return
	end

	if self.view.node_t_list.text_convert_awar_time then
		self.view.node_t_list.text_convert_awar_time.node:setString(time)
	end
end