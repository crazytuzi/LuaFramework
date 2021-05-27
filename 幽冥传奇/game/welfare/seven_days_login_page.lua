SevenDaysLoginPage = SevenDaysLoginPage or BaseClass()

function SevenDaysLoginPage:__init()
	self.view = nil
	self.selec_item_index = 1
	self.big_pic_list = {}
end

function SevenDaysLoginPage:__delete()
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

function SevenDaysLoginPage:InitPage(view)
	self.view = view
	XUI.AddClickEventListener(self.view.node_t_list.btn_fetch_gift.node, BindTool.Bind(self.OnFetchClick, self), true)
	self:InitEvent()
	self:CreateEveryDayReward()
	-- self:CreateStageEffect()
	-- self:OnSevenDaysInfoChange()
end

function SevenDaysLoginPage:InitEvent()
	self.seven_event = GlobalEventSystem:Bind(WelfareEventType.SEVEN_DAYS_LOGIN_DATA_CHANGE, BindTool.Bind(self.OnSevenDaysInfoChange, self))
end

function SevenDaysLoginPage:RemoveEvent()
	if self.seven_event then
		GlobalEventSystem:UnBind(self.seven_event)
		self.seven_event = nil
	end
	if self.delay_timer then
		GlobalTimerQuest:CancelQuest(self.delay_timer)
		self.delay_timer = nil
	end
end

--更新视图界面
function SevenDaysLoginPage:UpdateData(data)
	self:OnSevenDaysInfoChange()
end	

function SevenDaysLoginPage:CreateEveryDayReward()
	if nil == self.day_reward_list then
		local ph_start = self.view.ph_list.ph_day_item_start
		-- local ph_end = self.view.ph_list.ph_day_item_end

		local ph = self.view.ph_list.ph_day_list
		self.day_reward_list = ListView.New()
		self.day_reward_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, SevenDaysLoginAwardRender, ListViewGravity.Left, false, ph_start)
		self.day_reward_list:SetIsUseStepCalc(false)
		self.day_reward_list:SetJumpDirection(ListView.Left)
		self.day_reward_list:SetSelectCallBack(BindTool.Bind(self.SelectRewardList, self))
		self.view.node_t_list.page3.node:addChild(self.day_reward_list:GetView(), 100)
		local data = WelfareData.Instance:GetAddupLoginBaseInfo()
		self.day_reward_list:SetDataList(data)  
	end
end

