-- 运营活动-元宝转盘
OperateActYBWheelPage = OperateActYBWheelPage or BaseClass()

function OperateActYBWheelPage:__init()
	self.view = nil
	self.is_cancel_animate = false
	self.is_ten_turn = false
	self.fix_now_time = 0
end

function OperateActYBWheelPage:__delete()
	self:RemoveEvent()
	if self.record_list then
		self.record_list:DeleteMe()
		self.record_list = nil
	end
	self.fix_now_time = 0
	self:StopRemindTurnEffect()

	self.view = nil
end


function OperateActYBWheelPage:InitPage(view)
	self.view = view
	self:CreateRecordList()
	self.view.node_t_list.img_point.node:setAnchorPoint(0.5, 0)
	self.view.node_t_list.img_hook.node:setVisible(self.is_cancel_animate)
	self.view.node_t_list.img_hook1.node:setVisible(self.is_ten_turn)
	self.is_cancel_animate = self.view.node_t_list.img_hook.node:isVisible()
	self.is_ten_turn = self.view.node_t_list.img_hook1.node:isVisible()

	-- self.view.node_t_list.rich_yuanbao_wheel_des.node:setHorizontalAlignment(RichHAlignment.HA_CENTER)
	self.view.node_t_list.rich_clean_tip.node:setHorizontalAlignment(RichHAlignment.HA_CENTER)
	self:InitEvent()
end

--初始化事件
function OperateActYBWheelPage:InitEvent()
	self.view.node_t_list.btn_yb_wheel_tip.node:setVisible(false)
	XUI.AddClickEventListener(self.view.node_t_list.btn_yuanbao_charge.node, BindTool.Bind(self.OnClickChongzhiHandler, self), true)
	XUI.AddClickEventListener(self.view.node_t_list.btn_start_turn.node, BindTool.Bind(self.OnStartTurnClick, self), true)
	XUI.AddClickEventListener(self.view.node_t_list.btn_yb_wheel_tip.node,BindTool.Bind(self.OnHelp,self),true)
	XUI.AddClickEventListener(self.view.node_t_list.layout_cancel_animate.node, BindTool.Bind(self.OnCancelAnimateClick, self), true)
	XUI.AddClickEventListener(self.view.node_t_list.layout_turn_10.node, BindTool.Bind(self.OnTenTurnClick, self), true)

	self.yb_wheel_record_info_evt = GlobalEventSystem:Bind(OperateActivityEventType.YB_WHEEL_RECORD_DATA_CHANGE, BindTool.Bind(self.OnRecordDataChange, self))
	self.yb_wheel_turn_place_evt = GlobalEventSystem:Bind(OperateActivityEventType.YB_WHEEL_TURN_PLACE_CHANGE, BindTool.Bind(self.OnTurnDataChange, self))
	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushRemainTime, self), 1)
end

--移除事件
function OperateActYBWheelPage:RemoveEvent()
	if self.yb_wheel_record_info_evt then
		GlobalEventSystem:UnBind(self.yb_wheel_record_info_evt)
		self.yb_wheel_record_info_evt = nil
	end

	if self.yb_wheel_turn_place_evt then
		GlobalEventSystem:UnBind(self.yb_wheel_turn_place_evt)
		self.yb_wheel_turn_place_evt = nil
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end

end

function OperateActYBWheelPage:SetStaticInfo()
	local yb_wheel_cfg = OperateActivityData.Instance:GetYBWheelCfgInfo()
	if yb_wheel_cfg then
		self.view.node_t_list.txt_per_time_cost.node:setString(string.format(Language.OperateActivity.YBWheelTexts[2], yb_wheel_cfg.per_play_cost))
		local path = nil
		for k, v in ipairs(yb_wheel_cfg.icons_bag) do
			path = ResPath.GetItem(v)
			if self.view.node_t_list["img_wheel_sec_" .. k] then
				self.view.node_t_list["img_wheel_sec_" .. k].node:setScale(0.8)
				self.view.node_t_list["img_wheel_sec_" .. k].node:loadTexture(path)
			end
		end
	end
end

