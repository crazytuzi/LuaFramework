TaskSlideView = TaskSlideView or BaseClass(BaseView)

function TaskSlideView:__init()
	self.ui_config = {"uis/views/taskview", "TaskSlideView"}
	self.play_audio = true

	self.slide_num = 0

	self.yingjiumeiren_task_id = 0

	self.phase_num_1 = 5				-- 割绳子第一阶段数
	self.phase_num_2 = 10   			-- 割绳子第二阶段数
	self.phase_max_num = 10				-- 割绳子最大阶段的数

	self.is_count_down_finish = false
	self.next_slide_time = 0

	self.click_down = false
	self.touch_state = false
	self.is_saved = false       --美人是否拯救成功（割完绳子）
	self:SetMaskBg(true)

end

function TaskSlideView:__delete()
end

function TaskSlideView:ReleaseCallBack()
	self.npc_img = nil
	self.time_slider = nil
	self.img_beauty_asset = nil
	self.npc_dialog_string = nil
	self.npc_name_string = nil
	self.desc_text = nil
	self.show_text = nil
	self:ClearTimer()
end

function TaskSlideView:LoadCallBack()
	self:ListenEvent("Close", BindTool.Bind(self.OnClose, self))
	self:ListenEvent("OnUpClick", BindTool.Bind(self.OnUpClickHandler, self))
	self:ListenEvent("OnDownClick", BindTool.Bind(self.OnDownClickHandler, self))
	self.npc_img = self:FindObj("npc_img")						--美人NPC Obj
	self.time_slider = self:FindObj("time_slider")				--进度条 Obj
	self.img_beauty_asset = self:FindVariable("Img_beauty")		--美人NPC图片资源路径
	self.npc_dialog_string = self:FindVariable("npc_dialog")	--NPC对话内容
	self.npc_name_string = self:FindVariable("npc_name")		--NPC姓名
	self.desc_text = self:FindVariable("desc_text")
	self.show_text = self:FindVariable("ShowText")
	self:CalTime()
end

function TaskSlideView:OpenCallBack()
	self.slide_num = 0
	Runner.Instance:AddRunObj(self, 9)
	self.click_down = false
	self.is_count_down_finish = false

	--初始化
	self.img_beauty_asset:SetAsset(self:GetAssetPath(0))
	self.is_saved = false
	self.time_slider.slider.value = 0
	self.sliderTargetValue = 0
	self:SetTalk(0)
end

function TaskSlideView:CloseCallBack()
	self.slide_num = 0
	self.click_down = false
	self.is_count_down_finish = false
	self.touch_state = false
	Runner.Instance:RemoveRunObj(self)
	-- 	TaskCtrl.Instance:DoTask(TaskData.Instance:GetHoldMeirenTaskId())
	MainUICtrl.Instance:SetTaskAutoState(true)
end

function TaskSlideView:Update(now_time, elapse_time)
	if not self.touch_state and self:IsTouchDown() then
		self.touch_state = true
		-- self.click_down = true
	end

	if self.touch_state then
		if self:IsTouchUp() then
			self.touch_state = false
			-- self.click_down = false
		else
			if self.touch_state then
				self:OnTouchMove()
			end
		end
	end
	
	--进度条过渡插值
	if  self.time_slider.slider.value ~=  self.sliderTargetValue then 
		self.time_slider.slider.value = self.time_slider.slider.value + elapse_time * 0.3
		if self.time_slider.slider.value > self.sliderTargetValue then
			self.time_slider.slider.value = self.sliderTargetValue
		end
	end

	if self.is_count_down_finish then
		if now_time >= self.next_slide_time then
			self.next_slide_time = now_time + 0.5
			self:SlideRope()
		end
	end
end

function TaskSlideView:OnClose()
	self:Close()
end

function TaskSlideView:OnFlush(param_list)
	for k, v in pairs(param_list) do
		if k == "zhuxian_meiren" then
			self.yingjiumeiren_task_id = TaskData.Instance:GetYingJiuMeirenTaskId()
		elseif k == "zhixian_meiren" then
			self.yingjiumeiren_task_id = TaskData.Instance:GetOtherYingJiuMeirenTaskId()
		end
	end
	TaskCtrl.SendTaskAccept(self.yingjiumeiren_task_id)

	self:SetName()
end

function TaskSlideView:OnUpClickHandler()
	self.click_down = false
end

function TaskSlideView:OnDownClickHandler()
	self.click_down = true
	-- self.begin_pos = UnityEngine.Input.mousePosition
end

function TaskSlideView:IsTouchDown()
	--0是左键, touchCount触摸数量
	return UnityEngine.Input.GetMouseButtonDown(0) or UnityEngine.Input.touchCount > 0
end

function TaskSlideView:IsTouch()
	return UnityEngine.Input.GetMouseButton(0)
end

function TaskSlideView:IsTouchUp()
	return UnityEngine.Input.GetMouseButtonUp(0)
end

--设置NPC对话
function TaskSlideView:SetTalk(id)

	--获取救美人任务配置
	local task_config = TaskData.Instance:GetTaskConfig(self.yingjiumeiren_task_id)   
	--根据任务配置的 提交对话(commit_dialog) 获取对话配置
	if task_config == nil or task_config.accept_dialog == nil then return end
	local talk_cfg = TaskData.Instance.npc_talk_list[task_config.accept_dialog]
	if talk_cfg then
		talk_content = talk_cfg.talk_text        			--对话内容 
		if not talk_content then return end
		talk_content_table = Split(talk_content, "|")		--分割对话内容
		local cur_talk_content = talk_content_table[id+1]
		--忽略{npc}
		local i,j = string.find(cur_talk_content, "{npc}")
		if i ~= nil and j ~= nil then
			cur_talk_content = string.sub(cur_talk_content, j + 1, -1)
		end
		--忽略{plr}
		local i,j = string.find(cur_talk_content, "{plr}")
		if i ~= nil and j ~= nil then
			cur_talk_content = string.sub(cur_talk_content, j + 1, -1)
		end
		self.npc_dialog_string:SetValue(cur_talk_content)
	end
