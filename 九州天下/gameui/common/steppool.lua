
-- 分步计算池，加入池中的对象必需有Step函数

StepPool = StepPool or BaseClass()
function StepPool:__init()
	if StepPool.Instance then
		print_error("[StepPool] Attempt to create singleton twice!")
		return
	end
	StepPool.Instance = self

	self.step_list = {}

	Runner.Instance:AddRunObj(self, 3)
end

function StepPool:__delete()
	Runner.Instance:RemoveRunObj(self)
end

function StepPool:AddStep(obj)
	table.insert(self.step_list, obj)
end

function StepPool:DelStep(obj)
	local step_count = #self.step_list
	for i = step_count, 1, -1 do
		if self.step_list[i] == obj then
			table.remove(self.step_list, i)
		end
	end
end

function StepPool:Update(now_time, elapse_time)
	for i = 1, 1 do
		local obj = table.remove(self.step_list, 1)
		if nil == obj then
			break
		end
		obj:Step()
	end
end
