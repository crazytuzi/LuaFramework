--------------------------------------------------------
-- 日常任务(降妖除魔) 数据
--------------------------------------------------------

DailyTasksData = DailyTasksData or BaseClass()

DailyTasksData.TASKS_DATA_CHANGE = "tasks_data_change"

function DailyTasksData:__init()
	if DailyTasksData.Instance then
		ErrorLog("[DailyTasksData]:Attempt to create singleton twice!")
	end
	DailyTasksData.Instance = self

	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	self.data = {
		state = 0, -- 任务状态 (0可接任务, 1任务进行中, 2完成)
		goal = '', -- 除魔目标
		times = 0, -- 剩余除魔次数
		stars_num = 0, -- 任务星级
		but_time = 0, --购买次数
	}

	self.text = nil
	self.completed_effect = nil
	self.fly_effect = nil
	self.is_new_task = false
	self.is_open_fly_eff = true -- 飞行特效是否开启
	-- 绑定红点提示触发条件
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindIndex), RemindName.DailyTasksReward)
end

function DailyTasksData:__delete()
	DailyTasksData.Instance = nil
end

----------日常任务data----------

--设置除魔数据(139, 15)
function DailyTasksData:SetData(protocol)
	if protocol.index ~= 7 then
		self.data.state = protocol.state
		self.data.goal = protocol.goal
		self.data.times = protocol.times
		self.data.stars_num = protocol.stars_num
		self.data.but_time = protocol.buy_time
		if self.data.state == 0 then
			-- 日常任务剩余次数为0时,移除在主界面的所有节点
			if self.data.times == 0 then
				self:DeleteDailyTasksView()
			end
		elseif self.data.state == 1 then
			self.is_new_task = true
		elseif self.data.state == 2 then
			if self.is_new_task then
				-- self:FlushTasksText(protocol.goal)
				-- self:PlayCompletedEffect()
				self.data.goal = protocol.goal
			else
			end
		end	
		RemindManager.Instance:DoRemindDelayTime(RemindName.DailyTasksReward)
	else
		-- self:FlushTasksText(protocol.goal)
		self.data.goal = protocol.goal
	end
	self:DispatchEvent(DailyTasksData.TASKS_DATA_CHANGE)
end

--获取除魔数据
function DailyTasksData:GetData()
	return self.data
end

--------------------

-- 获取提醒显示索引 0不显示红点, 1显示红点
function DailyTasksData.GetRemindIndex()
	local data = DailyTasksData.Instance:GetData()
	local index = data.times > 0 and 1 or 0
	return index
end

----------主界面的"日常任务"视图----------

-- 有已接"日常任务",在主界面显示任务内容 
function DailyTasksData:FlushTasksText(text)
	local right_top = MainuiCtrl.Instance:GetView():GetPartLayout(MainuiView.LAYOUT_PART.RIGHT_TOP)
	local screen_width, screen_height = HandleRenderUnit:GetWidth(), HandleRenderUnit:GetHeight()

	if nil == self.text then
		self.text = RichTextUtil.ParseRichText(nil, text, 21, COLOR3B.GREEN)
		XUI.RichTextSetCenter(self.text)
		self.text:setPosition(screen_width - 230, screen_height - 200)
		right_top:TextLayout():addChild(self.text, 999)
	else
		RichTextUtil.ParseRichText(self.text, text, 22, COLOR3B.GREEN)
		self.text:setVisible(true)
	end
end

-- 播放"任务已完成"特效
function DailyTasksData:PlayCompletedEffect()
	self.is_new_task = false

	local path, name = ResPath.GetEffectUiAnimPath(310)
	if nil == self.completed_effect then
		local right_top = MainuiCtrl.Instance:GetView():GetPartLayout(MainuiView.LAYOUT_PART.RIGHT_TOP)
		local screen_width, screen_height = HandleRenderUnit:GetWidth(), HandleRenderUnit:GetHeight()
		
		self.completed_effect = AnimateSprite:create(path, name, 1, FrameTime.Effect, false)
		self.completed_effect:addEventListener(function(sender, event_type, frame)
			if event_type == AnimateEventType.Stop then
				if self.is_open_fly_eff then
					self:PlayFlyEffect()
				else
					self.text:setVisible(false)
				end
			end
		end)

		self.completed_effect:setPosition(screen_width - 230, screen_height - 270)
		right_top:TextLayout():addChild(self.completed_effect, 999)
	else
		self.completed_effect:setAnimate(path, name, 1, 0.1, false)
	end
end

function DailyTasksData:PlayFlyEffect()
	local right_top = MainuiCtrl.Instance:GetView():GetPartLayout(MainuiView.LAYOUT_PART.RIGHT_TOP)
	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(331)
	local node = ViewManager.Instance:GetUiNode("MainUi", "DailyTasks")
	local move_end_pos = node:convertToWorldSpace(cc.p(120,25))

	local fly_eff = AnimateSprite:create(anim_path, anim_name, 3,0.5,false)
	local screen_w, screen_h = HandleRenderUnit:GetWidth(), HandleRenderUnit:GetHeight()
	fly_eff:setPosition(screen_w - 230, screen_h - 270)
	right_top:TextLayout():addChild(fly_eff)
	local callfunc = cc.CallFunc:create(function()
		if fly_eff then
			fly_eff:removeFromParent()
			fly_eff = nil
		end
		if nil ~= self.text then
			self.text:setVisible(false)
		end
		RemindManager.Instance:DoRemindDelayTime(RemindName.DailyTasksReward)
		ViewManager.Instance:OpenViewByDef(ViewDef.DailyTasks)
	end)
	local move = cc.EaseSineIn:create(cc.MoveTo:create(1, move_end_pos))
	local seq = cc.Sequence:create(move, callfunc)
	fly_eff:runAction(seq)
end

-- 设置飞行特效开启
function DailyTasksData:SetFlyEffSwitch(state)
	self.is_open_fly_eff = state
end

-- 移除"日常任务"在主界面的所有节点
function DailyTasksData:DeleteDailyTasksView()
	if nil ~= self.text then
		self.text:removeFromParent()
		self.text = nil
	end
	if nil ~= self.completed_effect then
		self.completed_effect:removeFromParent()
		self.completed_effect = nil
	end
end

-- 获取任务奖励的档次
function DailyTasksData:GetTaskRewIndex()
	local index = 1
	local lv = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	for k, v in pairs(XiangYaoChuMoCfg.reward) do
		if v.maxLv > 0 then
			if lv >= v.minLv and lv <= v.maxLv then
				index = k
				break
			end
		else
			index = k
		end
	end
	return index
end

----------end----------