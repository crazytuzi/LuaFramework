-- 运营活动-元宝转盘
NatiRotatePanelAwardPage = NatiRotatePanelAwardPage or BaseClass()

function NatiRotatePanelAwardPage:__init()
	self.view = nil
	self.is_cancel_animate = false
	self.is_ten_turn = false
	self.fix_now_time = 0
end

function NatiRotatePanelAwardPage:__delete()
	self:RemoveEvent()
	self.fix_now_time = 0
	self:StopRemindTurnEffect()
	if self.show_items then
		for k, v in pairs(self.show_items) do
			v:DeleteMe()
		end
		self.show_items = nil
	end
	if self.alert_view ~= nil then
		self.alert_view:DeleteMe()
		self.alert_view = nil 
	end
	if self.awards_result_wnd then
		self.awards_result_wnd:DeleteMe()
		self.awards_result_wnd = nil
	end
	self.view = nil
end


function NatiRotatePanelAwardPage:InitPage(view)
	self.view = view
	self:CreateItemList()
	self.btn_rotate = self.view.node_tree.layout_rotary_table.btn_rotate.node
	self.btn_rotate:setAnchorPoint(0.5, 0.35)
	self.btn_rotate:setLocalZOrder(50)
	-- self.view.node_tree.layout_rotary_table.img_hook.node:setVisible(self.is_cancel_animate)
	-- self.view.node_tree.layout_rotary_table.img_hook1.node:setVisible(self.is_ten_turn)
	-- self.is_cancel_animate = self.view.node_tree.layout_rotary_table.img_hook.node:isVisible()
	-- self.is_ten_turn = self.view.node_tree.layout_rotary_table.img_hook1.node:isVisible()
	-- self.view.node_tree.layout_rotary_table.rich_yuanbao_wheel_des.node:setHorizontalAlignment(RichHAlignment.HA_CENTER)
	-- self.view.node_tree.layout_rotary_table.rich_clean_tip.node:setHorizontalAlignment(RichHAlignment.HA_CENTER)
	self:InitEvent()
	self:OnAllDataChange()
end

--初始化事件
function NatiRotatePanelAwardPage:InitEvent()
	-- self.view.node_tree.layout_rotary_table.btn_yb_wheel_tip.node:setVisible(false)
	XUI.AddClickEventListener(self.view.node_tree.layout_rotary_table.btn_refre_panel.node, BindTool.Bind(self.OnRefefrePanelClick, self), true)
	XUI.AddClickEventListener(self.btn_rotate, BindTool.Bind(self.OnStartTurnClick, self), true)
	-- XUI.AddClickEventListener(self.view.node_tree.layout_rotary_table.btn_yb_wheel_tip.node,BindTool.Bind(self.OnHelp,self),true)
	-- XUI.AddClickEventListener(self.view.node_tree.layout_rotary_table.layout_cancel_animate.node, BindTool.Bind(self.OnCancelAnimateClick, self), true)
	-- XUI.AddClickEventListener(self.view.node_tree.layout_rotary_table.layout_turn_10.node, BindTool.Bind(self.OnTenTurnClick, self), true)

	self.yb_wheel_record_info_evt = GlobalEventSystem:Bind(OperateActivityEventType.ROTATE_PANEL_AWARD_TOTAL_DATA, BindTool.Bind(self.OnAllDataChange, self))
	self.yb_wheel_turn_place_evt = GlobalEventSystem:Bind(OperateActivityEventType.ROTATE_PANEL_AWARD_BEGIN_ROTATE, BindTool.Bind(self.OnTurnDataChange, self))
	self.rotate_result_evt = GlobalEventSystem:Bind(OperateActivityEventType.ROTATE_PANEL_RESULT_BACK, BindTool.Bind(self.OnRotateResultBack, self))
	-- self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushRemainTime, self), 1)
end

--移除事件
function NatiRotatePanelAwardPage:RemoveEvent()
	if self.yb_wheel_record_info_evt then
		GlobalEventSystem:UnBind(self.yb_wheel_record_info_evt)
		self.yb_wheel_record_info_evt = nil
	end

	if self.yb_wheel_turn_place_evt then
		GlobalEventSystem:UnBind(self.yb_wheel_turn_place_evt)
		self.yb_wheel_turn_place_evt = nil
	end

	if self.rotate_result_evt then
		GlobalEventSystem:UnBind(self.rotate_result_evt)
		self.rotate_result_evt = nil
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end

end

-- 刷新
function NatiRotatePanelAwardPage:UpdateData(param_t)
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.ROTATE_PANEL_AWARD)
	if cmd_id then
		OperateActivityCtrl.Instance:ReqOperateActData(cmd_id, OPERATE_ACTIVITY_ID.ROTATE_PANEL_AWARD)
	end

	local cfg = OperateActivityData.Instance:GetActCfgByActID(OPERATE_ACTIVITY_ID.ROTATE_PANEL_AWARD)
	local content = cfg and cfg.act_desc or ""
	RichTextUtil.ParseRichText(self.view.node_tree.layout_rotary_table.rich_zhuan_desc.node, content, 22, COLOR3B.YELLOW)
