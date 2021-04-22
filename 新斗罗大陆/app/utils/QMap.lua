local QMap = class("QMap")
--[[
	一个Map，其实就是对table做了简单的封装
	战斗中使用它可以减少很多没必要的临时字段
	使用get的时候会优先从局部中找 找不到的时候才会从static表中找

	setObject与getObject函数是用来将键值对与某个对象绑定的,相当于给对象增加了一些没有写在对象上的属性
--]]
local static_cache = {}
local static_obj_cache = {}
setmetatable(static_obj_cache,{__mode = 'k'}) -- 设置弱表,防止此table一直引用着对象导致无法gc 

function QMap:ctor()
	self._cache = {}
	self._obj_cache = {}
	setmetatable(self._obj_cache,{__mode = 'k'})
end

function QMap.setStatic(key,value)
	static_cache[key] = value
end

function QMap:set(key,value)
	self._cache[key] = value
end

function QMap:get(key)
	return self._cache[key] or static_cache[key]
end

function QMap.getStatic(key)
	return static_cache[key]
end

function QMap:getProp(key)
	return self._cache[key]
end

function QMap.setObjectStatic(obj,key,value)
	if not static_obj_cache[obj] then
		static_obj_cache[obj] = {}
	end
	static_obj_cache[obj][key] = value
end

function QMap:setObject(obj,key,value)
	if not self._obj_cache[obj] then
		self._obj_cache[obj] = {}
	end
	self._obj_cache[obj][key] = value
end

function QMap:getObject(obj,key)
	if self._obj_cache[obj] then
		if self._obj_cache[obj][key] then
			return self._obj_cache[obj][key]
		end
	end

	if static_obj_cache[obj] then
		return static_obj_cache[obj][key]
	end

	return nil
end

function QMap.getObjectStatic(obj,key)
	return static_obj_cache[obj] and static_obj_cache[obj][key] or nil
end

function QMap:getObjectProp(obj,key)
	return self._obj_cache[obj] and self._obj_cache[obj][key] or nil
end

return QMap