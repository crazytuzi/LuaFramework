
BaseData = BaseData or BaseClass()

function BaseData:__init()
	GameObject.Extend(self)
	self:AddComponent(EventProtocol):ExportMethods()					-- 增加事件组件

	self.global_event_map = {}
end

function BaseData:__delete()
	self:RemoveAllEventlist()
	self:UnBindAllGlobalEvent()
end

function BaseData:BindGlobalEvent(event_id, event_func)
	local handle = GlobalEventSystem:Bind(event_id, event_func)
	self.global_event_map[handle] = event_id
	return handle
end

function BaseData:UnBindGlobalEvent(handle)
	GlobalEventSystem:UnBind(handle)
	self.global_event_map[handle] = nil
end

function BaseData:UnBindAllGlobalEvent()
	for k, _ in pairs(self.global_event_map) do
		GlobalEventSystem:UnBind(k)
	end
	self.global_event_map = {}
end
