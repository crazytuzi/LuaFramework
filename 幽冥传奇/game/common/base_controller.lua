
-- 功能: 协议处理类的基类
BaseController = BaseController or BaseClass()
function BaseController:__init()
	self.event_map = {}			--事件表
end

function BaseController:__delete()
	for k, _ in pairs(self.event_map) do
		GlobalEventSystem:UnBind(k)
	end
	self.event_map = {}
end

-- 注册协议
function BaseController:RegisterProtocol(protocol, func_name)
	-- 注册到协议池
	local msg_type = ProtocolPool.Instance:Register(protocol)
	if msg_type < 0 then return end

	if func_name then
		if not self[func_name] then
			Log("BaseController:RegisterProtocol error func not exist [" .. func_name .. "]")
			return
		end

		-- 注册协议处理函数
		GameNet.Instance:RegisterMsgOperate(msg_type, BindTool.Bind(self[func_name], self))
	end
end

function BaseController:Bind(event_id, event_func)
	self:BindGlobalEvent(event_id, event_func)
end

function BaseController:BindGlobalEvent(event_id, event_func)
	local handle = GlobalEventSystem:Bind(event_id, event_func)
	self.event_map[handle] = event_id
	return handle
end

function BaseController:UnBindGlobalEvent(handle)
	GlobalEventSystem:UnBind(handle)
	self.event_map[handle] = nil
end

function BaseController:Fire(event_id, ...)
	GlobalEventSystem:Fire(event_id, ...)
end
