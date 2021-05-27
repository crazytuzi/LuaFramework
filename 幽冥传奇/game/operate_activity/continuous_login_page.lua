-- 运营活动-连续登录
ContinuousLoginPage = ContinuousLoginPage or BaseClass()

function ContinuousLoginPage:__init()
	self.view = nil
	self.selec_item_index = 1
	-- self.big_pic_list = {}
end

function ContinuousLoginPage:__delete()
	self:RemoveEvent()
	if self.login_day_number then
		self.login_day_number:DeleteMe()
		self.login_day_number = nil
	end

	if self.day_reward_list then
		self.day_reward_list:DeleteMe()
		self.day_reward_list = nil
	end

	if self.reward_cell_list_1 then
		self.reward_cell_list_1:DeleteMe()
		self.reward_cell_list_1 = nil
	end

	if self.reward_cell_list_2 then
		self.reward_cell_list_2:DeleteMe()
		self.reward_cell_list_2 = nil
	end

	self.selec_item_index = 1

	-- self.big_pic_list = {}
	-- if self.stage_effect then
	-- 	self.stage_effect:removeFromParent()
	-- 	self.stage_effect = nil
	-- end
	self.view = nil
end

function ContinuousLoginPage:InitPage(view)
	self.view = view
	XUI.AddClickEventListener(self.view.node_t_list.btn_fetch_gift_norm.node, BindTool.Bind(self.OnFetchClick, self, 1), true)
	XUI.AddClickEventListener(self.view.node_t_list.btn_fetch_gift_extr.node, BindTool.Bind(self.OnFetchClick, self, 2), true)
	self:InitEvent()
	self:CreateEveryDayReward()
	-- self:CreateStageEffect()
	-- self:OnSevenDaysInfoChange()
end

function ContinuousLoginPage:InitEvent()
	self.seven_event = GlobalEventSystem:Bind(OperateActivityEventType.CONTINUOUS_LOGIN_DATA, BindTool.Bind(self.OnSevenDaysInfoChange, self))
	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushRemainTime, self), 1)
end

function ContinuousLoginPage:RemoveEvent()
	if self.seven_event then
		GlobalEventSystem:UnBind(self.seven_event)
		self.seven_event = nil
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end

	if self.delay_timer then
		GlobalTimerQuest:CancelQuest(self.delay_timer)
		self.delay_timer = nil
	end

end

--更新视图界面
function ContinuousLoginPage:UpdateData(data)
	self:OnSevenDaysInfoChange()
	self:FlushRemainTime()
end	

function ContinuousLoginPage:FlushRemainTime()
	local time = OperateActivityData.Instance:GetActRemainTimeStrByActId(OPERATE_ACTIVITY_ID.CONTINUOUS_LOGIN)
	if self.view.node_t_list.continuous_login_rest_time_1 then
		self.view.node_t_list.continuous_login_rest_time_1.node:setString(time)
	end
end

