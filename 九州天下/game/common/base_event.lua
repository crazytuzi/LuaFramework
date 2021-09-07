BaseEvent = BaseEvent or BaseClass()

function BaseEvent:__init()
	self.listener_list = {}
end

function BaseEvent:__delete()

end

function BaseEvent:GetTotalEventNum()
	local num = 0
	for _, v1 in pairs(self.listener_list) do
		for _, v2 in pairs(v1) do
			num = num + 1
		end
	end

	return num
end

-- 添加事件
function BaseEvent:AddEvent(event_id)
	self.listener_list[event_id] = {}
end

-- 添加监听回调
function BaseEvent:AddListener(event_id, callback)
	if nil == self.listener_list[event_id] then
		print_error("BaseEvent:AddListener Error:not find Event" .. event_id)
		return
	end
	self.listener_list[event_id][callback] = callback
end

--移除监听回调
function BaseEvent:RemoveListener(event_id, callback)
	if nil == self.listener_list[event_id] then
		print_error("BaseEvent:RemoveListener Error:not find Event" .. event_id)
		return
	end
	self.listener_list[event_id][callback] = nil
end

--事件处理
function BaseEvent:NotifyEventChange(event_id, ...)
	if nil == self.listener_list[event_id] then
		print_error("BaseEvent:NotifyEvent Error:not find Event" .. event_id)
		return
	end
	for k, v in pairs(self.listener_list[event_id]) do
		v(...)
	end
end

