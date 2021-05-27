-- 运营活动-幸运转盘
OperateActLuckTurnPage = OperateActLuckTurnPage or BaseClass()

function OperateActLuckTurnPage:__init()
	self.view = nil
	self.is_cancel_animate = false
	self.is_ten_turn = false
	self.fix_now_time = 0
end

function OperateActLuckTurnPage:__delete()
	self:RemoveEvent()
	if self.record_list then
		self.record_list:DeleteMe()
		self.record_list = nil
	end

	if self.show_awar_pool then
		for k, v in pairs(self.show_awar_pool) do
			v:DeleteMe()
		end
		self.show_awar_pool = nil
	end

	self.fix_now_time = 0
	self:StopRemindTurnEffect()

	self.view = nil
end


function OperateActLuckTurnPage:InitPage(view)
	self.view = view
	self:CreateShowAwarPoolList()
	self:CreateRecordList()
	self.view.node_t_list.luck_turn_point.node:setAnchorPoint(0.5, 0)
	-- self.view.node_t_list.luck_turn_point.node:setVisible(false)
	self.view.node_t_list.img_luck_hook.node:setVisible(self.is_cancel_animate)
	self.view.node_t_list.img_luck_hook1.node:setVisible(self.is_ten_turn)
	self.is_cancel_animate = self.view.node_t_list.img_luck_hook.node:isVisible()
	self.is_ten_turn = self.view.node_t_list.img_luck_hook1.node:isVisible()

	self.view.node_t_list.rich_luck_plate_des.node:setHorizontalAlignment(RichHAlignment.HA_CENTER)
	self.view.node_t_list.rich_luck_clean_tip.node:setHorizontalAlignment(RichHAlignment.HA_CENTER)
	self:InitEvent()
	if self.turn_point_timer then
		GlobalTimerQuest:CancelQuest(self.turn_point_timer)
		self.turn_point_timer = nil
	end
end

--初始化事件
function OperateActLuckTurnPage:InitEvent()
	self.view.node_t_list.btn_luck_plate_tip.node:setVisible(false)
	XUI.AddClickEventListener(self.view.node_t_list.btn_luck_charge.node, BindTool.Bind(self.OnClickChongzhiHandler, self), true)
	XUI.AddClickEventListener(self.view.node_t_list.btn_luck_start_turn.node, BindTool.Bind(self.OnStartTurnClick, self), true)
	XUI.AddClickEventListener(self.view.node_t_list.btn_luck_plate_tip.node,BindTool.Bind(self.OnHelp,self),true)
	XUI.AddClickEventListener(self.view.node_t_list.layout_luck_cancel_animate.node, BindTool.Bind(self.OnCancelAnimateClick, self), true)
	XUI.AddClickEventListener(self.view.node_t_list.layout_luck_turn_10.node, BindTool.Bind(self.OnTenTurnClick, self), true)

	self.yb_wheel_record_info_evt = GlobalEventSystem:Bind(OperateActivityEventType.LUCK_TURN_WHEEL_RECORD_DATA_CHANGE, BindTool.Bind(self.OnRecordDataChange, self))
	self.yb_wheel_turn_place_evt = GlobalEventSystem:Bind(OperateActivityEventType.LUCK_TURN_WHEEL_TURN_PLACE_CHANGE, BindTool.Bind(self.OnTurnDataChange, self))
	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushRemainTime, self), 1)
end

--移除事件
function OperateActLuckTurnPage:RemoveEvent()
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

	if self.turn_point_timer then
		GlobalTimerQuest:CancelQuest(self.turn_point_timer)
		self.turn_point_timer = nil
	end

end

-- 刷新
function OperateActLuckTurnPage:UpdateData(param_t)
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.LUCK_TURN_WHEEL)
	if cmd_id then
		OperateActivityCtrl.Instance:ReqOperateActData(cmd_id, OPERATE_ACTIVITY_ID.LUCK_TURN_WHEEL)
	end

	local cfg = OperateActivityData.Instance:GetActCfgByActID(OPERATE_ACTIVITY_ID.LUCK_TURN_WHEEL)
	local content = cfg and cfg.act_desc or ""
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_luck_plate_des.node, content, 24, COLOR3B.YELLOW)
	self:SetStaticInfo()
end

function OperateActLuckTurnPage:CreateShowAwarPoolList()
	if not self.show_awar_pool then
		self.show_awar_pool = {}
		for i = 1, 12 do
			local ph = self.view.ph_list["ph_awrd_pos_" .. i]
			local render = OperateActLuckTurnAwarRender.New()
			render:SetIndex(i)
			render:SetUiConfig(self.view.ph_list.ph_luck_awar_item, true)
			render:SetPosition(ph.x, ph.y)
			self.view.node_t_list.layout_show_awar_pool.node:addChild(render:GetView(), 100)
			self.show_awar_pool[i] = render
		end
	end