function ContinuousLoginPage:CreateEveryDayReward()
	local ph_start = self.view.ph_list.ph_conti_day_item_start
	local ph = self.view.ph_list.ph_conti_day_list
	if nil == self.day_reward_list then
		-- local ph_end = self.view.ph_list.ph_day_item_end
		self.day_reward_list = ListView.New()
		self.day_reward_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, SpringFestivalLoginAwardRender, ListViewGravity.Left, false, ph_start)
		self.day_reward_list:SetIsUseStepCalc(false)
		self.day_reward_list:SetJumpDirection(ListView.Left)
		self.day_reward_list:SetSelectCallBack(BindTool.Bind(self.SelectRewardList, self))
		self.view.node_t_list.layout_continuous_login.node:addChild(self.day_reward_list:GetView(), 100)
		local data = OperateActivityData.Instance:GetContinuousLoginBaseInfo()
		self.day_reward_list:SetDataList(data)  
	end

	local interval = 0
	ph_start = self.view.ph_list.ph_cn_cell_1
	if nil == self.reward_cell_list_1 then
		ph = self.view.ph_list.ph_conti_award_list_1
		interval = (ph.w - 5 * ph_start.w) / 4
		self.reward_cell_list_1 = ListView.New()
		self.reward_cell_list_1:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, ContinuousLoginAwarCell, ListViewGravity.Left, false, ph_start)
		self.reward_cell_list_1:GetView():setAnchorPoint(0, 0.5)
		self.reward_cell_list_1:SetIsUseStepCalc(false)
		self.reward_cell_list_1:SetItemsInterval(interval)
		self.view.node_t_list.layout_continuous_login.node:addChild(self.reward_cell_list_1:GetView(), 5)
	end

	if nil == self.reward_cell_list_2 then
		ph = self.view.ph_list.ph_conti_award_list_2
		-- ph_start = self.view.ph_list.ph_cn_cell_1
		interval = (ph.w - 5 * ph_start.w) / 4
		self.reward_cell_list_2 = ListView.New()
		self.reward_cell_list_2:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, ContinuousLoginAwarCell, ListViewGravity.Left, false, ph_start)
		self.reward_cell_list_2:GetView():setAnchorPoint(0, 0.5)
		self.reward_cell_list_2:SetIsUseStepCalc(false)
		self.reward_cell_list_2:SetItemsInterval(interval)
		self.view.node_t_list.layout_continuous_login.node:addChild(self.reward_cell_list_2:GetView(), 5)
	end
end

function ContinuousLoginPage:SetRewardCellData(index)
	local reward_data = OperateActivityData.Instance:GetContinuousLoginRewardData(index, 1)
	if not reward_data then return end
	local ph = self.view.ph_list.ph_conti_award_list_1
	local len = #reward_data
	local item_ui_cfg = self.view.ph_list.ph_cn_cell_1
	local interval = self.reward_cell_list_1:GetView():getItemsInterval()
	self:AdjustAwardListPos(self.reward_cell_list_1:GetView(), ph, interval, len, item_ui_cfg)
	self.reward_cell_list_1:SetData(reward_data)

	reward_data = OperateActivityData.Instance:GetContinuousLoginRewardData(index, 2)
	ph = self.view.ph_list.ph_conti_award_list_2
	len = #reward_data
	interval = self.reward_cell_list_2:GetView():getItemsInterval()
	self:AdjustAwardListPos(self.reward_cell_list_2:GetView(), ph, interval, len, item_ui_cfg)
	self.reward_cell_list_2:SetData(reward_data)
end

function ContinuousLoginPage:AdjustAwardListPos(list_view, ph, interval, len, item_ui_cfg)
	if len < 5 then
		local w = item_ui_cfg.w * len + (len - 1) * interval
		list_view:setPosition(ph.x + ph.w - w, ph.y)
	else
		list_view:setPosition(ph.x, ph.y)
	end	
end

function ContinuousLoginPage:ShowBigReward(index)
	self.big_pic_list = self.big_pic_list or {}
	if self.big_pic_list[index] == nil then
		self.big_pic_list[index] = {}
		-- local ph_word = self.view.ph_list.ph_text
		local ph_pic = self.view.ph_list.ph_reward
		-- local word = XUI.CreateImageView(ph_word.x, ph_word.y, ResPath.GetWelfare("word_reward_" .. index), true)
		-- word:setScale(1.1)
		local pic = XUI.CreateImageView(ph_pic.x, ph_pic.y, ResPath.GetWelfare("login_normal_" .. index), true)
		-- pic:setScale(1.1)
		CommonAction.ShowJumpAction(pic, 18)
		-- self.view.node_t_list.layout_continuous_login.node:addChild(word, 10)
		self.view.node_t_list.layout_continuous_login.node:addChild(pic, 10)
		-- self.big_pic_list[index].word = word
		self.big_pic_list[index].pic = pic
	end
	for k,v in pairs(self.big_pic_list) do
		local visible = k == index
		-- if v.word then
		-- 	v.word:setVisible(visible)
		-- end
		if v.pic then
			v.pic:setVisible(visible)
		end
	end
end

