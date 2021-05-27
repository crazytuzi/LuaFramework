-- 运营活动-聚宝盆
OperateJvBaoPenPage = OperateJvBaoPenPage or BaseClass()

function OperateJvBaoPenPage:__init()
	self.view = nil

end

function OperateJvBaoPenPage:__delete()
	self:RemoveEvent()
	if self.record_list then
		self.record_list:DeleteMe()
		self.record_list = nil
	end

	if self.rest_cnt_numbar then
		self.rest_cnt_numbar:DeleteMe()
		self.rest_cnt_numbar = nil
	end

	self.view = nil
end


function OperateJvBaoPenPage:InitPage(view)
	self.view = view
	self:CreateRecordList()
	self:CreateRestCntNumberBar()
	self.view.node_t_list.rich_jvbao_cannot_reason.node:setHorizontalAlignment(RichHAlignment.HA_CENTER)
	-- 安卓平台调整位置
	-- if PLATFORM == cc.PLATFORM_OS_ANDROID then
	-- 	local pos_y = self.view.node_t_list.rich_wish_rest_get_info.node:getPositionY()
	-- 	self.view.node_t_list.rich_wish_rest_get_info.node:setPositionY(pos_y + 6)
	-- end
	self:InitEvent()
	self:FlushInfo()
end

--初始化事件
function OperateJvBaoPenPage:InitEvent()
	XUI.AddClickEventListener(self.view.node_t_list.btn_earn_money.node, BindTool.Bind(self.OnEarnMoneyClick, self), true)
	XUI.AddClickEventListener(self.view.node_t_list.btn_recharge_jv_bao.node, BindTool.Bind(self.OnChargeMoneyClick, self), true)
	self.jv_bao_pen_evt = GlobalEventSystem:Bind(OperateActivityEventType.JV_BAO_PEN_DATA_CHANGE, BindTool.Bind(self.OnJvBaoPenDataChange, self))
	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushRemainTime, self), 1)
	self.role_data_evt = BindTool.Bind(self.RoleDataChange, self)
	RoleData.Instance:NotifyAttrChange(BindTool.Bind(self.role_data_evt, self))
end

function OperateJvBaoPenPage:RoleDataChange(key, value)
	if key == OBJ_ATTR.ACTOR_GOLD then
		self:FlushInfo()
	end
end

--移除事件
function OperateJvBaoPenPage:RemoveEvent()
	if self.jv_bao_pen_evt then
		GlobalEventSystem:UnBind(self.jv_bao_pen_evt)
		self.jv_bao_pen_evt = nil
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end

	if self.role_data_evt then
		RoleData.Instance:UnNotifyAttrChange(self.role_data_evt)
		self.role_data_evt = nil
	end

end

-- 刷新
function OperateJvBaoPenPage:UpdateData(param_t)
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.JVBAO_PEN)
	if cmd_id then
		OperateActivityCtrl.Instance:ReqOperateActData(cmd_id, OPERATE_ACTIVITY_ID.JVBAO_PEN)
	end
	self:FlushRemainTime()
end

function OperateJvBaoPenPage:CreateRecordList()
	if not self.record_list then
		local ph = self.view.ph_list.ph_jvbao_record_list
		self.record_list = ListView.New()
		self.record_list:SetIsUseStepCalc(false)
		self.record_list:Create(ph.x, ph.y, ph.w, ph.h, direction, JvBaoRecordRender, gravity, is_bounce, self.view.ph_list.ph_jvbao_record_content)
		self.record_list:SetJumpDirection(ListView.Top)
		self.record_list:SetItemsInterval(5)
		self.record_list:SetMargin(2)
		self.view.node_t_list.layout_jvbao_pen.node:addChild(self.record_list:GetView(), 100)
	end
end

function OperateJvBaoPenPage:CreateRestCntNumberBar()
	if not self.rest_cnt_numbar then
		local ph = self.view.ph_list.ph_jvbao_numbar
		-- 需要充值金额
		self.rest_cnt_numbar = NumberBar.New()
		self.rest_cnt_numbar:SetRootPath(ResPath.GetVipResPath("vip_"))
		self.rest_cnt_numbar:SetPosition(ph.x, ph.y)
		self.rest_cnt_numbar:SetSpace(-3)
		self.rest_cnt_numbar:SetGravity(NumberBarGravity.Center)
		-- self.rest_cnt_numbar:GetView():setScale(1.5)
		self.view.node_t_list.layout_jvbao_pen.node:addChild(self.rest_cnt_numbar:GetView(), 300, 300)
		self.rest_cnt_numbar:SetNumber(0)
	end
end

function OperateJvBaoPenPage:FlushInfo()
	local jv_bao_rest_cnt, jv_bao_cur_award_info, record_data, jv_bao_charged_money = OperateActivityData.Instance:GetJvBaoPenData()
	if record_data and self.record_list then
		self.record_list:SetDataList(record_data)
	end
	self.rest_cnt_numbar:SetNumber(jv_bao_rest_cnt)
	local cost_cond = jv_bao_cur_award_info and jv_bao_cur_award_info.costGoldNum or 0
	self.view.node_t_list.txt_jvbao_charged_money.node:setString(string.format(Language.OperateActivity.JvBaoYBNum, jv_bao_charged_money))
	if jv_bao_rest_cnt <= 0 then
		self.view.node_t_list.layout_jb_cost_info.node:setVisible(false)
		return
	else
		self.view.node_t_list.layout_jb_cost_info.node:setVisible(true)
	end
	self.view.node_t_list.txt_jvbao_cur_cost.node:setString(cost_cond)
	local content = nil
	if cost_cond == 0 then
		self.view.node_t_list.txt_jvbao_need_charge.node:setString(cost_cond)
	else
		local role_own_yb = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD)
		local not_enough_num = nil
		if jv_bao_charged_money < jv_bao_cur_award_info.needRechargeGoldNum then
			not_enough_num = jv_bao_cur_award_info.needRechargeGoldNum - jv_bao_charged_money
			content = string.format(Language.OperateActivity.JvBaoRichContents[1], not_enough_num)
		elseif role_own_yb < cost_cond then
			not_enough_num = cost_cond - role_own_yb
			content = string.format(Language.OperateActivity.JvBaoRichContents[2], not_enough_num)
		end
		cost_cond = string.format(Language.OperateActivity.JvBaoYBNum, jv_bao_cur_award_info.needRechargeGoldNum)
		self.view.node_t_list.txt_jvbao_need_charge.node:setString(cost_cond)
	end
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_jvbao_cannot_reason.node, content or "", 20)
	self.view.node_t_list.btn_earn_money.node:setVisible(content == nil)
	
end

function OperateJvBaoPenPage:OnJvBaoPenDataChange()
	self:FlushInfo()
end

function OperateJvBaoPenPage:FlushRemainTime()
	local time = OperateActivityData.Instance:GetActRemainTimeStrByActId(OPERATE_ACTIVITY_ID.JVBAO_PEN)

	if self.view.node_t_list.lbl_jvbao_remain_time then
		self.view.node_t_list.lbl_jvbao_remain_time.node:setString(time)
	end
end

function OperateJvBaoPenPage:OnEarnMoneyClick()
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.JVBAO_PEN)
	if cmd_id then
		OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.JVBAO_PEN)
	end
end

function OperateJvBaoPenPage:OnChargeMoneyClick()
	ViewManager.Instance:Open(ViewName.ChargePlatForm)
end