end

function OperateActLuckTurnPage:HideShowAwarSelecStamp()
	if not self.show_awar_pool then return end
	for k, v in ipairs(self.show_awar_pool) do
		v:SetSelecStampVis(false)
	end
end

function OperateActLuckTurnPage:ShowAwarSelecStamp(index)
	if not self.show_awar_pool then return end
	for k, v in ipairs(self.show_awar_pool) do
		v:SetSelecStampVis(v:GetIndex() == index)
	end
end

function OperateActLuckTurnPage:SetStaticInfo()
	local luck_turn_cfg = OperateActivityData.Instance:GetLuckTurnCfgInfo()
	if luck_turn_cfg then
		self.view.node_t_list.txt_luck_per_cost.node:setString(string.format(Language.OperateActivity.YBWheelTexts[2], luck_turn_cfg.per_play_cost))
		local path = nil
		for k, v in ipairs(luck_turn_cfg.icons_bag) do
			if self.show_awar_pool[k] then
				self.show_awar_pool[k]:SetData(v)
			end
		end
		-- self:ShowAwarSelecStamp(1)
	end
end

function OperateActLuckTurnPage:CreateRecordList()
	if not self.record_list then
		local ph = self.view.ph_list.ph_luck_record_list
		self.record_list = ListView.New()
		self.record_list:SetIsUseStepCalc(false)
		self.record_list:Create(ph.x, ph.y, ph.w, ph.h, direction, RecordRender, gravity, is_bounce, self.view.ph_list.ph_luck_record_content)
		self.record_list:SetJumpDirection(ListView.Top)
		self.record_list:SetMargin(2)
		self.view.node_t_list.layout_luck_plate.node:addChild(self.record_list:GetView(), 100)
	end
end

function OperateActLuckTurnPage:FlushInfo()
	local cur_own_yb_score = OperateActivityData.Instance:GetLuckOwnYBScore()
	self.view.node_t_list.txt_luck_my_score.node:setString(cur_own_yb_score)
	if OperateActivityData.Instance:IsLuckTurnNeedRemind() then
		self:PlayRemindTurnEffect()
	else
		self:StopRemindTurnEffect()
	end

	local record_data = OperateActivityData.Instance:GetLuckTurnRecordList()
	if record_data and self.record_list then
		self.record_list:SetDataList(record_data)
	end
end

function OperateActLuckTurnPage:OnRecordDataChange()
	self:FlushRemainTime()
	self:FlushInfo()
end

-- 转动到目标位置
function OperateActLuckTurnPage:RotateToTargetPos(index)
	self.view.node_t_list.luck_turn_point.node:setRotation(0)
	-- print("index = ", index)
	local target_deg = 0
	local rotate_to = nil
	local sequ_actions = nil
	local call_back_fun = nil
	self.view.node_t_list.btn_luck_start_turn.node:setEnabled(false)
	if not self.is_cancel_animate and not self.is_ten_turn then
		local laps = math.random(3, 5)
		target_deg = (index  - 1) * 30 + 360 * laps
		rotate_to = cc.RotateTo:create(4, target_deg)
		local easeSineOut = cc.EaseSineOut:create(rotate_to)
		local turn_complete_call_fun = function()
			self.view.node_t_list.btn_luck_start_turn.node:setEnabled(true)
			self:ShowAwarSelecStamp(index)
			if self.turn_point_timer then
				GlobalTimerQuest:CancelQuest(self.turn_point_timer)
				self.turn_point_timer = nil
			end
			local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.LUCK_TURN_WHEEL)
			if cmd_id then
				OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.LUCK_TURN_WHEEL, nil, 2)
			end
		end
		call_back_fun = cc.CallFunc:create(turn_complete_call_fun)
		if self.turn_point_timer then
			GlobalTimerQuest:CancelQuest(self.turn_point_timer)
			self.turn_point_timer = nil
		end
		if not self.turn_point_timer then
			self.turn_point_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.ChangeAwarMark, self), 0.03)
		end
		sequ_actions = cc.Sequence:create(easeSineOut, call_back_fun)
	else
		target_deg = (index - 1) * 30
		rotate_to = cc.RotateTo:create(0.15, target_deg)
		local delay_act = cc.DelayTime:create(0.2)
		call_back_fun = cc.CallFunc:create(function() 
			local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.LUCK_TURN_WHEEL)
			if cmd_id then
				OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.LUCK_TURN_WHEEL, nil, 2)
			end
			self.view.node_t_list.btn_luck_start_turn.node:setEnabled(true)
			self:ShowAwarSelecStamp(index)
		end)
		sequ_actions = cc.Sequence:create(rotate_to, delay_act, call_back_fun)
	end
	self.view.node_t_list.luck_turn_point.node:runAction(sequ_actions)
end

