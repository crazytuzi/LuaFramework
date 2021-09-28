module(..., package.seeall)

--xxxtodo: add doc
--xxxtodo: unit test
local utils = require("ui/utility")
local NIL = utils.NIL
local rcsReturn = utils.rcsReturn

local mt = {_isCallback = true}	--xxxtodo: add unit test
--创建回调对象，如果weakRef为true则回调用weaktable保存
i3k_callback = {new = function(weakRef) 	
	local obj = setmetatable({_callbacks = {}}, mt) --todo: hide _callbacks
	if weakRef then
		setmetatable(obj._callbacks, {__mode = 'k'})
	end
	return obj
end}

--添加回调,再此传入的参数会首先传给回调，其次再传调用该回调传的参数。
function mt:add(cb, ...)
	self._callbacks[cb] = {...}
end

--删除回调
function mt:remove(cb)
	self._callbacks[cb] = nil
end

--触发回调
function mt:invoke(...)
	local args = {...}
	for k, v in pairs(self._callbacks) do
		local cbArgs = {}
		for i = 1, #v do 
			local d
			if v[i] ~= nil then
				d = v[i]
			else
				d = NIL
			end
			table.insert(cbArgs, d) 
		end
		for i = 1, #args do 
			local d
			if args[i] ~= nil then
				d = args[i]
			else
				d = NIL
			end
			table.insert(cbArgs, d) 
		end
		k(rcsReturn(cbArgs, 1))
	end
end

mt.__index = mt

-------sugar-------
function mt:__call(...) 
	self:invoke(...)
end

function mt.__add(l, r)
	local lmt = getmetatable(l)
	local rmt = getmetatable(r)
	assert(lmt._isCallback and rmt._isCallback, 
		string.format("attempting perform arithmetic operator to a callback object and a %s object", lmt._isCallback and type(r) or type(l)))
	local result = i3k_callback.new()
	for k, _ in pairs(l._callbacks) do
		result:add(k)
	end
	for k, _ in pairs(r._callbacks) do
		result:add(k)
	end
	
	return result
end
