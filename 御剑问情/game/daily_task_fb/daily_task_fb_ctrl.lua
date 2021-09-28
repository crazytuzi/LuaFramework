require ("game/daily_task_fb/daily_task_fb_data")
require ("game/daily_task_fb/daily_task_fb_view")

DailyTaskFbCtrl = DailyTaskFbCtrl or BaseClass(BaseController)

function DailyTaskFbCtrl:__init()
	if 	DailyTaskFbCtrl.Instance ~= nil then
		print_error("[DailyTaskFbCtrl] attempt to create singleton twice!")
		return
	end
	DailyTaskFbCtrl.Instance = self
	self.view = DailyTaskFbView.New(ViewName.DailyTaskFb)
	self.data = DailyTaskFbData.New()

	self:RegisterAllProtocols()
end

function DailyTaskFbCtrl:__delete()
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.scene_load_complete ~= nil then
		GlobalEventSystem:UnBind(self.scene_load_complete)
		self.scene_load_complete = nil
	end
	self:RemoveDelayTime()
	DailyTaskFbCtrl.Instance = nil
end

function DailyTaskFbCtrl:RegisterAllProtocols()
	self.scene_load_complete = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_QUIT, BindTool.Bind(self.SceneLoadComplete, self))
end

function DailyTaskFbCtrl:SceneLoadComplete(old_scene_type, scene_id)
	if self.timer or old_scene_type ~= SceneType.DailyTaskFb then
		return
	end
	ViewManager.Instance:Close(ViewName.FBVictoryFinishView)
	self.timer = GlobalTimerQuest:AddDelayTimer(function ()
		if old_scene_type == SceneType.DailyTaskFb then
			local daily_task = TaskData.Instance:GetTaskListIdByType(TASK_TYPE.RI)
			if daily_task[1] and TaskData.Instance:GetTaskIsCanCommint(daily_task[1]) then
				TaskCtrl.SendTaskCommit(daily_task[1])
			end
		end
		self:RemoveDelayTime()
	end, 0.5)

end

function DailyTaskFbCtrl:RemoveDelayTime()
	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end