--[[class.lua
描述：
	提供类的继承机制
--]]

local advance = true
local classMap = define { __mode = "k" }

--@note：初始化实例对象
local function rawnew(class, object, ...)
	if isclass(class.__super) then
		rawnew(class.__super, object, ...)
	end
	if type(class.__init) == "function" then
		class.__init(object, ...)
	end
	return object
end

--@note：根据class生成一个实例对象
local function new(class, ...)
	if not class.__implemented then
		local interfaces = getInterfaces(class)
		if interfaces then
			advance = false
			local ret, method = implemented(class, unpack(interfaces))
			advance = true
			if not ret then
				error(string.format("The %q not implemented.", method))
			end
		end
		class.__implemented = true
	end
	if table.contains(getInterfaces(class), Singleton) then
		local inst = rawget(class, "__instance")
		if not inst then
			local object = define(class.__vtbl)
			inst = rawnew(class, object, ...)
			rawset(class, "__instance", inst)
		end
		return inst
	else
		local object = define(class.__vtbl)
		return rawnew(class, object, ...)
	end
end

--@note：销毁实例对象的成员
local function rawrelease(class, object)
	if type(class.__release) == "function" then
		class.__release(object)
	end
	if isclass(class.__super) then
		rawrelease(class.__super, object)
	end
end

--@note：对象的tostring
local function object_tostring(object)
	if type(object.tostring) == "function" then
		return object:tostring()
	end
	local separator = ""
	local ret = StringBuffer("<<object>> = {")
	for f,v in pairs(object) do
		if not string.startsWith(f, "_") then
			if type(v) == "string" then
				ret = ret .. separator .. f .. " = " .. string.format("%q", v)
			else
				ret = ret .. separator .. f .. " = " .. tostring(v)
			end
			separator = ", "
		end
	end
	ret = ret .. "}"
	return tostring(ret)
end

--@note：class的元表
local classMT = {
	__call = new,
	__index = function(class, field)
		return rawget(class.__vtbl, field)
	end,
	__newindex = function(class, field, value)
		rawset(class.__vtbl, field, value)
	end,
	__tostring = function(class)
		local members = {}
		local super = class
		local separator = ""
		local ret = StringBuffer("<<class>> = {")
		while super do
			local vtbl = super.__vtbl
			for f,v in pairs(vtbl) do
				if not members[f] and not string.startsWith(f, "_") then
					if type(v) == "string" then
						ret = ret .. separator .. f .. " = " .. string.format("%q", v)
					else
						ret = ret .. separator .. f .. " = " .. tostring(v)
					end
					separator = ", "
				end
				members[f] = true
			end
			super = super.__super
		end
		ret = ret .. "}"
		return tostring(ret)
	end
}

--@note：Export API，释放一个对象的成员
function release(object)
	local class = classof(object)
	if class then
		rawrelease(class, object)
	end
end

--@note：Export API，生成一个类型
function class(super, ...)
	local interfaces = {}
	for i = 1, select("#", ...) do
		local interface = select(i, ...)
		if isInterface(interface) then
			interfaces[#interfaces + 1] = interface
		end
	end

	local vtbl = {
		__tostring = object_tostring,
		release = release,
	}
	vtbl.__index = vtbl

	local class = define(classMT, {
		__super = super,
		__interfaces = #interfaces > 0 and interfaces or nil,
		__vtbl = vtbl,
		__init = false,
		__release = false,
	})

	classMap[vtbl] = class

	if super then
		define({__index = class.__super}, vtbl)
	end

	return class
end

--@note：Export API，判断是否是class，实例也认为是class
function isclass(class)
	local mt = getmetatable(class)
	if classMap[mt] or mt == classMT then
		return true
	end
	return false
end

--@note：Export API，返回一个对象的类型
function classof(object)
	local mt = getmetatable(object)
	return classMap[mt]
end

--@note：Export API，判断是否是实例
function isClassInstance(object)
	--return classof(object) ~= nil
	local mt = getmetatable(object)
	return (classMap[mt] ~= nil)
end

--@note：Export API，返回一个类型的所有接口
function getInterfaces(class)
	class = isclass(class) and class or classof(class)
	return class.__interfaces
end

--@note：Export API，返回基类
function superclass(class)
	return rawget(class, "__super")
end

--@note：Export API，是否是继承关系
function subclassof(class, super)
	while class do
		if class == super then return true end
		class = rawget(class, "__super")
	end
	return false
end

--@note：Export API，判断是否是class的实例
function instanceof(object, class)
	if object then
		if isClassInstance(object) then
			if isclass(class) then
				return subclassof(classof(object), class)
			elseif isInterface(class) then
				local interface = class
				local class = classof(object)
				while class do
					local interfaces = getInterfaces(class)
					if interfaces then
						for i = 1, #interfaces do
							if subinterfaceof(interfaces[i], interface) then
								return implemented(class, interface)
							end
						end
					end
					class = superclass(class)
				end
			end
		elseif isInterfaceInstance(object) then
			return subinterfaceof(object.__interface, class)
		elseif isclass(object) then
			if isclass(class) then
				return subclassof(object, class)
			elseif isInterface(class) then
				return implemented(object, class)
			end
		end
	end
	return false
end

--@note：Export API，根据字符串得到这个类
function getClass(classStr)
	local code, cls = pcall(loadstring("local rst="..classStr.." return rst"))
	if isclass(cls) then
		return cls
	end
end