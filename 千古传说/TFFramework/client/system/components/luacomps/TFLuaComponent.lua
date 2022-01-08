--
-- Author: Bai Yun
-- Date: 2014-07-17 15:53:33
--

local coroutine = coroutine
local pairs 	= pairs
local unpack 	= unpack

TFLuaComponent = CLASS("TFLuaComponent")

TFYield = coroutine.yield
TFResume = coroutine.resume

function TFLuaComponent:ctor(gameObject)
	self.gameObject = gameObject
	self.isEnabled = true
end

function TFLuaComponent:create(gameObject)
	return self:new(gameObject)
end

function TFLuaComponent:start()
	self.gameObject:resumeSchedulerAndActions()
end

function TFLuaComponent:stop()
	self.gameObject:pauseSchedulerAndActions()
end

function TFLuaComponent:resume()
	self:start()
end

function TFLuaComponent:TFWaitForSeconds(fDT)
	if fDT < 0.017 and not self.gameObject then 
	else 
		local co = coroutine.running()
		self.gameObject:timeOut(function() self.__coroutineList[co] = true end, fDT)
		self.__coroutineList[co] = false
	end
	return TFYield()
end

function TFLuaComponent:OnCoroutineResume(nDT)
	if self.__coroutineList then 
		local bRet = true
		for co in pairs(self.__coroutineList) do 
			if self.__coroutineList[co] then 
				TFResume(co, co)
			end
			bRet = false
		end
		if bRet then 
			self.__coroutineList = nil
		end
	end
end

function TFLuaComponent:addTimer(fDT, nRepeat, completeCall, timerCall, ...)
	fDT = fDT - me.Director:getAnimationInterval()
	fDT = fDT < 0 and 0 or fDT
	nRepeat = nRepeat == -1 and INT_MAXVALUE or nRepeat
	local tParams = {...}
	local nCount = 1
	if nRepeat == 0 then nRepeat = 1 end
	return self:StartCoroutine(function()
		while nCount <= nRepeat do 
			if timerCall then timerCall(unpack(tParams)) end
			if nCount == nRepeat and completeCall then completeCall(unpack(tParams)) end
			if self:TFWaitForSeconds (fDT) == true then break end
			nCount = nCount + 1
		end
	end)
end

function TFLuaComponent:removeTimer(co, imed)
	if self.__coroutineList and type(co) == 'thread' then 
		if not imed then TFResume(co, true) end
		self.__coroutineList[co] = nil
	end
end

function TFLuaComponent:StartCoroutine(callback)
	self.__coroutineList = self.__coroutineList or {}
	local co = coroutine.create(function()
		callback()
		self.__coroutineList[coroutine.running()] = nil
	end)
	self.__coroutineList[co] = true
	return co
end

function TFLuaComponent:Awake()
	-- print("TFLuaComponent:Awake()", tostring(self))
end

function TFLuaComponent:OnDestroy()
	-- print("TFLuaComponent:OnDestroy()", tostring(self)) 
end

function TFLuaComponent:Start()
	-- print("TFLuaComponent:Start()", tostring(self))
end

--[[
function TFLuaComponent:Update(nDT)
	--print("TFLuaComponent:Update()", nDT)
end
]]

function TFLuaComponent:OnEnable()
	-- print("TFLuaComponent:OnEnable()", tostring(self))
end

function TFLuaComponent:OnDisable()
	-- print("TFLuaComponent:OnDisable()", tostring(self))
end

function TFLuaComponent:set__enable(isEnabled)
	if isEnabled ~= self.isEnabled then 
		self.isEnabled = isEnabled
		if isEnabled then 
			self:OnEnable()
		else 
			self:OnDisable()
		end
	end
end

function TFLuaComponent:get__enable()
	return self.isEnabled
end

return TFLuaComponent