function ContinuousLoginPage:SelectRewardList(item, index)
	if self.delay_timer then
		GlobalTimerQuest:CancelQuest(self.delay_timer)
		self.delay_timer = nil
	end
	if nil == item or nil == item:GetData() then return end
	local data = item:GetData()
	self.cur_data = data
	self.selec_item_index = index
	self:SetRewardCellData(index)
	-- self:ShowBigReward(data.big_show)
	self.day_reward_list:SetSelectItemToLeft(index)
	self:SetDayNumber(data.day)
	local role_lv = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local vip_lv = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_VIP_GRADE)
	local is_grey = role_lv < data.get_lv or (not data.need_makeup and data.state_1 ~= SEVEN_DAYS_LOGIN_FETCH_STATE.CAN)
	XUI.SetLayoutImgsGrey(self.view.node_t_list.btn_fetch_gift_norm.node, is_grey, false)
	is_grey = vip_lv < data.vip_cond or data.state_2 ~= SEVEN_DAYS_LOGIN_FETCH_STATE.CAN
	XUI.SetLayoutImgsGrey(self.view.node_t_list.btn_fetch_gift_extr.node, is_grey, false)
	-- self.view.node_t_list.txt_continuous_cost_money.node:setVisible(data.need_makeup)
	-- local cost = OperateActivityData.Instance:GetMakeupCost()
	self.view.node_t_list.txt_continuous_cost_money.node:setString("") --string.format(Language.OperateActivity.JvBaoYBNum, cost)
	self.view.node_t_list.txt_continuous_extr_cond.node:setString(string.format(Language.OperateActivity.VipCond, data.vip_cond or 0))
end

function ContinuousLoginPage:SetDayNumber(num)
	if self.login_day_number == nil then
		self.login_day_number = NumberBar.New()
		self.login_day_number:SetRootPath(ResPath.GetWelfare("dayNum_"))
		local x, y = self.view.ph_list.ph_continuous_day_num.x, self.view.ph_list.ph_continuous_day_num.y
		self.login_day_number:SetPosition(x, y)
		self.login_day_number:SetGravity(NumberBarGravity.Center)
		self.login_day_number:SetSpace(-5)
		self.view.node_t_list.layout_continuous_login.node:addChild(self.login_day_number:GetView(), 100)
	end
	self.login_day_number:SetNumber(num)
end

function ContinuousLoginPage:OnFetchClick(oper_type)
	local act_id = OPERATE_ACTIVITY_ID.CONTINUOUS_LOGIN
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(act_id)
	if not cmd_id then return end
	if self.cur_data and self.selec_item_index then
		-- local oper_type = 1
		-- if self.cur_data.need_makeup then
		-- 	oper_type = 2
		-- end
		OperateActivityCtrl:ReqOperateActOpr(cmd_id, act_id, self.selec_item_index, oper_type, oper_time, dindan_id, role_id, join_type)
	end
end

function ContinuousLoginPage:CreateStageEffect()
	local ph_pic = self.view.ph_list.ph_reward
	if self.stage_effect == nil then
		self.stage_effect = RenderUnit.CreateEffect(989, 
			self.view.node_t_list.layout_continuous_login.node,
			9, nil, nil, ph_pic.x + 10, ph_pic.y - 80)
		self.stage_effect:setScale(1.2)
	end
end

function ContinuousLoginPage:OnSevenDaysInfoChange()
	-- local day = OperateActivityData.Instance:GetAddLoginTimes()
	local data = OperateActivityData.Instance:GetContinuousLoginBaseInfo()
	self.day_reward_list:SetDataList(data) 
	local start_idx = 1
	local vip_lv = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_VIP_GRADE)
	for k, v in ipairs(data) do
		if v.state_1 == SEVEN_DAYS_LOGIN_FETCH_STATE.CAN or (v.state_2 == SEVEN_DAYS_LOGIN_FETCH_STATE.CAN and vip_lv >= v.vip_cond) then
			start_idx = k
			break
		elseif v.state_1 == SEVEN_DAYS_LOGIN_FETCH_STATE.FETCHED then
			start_idx = k
		end
	end

	local timer_callback = function() 
		if self.day_reward_list then
			self.day_reward_list:SelectIndex(start_idx)
		end
	end
	self.delay_timer = GlobalTimerQuest:AddDelayTimer(timer_callback, 0.025)
end