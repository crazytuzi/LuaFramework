------------------------------------------------------
--功能引导
------------------------------------------------------
NextGuideStepFlag = "NextGuideStepFlag"

FunctionGuide = FunctionGuide or BaseClass()
function FunctionGuide:__init()
	if FunctionGuide.Instance ~= nil then
		print_error("[FunctionGuide] attempt to create singleton twice!")
		return
	end
	FunctionGuide.Instance = self

	self.is_open_fun_guide = true					--是否开启整个功能引导

	self.not_find_ui_time = 5						--查找ui时间（找不到则停止引导）

	self.is_welcome_guided = false		--是否欢迎引导过
	self.is_hangup_guided_in_cur_fuben = false 		--是否指引过挂机
	self.is_wait_guiding = false		--是否等待引导中
	self.is_guiding = false
	self.is_pausing = false				--是否暂停引导（只是界面）
	self.is_stop_task = false			--是否强制停止任务
	self.is_week = false				--是否弱指引
	self.cur_guide_cfg = nil
	self.cur_guide_step = 0
	self.get_guide_ui_callback_list = {}
	self.check_gap_time = 0.03
	self.prve_time = 0

	self.is_close_all = false

	self.guide_num = 0

	self.wait_guide_list = {}					--等待引导的列表

	self.is_guide_list = {}

	self.guide_list = ConfigManager.Instance:GetAutoConfig("function_guide_auto").guide_list

	self.normal_guide_view = NormalGuideView.New()
	self.girl_guide_view = GirlGuideView.New()
	self.gesture_view = FunGestureView.New()

	self.mainui_open_complete_handle = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.OnLoadingComplete, self))
	self.player_listen_callback = BindTool.Bind(self.OnRoleAttrValueChange, self)
	self.item_listen_callback = BindTool.Bind(self.OnItemDataChange, self)
	self.task_change_handle = nil
	self.finished_open_fun = nil
end

function FunctionGuide:__delete()
	FunctionGuide.Instance = nil

	if self.normal_guide_view then
		self.normal_guide_view:DeleteMe()
		self.normal_guide_view = nil
	end

	if self.girl_guide_view then
		self.girl_guide_view:DeleteMe()
		self.girl_guide_view = nil
	end

	if self.gesture_view then
		self.gesture_view:DeleteMe()
		self.gesture_view = nil
	end

	if self.mainui_open_complete_handle then
		GlobalEventSystem:UnBind(self.mainui_open_complete_handle)
		self.mainui_open_complete_handle = nil
	end

	if self.task_change_handle then
		GlobalEventSystem:UnBind(self.task_change_handle)
		self.task_change_handle = nil
	end

	if self.finished_open_fun then
		GlobalEventSystem:UnBind(self.finished_open_fun)
		self.finished_open_fun = nil
	end

	if self.not_find_ui_countdown then
		CountDown.Instance:RemoveCountDown(self.not_find_ui_countdown)
		self.not_find_ui_countdown = nil
	end

	if PlayerData.Instance then
		PlayerData.Instance:UnlistenerAttrChange(self.player_listen_callback)
	end
	
	if ItemData.Instance then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_listen_callback)
	end

	Runner.Instance:RemoveRunObj(self)
end

function FunctionGuide:OnLoadingComplete()
	GlobalTimerQuest:AddDelayTimer(function()
		PlayerData.Instance:ListenerAttrChange(self.player_listen_callback)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_listen_callback)
		self.task_change_handle = GlobalEventSystem:Bind(OtherEventType.TASK_CHANGE, BindTool.Bind(self.OnTaskChange, self))
		self.finished_open_fun = GlobalEventSystem:Bind(FinishedOpenFun, BindTool.Bind(self.FinishedOpenFun, self))

		Runner.Instance:AddRunObj(self, 8)
	end, 2)
end

function FunctionGuide:Update(now_time, elapse_time)
	if not self.is_open_fun_guide or self.is_pausing then
		return
	end

	if now_time - self.prve_time < self.check_gap_time then
		return
	end

	self.prve_time = now_time
	self.guide_num = 0

	self:CheckConfigGuide()

	if not self.is_guiding then
		for k, v in pairs(self.wait_guide_list) do
			self:SetCurrentGuideCfg(v)
			if self.is_guiding then
				break
			end
		end
	end

	if self.guide_num == 0 then
		self.is_close_all = false
		self:EndGuide()
	end
