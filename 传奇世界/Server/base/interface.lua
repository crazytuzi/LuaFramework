--[[interface.lua
描述：
	提供接口机制

Exported API:
	interface(super, ...)
	implemented(class, ...)
	isInterface(interface)
	isInterfaceInstance(object)
	superinterface(class)
	subinterfaceof(class, supe)

Example:
	Execute = interface(nil, "execute")
	Listener = interface(Execute, "getTarget", "execute")
	GroupListener = class(nil, Listener)
--]]

require "base.string"

local interfaceMap = define { __mode = "k" }
local instanceMT = {}

--@note：虚接口的调用
local function dummy()
	error("Don't execute an interface method.")
end

--@note：
local function undefined(interface, method)
	if interface then
		return interface[method] == nil
	end
	return true
end

--@note：遍历所有接口的迭代子
local function iterator(interface)
	local methods = {}
	local index = 0

	while interface do
		for f, v in pairs(interface) do
			methods[#methods + 1] = f
		end
		interface = superinterface(interface)
	end

	function iter()
		local f, v
		if index < #methods then
			index = index + 1
			f, v = index, methods[index]
		end
		return f, v
	end

	return iter
end

--@note：生成一个和object相关的实例
local function cast(interface, object)
	local class = classof(object)
	local ret, _ = implemented(class, interface)
	if ret then
		local instance = define(instanceMT)
		instance.__interface = interface
		for _, m in iterator(interface) do
			instance[m] = function(self, ...)
				return class[m](object, ...)
			end
		end
		return instance
	end
end

--@note：接口的字符串转换函数
local function interfaceToString(interface)
	local members = {}
	local separator = ""
	local ret = StringBuffer("<<interface>> = {")
	while interface do
		for f,_ in pairs(interface) do
			if not members[f] then
				ret = ret .. separator .. string.format("%q", f)
				separator = ", "
			end
			members[f] = true
		end
		interface = superinterface(interface)
	end
	ret = ret .. "}"
	return tostring(ret)
end

--note：接口定义函数
function interface(super, ...)
	local methods = {}
	for i = 1, select("#", ...) do
		local method = select(i, ...)
		if type(method) == "string" and undefined(super, method) then
			methods[method] = dummy
		end
	end

	local interface = define({
		__call = cast,
		__index = super,
		__tostring = interfaceToString
	}, methods)

	interfaceMap[interface] = true

	return interface
end

--@note：判断一个类是否实现了他的所有接口
function implemented(class, ...)
	class = isclass(class) and class or classof(class)
	if class then
		if class.__interfaces then
			for i = 1, select("#", ...) do
				local interface = select(i, ...)
				if class.__interfaces[interface] ~= true then
					for _, m in iterator(interface) do
						if type(interface[m]) == "function" and not class[m] then
							return false, m
						end
					end
					class.__interfaces[interface] = true
				end
			end
			return true
		end
	end
	return false
end

--@note：判断该对象是否是一个接口
function isInterface(interface)
	return interfaceMap[interface] == true
end

--@note：判断对象是否是一个接口的实例
function isInterfaceInstance(object)
	return getmetatable(object) == instanceMT
end

--@note：查找父接口
function superinterface(interface)
	return getmetatable(interface).__index
end

--@note：判断接口是否从super继承
function subinterfaceof(interface, super)
	while interface do
		if interface == super then return true end
		interface = getmetatable(interface).__index
	end
	return false
end