end

function NatiRotatePanelAwardPage:OnCancelAnimateClick()
	-- self.is_cancel_animate = not self.is_cancel_animate
	-- self.view.node_tree.layout_rotary_table.img_hook.node:setVisible(self.is_cancel_animate)
end

function NatiRotatePanelAwardPage:OnTenTurnClick()
	-- self.is_ten_turn = not self.is_ten_turn
	-- self.view.node_tree.layout_rotary_table.img_hook1.node:setVisible(self.is_ten_turn)
end

function NatiRotatePanelAwardPage:CreateItemList()
	self.show_items = {}
	local ph, cell
	for i = 1, 10 do
		ph = self.view.ph_list["ph_rp_item_" .. i]
		cell = BaseCell.New()
		cell:SetPosition(ph.x, ph.y)
		cell:GetView():setScale(0.7, 0.7)
		self.view.node_tree.layout_rotary_table.node:addChild(cell:GetView(), 30)
		self.show_items[i] = cell
	end
end

function NatiRotatePanelAwardPage:SetShowItemInfo()
	local data = OperateActivityData.Instance:GetRotatePanelAwardCfgInfo()
	for k, v in ipairs(data) do
		if self.show_items[k] then
			self.show_items[k]:SetData(v)
			self.show_items[k]:MakeGray(v.state == 1)
		end
	end
end

function NatiRotatePanelAwardPage:FlushInfo()
	local cur_own_yb_score = OperateActivityData.Instance:GetRotatePanelTipTxt()
	-- print("cur_own_yb_score:", cur_own_yb_score)
	self.view.node_tree.layout_rotary_table.rich_get_cnt_tip.node:setString(cur_own_yb_score)
	if OperateActivityData.Instance:IsRotatePanelAwardNeedRemind() then
		self:PlayRemindTurnEffect()
	else
		self:StopRemindTurnEffect()
	end
end

function NatiRotatePanelAwardPage:OnAllDataChange()
	-- self:FlushRemainTime()
	self:SetShowItemInfo()
	self:FlushInfo()
end

function NatiRotatePanelAwardPage:OnRotateResultBack(pop_flag, idx, state)
	if pop_flag ~= 0 then
		if self.show_items[idx] then
			if pop_flag == 1 then
				self.show_items[idx]:MakeGray(state == 1)
			end
			if not self.awards_result_wnd then
				self.awards_result_wnd = RotatePanelAwardResultWnd.New()
			end
			local award_data = {}
			if self.show_items[idx]:GetData() then
				self.awards_result_wnd:SetData({self.show_items[idx]:GetData()})
				self.awards_result_wnd:Open()
			end
		end
	end
end

-- 转动到目标位置
function NatiRotatePanelAwardPage:RotateToTargetPos(index)
	local target_deg = 0
	local rotate_to = nil
	local sequ_actions = nil
	local call_back_fun = nil
	self.btn_rotate:setTouchEnabled(false)
	if not self.is_cancel_animate and not self.is_ten_turn then
		local laps = math.random(5, 8)
		target_deg = (index  - 1) * 36 + 360 * laps + math.random(-20,20) * 0.3
		rotate_to = cc.RotateTo:create(5, target_deg)
		local easeOptionOut = cc.EaseExponentialOut:create(rotate_to)
		local turn_complete_call_fun = function()
			self.btn_rotate:setTouchEnabled(true)
			local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.ROTATE_PANEL_AWARD)
			if cmd_id then
				OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.ROTATE_PANEL_AWARD, nil, 2)
			end
		end
		call_back_fun = cc.CallFunc:create(turn_complete_call_fun)
		sequ_actions = cc.Sequence:create(easeOptionOut, call_back_fun)
	else
		target_deg = (index - 1) * 60
		rotate_to = cc.RotateTo:create(0.15, target_deg)
		local delay_act = cc.DelayTime:create(0.2)
		call_back_fun = cc.CallFunc:create(function() 
			local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.ROTATE_PANEL_AWARD)
			if cmd_id then
				OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.ROTATE_PANEL_AWARD, nil, 2)
			end
			self.btn_rotate:setTouchEnabled(true)
		end)
		sequ_actions = cc.Sequence:create(rotate_to, delay_act, call_back_fun)
	end
	self.view.node_tree.layout_rotary_table.btn_rotate.node:runAction(sequ_actions)
end

-- 转动位置数据变化
function NatiRotatePanelAwardPage:OnTurnDataChange()
	self:FlushInfo()
	local target_place = OperateActivityData.Instance:GetRotatePanelTurnTargetIdx()
	self:RotateToTargetPos(target_place)
end

