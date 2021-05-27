require("scripts/game/time_limit_task/time_limit_task_data")
require("scripts/game/time_limit_task/time_limit_task_view")
require("scripts/game/time_limit_task/time_limit_task_remind_view")

-- 限时任务
TimeLimitTaskCtrl = TimeLimitTaskCtrl or BaseClass(BaseController)

function TimeLimitTaskCtrl:__init()
	if TimeLimitTaskCtrl.Instance then
		ErrorLog("[TimeLimitTaskCtrl]:Attempt to create singleton twice!")
	end
	TimeLimitTaskCtrl.Instance = self

	self.data = TimeLimitTaskData.New()
	self.view = TimeLimitTaskView.New(ViewDef.TimeLimitTask)
	self.remind_view = TimeLimitTaskRemindView.New(ViewDef.TimeLimitTaskRemind)

	self:RegisterAllProtocols()
end

function TimeLimitTaskCtrl:__delete()
	TimeLimitTaskCtrl.Instance = nil

	self.view:DeleteMe()
	self.view = nil

	self.remind_view:DeleteMe()
	self.remind_view = nil

	self.data:DeleteMe()
	self.data = nil
end

function TimeLimitTaskCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCAllTimeLimitTaskData, "OnAllTimeLimitTaskData")
	self:RegisterProtocol(SCOneTimeLimitTaskData, "OnOneTimeLimitTaskData")
end

function TimeLimitTaskCtrl:OnAllTimeLimitTaskData(protocol)
	for k, v in pairs(protocol.task_data_list) do
		self.data:SetTaskData(v, false)
	end
	self.data:DispatchEvent(TimeLimitTaskData.LIMIT_TASK_DATA_CHG, -1)
end

function TimeLimitTaskCtrl:OnOneTimeLimitTaskData(protocol)
	local task_data = {
		task_type = protocol.task_type,
		done_times = protocol.done_times,
		rec_state = protocol.rec_state,
	}
	self.data:SetTaskData(task_data, true)
end

-----------------------------------------------------------------------------
-- 领取开服限时任务活动奖励
function TimeLimitTaskCtrl.SendRecTimeLimitTaskReward(task_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSRecTimeLimitTaskReward)
	protocol.task_type = task_type or 0
	protocol:EncodeAndSend()
end
