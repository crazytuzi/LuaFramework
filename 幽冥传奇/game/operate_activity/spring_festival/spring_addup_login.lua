SpringAddupLoginPage = SpringAddupLoginPage or BaseClass()

function SpringAddupLoginPage:__init()
	self.view = nil
	self.selec_item_index = 1
	self.big_pic_list = {}
end

function SpringAddupLoginPage:__delete()
	self:RemoveEvent()
	if self.login_day_number then
		self.login_day_number:DeleteMe()
		self.login_day_number = nil
	end

	if self.day_reward_list then
		self.day_reward_list:DeleteMe()
		self.day_reward_list = nil
	end

	if self.reward_cell_list then
		for k, v in pairs(self.reward_cell_list) do
			v:DeleteMe()
		end
		self.reward_cell_list = nil
	end

	self.selec_item_index = 1

	self.big_pic_list = {}
	if self.stage_effect then
		self.stage_effect:removeFromParent()
		self.stage_effect = nil
	end
	self.view = nil
end

function SpringAddupLoginPage:InitPage(view)
	self.view = view
	XUI.AddClickEventListener(self.view.node_t_list.btn_fetch_gift.node, BindTool.Bind(self.OnFetchClick, self), true)
	self:InitEvent()
	self:CreateEveryDayReward()
	self:CreateStageEffect()
	-- self:OnSevenDaysInfoChange()
end

function SpringAddupLoginPage:InitEvent()
	self.seven_event = GlobalEventSystem:Bind(OperateActivityEventType.ADDUP_LOGIN_GIFT_DATA_CHANGE, BindTool.Bind(self.OnSevenDaysInfoChange, self))
	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushRemainTime, self), 1)
end

function SpringAddupLoginPage:RemoveEvent()
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
function SpringAddupLoginPage:UpdateData(data)
	self:OnSevenDaysInfoChange()
	self:FlushRemainTime()
end	

function SpringAddupLoginPage:FlushRemainTime()
	local time = OperateActivityData.Instance:GetActRemainTimeStrByActId(OPERATE_ACTIVITY_ID.ADDUP_LOGIN_GET_GIFT)

	if self.view.node_t_list.spring_act_rest_time_1 then
		self.view.node_t_list.spring_act_rest_time_1.node:setString(time)
	end
end

function SpringAddupLoginPage:CreateEveryDayReward()
	if nil == self.day_reward_list then
		local ph_start = self.view.ph_list.ph_day_item_start
		-- local ph_end = self.view.ph_list.ph_day_item_end

		local ph = self.view.ph_list.ph_day_list
		self.day_reward_list = ListView.New()
		self.day_reward_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, SpringFestivalLoginAwardRender, ListViewGravity.Left, false, ph_start)
		self.day_reward_list:SetIsUseStepCalc(false)
		self.day_reward_list:SetJumpDirection(ListView.Left)
		self.day_reward_list:SetSelectCallBack(BindTool.Bind(self.SelectRewardList, self))
		self.view.node_t_list.spring_addup_login.node:addChild(self.day_reward_list:GetView(), 100)
		local data = OperateActivityData.Instance:GetAddupLoginBaseInfo()
		self.day_reward_list:SetDataList(data)  
	end
end