local clean_end_time = 24 * 3600
function NatiRotatePanelAwardPage:FlushRemainTime()
	-- local time = OperateActivityData.Instance:GetActRemainTimeStrByActId(OPERATE_ACTIVITY_ID.ROTATE_PANEL_AWARD)

	-- if self.view.node_tree.layout_rotary_table.txt_yuanbao_wheel_time then
	-- 	self.view.node_tree.layout_rotary_table.txt_yuanbao_wheel_time.node:setString(time)
	-- end

	-- local server_time = TimeCtrl.Instance:GetServerTime() or os.time()
	-- local format_time = os.date("*t", server_time)		--获取年月日时分秒的表
	-- local cur_time = (format_time.hour * 60 + format_time.min) * 60 + format_time.sec
	
	-- local clean_rest_time = clean_end_time - cur_time
	-- if clean_rest_time > 0 then
	-- 	local clean_rest_time_str = TimeUtil.FormatSecond2Str(clean_rest_time, 1)
	-- 	local content = string.format(Language.OperateActivity.YBWheelTexts[1], clean_rest_time_str)
	-- 	RichTextUtil.ParseRichText(self.view.node_tree.layout_rotary_table.rich_clean_tip.node, content, 22)
	-- else
	-- 	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.ROTATE_PANEL_AWARD)
	-- 	if cmd_id then
	-- 		OperateActivityCtrl.Instance:ReqOperateActData(cmd_id, OPERATE_ACTIVITY_ID.ROTATE_PANEL_AWARD)
	-- 	end
	-- end
	
end

function NatiRotatePanelAwardPage:PlayRemindTurnEffect()
	-- if not self.turn_btn_effect then
	-- 	local size = self.view.node_tree.layout_rotary_table.btn_rotate.node:getContentSize()
	-- 	self.turn_btn_effect = XUI.CreateImageView(size.width / 2, size.height / 2, ResPath.GetSkillIcon("common_exterior_effect"), true)
	-- 	self.turn_btn_effect:setScale(0.5)
	-- 	self.view.node_tree.layout_rotary_table.btn_rotate.node:addChild(self.turn_btn_effect)

	-- 	local scale_to = cc.ScaleTo:create(1, 1)
	-- 	local fade_to = cc.FadeOut:create(1)
	-- 	local action_complete_callback = function()
	-- 		self.turn_btn_effect:setScale(0.5)
	-- 		self.turn_btn_effect:setOpacity(255)
	-- 	end

	-- 	local spawn = cc.Spawn:create(scale_to, fade_to)
	-- 	local action = cc.Sequence:create(spawn, cc.CallFunc:create(action_complete_callback))
	-- 	self.turn_btn_effect:runAction(cc.RepeatForever:create(action))
	-- end	
end

function NatiRotatePanelAwardPage:StopRemindTurnEffect()
	if self.turn_btn_effect then
		self.turn_btn_effect:removeFromParent()
		self.turn_btn_effect = nil
	end	
end	

-- 开始转动指针
local click_min_time_gap = 1
function NatiRotatePanelAwardPage:OnStartTurnClick()
	-- self.view.node_tree.layout_rotary_table.btn_rotate.node:setEnabled(false)
	if not self.is_cancel_animate and not self.is_ten_turn then
		local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.ROTATE_PANEL_AWARD)
		if cmd_id then
			OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.ROTATE_PANEL_AWARD, nil, 1)
		end
	else 
		if not self.is_ten_turn and self.is_cancel_animate then
			if Status.NowTime > self.fix_now_time then
				self.fix_now_time = Status.NowTime + click_min_time_gap
				local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.ROTATE_PANEL_AWARD)
				if cmd_id then
					OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.ROTATE_PANEL_AWARD, nil, 1)
				end
			end
		-- elseif self.is_ten_turn then
		-- 	if Status.NowTime > self.fix_now_time then
		-- 		self.fix_now_time = Status.NowTime + click_min_time_gap
		-- 		local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.ROTATE_PANEL_AWARD)
		-- 		if cmd_id then
		-- 			OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.ROTATE_PANEL_AWARD, nil, 3)
		-- 		end
		-- 	end
		end
	end
end

-- 手动刷新轮盘
function NatiRotatePanelAwardPage:OnRefefrePanelClick()
	local cost = OperateActivityData.Instance:GetRotatePanelRefreNeedMoney()
	if self.alert_view == nil then
		self.alert_view = Alert.New()
		-- self.alert_view:SetShowCheckBox(true)
		self.alert_view:SetOkFunc(function ()
			local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.ROTATE_PANEL_AWARD)
			if cmd_id then
				OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.ROTATE_PANEL_AWARD, nil, 3)
			end
	  	end)
	end
	if cost then
		local txt = string.format(Language.OperateActivity.RotatePanelAward[3], cost or 0)
		self.alert_view:SetLableString(txt)
  		self.alert_view:Open()
  	end
end

--帮助点击
function NatiRotatePanelAwardPage:OnHelp()
	DescTip.Instance:SetContent(Language.OperateActivity.Content[1], Language.OperateActivity.Title[1])
end	