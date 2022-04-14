--------------------------------------------------------------------------------
--      Copyright (c) 2015 - 2016 , 蒙占志(topameng) topameng@gmail.com
--      All rights reserved.
--      Use, modification and distribution are subject to the "MIT License"
--------------------------------------------------------------------------------

local setmetatable = setmetatable
local xpcall = xpcall
local pcall = pcall
local assert = assert
local rawget = rawget
local error = error
local print = print
local traceback = tolua.traceback
-- local ilist = ilist

-- local _xpcall = {}

-- _xpcall.__call = function(self, ...)	
-- 	if jit then
-- 		if nil == self.obj then
-- 			return xpcall(self.func, traceback, ...)					
-- 		else		
-- 			return xpcall(self.func, traceback, self.obj, ...)					
-- 		end
-- 	else
-- 		local args = {...}
			
-- 		if nil == self.obj then
-- 			local func = function() self.func(unpack(args)) end
-- 			return xpcall(func, traceback)					
-- 		else		
-- 			local func = function() self.func(self.obj, unpack(args)) end
-- 			return xpcall(func, traceback)
-- 		end
-- 	end	
-- end

-- _xpcall.__eq = function(lhs, rhs)
-- 	return lhs.func == rhs.func and lhs.obj == rhs.obj
-- end

-- local function xfunctor(func, obj)	
-- 	return setmetatable({func = func, obj = obj}, _xpcall)			
-- end

-- local _pcall = {}

-- _pcall.__call = function(self, ...)
-- 	if nil == self.obj then
-- 		return pcall(self.func, ...)					
-- 	else		
-- 		return pcall(self.func, self.obj, ...)					
-- 	end	
-- end

-- _pcall.__eq = function(lhs, rhs)
-- 	return lhs.func == rhs.func and lhs.obj == rhs.obj
-- end

-- local function functor(func, obj)	
-- 	return setmetatable({func = func, obj = obj}, _pcall)			
-- end

-- local _event = {}
-- _event.__index = _event

-- --废弃
-- function _event:Add(func, obj)
-- 	assert(func)		

-- 	if self.keepSafe then			
-- 		func = xfunctor(func, obj)
-- 	else
-- 		func = functor(func, obj)
-- 	end	

-- 	if self.lock then
-- 		local node = {value = func, _prev = 0, _next = 0, removed = true}
-- 		table.insert(self.opList, function() self.list:pushnode(node) end)			
-- 		return node
-- 	else
-- 		return self.list:push(func)
-- 	end	
-- end

-- --废弃
-- function _event:Remove(func, obj)	
-- 	for i, v in ilist(self.list) do							
-- 		if v.func == func and v.obj == obj then
-- 			if self.lock then
-- 				table.insert(self.opList, function() self.list:remove(i) end)				
-- 			else
-- 				self.list:remove(i)
-- 			end
-- 			break
-- 		end
-- 	end		
-- end

-- function _event:CreateListener(func, obj)
-- 	if self.keepSafe then			
-- 		func = xfunctor(func, obj)
-- 	else
-- 		func = functor(func, obj)
-- 	end	
	
-- 	return {value = func, _prev = 0, _next = 0, removed = true}		
-- end

-- function _event:AddListener(handle)	
-- 	assert(handle)

-- 	if self.lock then		
-- 		table.insert(self.opList, function() self.list:pushnode(handle) end)		
-- 	else
-- 		self.list:pushnode(handle)
-- 	end	
-- end

-- function _event:RemoveListener(handle)	
-- 	assert(handle)	

-- 	if self.lock then		
-- 		table.insert(self.opList, function() self.list:remove(handle) end)				
-- 	else
-- 		self.list:remove(handle)
-- 	end
-- end

-- function _event:Count()
-- 	return self.list.length
-- end	

-- function _event:Clear()
-- 	self.list:clear()
-- 	self.opList = {}	
-- 	self.lock = false
-- 	self.keepSafe = false
-- 	self.current = nil
-- end

-- function _event:Dump()
-- 	local count = 0
	
-- 	for _, v in ilist(self.list) do
-- 		if v.obj then
-- 			print("update function:", v.func, "object name:", v.obj.name)
-- 		else
-- 			print("update function: ", v.func)
-- 		end
		
