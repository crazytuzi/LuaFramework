-- 事件自发生成器
-- 利用ID分离对 InnerEvent 的直接引用
InnerEvent = BaseClass()
function InnerEvent:__init()
	self.isDispatcher = true
	GEventConst._inner_event_outo_id = GEventConst._inner_event_outo_id + 1
	self.system_id = GEventConst._inner_event_outo_id
	GEventConst._inner_event_list_[self.system_id] = self
	self.noSync_events = {} -- 异步事件
	self.event_list = {} -- 事件列表
	self.useNoSync = nil
	self.is_destroy_ = false
end

-- 开启异步处理
function InnerEvent:Setup_noSync_events()
	if self.useNoSync then return end
	self.useNoSync = true
	CoUpdateBeat:Add(self.Update__, self)
end

function InnerEvent:AddEventListener(event_id, event_func)
	if self.is_destroy_ then return end
	if event_id == nil then
		debug.traceback()
		error("正在尝试绑定一个 nil 的事件名id")
		return
	end
	if self.event_list[event_id] == nil then
		self.event_list[event_id] = GEvent.New(event_id)
	end
	local tmp_event = self.event_list[event_id]
	return tmp_event:AddEventListener(event_func) -- 返回事件句柄 handle
end

-- 同步程序中触发
function InnerEvent:DispatchEvent(event_id, ...)
	if self.is_destroy_ then return end
	if event_id == nil then
		debug.traceback()
		error("正在尝试发送一个事件名id为 nil 的事件！")
		return
	end
	local tmp_event = self.event_list[event_id] 
	if tmp_event ~= nil then
		tmp_event:DispatchEvent({...})
	end
end

-- 调用已经处于派发队列中的Event (需要将事件注册到 心跳或帧频机制中)
function InnerEvent:Update__()
	if self.is_destroy_ then return end
	while #self.noSync_events ~= 0 do -- 依次执行所有需要触发的事件
		local dispatch_info = table.remove(self.noSync_events, 1)
		dispatch_info.event:DispatchEvent(dispatch_info.arg_list)
		break
	end
	if self.noSync_events == 0 then
		self.useNoSync = nil
		CoUpdateBeat:Remove(self.Update__, self)
	end
end
-- 程序下一帧触发 (需要将事件注册到 心跳或帧频机制中)
function InnerEvent:Fire(event_id, ...)
	if self.is_destroy_ then return end
	self:Setup_noSync_events()
	if event_id == nil then
		debug.traceback()
		error("正在尝试发送一个 异步发送的事件名id 为 nil 的事件！")
		return
	end
	local tmp_event = self.event_list[event_id] 
	if tmp_event ~= nil then
		local dispatch_info = {}
		dispatch_info.event = tmp_event
		dispatch_info.arg_list = {...}
		table.insert(self.noSync_events, dispatch_info)
	end
end

-- 清除事件
function InnerEvent:RemoveEventListener(event_handle)
	if self.is_destroy_ then return end
	if event_handle == nil or event_handle.event_id == nil then
		-- debug.traceback()
		-- logWarn("正在尝试移除一个 nil 值的 handle！")
		return
	end
	local tmp_event = self.event_list[event_handle.event_id]
	if tmp_event ~= nil then
		tmp_event:RemoveEventListener(event_handle)
	end
end
function InnerEvent:RemoveEventListeners(event_id)
	if self.is_destroy_ then return end
	if event_id == nil then
		self.event_list = {}
		self.noSync_events = {}
	else
		self.event_list[event_id] = nil
	end
end

function InnerEvent:__delete()
	self:RemoveEventListeners()
	if not self.is_destroy_ then
		GEventConst._inner_event_list_[self.system_id] = nil
	end
	if self.useNoSync == true then
		self.useNoSync = nil
		CoUpdateBeat:Remove(self.Update__, self)
	end
	self.isDispatcher = false
	self.event_list = nil
	self.is_destroy_ = true
end