-- 刷新
function OperateActYBWheelPage:UpdateData(param_t)
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.YB_WHEEL)
	if cmd_id then
		OperateActivityCtrl.Instance:ReqOperateActData(cmd_id, OPERATE_ACTIVITY_ID.YB_WHEEL)
	end

	local cfg = OperateActivityData.Instance:GetActCfgByActID(OPERATE_ACTIVITY_ID.YB_WHEEL)
	local content = cfg and cfg.act_desc or ""
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_yuanbao_wheel_des.node, content, 24, COLOR3B.YELLOW)
	self:SetStaticInfo()
end

function OperateActYBWheelPage:OnCancelAnimateClick()
	self.is_cancel_animate = not self.is_cancel_animate
	self.view.node_t_list.img_hook.node:setVisible(self.is_cancel_animate)
end

function OperateActYBWheelPage:OnTenTurnClick()
	self.is_ten_turn = not self.is_ten_turn
	self.view.node_t_list.img_hook1.node:setVisible(self.is_ten_turn)
end

function OperateActYBWheelPage:CreateRecordList()
	if not self.record_list then
		local ph = self.view.ph_list.ph_yuanbao_record_list
		self.record_list = ListView.New()
		self.record_list:SetIsUseStepCalc(false)
		self.record_list:Create(ph.x, ph.y, ph.w, ph.h, direction, RecordRender, gravity, is_bounce, self.view.ph_list.ph_wheel_record_content)
		self.record_list:SetJumpDirection(ListView.Top)
		self.record_list:SetMargin(2)
		self.view.node_t_list.layout_yuanbao_wheel.node:addChild(self.record_list:GetView(), 100)
	end
end

function OperateActYBWheelPage:FlushInfo()
	local cur_own_yb_score = OperateActivityData.Instance:GetCurOwnYBScore()
	self.view.node_t_list.txt_my_yb_score.node:setString(cur_own_yb_score)
	if OperateActivityData.Instance:IsYBWheelNeedRemind() then
		self:PlayRemindTurnEffect()
	else
		self:StopRemindTurnEffect()
	end

	local record_data = OperateActivityData.Instance:GetYBWheelRecordList()
	if record_data and self.record_list then
		self.record_list:SetDataList(record_data)
	end
end

function OperateActYBWheelPage:OnRecordDataChange()
	self:FlushRemainTime()
	self:FlushInfo()
end

-- 转动到目标位置
function OperateActYBWheelPage:RotateToTargetPos(index)
	local target_deg = 0
	local rotate_to = nil
	local sequ_actions = nil
	local call_back_fun = nil
	self.view.node_t_list.btn_start_turn.node:setEnabled(false)
	if not self.is_cancel_animate and not self.is_ten_turn then
		local laps = math.random(5, 8)
		target_deg = (index  - 1) * 60 + 360 * laps + math.random(-80,80) * 0.3
		rotate_to = cc.RotateTo:create(5, target_deg)
		local easeOptionOut = cc.EaseExponentialOut:create(rotate_to)
		local turn_complete_call_fun = function()
			self.view.node_t_list.btn_start_turn.node:setEnabled(true)
			local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.YB_WHEEL)
			if cmd_id then
				OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.YB_WHEEL, nil, 2)
			end
		end
		call_back_fun = cc.CallFunc:create(turn_complete_call_fun)
		sequ_actions = cc.Sequence:create(easeOptionOut, call_back_fun)
	else
		target_deg = (index - 1) * 60
		rotate_to = cc.RotateTo:create(0.15, target_deg)
		local delay_act = cc.DelayTime:create(0.2)
		call_back_fun = cc.CallFunc:create(function() 
			local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.YB_WHEEL)
			if cmd_id then
				OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.YB_WHEEL, nil, 2)
			end
			self.view.node_t_list.btn_start_turn.node:setEnabled(true)
		end)
		sequ_actions = cc.Sequence:create(rotate_to, delay_act, call_back_fun)
	end
	self.view.node_t_list.img_point.node:runAction(sequ_actions)
end