end

--获取是否在引导中
function FunctionGuide:GetIsGuide()
	return self.is_guiding
end

function FunctionGuide:GetIsWaitGuide()
	return self.is_wait_guiding
end

function FunctionGuide:DelWaitGuideListByName(guide_name)
	self.wait_guide_list[guide_name] = nil
end

--初始化是否进行过引导的表
function FunctionGuide:InitIsGuideList()
	self.is_guide_list = {}
	local guide_cfg = self.cur_guide_cfg or {}
	local step_list = guide_cfg.step_list or {}
	for i = 1, #step_list do
		self.is_guide_list[i] = false
	end
end

function FunctionGuide:StartGuide(guide_cfg)
	-- print_error("触发引导-------------->",guide_cfg.guide_name)
	self.cur_guide_cfg = guide_cfg
	self.cur_guide_step = 0
	self:StartNextStep()
	self:InitIsGuideList()
	GlobalEventSystem:Fire(MainUIEventType.CHNAGE_FIGHT_STATE_BTN, false)
end

function FunctionGuide:EndGuide()
	if self.is_guiding then
		-- print_error("结束引导-------------->")
		if self.is_stop_task then
			self.is_stop_task = false
			TaskCtrl.Instance:SetAutoTalkState(true)
		end
		if self.cur_guide_cfg then
			self.wait_guide_list[self.cur_guide_cfg.guide_name] = nil
		end

		self.is_guiding = false
		self.cur_guide_cfg = nil
		self.cur_guide_step = 0
		if self.normal_guide_view:IsOpen() then
			self.normal_guide_view:Close()
		end
	end
end

--获得经过解析参数，或指定index，则返回指定的，否则返回参数表
function FunctionGuide:GetParam(param,index)
	local pos = string.find(param, "#")
	if pos == nil then
		if index == nil then
			return {[1] = param}
		else
			return param
		end
	end
	local t = Split(param,"#")
	if t ~= nil then
		if index == nil then
			return t
		else
			return t[index]
		end
	end
	return nil
end

function FunctionGuide:OnRoleAttrValueChange(key, new_value, old_value)
	if not self.is_open_fun_guide then return end
	local guide_cfg = nil
	if key == "level" then
		guide_cfg = self:GetGuideCfgByTrigger(GuideTriggerType.LevelUp, new_value)
	end

	if guide_cfg then
		self:SetCurrentGuideCfg(guide_cfg)
	end
end

function FunctionGuide:OnItemDataChange(change_item_id, change_item_index, change_reason)
end

function FunctionGuide:OnTaskChange(task_event_type, task_id)
	if not self.is_open_fun_guide then return end

	local guide_cfg = nil
	if task_event_type == "accepted_add" then
		guide_cfg = self:GetGuideCfgByTrigger(GuideTriggerType.AcceptTask, task_id)
	end

	if task_event_type == "completed_add" then
		guide_cfg = self:GetGuideCfgByTrigger(GuideTriggerType.CommitTask, task_id)
	end

	if guide_cfg then
		self:SetCurrentGuideCfg(guide_cfg)
	end
end

--天数开启的功能引导有改变
function FunctionGuide:OpenSeverDayFunChange()
	local guide_cfg = self:GetGuideCfgByTrigger(GuideTriggerType.OpenServerDay, TimeCtrl.Instance:GetCurOpenServerDay())
	if guide_cfg then
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		if main_role_vo.level >= guide_cfg.with_param then
			self:SetCurrentGuideCfg(guide_cfg)
		end
	end
end

function FunctionGuide:FinishedOpenFun(state)
	-- print_error("FunctionGuide====", state)
	self.is_pausing = state
end

function FunctionGuide:TriggerGuideByGuideName(guide_name)
	for k,v in pairs(self.guide_list) do
		if v.guide_name == guide_name then
			self:SetCurrentGuideCfg(v)
			break
		end
	end
end

