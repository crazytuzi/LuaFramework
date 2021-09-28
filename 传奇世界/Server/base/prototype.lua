--[[prototype.lua
描述：
	提供基于原型/模板数据操作机制
--]]

local ACCESSOR = 1
local WRITER = 2
local READER = 3

local classMT = {}

--@note：原型方法代理
local function prototype_accessor(prototype, class, name, default, rfunc, wfunc, mode)
	--assert(class, "error Class type.")
	--assert(name, "error Name attribute.")
	local _name = string.title(name)

	if mode <= WRITER then
		local prop = rawget(prototype, "__prop")
		local modified = rawget(prototype, "__modified")

		prop:writer(name, default)

		local set_method = class["set".._name]
		if modified then
			local old_set_method = set_method
			set_method = function(self, value)
				if self.__modified == nil then
					self.__modified = {}
				end
				self.__modified[name] = true
				old_set_method(self, value)
			end
			class["set".._name] = set_method
		end

		if type(wfunc) == "function" then
			class["set".._name] = function(self, value)
				wfunc(self, value, set_method)
			end
		elseif type(wfunc) == "name" then
			class["set".._name] = class[wfunc]
		end

		mode = mode + 2
	end

	if mode <= READER then
		local proto_method = rawget(prototype, "__method")

		if type(rfunc) == "function" then
			class["get".._name] = rfunc
		elseif type(rfunc) == "name" then
			class["get".._name] = class[rfunc]
		else
			class["get".._name] = function(self)
				local ret = self[name]

				if not ret then
					local object = proto_method(self)
					if object then
						if type(object["get".._name]) == "function" then
							ret = object["get".._name](object, self)
						else
							ret = object:__getValue(name, self, default)
						end
					end
				end

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

--@note：class对应的原型的生成
local function prototype_new(_, class, prop, method, modified)
	--assert(class, "error Class type.")

	local prototype = define(classMT, {
		__prop = prop,
		__method = method,
		__modified = (modified==true),
		reader = function(self, name, default, rfunc)
			prototype_accessor(self, class, name, default, rfunc, nil, READER)
		end,
		writer = function(self, name, default, wfunc)
			prototype_accessor(self, class, name, default, nil, wfunc, WRITER)
		end,
		accessor = function(self, name, default, rfunc, wfunc)
			prototype_accessor(self, class, name, default, rfunc, wfunc, ACCESSOR)
		end
	})

	return prototype
end

Prototype = define { __call = prototype_new }