-- 转动位置数据变化
function OperateActYBWheelPage:OnTurnDataChange()
	local cur_own_yb_score = OperateActivityData.Instance:GetCurOwnYBScore()
	self.view.node_t_list.txt_my_yb_score.node:setString(cur_own_yb_score)
	local target_place = OperateActivityData.Instance:GetYBWheelTurnPlace()
	self:RotateToTargetPos(target_place)
end

local clean_end_time = 24 * 3600
function OperateActYBWheelPage:FlushRemainTime()
	local time = OperateActivityData.Instance:GetActRemainTimeStrByActId(OPERATE_ACTIVITY_ID.YB_WHEEL)

	if self.view.node_t_list.txt_yuanbao_wheel_time then
		self.view.node_t_list.txt_yuanbao_wheel_time.node:setString(time)
	end

	local server_time = TimeCtrl.Instance:GetServerTime() or os.time()
	local format_time = os.date("*t", server_time)		--获取年月日时分秒的表
	local cur_time = (format_time.hour * 60 + format_time.min) * 60 + format_time.sec
	
	local clean_rest_time = clean_end_time - cur_time
	if clean_rest_time > 0 then
		local clean_rest_time_str = TimeUtil.FormatSecond2Str(clean_rest_time, 1)
		local content = string.format(Language.OperateActivity.YBWheelTexts[1], clean_rest_time_str)
		RichTextUtil.ParseRichText(self.view.node_t_list.rich_clean_tip.node, content, 22)
	else
		local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.YB_WHEEL)
		if cmd_id then
			OperateActivityCtrl.Instance:ReqOperateActData(cmd_id, OPERATE_ACTIVITY_ID.YB_WHEEL)
		end
	end
	
end

function OperateActYBWheelPage:PlayRemindTurnEffect()
	if not self.turn_btn_effect then
		local size = self.view.node_t_list.btn_start_turn.node:getContentSize()
		self.turn_btn_effect = XUI.CreateImageView(size.width / 2, size.height / 2, ResPath.GetSkillIcon("common_exterior_effect"), true)
		self.turn_btn_effect:setScale(0.5)
		self.view.node_t_list.btn_start_turn.node:addChild(self.turn_btn_effect)

		local scale_to = cc.ScaleTo:create(1, 1)
		local fade_to = cc.FadeOut:create(1)
		local action_complete_callback = function()
			self.turn_btn_effect:setScale(0.5)
			self.turn_btn_effect:setOpacity(255)
		end

		local spawn = cc.Spawn:create(scale_to, fade_to)
		local action = cc.Sequence:create(spawn, cc.CallFunc:create(action_complete_callback))
		self.turn_btn_effect:runAction(cc.RepeatForever:create(action))
	end	
end

function OperateActYBWheelPage:StopRemindTurnEffect()
	if self.turn_btn_effect then
		self.turn_btn_effect:removeFromParent()
		self.turn_btn_effect = nil
	end	
end	

-- 开始转动指针
local click_min_time_gap = 1
function OperateActYBWheelPage:OnStartTurnClick()
	-- self.view.node_t_list.btn_start_turn.node:setEnabled(false)
	if not self.is_cancel_animate and not self.is_ten_turn then
		local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.YB_WHEEL)
		if cmd_id then
			OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.YB_WHEEL, nil, 1)
		end
	else 
		if not self.is_ten_turn and self.is_cancel_animate then
			if Status.NowTime > self.fix_now_time then
				self.fix_now_time = Status.NowTime + click_min_time_gap
				local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.YB_WHEEL)
				if cmd_id then
					OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.YB_WHEEL, nil, 1)
				end
			end
		elseif self.is_ten_turn then
			if Status.NowTime > self.fix_now_time then
				self.fix_now_time = Status.NowTime + click_min_time_gap
				local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.YB_WHEEL)
				if cmd_id then
					OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.YB_WHEEL, nil, 3)
				end
			end
		end
	end
	
end

-- 去充值
function OperateActYBWheelPage:OnClickChongzhiHandler()
	if self.view then
		self.view:Close()
		ViewManager.Instance:Open(ViewName.ChargePlatForm)
	end
end

--帮助点击
function OperateActYBWheelPage:OnHelp()
	DescTip.Instance:SetContent(Language.OperateActivity.Content[1], Language.OperateActivity.Title[1])
end	