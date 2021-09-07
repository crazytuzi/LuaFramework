TaskChapterView = TaskChapterView or BaseClass(BaseView)

function TaskChapterView:__init()
	self.ui_config = {"uis/views/taskview", "TaskChapterView"}
	self:SetMaskBg(true)
	self.chapter_data = {}
	self.close_timer = nil
	self.auto_close = nil
	self.is_close = false
end

function TaskChapterView:__delete()
end

function TaskChapterView:ReleaseCallBack()
	self.task_name = nil
	self.taks_content = nil
	self.chapter_icon = nil
	self.chapter_bg = nil
	self.chapter_name = nil
	self.task_desc_1 = nil
	self.task_desc_2 = nil
	self.frame = nil 
	self.chapter_data = {}
	self.frame = nil
	GlobalTimerQuest:CancelQuest(self.close_timer)
	GlobalTimerQuest:CancelQuest(self.auto_close)
end

function TaskChapterView:LoadCallBack()
	TaskCtrl.Instance:CancelTask()
	self.task_name = self:FindVariable("TaskName")
	self.taks_content = self:FindVariable("TaskContent")
	self.chapter_icon = self:FindVariable("chapter_icon")
	self.chapter_bg = self:FindVariable("chapter_bg")
	self.chapter_name = self:FindVariable("chapter_name")
	self.task_desc_1 = self:FindVariable("TaskDesc1")
	self.task_desc_2 = self:FindVariable("TaskDesc2")
	self.frame = self:FindObj("Frame").animator
	
	self:ListenEvent("OnClickClose",BindTool.Bind(self.OnClickClose,self))
end

function TaskChapterView:OpenCallBack()
	self.task_name:SetValue(CommonDataManager.GetDaXie(self.chapter_data.chapter))
	-- self.taks_content:SetValue(self.chapter_data.content)
	self.chapter_name:SetValue(self.chapter_data.title)
	self.chapter_bg:SetValue(self.chapter_data.chapter)
	self.task_desc_1:SetAsset(ResPath.GetTaskBG("task_desc_" .. tonumber(self.chapter_data.content) .. "_0"))
	self.task_desc_2:SetAsset(ResPath.GetTaskBG("task_desc_" .. tonumber(self.chapter_data.content) .. "_1"))

	local bundle, asset = ResPath.GetTaskBG("chapmter_icon_" .. self.chapter_data.chapter)
	self.chapter_icon:SetAsset(bundle, asset)
	
	GlobalTimerQuest:CancelQuest(self.close_timer)
	self.close_timer = GlobalTimerQuest:AddDelayTimer(function ()
		self.is_close = true
	end, 1)
	GlobalTimerQuest:CancelQuest(self.auto_close)
	self.auto_close = GlobalTimerQuest:AddDelayTimer(function ()
		self:OnClickClose()
	end, 5)
end

function TaskChapterView:CloseCallBack()
	-- TaskCtrl.Instance:DoTask(self.chapter_data.task_id)
	local task_cfg = TaskData.Instance:GetZhuTaskConfig()
	if task_cfg and task_cfg.task_id then
		TaskCtrl.Instance:DoTask(task_cfg.task_id)
	end
end

function TaskChapterView:OnFlush(param_list)
end

function TaskChapterView:OnClickClose(param_list)
	if self.is_close == false then return end
	if self.frame.isActiveAndEnabled then
		self.frame:SetBool("fold", true)
		self.frame:WaitEvent("exit", function(param)
			self:Close()
		end)
	end
end

function TaskChapterView:SetChapterData(data)
	if not data then return end
	self.chapter_data = data
	self:Open()
end
-- 切换标签调用
function TaskChapterView:ShowIndexCallBack(index)
	if self.is_close then
		GlobalTimerQuest:CancelQuest(self.auto_close)
		self.auto_close = GlobalTimerQuest:AddDelayTimer(function ()
			self:OnClickClose()
		end, 4)
	end
end
