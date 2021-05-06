local CTeachCtrl = class("CTeachCtrl", CCtrlBase)

function CTeachCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self:ResetCtrl()
end

function CTeachCtrl.ResetCtrl(self)
	self.m_NeedOpenView = false
	self.m_Progress = 0
	self.m_ProgressRewardStatus = 0
end

function CTeachCtrl.OpenTeach(self)
	-- if data.globalcontroldata.GLOBAL_CONTROL.teach.is_open == "y" then
		-- CTeachView:ShowView()
	-- else
		g_NotifyCtrl:FloatMsg("该功能正在维护，已临时关闭。请您留意官网相关信息。")
	-- end
end

function CTeachCtrl.GetProgress(self)
	return self.m_Progress
end

function CTeachCtrl.IsNeedRedDot(self)
	--有未领取的奖励
	local taskInfo = g_TaskCtrl:GetTaskListByType(define.Task.TaskType.TASK_TEACH)
	for k,v in pairs(taskInfo) do
		if v.m_SData.statusinfo.status == define.Task.TaskStatus.Done then
			return true
		end
	end

	for k,v in pairs(data.teachdata.ProgressReward) do
		if MathBit.andOp(self.m_ProgressRewardStatus, 2 ^ (v.progress - 1)) == 0 and v.progress <= self.m_Progress then
			return true
		end
	end

	return false
end

function CTeachCtrl.OnUpdateTeachProgress(self, times, status)
	self.m_Progress = times
	self.m_ProgressRewardStatus = status
	self:OnEvent(define.Teach.Event.OnUpdateProgressInfo)
end

function CTeachCtrl.GetMaxProgress(self)
	if self.m_MaxProgress == nil then
		self.m_MaxProgress = 0
		for k,v in pairs(data.teachdata.ProgressReward) do
			if v.progress > self.m_MaxProgress then
				self.m_MaxProgress = v.progress
			end
		end
	end
	return self.m_MaxProgress
end

function CTeachCtrl.GetProgressRewardStatus(self, progressID)
	local oData = data.teachdata.ProgressReward[progressID]
	-- printc("self.m_ProgressRewardStatus：" .. self.m_ProgressRewardStatus)
	-- printc("2 ^ (oData.progress - 1): " .. 2 ^ (oData.progress - 1))
	if MathBit.andOp(self.m_ProgressRewardStatus, 2 ^ (oData.progress - 1)) ~= 0 then
		--已领
		return define.Teach.Status.GotReward
	elseif oData.progress <= self.m_Progress then
		--已达到
		return define.Teach.Status.Done
	else
		--未达到
		return define.Teach.Status.Doing
	end
end

function CTeachCtrl.IsOver(self)
	local count = 0
	for k,v in pairs(data.teachdata.DATA) do
		if v.min_lv < 999 and v.show == 1 then
			count = count + 1
		end
	end

	if self.m_Progress < count then
		return false
	end

	local taskInfo = g_TaskCtrl:GetTaskListByType(define.Task.TaskType.TASK_TEACH)
	if table.count(taskInfo) > 0 then
		return false
	end

	for k,v in pairs(data.teachdata.ProgressReward) do
		if self:GetProgressRewardStatus(v.id) ~= define.Teach.Status.GotReward then
			return false
		end
	end
	return true
end

function CTeachCtrl.CanGetProgressReward(self)
	for k,v in pairs(data.teachdata.ProgressReward) do
		if self:GetProgressRewardStatus(v.id) == define.Teach.Status.Done then
			return true
		end
	end
	return false
end

function CTeachCtrl.IsNeedToShow(self)
	return g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.teach.open_grade and not self:IsOver()
end

function CTeachCtrl.GetMissonData(self, missionID)
	return data.teachdata.DATA[missionID]
end

return CTeachCtrl