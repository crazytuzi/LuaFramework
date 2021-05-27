
TimerQuest = TimerQuest or BaseClass()

function TimerQuest:__init()
	self.quest_list = {}

	Runner.Instance:AddRunObj(self, 10)
end

function TimerQuest:__delete()
	self.quest_list = nil
	Runner.Instance:RemoveRunObj(self)
end

function TimerQuest:Update(now_time, elapse_time)
	local callback_list = {}
	local delete_list = {}

	for k, v in pairs(self.quest_list) do
		if v[4] <= 0 then
			table.insert(delete_list, k)
		else
			if v[3] <= now_time then
				table.insert(callback_list, k)
				v[3] = v[3] + v[2]
				v[4] = v[4] - 1
			end
		end
	end

	for k, v in pairs(delete_list) do
		self.quest_list[v] = nil
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

-- callback:执行方法
-- delay_time:回调时间间隔，时间单位是秒
-- times:回调次数
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
