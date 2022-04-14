-- 
-- @Author: LaoY
-- @Date:   2018-09-05 20:55:58
-- 
TaskEvent = TaskEvent or {
	StartTask 			= "TaskEvent.StartTask",			--开始任务
	FinishTask 			= "TaskEvent.FinishTask",			--完成任务

	--
	ReqTaskList 		= "TaskEvent.ReqTaskList",				--请求任务列表
	AccTaskList 		= "TaskEvent.AccTaskList",				--请求任务列表

	ReqTaskAccept 		= "TaskEvent.ReqTaskAccept",			--接受任务
	AccTaskAccept 		= "TaskEvent.AccTaskAccept",			--接受任务

	ReqTaskSubmit 		= "TaskEvent.ReqTaskSubmit",			--提交任务
	AccTaskSubmit 		= "TaskEvent.AccTaskSubmit",			--提交任务

	ReqTaskQuick 		= "TaskEvent.ReqTaskQuick",				--快速完成
	AccTaskQuick 		= "TaskEvent.AccTaskQuick",				--快速完成

	AccTaskUpdate 		= "TaskEvent.AccTaskUpdate",			--更新任务

	ReqTaskReward 		= "TaskEvent.ReqTaskReward",			--章节奖励
	AccTaskReward 		= "TaskEvent.AccTaskReward",			--章节奖励

	FinishMainTask		= "TaskEvent.FinishMainTask",			--完成某个主线任务

	FinishTask			= "TaskEvent.FinishTask",				--完成任务（所有的，注意区分完成主线）

	GlobalAddTask       = "TaskEvent.GlobalAddTask",            --新增任务事件

	GlobalUpdateTask    = "TaskEvent.GlobalUpdateTask",

	DoTask    			= "TaskEvent.DoTask", 					-- 当前正在做的任务

	UpdateGuild    		= "TaskEvent.UpdateGuild", 				-- 配置的任务引导结束
}