function SevenDaysLoginPage:SetRewardCellData(index)
	self.reward_cell_list = self.reward_cell_list or {}
	local reward_data = WelfareData.Instance:GetLoginRewardData(index)
	if reward_data then
		for i,v in ipairs(reward_data) do
			if nil == self.reward_cell_list[i] then
				local ph_cell = self.view.ph_list["ph_cell_" .. i]
				if ph_cell then
					local cell = BaseCell.New()
					cell:GetView():setAnchorPoint(0.5, 0.5)
					cell:SetPosition(ph_cell.x, ph_cell.y)
					cell:SetData(v)
					self.view.node_t_list.page3.node:addChild(cell:GetView(), 20)
					self.reward_cell_list[i] = cell

					local cell_effect = AnimateSprite:create()
					cell_effect:setScale(1.1)
					cell_effect:setPosition(ph_cell.w / 2, ph_cell.h / 2)
					cell:GetView():addChild(cell_effect, 300)
					cell.cell_effect = cell_effect

					if v.sp_effect_id then
						local path, name = ResPath.GetEffectUiAnimPath(v.sp_effect_id)
						if path and name then
							cell.cell_effect:setAnimate(path, name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
						end
					end
				end
			else
				self.reward_cell_list[i]:SetData(v)
				if v.sp_effect_id then
					local path, name = ResPath.GetEffectUiAnimPath(v.sp_effect_id)
					if path and name and self.reward_cell_list[i].cell_effect then
						self.reward_cell_list[i].cell_effect:setAnimate(path, name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
					end
				else
					if self.reward_cell_list[i].cell_effect then
						self.reward_cell_list[i].cell_effect:setStop()
					end
				end

			end
		end

	end
end

function SevenDaysLoginPage:ShowBigReward(index)
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
		-- self.view.node_t_list.page3.node:addChild(word, 10)
		self.view.node_t_list.page3.node:addChild(pic, 10)
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

function SevenDaysLoginPage:SelectRewardList(item, index)
	if self.delay_timer then
		GlobalTimerQuest:CancelQuest(self.delay_timer)
		self.delay_timer = nil
	end
	if nil == item or nil == item:GetData() then return end
	local data = item:GetData()
	self.selec_item_index = index
	self:SetRewardCellData(index)
	-- self:ShowBigReward(index)
	self.day_reward_list:SetSelectItemToLeft(index)
	self:SetDayNumber(data.day)

	local role_lv = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local turn_value = Circle.activeLevel
	role_lv = circle * turn_value + role_lv
	local is_grey = role_lv < data.get_lv or data.state ~= SEVEN_DAYS_LOGIN_FETCH_STATE.CAN
	XUI.SetLayoutImgsGrey(self.view.node_t_list.btn_fetch_gift.node, is_grey, false)
end

function SevenDaysLoginPage:SetDayNumber(num)
	if self.login_day_number == nil then
		self.login_day_number = NumberBar.New()
		self.login_day_number:SetRootPath(ResPath.GetWelfare("dayNum_"))
		local x, y = self.view.ph_list.ph_day_num.x, self.view.ph_list.ph_day_num.y
		self.login_day_number:SetPosition(x, y)
		self.login_day_number:SetGravity(NumberBarGravity.Center)
		self.login_day_number:SetSpace(-5)
		self.view.node_t_list.page3.node:addChild(self.login_day_number:GetView(), 100)
	end
	self.login_day_number:SetNumber(num)
end

function SevenDaysLoginPage:OnFetchClick()
	if self.selec_item_index then
		WelfareCtrl:GetSevenDaysLoginAwardReq(self.selec_item_index)
	end
end

function SevenDaysLoginPage:CreateStageEffect()
	local ph_pic = self.view.ph_list.ph_reward
	if self.stage_effect == nil then
		self.stage_effect = RenderUnit.CreateEffect(989, 
			self.view.node_t_list.page3.node,
			9, nil, nil, ph_pic.x + 10, ph_pic.y - 80)
		self.stage_effect:setScale(1.2)
	end
end

function SevenDaysLoginPage:OnSevenDaysInfoChange()
	-- local day = WelfareData.Instance:GetAddLoginTimes()
	local data = WelfareData.Instance:GetAddupLoginBaseInfo()
	self.day_reward_list:SetDataList(data) 
	local start_idx = 1
	for k, v in ipairs(data) do
		if v.state == SEVEN_DAYS_LOGIN_FETCH_STATE.CAN then
			start_idx = k
			break
		elseif v.state == SEVEN_DAYS_LOGIN_FETCH_STATE.FETCHED then
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



----------------------------------------------------
-- SevenDaysLoginAwardRender
----------------------------------------------------
SevenDaysLoginAwardRender = SevenDaysLoginAwardRender or BaseClass(BaseRender)
function SevenDaysLoginAwardRender:__init()
	self.is_select = false
end

function SevenDaysLoginAwardRender:__delete()
	self.reward_item = nil
end

function SevenDaysLoginAwardRender:CreateChild()
	BaseRender.CreateChild(self)
	self.select_effect = self.node_tree.img_select.node
	self.select_effect:setVisible(false)
	self.node_tree.img_reward_name.node:setScale(0.7)
	self.node_tree.img_reward_name.node:setVisible(false)
	self.node_tree.img_stamp.node:setVisible(false)
	self.node_tree.img_stamp.node:setLocalZOrder(11)
	-- self:AddClickEventListener(self.click_callback)
end

function SevenDaysLoginAwardRender:SetSelectVisible(is_select)
	-- if self.node_tree.img_select then
	-- 	self.node_tree.img_select.node:setVisible(is_select)
	-- end
	-- self.is_select = is_select
end

function SevenDaysLoginAwardRender:CreateSelectEffect()
end

function SevenDaysLoginAwardRender:OnFlush()
	if not self.data then return end
	local index = self.index
	if nil == self.reward_item then
		local x, y = self.node_tree.award_bg.node:getPosition()
		self.reward_item = XUI.CreateImageView(x, y, ResPath.GetItem(self.data.icon), true)
		-- self.reward_item:setScale(0.5)
		self.view:addChild(self.reward_item, 10)
	end

	self.node_tree.img_day.node:loadTexture(ResPath.GetWelfare("day_" .. self.data.day))
	self.node_tree.img_stamp.node:setVisible(self.data.state == SEVEN_DAYS_LOGIN_FETCH_STATE.FETCHED)
	-- self.node_tree.img_reward_name.node:loadTexture(ResPath.GetWelfare("word_reward_" .. index))
	-- self.node_tree.img_select.node:setVisible(self.is_select)
end

function SevenDaysLoginAwardRender:SetRewardState(state)
	-- self.node_tree.img_stamp.node:setVisible(state == SEVEN_DAYS_LOGIN_FETCH_STATE.FETCHED)
end