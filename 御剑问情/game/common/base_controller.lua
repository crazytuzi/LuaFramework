
-- 功能: 协议处理类的基类

BaseController = BaseController or BaseClass()
function BaseController:__init()
	self.event_map = {}			--事件表
	self.msg_type_map = {}
end

function BaseController:__delete()
	for k, _ in pairs(self.event_map) do
		GlobalEventSystem:UnBind(k)
	end
	self.event_map = {}

	for k, v in pairs(self.msg_type_map) do
		ProtocolPool.Instance:UnRegister(v, k)
		GameNet.Instance:UnRegisterMsgOperate(k)
	end
	self.msg_type_map = {}
end

-- 注册协议
function BaseController:RegisterProtocol(protocol, func_name)
	if protocol == nil then
		print_error("Ther register protocol is nil.")
		return
	end

	-- 注册到协议池
	local msg_type = ProtocolPool.Instance:Register(protocol)
	if msg_type < 0 then return end

	self.msg_type_map[msg_type] = protocol

	if func_name then
		if not self[func_name] then
			print_log("BaseController:RegisterProtocol error func not exist [" .. func_name .. "]")
			return
		end

		-- 注册协议处理函数
		GameNet.Instance:RegisterMsgOperate(msg_type, BindTool.Bind1(self[func_name], self))
	end
end

function BaseController:BindGlobalEvent(event_id, event_func)
	local handle = GlobalEventSystem:Bind(event_id, event_func)
	self.event_map[handle] = event_id
end

function BaseController:UnBind(handle)
	GlobalEventSystem:UnBind(handle)
	self.event_map[handle] = nil
end

function BaseController:Fire(event_id, ...)
	GlobalEventSystem:Fire(event_id, ...)
end

function BaseController:FireNextFrame(event_id, ...)
	GlobalEventSystem:FireNextFrame(event_id, ...)
end

--[[@
功能：  注册一条错误码回调函数
]]
function BaseController:RegisterErrNumCallback(err_num, func_name)
	if not self[func_name] then
		return
	end

	SysMsgCtrl.Instance:RegisterErrNumCallback(err_num, BindTool.Bind1(self[func_name], self))
end