-- 		count = count + 1
-- 	end
	
-- 	print("all function is:", count)
-- end

-- _event.__call = function(self, ...)			
-- 	local _list = self.list	
-- 	self.lock = true
-- 	local ilist = ilist				

-- 	for i, f in ilist(_list) do		
-- 		self.current = i						
-- 		local flag, msg = f(...)
		
-- 		if not flag then			
-- 			_list:remove(i)			
-- 			self.lock = false		
-- 			error(msg)				
-- 		end
-- 	end	

-- 	local opList = self.opList	
-- 	self.lock = false		

-- 	for i, op in ipairs(opList) do									
-- 		op()
-- 		opList[i] = nil
-- 	end
-- end

-- 旧方法废弃
-- function event(name, safe)
	-- safe = safe or false
	-- return setmetatable({name = name, keepSafe = safe, lock = false, opList = {}, list = list:new()}, _event)
-- end
function event(name, safe)
	local cls = {list = {},name = name,safe = safe or false,level_list = {}}
	for i=1,8 do
		cls.level_list[i] = {}
	end
	-- 分4级刷新顺序，等级数字底先刷新
	cls.Add = function(self,func,obj,level,rate)
		level = level or 2
		local call_func
		if obj then
			call_func = function(deltaTime)
				func(obj, deltaTime)
			end
		else
			call_func = func
		end
		if not self.level_list[level] then
			logError(level)
			return
		end
		self.list[func] = call_func
		local info = {call_func = call_func , rate = rate or 2,cur_frame = 0,time = 0,obj = obj}
		table.insert(self.level_list[level],info)
	end
	cls.IsContain = function(self,func)
		return self.list[func] ~= nil
	end
	cls.Remove = function(self,func)
		if not self.list[func] then
			return
		end
		for i=1,#self.level_list do
			local remove_index
			for index,info in pairs(self.level_list[i]) do
				if self.list[func] == info.call_func then
					-- self.level_list[i][index] = nil
					remove_index = index
					self.list[func] = nil
					break
				end
			end
			if remove_index then
				local info = table.remove(self.level_list[i],remove_index)
				if AppConfig.Debug and info then
					local cname = info and info.obj and info.obj.__cname
					cname = cname or ""
					log('--LaoY event.lua,line 233--',cname,remove_index)
				end
			end
			if not self.list[func] then
				break
			end
		end
	end

	local last_time = Time.time
	cls.Update = function(self,deltaTime)
		for i=1,#self.level_list do
			for j=1,#self.level_list[i] do
			-- for k,info in pairs(self.level_list[i]) do
				local info = self.level_list[i][j]
				if info then
					info.cur_frame = info.cur_frame + 1
					info.time = info.time + deltaTime
					if info.cur_frame >= info.rate then
						xpcall(function()
							info.call_func(info.time)
						end,_G_TRACKBACK)
						info.cur_frame = 0
						info.time = 0
					end
				end
			end
		end
	end
	-- 用元方法比普通方法要快 cls()速度略快于cls:Update()
	setmetatable(cls,{__call = cls.Update})
	return cls
end

UpdateBeat 		= event("Update", true)
LateUpdateBeat	= event("LateUpdate", true)
FixedUpdateBeat	= event("FixedUpdate", true)

-- 不需要使用
CoUpdateBeat	= event("CoUpdate")				--只在协同使用

local Time = Time
local UpdateBeat = UpdateBeat
local LateUpdateBeat = LateUpdateBeat
local FixedUpdateBeat = FixedUpdateBeat
local CoUpdateBeat = CoUpdateBeat

--逻辑update
function Update(deltaTime, unscaledDeltaTime)
	Time:SetDeltaTime(deltaTime, unscaledDeltaTime)				
	UpdateBeat(deltaTime)
end

function LateUpdate()	
	LateUpdateBeat(Time.deltaTime)
	CoUpdateBeat(Time.deltaTime)		
	Time:SetFrameCount()		
end

function FixedUpdate(fixedDeltaTime)
	-- Time:SetFixedDelta(fixedDeltaTime)
	-- FixedUpdateBeat(fixedDeltaTime)
end

function PrintEvents()
	UpdateBeat:Dump()
	FixedUpdateBeat:Dump()
end