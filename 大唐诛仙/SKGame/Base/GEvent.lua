-- 内部事件收集器
GEventConst = GEventConst or {
	event_obj__ = {}, -- 事件收集器
	_inner_event_list_ = {},
	_inner_event_outo_id = 0,
}

-- 事件
GEvent = BaseClass()
function GEvent:__init(event_id)
	self.event_id = event_id
	self.event_obj_id__ = 0
	self.handler_list_ = {}
end

-- 广播
function GEvent:DispatchEvent(arg_table)
	for k, func in pairs(self.handler_list_) do
		func(unpack(arg_table))
	end
end

-- 当obj符合类型时才删除
function GEvent:RemoveEventListener(obj)
	if getmetatable(obj) == GEventConst.event_obj__ and obj.event_id == self.event_id then
		self.handler_list_[obj.event_obj_id] = nil
	end
end

-- 注册事件
function GEvent:AddEventListener(handle)
	self.event_obj_id__ = self.event_obj_id__ + 1
	local obj = {}
	setmetatable(obj, GEventConst.event_obj__)
	obj.event_id = self.event_id
	obj.event_obj_id = self.event_obj_id__
	self.handler_list_[obj.event_obj_id] = handle
	return obj
end