function FunctionGuide:TriggerGuideByName(guide_name)
	for k,v in pairs(self.guide_list) do
		if v.guide_name == guide_name then
			--先获取是否已经引导过了
			local temp_id = v.id
			local key = HOT_KEY.GUIDE_KEY_FLAG1
			if temp_id > 16 then
				temp_id = temp_id - 16
				key = HOT_KEY.GUIDE_KEY_FLAG2
			end
			local guide_flag_list = SettingData.Instance:GetSettingDataListByKey(key)
			local flag = guide_flag_list.item_id
			local guide_id_list = bit:d2b(flag)
			if guide_id_list[32-temp_id] == 1 then				--等于1则表示已经引导过了
				return
			end
			self.wait_guide_list[guide_name] = v
			-- self:SetCurrentGuideCfg(v)
			break
		end
	end
end

function FunctionGuide:TriggerGuideById(guide_id)
	guide_id = tonumber(guide_id)
	for k,v in pairs(self.guide_list) do
		if v.id == guide_id then
			self:SetCurrentGuideCfg(v)
			break
		end
	end
end

function FunctionGuide:GetGuideUi(module_name, ui_name, ui_param)
	local list = self.get_guide_ui_callback_list[module_name]
	local ui = nil
	local clickCallback
	local param_1 = nil
	if list ~= nil then
		for _, v in ipairs(list) do
			ui, clickCallback = v(ui_name, ui_param)
			if ui ~= nil then
				break
			end
		end
	end
	return ui, clickCallback
end

--各个模块注册引导取ui的方法
--get_guide_ui_callback。方法提供ui_name，ui_param参数，用于获取实际ui对象
function FunctionGuide:RegisteGetGuideUi(module_name, get_guide_ui_callback)
	if module_name == nil or get_guide_ui_callback == nil then
		return
	end

	if self.get_guide_ui_callback_list[module_name] == nil then
		self.get_guide_ui_callback_list[module_name] = {}
	end

	local list = self.get_guide_ui_callback_list[module_name]
	for _,v in ipairs(list) do
		if v == get_guide_ui_callback then
			return
		end
	end
	table.insert(list, get_guide_ui_callback)
end

function FunctionGuide:UnRegiseGetGuideUi(module_name)
	self.get_guide_ui_callback_list[module_name] = nil
end

function FunctionGuide:UnRegiseGetGuideUiByFun(module_name, get_guide_ui_callback)
	local list = self.get_guide_ui_callback_list[module_name]
	for k,v in ipairs(list) do
		if v == get_guide_ui_callback then
			table.remove(list, k)
			break
		end
	end
end

function FunctionGuide:GetRegisteGuideNum(t)
	for k1, v1 in pairs(self.get_guide_ui_callback_list) do
		local num = 0
		for k2, v2 in pairs(v1) do
			num = num + 1
		end

		t["guide : " .. k1] = num
	end
end

function FunctionGuide:GetGuideCfgByTrigger(trigger_type, trigger_param)
	for k,v in pairs(self.guide_list) do
		if v.trigger_type == trigger_type then
			if v.trigger_param == trigger_param then
				return v
			end
		end
	end
	return nil
end

function FunctionGuide:SetCurrentGuideCfg(guide_cfg)
	if self.cur_guide_cfg ~= guide_cfg then
		if guide_cfg ~= nil then
			self:EndGuide()
			self:StartGuide(guide_cfg)
		else
			self:EndGuide()
		end
	end
end

--获得下一步是否是美女介绍类
function FunctionGuide:GetNextStepIsIntroduce()
	local next_step_cfg = self:GetGuideStepCfg(self.cur_guide_cfg, self.cur_guide_step + 1)
	if next_step_cfg ~= nil and next_step_cfg.unuseful ~= 1 and next_step_cfg.step_type == GuideStepType.Introduce then
		return true
	end
	return false
end

