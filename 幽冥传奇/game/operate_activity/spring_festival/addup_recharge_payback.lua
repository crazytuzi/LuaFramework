SpringAddupChargePayPage = SpringAddupChargePayPage or BaseClass()

function SpringAddupChargePayPage:__init()
	self.view = nil
	self.selec_item_index = 1
	self.big_pic_list = {}
end

function SpringAddupChargePayPage:__delete()
	self:RemoveEvent()
	self.view = nil
end

function SpringAddupChargePayPage:InitPage(view)
	self.view = view
	XUI.AddClickEventListener(self.view.node_t_list.btn_yuanbao_charge_addup.node, BindTool.Bind(self.OnClickChongzhiHandler, self), true)
	self:InitEvent()
	-- self:OnInfoChange()
end

function SpringAddupChargePayPage:InitEvent()
	self.seven_event = GlobalEventSystem:Bind(OperateActivityEventType.ADDUP_RECHARGE_PAYBACK_DATA_CHANGE, BindTool.Bind(self.OnInfoChange, self))
	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushRemainTime, self), 1)
end

function SpringAddupChargePayPage:RemoveEvent()
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
function SpringAddupChargePayPage:UpdateData(data)
	self:FlushCfgInfo()
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.ADDUP_CHARGE_PAYBACK)
	OperateActivityCtrl.Instance:ReqOperateActData(cmd_id or 1, OPERATE_ACTIVITY_ID.ADDUP_CHARGE_PAYBACK)
	self:FlushRemainTime()
end	

function SpringAddupChargePayPage:OnInfoChange()
	local my_money = OperateActivityData.Instance:GetAddupRechargePaybackMoney()
	local content = string.format(Language.OperateActivity.ChargeGiveMyMoney, my_money)
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_my_addup_charge.node, content, 24)
	my_money = OperateActivityData.Instance:GetAddupRechargePaybackCnt()
	content = string.format(Language.OperateActivity.AddChargePayback, my_money)
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_my_addup_back_cnt.node, content, 24)
	
end

function SpringAddupChargePayPage:FlushCfgInfo()
	local cfg = OperateActivityData.Instance:GetAddupRechargePaybackCfg()
	if cfg == nil then return end
	for k, v in ipairs(cfg) do
		if self.view.node_t_list["txt_stage_title_" .. k] then
			self.view.node_t_list["txt_stage_title_" .. k].node:setString(v.desc)
			local per = v.awardFactor * 100
			self.view.node_t_list["txt_stage_back_per_" .. k].node:setString(per .. "%")
		end
	end
end

function SpringAddupChargePayPage:FlushRemainTime()
	local time = OperateActivityData.Instance:GetActRemainTimeStrByActId(OPERATE_ACTIVITY_ID.ADDUP_CHARGE_PAYBACK)

	if self.view.node_t_list.spring_act_rest_time_4 then
		self.view.node_t_list.spring_act_rest_time_4.node:setString(time)
	end
end

-- 去充值
function SpringAddupChargePayPage:OnClickChongzhiHandler()
	if self.view then
		self.view:Close()
		ViewManager.Instance:Open(ViewName.ChargePlatForm)
	end
end