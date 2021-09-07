BaseRender = BaseRender or BaseClass()

function BaseRender:__init(instance)
	self.root_node = nil
	if instance ~= nil then
		self:SetInstance(instance)
	end

	self.global_event_map = {}
	self.flush_param_t = nil								-- 界面刷新参数
end

function BaseRender:__delete()
	if not IsNil(self.event_table) then
		self.event_table:ClearAllEvents()
		self.event_table = nil
	end

	for k, _ in pairs(self.global_event_map) do
		GlobalEventSystem:UnBind(k)
	end
	self.global_event_map = {}

	self.name_table = nil
	self.variable_table = nil
	self.root_node = nil
end

function BaseRender:SetInstance(instance)
	-- UI根节点, 支持instance是GameObject或者U3DObject
	if type(instance) == "userdata" then
		self.root_node = U3DObject(instance)
	else
		self.root_node = instance
	end

	self.name_table = instance:GetComponent(typeof(UINameTable))			-- 名字绑定
	self.event_table = instance:GetComponent(typeof(UIEventTable))			-- 事件绑定
	self.variable_table = instance:GetComponent(typeof(UIVariableTable))	-- 变量绑定

	self:LoadCallBack(instance)

	self:FlushHelper()
end

function BaseRender:SetInstanceParent(instance_parent)
	self.root_node.transform:SetParent(instance_parent.transform, false)
end

-- 外部通知刷新，调用此接口
function BaseRender:Flush(key, value_t)
	key = key or "all"
	value_t = value_t or {"all"}

	self.flush_param_t = self.flush_param_t or {}
	for k, v in pairs(value_t) do
		self.flush_param_t[key] = self.flush_param_t[key] or {}
		self.flush_param_t[key][k] = v
	end
	if nil == self.delay_flush_timer and self.root_node ~= nil then
		self.delay_flush_timer = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.FlushHelper, self), 0)
	end
end

function BaseRender:FlushHelper()
	self:CancelDelayFlushTimer()

	if self.root_node == nil then
		return
	end

	if nil ~= self.flush_param_t then
		local param_list = self.flush_param_t
		self.flush_param_t = nil
		self:OnFlush(param_list)
	end
end

function BaseRender:CancelDelayFlushTimer()
	if self.delay_flush_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.delay_flush_timer)
		self.delay_flush_timer = nil
	end
end

-- 查找组件
-- name_path 对象名，支持name/name/name的形式
function BaseRender:FindObj(name_path)
	if self.name_table ~= nil then
		local game_obj = self.name_table:Find(name_path)
		if game_obj ~= nil then
			node = U3DObject(game_obj)
			return node
		end
	end

	local transform = self.root_node.transform:FindHard(name_path)
	if transform ~= nil then
		node = U3DObject(transform.gameObject, transform)
		return node
	end

	print_error("BaseRender: can not find: " .. name_path)
	return nil
end

-- 清空指定事件.
-- eventName: 事件名.
function BaseRender:ClearEvent(eventName)
	if self.event_table == nil then
		return
	end

	self.event_table:ClearEvent(eventName)
end

-- 监听指定的事件.
-- eventName: 事件名.
-- listener: 监听回调.
function BaseRender:ListenEvent(eventName, listener)
	if self.event_table == nil then
		return
	end

	return self.event_table:ListenEvent(eventName, listener)
end

-- 查找指定的绑定变量.
-- name: 绑定变量的名字.
function BaseRender:FindVariable(name)
	if self.variable_table == nil then
		return
	end

	return self.variable_table:FindVariable(name)
end

function BaseRender:SetActive(active)
	self.root_node:SetActive(active)
end

function BaseRender:SetParentActive(active)
	self.root_node.transform.parent.gameObject:SetActive(active)
end

function BaseRender:IsNil()
	return IsNil(self.root_node and self.root_node.gameObject)
end

-- 是否打开过
function BaseRender:IsOpen()
	return self.root_node and true or false
end

function BaseRender:BindGlobalEvent(event_id, event_func)
	local handle = GlobalEventSystem:Bind(event_id, event_func)
	self.global_event_map[handle] = event_id
	return handle
end

function BaseRender:UnBindGlobalEvent(handle)
	GlobalEventSystem:UnBind(handle)
	self.global_event_map[handle] = nil
end

----------------------------------------------------
-- 可重写继承的接口 begin
----------------------------------------------------
function BaseRender:LoadCallBack(instance)
	-- override
end

-- 刷新(用Flush刷新OnFlush的方法必须是有用LoadCallBack加载完成的时候使用,否则有可能引起报错)
function BaseRender:OnFlush(param_list)
end


----------------------------------------------------
-- 可重写继承的接口 end
----------------------------------------------------