function FunctionGuide:CheckConfigGuide()
	self.is_wait_guiding = false

	--配置的引导
	if self.cur_guide_cfg == nil then
		return
	end

	if self.is_pausing then
		self.is_wait_guiding = true
		return
	end

	local step_cfg = self:GetGuideStepCfg(self.cur_guide_cfg, self.cur_guide_step)
	if step_cfg == nil then
		return
	end

	if self.cur_guide_step == 1 and step_cfg.step_type ~= GuideStepType.FindUi then
		--如果第一步不是找ui的话就停止任务关闭所有界面
		self.is_guiding = true
		local is_auto_stop_task = Scene.Instance:GetSceneLogic():IsAutoStopTaskOnGuide()
		if is_auto_stop_task then
			TaskCtrl.Instance:SetAutoTalkState(false)		--停止接受任务
			self.is_stop_task = true
		end

		--只关闭一次界面
		if not self.is_close_all then
			self.is_close_all = true
			ViewManager.Instance:CloseAll()
			GlobalEventSystem:Fire(MainUIEventType.CHNAGE_FIGHT_STATE_BTN, false)
			GlobalEventSystem:Fire(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, false, false, true)
		end
	else
		if self.cur_guide_step == 2 and not self.is_guiding then
			--第一次进入引导后该做的事情
			self.is_guiding = true
			--保存引导标记到服务端
			local temp_id = self.cur_guide_cfg.id
			local key = HOT_KEY.GUIDE_KEY_FLAG1
			if temp_id > 16 then
				temp_id = temp_id - 16
				key = HOT_KEY.GUIDE_KEY_FLAG2
			end
			local guide_flag_list = SettingData.Instance:GetSettingDataListByKey(key)
			local flag = guide_flag_list.item_id
			local guide_id_list = bit:d2b(flag)												--转换为32位表
			guide_id_list[32-temp_id] = 1 													--标记已引导过了
			flag = bit:b2d(guide_id_list)													--重新转换为number
			guide_flag_list.item_id = flag													--保存到本地
			SettingCtrl.Instance:SendChangeHotkeyReq(key, flag)								--发送给服务器保存
		end
	end

	if step_cfg.step_type == GuideStepType.FindUi then
		--查找ui是否存在（找到后才开始真正的引导）
		self.guide_num = self.guide_num + 1
		local ui = self:GetGuideUi(step_cfg.module_name, step_cfg.ui_name, step_cfg.ui_param)
		if nil ~= ui then				--找到直接开始下一步
			self.is_guide_list[self.cur_guide_step] = true
			self:StartNextStep()
		end
	elseif step_cfg.step_type == GuideStepType.AutoOpenView then
		--自动打开面板
		self.guide_num = self.guide_num + 1
		self:AutoOpenView(step_cfg.module_name, step_cfg.ui_name, step_cfg.ui_param)
		self.is_guide_list[self.cur_guide_step] = true
	elseif step_cfg.step_type == GuideStepType.AutoCloseView then
		--自动关闭面板
		self.guide_num = self.guide_num + 1
		self:AutoCloseView(step_cfg.module_name, step_cfg.ui_name, step_cfg.ui_param)
		self.is_guide_list[self.cur_guide_step] = true
	elseif step_cfg.step_type == GuideStepType.Introduce then --美女介绍
		self.guide_num = self.guide_num + 1
		self.girl_guide_view:SetStepCfg(step_cfg)
		if not self.girl_guide_view:IsOpen() then
			self.girl_guide_view:Open()
		end
		self.girl_guide_view:Flush()
		self.girl_guide_view:SetIsNeedCloseOnClick(not self:GetNextStepIsIntroduce()) 	--如果下个是介绍类的，则当前介绍类的不关闭
		self.is_guide_list[self.cur_guide_step] = true
	elseif step_cfg.step_type == GuideStepType.Arrow or step_cfg.step_type == GuideStepType.GirlGuide then --指引方式为找到ui
		self.guide_num = self.guide_num + 1
		local ui, callback = self:GetGuideUi(step_cfg.module_name, step_cfg.ui_name, step_cfg.ui_param)
		if ui == NextGuideStepFlag then		--直接跳至下一引导的标记
			self.is_guide_list[self.cur_guide_step] = true
			self:StartNextStep()
		else
			if ui then
				self.is_guide_list[self.cur_guide_step] = true
				if self.not_find_ui_countdown then
					CountDown.Instance:RemoveCountDown(self.not_find_ui_countdown)
					self.not_find_ui_countdown = nil
				end
				step_cfg = self:GetGuideStepCfg(self.cur_guide_cfg, self.cur_guide_step)
				self:UpdateGuideStep(ui, callback, step_cfg)
			else
				if self.normal_guide_view:IsOpen() then
					self.normal_guide_view:Close()
				end

				--当前引导为弱指引的话直接停止整个引导
				if self.is_guide_list[self.cur_guide_step] and step_cfg.is_modal == 0 then
					self:EndGuide()
					return
				end

				local function timer_func(elapse_time, total_time)
					if elapse_time >= total_time then
						CountDown.Instance:RemoveCountDown(self.not_find_ui_countdown)
						self.not_find_ui_countdown = nil
						print("停止引导++++++++++++++++++")
						self:EndGuide()
						return
					end
				end
				if not self.not_find_ui_countdown then
					--只找5秒，找不到直接停止引导
					self.not_find_ui_countdown = CountDown.Instance:AddCountDown(self.not_find_ui_time, 1, timer_func)
				end
				-- print_error("没有找到ui----------------------->功能引导专用打印", step_cfg.module_name, step_cfg.ui_name, step_cfg.ui_param)
			end
		end
	elseif step_cfg.step_type == GuideStepType.Gesture then --手势引导
		self.guide_num = self.guide_num + 1
		if not self.gesture_view:IsOpen() then
			self.gesture_view:Open()
		end
		self.gesture_view:SetGestureCallBack(tonumber(self:GetParam(step_cfg.step_param, 1)), BindTool.Bind1(self.StartNextStep,self))
	end