function SpringAddupLoginPage:SetRewardCellData(index)
	self.reward_cell_list = self.reward_cell_list or {}
	local reward_data = OperateActivityData.Instance:GetLoginRewardData(index)
	if reward_data then
		local reward_cnt = #reward_data
		local cell_cnt = #self.reward_cell_list
		if cell_cnt > reward_cnt then
			for i = cell_cnt, reward_cnt + 1, -1 do
				local cell = self.reward_cell_list[i]
				if cell then
					cell:GetView():removeFromParent()
					cell:DeleteMe()
					self.reward_cell_list[i] = nil
				end
			end
		end
		for i,v in ipairs(reward_data) do
			if nil == self.reward_cell_list[i] then
				local ph_cell = self.view.ph_list["ph_cell_" .. i]
				if ph_cell then
					local cell = BaseCell.New()
					cell:GetView():setAnchorPoint(0.5, 0.5)
					cell:SetPosition(ph_cell.x, ph_cell.y)
					cell:SetData(v)
					self.view.node_t_list.spring_addup_login.node:addChild(cell:GetView(), 20)
					self.reward_cell_list[i] = cell

					local cell_effect = AnimateSprite:create()
					cell_effect:setPosition(ph_cell.w / 2, ph_cell.h / 2)
					cell:GetView():addChild(cell_effect, 300)
					cell_effect:setVisible(false)
					cell.cell_effect = cell_effect

					if v.sp_effect_id then
						local path, name = ResPath.GetEffectUiAnimPath(v.sp_effect_id)
						if path and name then
							cell.cell_effect:setAnimate(path, name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
							cell.cell_effect:setVisible(true)
						end
					end
				end
			else
				self.reward_cell_list[i]:SetData(v)

				if v.sp_effect_id then
					local path, name = ResPath.GetEffectUiAnimPath(v.sp_effect_id)
					if path and name and self.reward_cell_list[i].cell_effect then
						self.reward_cell_list[i].cell_effect:setAnimate(path, name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
						self.reward_cell_list[i].cell_effect:setVisible(true)
					end
				else
					if self.reward_cell_list[i].cell_effect then
						self.reward_cell_list[i].cell_effect:setVisible(false)
					end
				end

			end
		end

	end
end

function SpringAddupLoginPage:ShowBigReward(index)
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
		-- self.view.node_t_list.spring_addup_login.node:addChild(word, 10)
		self.view.node_t_list.spring_addup_login.node:addChild(pic, 10)
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

function SpringAddupLoginPage:SelectRewardList(item, index)
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
	local is_grey = role_lv < data.get_lv or (not data.need_makeup and data.state ~= SEVEN_DAYS_LOGIN_FETCH_STATE.CAN)
	XUI.SetLayoutImgsGrey(self.view.node_t_list.btn_fetch_gift.node, is_grey, false)
	self.view.node_t_list.txt_sal_cost_money.node:setVisible(data.need_makeup)
	local cost = OperateActivityData.Instance:GetMakeupCost()
	self.view.node_t_list.txt_sal_cost_money.node:setString(string.format(Language.OperateActivity.JvBaoYBNum, cost))
end

function SpringAddupLoginPage:SetDayNumber(num)
	if self.login_day_number == nil then
		self.login_day_number = NumberBar.New()
		self.login_day_number:SetRootPath(ResPath.GetWelfare("dayNum_"))
		local x, y = self.view.ph_list.ph_day_num.x, self.view.ph_list.ph_day_num.y
		self.login_day_number:SetPosition(x, y)
		self.login_day_number:SetGravity(NumberBarGravity.Center)
		self.login_day_number:SetSpace(-5)
		self.view.node_t_list.spring_addup_login.node:addChild(self.login_day_number:GetView(), 100)
	end
	self.login_day_number:SetNumber(num)
end

function SpringAddupLoginPage:OnFetchClick()
	local act_id = OPERATE_ACTIVITY_ID.ADDUP_LOGIN_GET_GIFT
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(act_id)
	if not cmd_id then return end
	if self.cur_data and self.selec_item_index then
		local oper_type = 1
		if self.cur_data.need_makeup then
			oper_type = 2
		end
		OperateActivityCtrl:ReqOperateActOpr(cmd_id, act_id, self.selec_item_index, oper_type, oper_time, dindan_id, player_name, join_type)
	end
end

function SpringAddupLoginPage:CreateStageEffect()
	local ph_pic = self.view.ph_list.ph_reward
	if self.stage_effect == nil then
		self.stage_effect = RenderUnit.CreateEffect(989, 
			self.view.node_t_list.spring_addup_login.node,
			9, nil, nil, ph_pic.x + 10, ph_pic.y - 80)
		self.stage_effect:setScale(1.2)
	end
end

function SpringAddupLoginPage:OnSevenDaysInfoChange()
	-- local day = OperateActivityData.Instance:GetAddLoginTimes()
	local data = OperateActivityData.Instance:GetAddupLoginBaseInfo()
	self.day_reward_list:SetDataList(data) 
	local start_idx = 1
	for k, v in ipairs(data) do
		if v.state == SEVEN_DAYS_LOGIN_FETCH_STATE.CAN or v.need_makeup then
			start_idx = k
			break
		elseif v.state == SEVEN_DAYS_LOGIN_FETCH_STATE.FETCHED then
			start_idx = k
		end
	end

	local timer_callback = function() 
		self.day_reward_list:SelectIndex(start_idx)
	end
	self.delay_timer = GlobalTimerQuest:AddDelayTimer(timer_callback, 0.025)
end