end

--根据切割次数控制图片、文字的转换和判定是否拯救成功
function TaskSlideView:BeautyImgCtrl()
	if self.slide_num < self.phase_num_1 then
		self.img_beauty_asset:SetAsset(self:GetAssetPath(0))
		self:SetTalk(0)
	elseif self.slide_num < self.phase_num_2 then
		self.img_beauty_asset:SetAsset(self:GetAssetPath(1))
		self:SetTalk(1)
	else
		self.img_beauty_asset:SetAsset(self:GetAssetPath(2))
		self:SetTalk(2)
		self.is_saved = true 													--表明拯救成功

		TaskCtrl.SendTaskCommit(self.yingjiumeiren_task_id)
		MainUICtrl.Instance:SetTaskAutoState(false)
		GlobalTimerQuest:AddDelayTimer(function() self:OnClose() end, 3)		--延迟三秒关闭窗口
	end
end

--切割次数+1
function TaskSlideView:AddSlideNum()
	self.slide_num = self.slide_num + 1	
	self.sliderTargetValue = self.slide_num / self.phase_max_num				--进度条控制
	self:BeautyImgCtrl()														--图片切换和成功判定
end


--获取NPC图片资源路径
function TaskSlideView:GetAssetPath(id)
	id = id % 3

	if GLOBAL_CONFIG.param_list.is_audit_android and GLOBAL_CONFIG.param_list.is_audit_android == 1 then
		id = 0
	end

	return ResPath.GetRawImage("task_slide_beauty" .. id)
end

function TaskSlideView:OnTouchMove()
	local pos = self.npc_img.transform.anchoredPosition3D  						--NPC图片位置
	local size = self.npc_img.transform.sizeDelta								--NPC图片大小

	local width = UnityEngine.Screen.width
	local height = UnityEngine.Screen.height

	if self.click_down and not self.is_saved and self.begin_pos 
		and self.begin_pos.x > width / 2 + pos.x-size.x/2 		--限定鼠标滑动位置
		and self.begin_pos.x < width / 2 + pos.x+size.x/2
		and self.begin_pos.y > height / 2 + pos.y-size.y/2 
		and self.begin_pos.y < height / 2 + pos.y+size.y/2  then

		self:ClearTimer()
		self.show_text:SetValue(false)

		local begin_pos_x, begin_pos_y = self.begin_pos.x, self.begin_pos.y
		local begin_pos = Vector3(begin_pos_x, begin_pos_y, 0)

		--获取鼠标当前坐标位置
		local end_pos_x, end_pos_y = UnityEngine.Input.mousePosition.x, UnityEngine.Input.mousePosition.y
		local end_pos = Vector3(end_pos_x, end_pos_y, 0)

		local delta_pos = u3d.v2Sub(end_pos, begin_pos)				--开始坐标到结束坐标的向量
		local move_total_distance = u3d.v2Length(delta_pos)			--向量的模
		local move_dir = u3d.v2Normalize(delta_pos)					--向量的方向

		if move_total_distance > 150 then		
			local z = math.deg(math.atan2(move_dir.y, move_dir.x))	--计算向量与X轴的夹角(弧度制)，再转换成角度制
			local rotation = Quaternion.Euler(0, 0, z)				--确定特效旋转值
			EffectManager.Instance:PlayAtTransform("effects2/prefab/ui/ui_daoguang_01_prefab", "UI_daoguang_01", self.npc_img.transform, 1.0, nil, rotation)	--播放特效
			self:AddSlideNum()										--切割次数+1
			self.click_down = false
		end
	else
		self.begin_pos = UnityEngine.Input.mousePosition
		self.click_down = true
	end
end

-- 设置Npc名字
function TaskSlideView:SetName()
	local task_cfg = TaskData.Instance:GetTaskConfig(self.yingjiumeiren_task_id)
	if task_cfg and task_cfg.accept_npc then
		local npc_cfg = TaskData.Instance:GetNpcInfoCfgById(task_cfg.accept_npc.id)
		if npc_cfg and npc_cfg.show_name then
			self.npc_name_string:SetValue(npc_cfg.show_name)
		end
	end
end

function TaskSlideView:CalTime()
	self:ClearTimer()

	local timer_cal = 10
	self.cal_time_quest = GlobalTimerQuest:AddRunQuest(function()
		timer_cal = timer_cal - UnityEngine.Time.deltaTime
		if timer_cal <= 0 then
			self.is_count_down_finish = true
			self.show_text:SetValue(false)
		else
			self.is_count_down_finish = false
			self.desc_text:SetValue(math.floor(timer_cal))
		end
	end, 0)
end

function TaskSlideView:ClearTimer()
	if self.cal_time_quest then
		GlobalTimerQuest:CancelQuest(self.cal_time_quest)
		self.cal_time_quest = nil
	end
end

function TaskSlideView:SlideRope()
	local z = math.random(0, 360)
	local rotation = Quaternion.Euler(0, 0, z)
	EffectManager.Instance:PlayAtTransform("effects2/prefab/ui/ui_daoguang_01_prefab", "UI_daoguang_01", self.npc_img.transform, 1.0, nil, rotation)	--播放特效
	self:AddSlideNum()	
end