end

function FunctionGuide:AutoMain(ui_name, state)
	local list = self.get_guide_ui_callback_list[ViewName.Main]
	if list then
		for _, v in ipairs(list) do
			v(ui_name, state)
		end
	end
end

function FunctionGuide:AutoOpenView(module_name, ui_name, ui_param)
	if module_name == nil or module_name == "" then
		return
	end
	if module_name == ViewName.Main then
		self:AutoMain(ui_name, MainViewOperateState.AutoOpen)
	else
		ViewManager.Instance:Open(module_name)
	end
	self:StartNextStep()
end

function FunctionGuide:AutoCloseView(module_name, ui_name, ui_param)
	if module_name == nil or module_name == "" then
		return
	end
	if module_name == ViewName.Main then
		self:AutoMain(ui_name, MainViewOperateState.AutoClose)
	else
		ViewManager.Instance:Close(module_name)
	end
	self:StartNextStep()
end

function FunctionGuide:UpdateGuideStep(ui, callback, step_cfg)
	if not self.normal_guide_view:IsOpen() then
		self.normal_guide_view:SetBtnObj(ui)
		self.normal_guide_view:SetClickCallBack(callback)
		self.normal_guide_view:SetStepCfg(step_cfg)
		self.normal_guide_view:SetIsFrist(true)
		self.normal_guide_view:Open()
	else
		self.normal_guide_view:SetIsFrist(false)
		self.normal_guide_view:Flush()
	end
end

function FunctionGuide:EndCurStep()
	self.normal_guide_view:Close()
end

function FunctionGuide:StartNextStep()
	self:EndCurStep()

	while true do
		self.cur_guide_step = self.cur_guide_step + 1
		local step_cfg = self:GetGuideStepCfg(self.cur_guide_cfg, self.cur_guide_step)
		if step_cfg == nil then				--已没有下一步
			self:EndGuide()
			return
		elseif step_cfg.unuseful ~= 1 then	--下一步可用
			self:CheckConfigGuide()
			return
		end
	end
end

--获取上一个引导的数据
function FunctionGuide:GetLastGuideStepCfg()
	if self.cur_guide_cfg and self.cur_guide_cfg.step_list then
		return self.cur_guide_cfg.step_list[self.cur_guide_step - 1]
	end
	return nil
end

function FunctionGuide:GetGuideStepCfg(guide_cfg, step)
	if guide_cfg ~= nil and guide_cfg.step_list ~= nil then
		return guide_cfg.step_list[step]
	end
	return nil
end