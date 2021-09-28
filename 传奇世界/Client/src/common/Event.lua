--Author:		bishaoqing
--DateTime:		2016-04-25 19:26:39
--Region:		Event事件处理器
Event = {
	map = {},
	list = {},
}

Event.Add = function(eventType, target, callback)
	local map = Event.map
	local list = Event.list
	if not map[eventType] then map[eventType] = {} end
	if not list[eventType] then list[eventType] = {} end
	local list = list[eventType]
	
	-- TODO Array
	if not map[eventType][target] then
		list[#list + 1] = target
	end
	
	map[eventType][target] = callback
	
end

Event.Remove = function(eventType, target)
	local map = Event.map
	local list = Event.list[eventType]
	if nil ~= map[eventType] then
		map[eventType][target] = nil
	end
	if nil ~= list then
		for k, v in pairs(list) do
			if v == target then
				table.remove(list, k)
				return
			end
		end
	end
end

Event.Dispatch = function(eventType, ...)
	local map = Event.map
	local mapEventType = map[eventType]
	
	if not mapEventType then return end
	
	local list = Event.list[eventType]
	local t = {...}
	for k, v in pairs(list) do
		mapEventType[v](v, ...)
	end
end

Event.Reset = function()
	Event.map = {}
end

return Event