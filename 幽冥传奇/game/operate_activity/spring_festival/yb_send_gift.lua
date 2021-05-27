SpringYBSendGiftPage = SpringYBSendGiftPage or BaseClass()

function SpringYBSendGiftPage:__init()
	self.view = nil
	self.selec_item_index = 1
	self.big_pic_list = {}
end

function SpringYBSendGiftPage:__delete()
	self:RemoveEvent()
	self.view = nil
end

function SpringYBSendGiftPage:InitPage(view)
	self.view = view
	-- XUI.AddClickEventListener(self.view.node_t_list.btn_fetch_gift.node, BindTool.Bind(self.OnFetchClick, self), true)
	self:InitEvent()
	-- self:OnSevenDaysInfoChange()
end

function SpringYBSendGiftPage:InitEvent()
	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushRemainTime, self), 1)
end

function SpringYBSendGiftPage:RemoveEvent()
	if self.seven_event then
		GlobalEventSystem:UnBind(self.seven_event)
		self.seven_event = nil
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end

--更新视图界面
function SpringYBSendGiftPage:UpdateData(data)
	local cfg = OperateActivityData.Instance:GetActCfgByActID(OPERATE_ACTIVITY_ID.YB_SEND_GIFT)
	if cfg then
		RichTextUtil.ParseRichText(self.view.node_t_list.rich_yb_send_des.node, cfg.act_desc)
	end
	self:FlushRemainTime()
end	

function SpringYBSendGiftPage:FlushRemainTime()
	local time = OperateActivityData.Instance:GetActRemainTimeStrByActId(OPERATE_ACTIVITY_ID.YB_SEND_GIFT)

	if self.view.node_t_list.spring_act_rest_time_2 then
		self.view.node_t_list.spring_act_rest_time_2.node:setString(time)
	end
end


