
TimerQuest = TimerQuest or BaseClass()

function TimerQuest:__init()
	self.quest_list = {}

	Runner.Instance:AddRunObj(self, 4)
end

function TimerQuest:__delete()
	self.quest_list = {}
	Runner.Instance:RemoveRunObj(self)
end

function TimerQuest:Update(now_time, elapse_time)
	local callback_list = {}

	for k, v in pairs(self.quest_list) do
		if v[4] <= 0 then
			self.quest_list[k] = nil
		else
			if v[3] <= now_time then
				table.insert(callback_list, k)
				v[3] = now_time
				v[3] = v[3] + v[2]
				v[4] = v[4] - 1
			end
		end
	end

	local quest = nil
	for k, v in pairs(callback_list) do
		quest = self.quest_list[v]
		if nil ~= quest then
			quest[1]()
		end
	end
end

function TimerQuest:AddDelayTimer(callback, delay_time)
	return self:AddTimesTimer(callback, delay_time, 1)
end

function TimerQuest:AddTimesTimer(callback, delay_time, times)
	local t = {callback, delay_time, Status.NowTime + delay_time, times}
	self.quest_list[t] = t
	return t
end

function TimerQuest:AddRunQuest(callback, delay_time)
	return self:AddTimesTimer(callback, delay_time, 999999999)
end

function TimerQuest:CancelQuest(quest)
	if quest == nil then return end

	self.quest_list[quest] = nil
end

function TimerQuest:EndQuest(quest)
	if quest == nil then return end

	if self.quest_list[quest] ~= nil then
		local callback = self.quest_list[quest][1]
		self.quest_list[quest] = nil
		callback()
	end
end

function TimerQuest:GetRunQuest(quest)
	if nil == quest then return nil end

	return self.quest_list[quest]
end

function TimerQuest:IsExistCallback(callback)
	for k, v in pairs(self.quest_list) do
		if v[1] == callback then
			return true
		end
	end

	return false
end