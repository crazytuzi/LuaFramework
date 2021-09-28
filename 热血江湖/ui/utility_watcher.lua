module(..., package.seeall)

--xxxtodo: add doc
--xxxtodo: unit test

local utils = require("ui/utility")
local i3k_callback = require("ui/utility_callback").i3k_callback
local NIL = utils.NIL
local switchNil = utils.switchNil

------------------------监视器-----------------
-----------做任务监视时监视器应与任务生命周期相同------
--被监视的字段如果被rawset监视将失效
i3k_watcher = i3k_class("i3k_watcher")
function i3k_watcher:ctor(weakWatch, weakCallback)
	self._onChange = i3k_callback.new(weakCallback)
	self._state = weakWatch and setmetatable({}, {__mode = 'k'}) or {}
end



--检测并设置是否要跳过原始metatable
--此函数会重置原表字段到nil并保存原值到内部缓存空间
local function checkRawset(self, obj, k)
	local value = rawget(obj, k)
	local bypass = value ~= nil	--bypass origin metatable
	self._state[obj]["bypass"][k] = bypass
	if value ~= nil then self._state[obj]["fields"][k] = value end
	rawset(obj, k, nil)
	return bypass, value
end

local function callOldGet(oldget, t, k)
	if type(oldget) == "function" then
		return oldget(t, k)
	else
		return oldget[k]
	end
end

local function callOldSet(oldset, t, k, v)
	if type(oldset) == "function" then
		oldset(t, k, v)
	else
		oldset[k] = v
	end
end

local function setMT(self, obj, omt)	--xxxtodo: clean metatable, set self to weak reference
	local mtget = function(t, k)
		local oldget = self._state[t]["oldindex"]
		if self._state[t]["fields"][k] ~= nil then
			local origin = switchNil(self._state[t]["fields"][k])
			if not oldget or self._state[t]["bypass"][k] then 
				return origin 
			end
			local result = callOldGet(oldget, t, k)
			if result ~= origin then
				if self._state[t]["firstget"][k] then
					self._state[t]["firstget"][k] = nil
				else
					self._onChange(self, t, k, result, origin, true, false)
				end
			end
			local fwd = result	--将要设置到self._state[t]["fields"][k]内的结果
			local bypass, rawResult = checkRawset(self, t, k)
			if bypass and rawResult ~= result then
				if result ~= rawResult then
					fwd = rawResult
					self._onChange(self, t, k, rawResult, origin, true, true)
				end
			end
			self._state[t]["fields"][k] = switchNil(fwd)
			return result
		else
			if oldget then
				return callOldGet(oldget, t, k)
			else
				return nil
			end
		end
	end
	
	local mtset = function(t, k, v)
		local oldset = self._state[t]["oldnewindex"]
		if self._state[t]["fields"][k] ~= nil then
			local origin = switchNil(self._state[t]["fields"][k])
			self._state[t]["firstget"][k] = nil
			if oldset then
				callOldSet(t, k, v)
				local bypass, rawResult = checkRawset(self, t, k)
				if bypass then
					if rawResult ~= origin then
						self._state[t]["fields"][k] = switchNil(rawResult)
						self._onChange(self, t, k, rawResult, origin, false, true)
					end
					return
				end
			end
			
			if v ~= origin then
				self._state[t]["fields"][k] = switchNil(v)
				self._onChange(self, t, k, v, origin, false, false)
			end
		else
			if oldset then
				callOldSet(t, k, v)
			else
				rawset(t, k, v)
			end
		end
	end
	
	self._state[obj] = self._state[obj] or {fields = {}, bypass = {}, firstget = {}}
	if omt then
		self._state[obj]["oldindex"] = omt.__index
		self._state[obj]["oldnewindex"] = omt.__newindex
		omt.__index = mtget
		omt.__newindex = mtset
		omt.isInjectedWatch = true
	else
		setmetatable(obj, {isInjectedWatch = true, __index = mtget, __newindex = mtset})
	end
end

local function watch(self, obj, k)
	local bypass, rawValue = checkRawset(self, obj, k)	
	if not bypass then
		if self._state[obj]["oldindex"] then 
			self._state[obj]["firstget"][k] = true	--为了尽量避免影响被监视对象的行为，就不再监视器里get对象了，故忽略第一次get的改变检测
		end
		self._state[obj]["fields"][k] = NIL
	end
end

local function tableSize(tb)
	assert(type(tb) == "table", "expect table, got "..type(tb))
	local array = 0
	local map = 0

	for _, __ in ipairs(tb) do array = array + 1 end
	for _, __ in pairs(tb) do map = map + 1 end
	
	return array, map, array + map
end

--添加监视回调，当监视变量改变时调用，可叠加
function i3k_watcher:addChangeCallback(cb, ...)
	self._onChange:add(cb, ...)
end

function i3k_watcher:removeChangeCallback(cb)
	self._onChange:remove(cb)
end

--xxxtodo: add all fields whatcher
function i3k_watcher:addWatch(obj, k)
	assert(obj and k, "object or key can't be nil")
	local omt = getmetatable(obj)
	if not omt then
		setMT(self, obj)
	elseif not omt.isInjectedWatch then
		setMT(self, obj, omt)
	end
	
	watch(self, obj, k)
end

function i3k_watcher:query(obj, k)
	return self._state[obj]["fields"][k]
end

function i3k_watcher:objectCount()
	local _, size = tableSize(self._state)
	return size
end

--xxxtodo:removeWatch
function i3k_watcher:removeWatch(obj, k)

end

--xxxtodo:release watcher
function i3k_watcher:release()

end
