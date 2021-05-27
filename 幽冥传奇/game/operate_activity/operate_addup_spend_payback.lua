OperAddupSpendPaybackPage = OperAddupSpendPaybackPage or BaseClass()

function OperAddupSpendPaybackPage:__init()
	self.view = nil
end

function OperAddupSpendPaybackPage:__delete()
	self:RemoveEvent()
	self.view = nil
end

function OperAddupSpendPaybackPage:InitPage(view)
	self.view = view
	XUI.AddClickEventListener(self.view.node_t_list.btn_yuanbao_spend_addup.node, BindTool.Bind(self.OnClickSpendHandler, self), true)
	self:InitEvent()
	-- self:OnInfoChange()
end

function OperAddupSpendPaybackPage:InitEvent()
	self.data_event = GlobalEventSystem:Bind(OperateActivityEventType.ADDUP_SPEND_PAYBACK_DATA, BindTool.Bind(self.OnInfoChange, self))
	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushRemainTime, self), 1)
end

function OperAddupSpendPaybackPage:RemoveEvent()
	if self.data_event then
		GlobalEventSystem:UnBind(self.data_event)
		self.data_event = nil
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end

--更新视图界面
function OperAddupSpendPaybackPage:UpdateData(data)
	self:FlushCfgInfo()
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.ADDUP_SPEND_PAYBACK)
	OperateActivityCtrl.Instance:ReqOperateActData(cmd_id or 1, OPERATE_ACTIVITY_ID.ADDUP_SPEND_PAYBACK)
	self:FlushRemainTime()
end	

function OperAddupSpendPaybackPage:OnInfoChange()
	local my_money = OperateActivityData.Instance:GetAddupSpendPaybackMoney()
	local content = string.format(Language.OperateActivity.SpendGiveMyMoney, my_money)
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_my_addup_spend.node, content, 24)
	my_money = OperateActivityData.Instance:GetAddupSpendPaybackCnt()
	content = string.format(Language.OperateActivity.AddChargePayback, my_money)
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_my_s_addup_back_cnt.node, content, 24)
	
end

function OperAddupSpendPaybackPage:FlushCfgInfo()
	local cfg = OperateActivityData.Instance:GetAddupSpendPaybackCfg()
	if cfg == nil then return end
	for k, v in ipairs(cfg) do
		if self.view.node_t_list["txt_s_stage_title_" .. k] then
			self.view.node_t_list["txt_s_stage_title_" .. k].node:setString(v.desc)
			local per = v.awardFactor * 100
			self.view.node_t_list["txt_s_stage_back_per_" .. k].node:setString(per .. "%")
		end
	end
end

function OperAddupSpendPaybackPage:FlushRemainTime()
	local time = OperateActivityData.Instance:GetActRemainTimeStrByActId(OPERATE_ACTIVITY_ID.ADDUP_SPEND_PAYBACK)

	if self.view.node_t_list.addup_spend_pb_rest_time then
		self.view.node_t_list.addup_spend_pb_rest_time.node:setString(time)
	end
end

-- 去消费
function OperAddupSpendPaybackPage:OnClickSpendHandler()
	if self.view then
		self.view:Close()
		ViewManager.Instance:Open(ViewName.Shop, 1)
	end
end