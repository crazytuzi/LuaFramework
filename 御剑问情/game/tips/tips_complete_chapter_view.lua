TipsCompleteChapterView = TipsCompleteChapterView or BaseClass(BaseView)

function TipsCompleteChapterView:__init()
	self.ui_config = {"uis/views/tips/completechapterview_prefab", "CompleteChapterView"}
	self.play_audio = true
	local config = ConfigManager.Instance:GetAutoConfig("fb_scene_config_auto").zhangjie_view
	self.chapter_cfg = ListToMap(config, "start_taskid")
	self.view_layer = UiLayer.PopTop
	self.task_change_handle = GlobalEventSystem:Bind(OtherEventType.TASK_CHANGE,BindTool.Bind(self.OnTaskChange, self))
	self.now_task_id = 0
end

function TipsCompleteChapterView:__delete()
	if nil ~= self.task_change_handle then
		GlobalEventSystem:UnBind(self.task_change_handle)
		self.task_change_handle = nil
	end
end

function TipsCompleteChapterView:ReleaseCallBack()
	-- 清理变量和对象
	self.title = nil
	self.name = nil
	self.des = nil
end

function TipsCompleteChapterView:LoadCallBack()
	self.title = self:FindVariable("Title")
	self.name = self:FindVariable("Name")
	self.des = self:FindVariable("Des")
	self:ListenEvent("Close",BindTool.Bind(self.CloseClick, self))
end

function TipsCompleteChapterView:OpenCallBack()
	self:Flush()
end

function TipsCompleteChapterView:CloseView()
	self:Close()
end

function TipsCompleteChapterView:CloseClick()
	self:Close()
end

function TipsCompleteChapterView:RemoveDelay()
	if nil ~= self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
end

function TipsCompleteChapterView:CloseCallBack()
	self:RemoveDelay()
	TaskCtrl.Instance:SetAutoTalkState(true)
end

function TipsCompleteChapterView:OnTaskChange(task_event_type, task_id)
	if task_event_type ~= "completed_add" then
		return
	end

	if nil == self.chapter_cfg[task_id] then
		return
	end
	TaskCtrl.Instance:SetAutoTalkState(false)
	self.now_task_id = task_id
	if self:IsOpen() then
		self:Flush()
	else
		self:Open()
	end
end

function TipsCompleteChapterView:OnFlush()
	local cfg = self.chapter_cfg[self.now_task_id]
	if nil == cfg then
		return
	end
	self:RemoveDelay()
	if nil == self.timer_quest then
		self.timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.CloseView, self), 4)
	end
	self.name:SetAsset("uis/rawimages/chapter_name_" .. cfg.zhangjie_id, "chapter_name_" .. cfg.zhangjie_id .. ".png")
	self.title:SetAsset("uis/views/tips/completechapterview/images_atlas", "chapter_title_" .. cfg.zhangjie_id .. ".png")
	self.des:SetValue(cfg.zhangjie_content)
end