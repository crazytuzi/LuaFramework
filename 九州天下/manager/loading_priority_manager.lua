-- 加载优先级管理器
LoadingPriorityManager = LoadingPriorityManager or BaseClass()

LoadingPriority = {
	Low = 0,
    BelowNormal = 1,
    Normal = 2,
    High = 4
}

function LoadingPriorityManager:__init()
	if LoadingPriorityManager.Instance ~= nil then
		print_error("LoadingPriorityManager to create singleton twice!")
	end
	LoadingPriorityManager.Instance = self

	self.priority_request = {}
	self.priority_id = 0
	self.priority = LoadingPriority.Low
	UnityEngine.Application.backgroundLoadingPriority =
		UnityEngine.ThreadPriority.Low
end

function LoadingPriorityManager:__delete()
	LoadingPriorityManager.Instance = nil
end

function LoadingPriorityManager:RequestPriority(priority)
	if priority > self.priority then
		self:SetPriority(priority)
	end

	self.priority_id = self.priority_id + 1
	self.priority_request[self.priority_id] = priority
	return self.priority_id
end

function LoadingPriorityManager:CancelRequest(priority_id)
	self.priority_request[priority_id] = nil

	local priority = LoadingPriority.Low
	for k,v in pairs(self.priority_request) do
		if v > priority then
			priority = v
		end
	end

	if priority ~= self.priority then
		self:SetPriority(priority)
	end
end

function LoadingPriorityManager:SetPriority(priority)
	self.priority = priority
	if priority == LoadingPriority.Low then
		UnityEngine.Application.backgroundLoadingPriority =
			UnityEngine.ThreadPriority.Low
	elseif priority == LoadingPriority.BelowNormal then
		UnityEngine.Application.backgroundLoadingPriority =
			UnityEngine.ThreadPriority.BelowNormal
	elseif priority == LoadingPriority.Normal then
		UnityEngine.Application.backgroundLoadingPriority =
			UnityEngine.ThreadPriority.Normal
	elseif priority == LoadingPriority.High then
		UnityEngine.Application.backgroundLoadingPriority =
			UnityEngine.ThreadPriority.High
	end
end