function OperateActLuckTurnPage:ChangeAwarMark()
	local now_rotate_deg = self.view.node_t_list.luck_turn_point.node:getRotation() % 360
	local aw_index = now_rotate_deg <= 50 and math.ceil(now_rotate_deg / 30) or math.ceil(now_rotate_deg / 30)+1
	-- print("now_rotate_deg, aw_index", now_rotate_deg, aw_index)
	self:ShowAwarSelecStamp(aw_index)
end

-- 转动位置数据变化
function OperateActLuckTurnPage:OnTurnDataChange()
	local cur_own_yb_score = OperateActivityData.Instance:GetLuckOwnYBScore()
	self.view.node_t_list.txt_luck_my_score.node:setString(cur_own_yb_score)
	local target_place = OperateActivityData.Instance:GetLuckTurnPlace()
	self:RotateToTargetPos(target_place)
end

local clean_end_time = 24 * 3600
function OperateActLuckTurnPage:FlushRemainTime()
	local time = OperateActivityData.Instance:GetActRemainTimeStrByActId(OPERATE_ACTIVITY_ID.LUCK_TURN_WHEEL)

	if self.view.node_t_list.txt_luck_plate_time then
		self.view.node_t_list.txt_luck_plate_time.node:setString(time)
	end

	local server_time = TimeCtrl.Instance:GetServerTime() or os.time()
	local format_time = os.date("*t", server_time)		--获取年月日时分秒的表
	local cur_time = (format_time.hour * 60 + format_time.min) * 60 + format_time.sec
	
	local clean_rest_time = clean_end_time - cur_time
	if clean_rest_time > 0 then
		local clean_rest_time_str = TimeUtil.FormatSecond2Str(clean_rest_time, 1)
		local content = string.format(Language.OperateActivity.YBWheelTexts[1], clean_rest_time_str)
		RichTextUtil.ParseRichText(self.view.node_t_list.rich_luck_clean_tip.node, content, 22)
	else
		local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.LUCK_TURN_WHEEL)
		if cmd_id then
			OperateActivityCtrl.Instance:ReqOperateActData(cmd_id, OPERATE_ACTIVITY_ID.LUCK_TURN_WHEEL)
		end
	end
	
end

function OperateActLuckTurnPage:PlayRemindTurnEffect()
	if not self.turn_btn_effect then
		local size = self.view.node_t_list.btn_luck_start_turn.node:getContentSize()
		self.turn_btn_effect = XUI.CreateImageView(size.width / 2, size.height / 2, ResPath.GetSkillIcon("common_exterior_effect"), true)
		self.turn_btn_effect:setScale(0.5)
		self.view.node_t_list.btn_luck_start_turn.node:addChild(self.turn_btn_effect)

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

function OperateActLuckTurnPage:StopRemindTurnEffect()
	if self.turn_btn_effect then
		self.turn_btn_effect:removeFromParent()
		self.turn_btn_effect = nil
	end	
end	

-- 开始转动指针
local click_min_time_gap = 1
function OperateActLuckTurnPage:OnStartTurnClick()
	-- self.view.node_t_list.btn_luck_start_turn.node:setEnabled(false)
	if not self.is_cancel_animate and not self.is_ten_turn then
		local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.LUCK_TURN_WHEEL)
		if cmd_id then
			OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.LUCK_TURN_WHEEL, nil, 1)
		end
	else 
		if not self.is_ten_turn and self.is_cancel_animate then
			if Status.NowTime > self.fix_now_time then
				self.fix_now_time = Status.NowTime + click_min_time_gap
				local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.LUCK_TURN_WHEEL)
				if cmd_id then
					OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.LUCK_TURN_WHEEL, nil, 1)
				end
			end
		elseif self.is_ten_turn then
			if Status.NowTime > self.fix_now_time then
				self.fix_now_time = Status.NowTime + click_min_time_gap
				local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.LUCK_TURN_WHEEL)
				if cmd_id then
					OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.LUCK_TURN_WHEEL, nil, 3)
				end
			end
		end
	end
	
end

-- 去充值
function OperateActLuckTurnPage:OnClickChongzhiHandler()
	if self.view then
		self.view:Close()
		ViewManager.Instance:Open(ViewName.ChargePlatForm)
	end
end

function OperateActLuckTurnPage:OnCancelAnimateClick()
	self.is_cancel_animate = not self.is_cancel_animate
	self.view.node_t_list.img_luck_hook.node:setVisible(self.is_cancel_animate)
end

function OperateActLuckTurnPage:OnTenTurnClick()
	self.is_ten_turn = not self.is_ten_turn
	self.view.node_t_list.img_luck_hook1.node:setVisible(self.is_ten_turn)
end

--帮助点击
function OperateActLuckTurnPage:OnHelp()
	DescTip.Instance:SetContent(Language.OperateActivity.Content[1], Language.OperateActivity.Title[1])
end	