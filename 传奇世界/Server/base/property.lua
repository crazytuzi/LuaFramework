--[[Property.lua
描述：
	用于属性方法声明

Exported API:
	Property(class)

	Property:reader(propertyName)
	Property:writer(propertyName)
	Property:accessor(propertyName)
	Property(object, propertyName, propertyValue)

Example:
	local Object = class()
	local prop = Property(Object)
	prop:reader("id")
	function Object:__init(id)
		self.id = id
	end
--]]

local ACCESSOR = 1
local WRITER = 2
local READER = 3

local observerMap = define { __mode = "k" }

local classMT = {
	__call = function(prop, obj, name, value)
		obj[name] = value
	end,
	__index = function(prop, obj)
		return obj
	end
}

--@note：属性方法代理
local function prop_accessor(prop, class, name, default, rfunc, wfunc, mode)
	assert(class, "error Class type.")
	assert(name, "error Name attribute.")
	local _name = string.title(name)

	if mode <= WRITER then
		local observer = rawget(observerMap[classof(self)] or prop, "__observer")
		local set_method = function(self, value)
			local oldval = self[name]
			if oldval == nil then
				oldval = default
			end
			self[name] = value
			if type(observer) == "function" then
				observer(self, name, oldval, value)
			elseif classof(observer) ~= nil then
				observer:onPropChanged(self, name, oldval, value)
			elseif type(observer) == "table" then
				observer.onPropChanged(self, name, oldval, value)
			end
		end

		if type(wfunc) == "function" then
			class["set".._name] = function(self, value)
				value = wfunc(self, value, set_method)
			end
		elseif type(wfunc) == "name" then
			class["set".._name] = class[wfunc]
		else
			class["set".._name] = set_method
		end

		mode = mode + 2
	end

	if mode <= READER then
		if type(rfunc) == "function" then
			class["get".._name] = rfunc
		elseif type(rfunc) == "name" then
			class["get".._name] = class[rfunc]
		else
			class["get".._name] = function(self)
				local ret = self[name]
				if ret ~= nil then
					return ret
				else
					return default
				end
			end
		end

		if type(default) == "boolean" then
			class["is".._name] = class["get".._name]
		end
	end
end

--@note：class对应的Property生成函数
local function prop_new(_, class, observer)
	assert(class, "error Class type.")

	local prop = define(classMT, {
		__class = class,
		__observer = observer,
		reader = function(self, name, default, rfunc)
			prop_accessor(self, class, name, default, rfunc, nil, READER)
		end,
		writer = function(self, name, default, wfunc)
			prop_accessor(self, class, name, default, nil, wfunc, WRITER)
		end,
		accessor = function(self, name, default, rfunc, wfunc)
			prop_accessor(self, class, name, default, rfunc, wfunc, ACCESSOR)
		end
	})

	if observer then
		observerMap[class] = prop
	end

	return prop
end

Property = define { __call = prop_new }