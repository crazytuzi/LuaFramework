--------------------------------------------------------------------------------------
-- 文件名:	Class_Timer.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李玉平
-- 日  期:	2014-4-21 15:24
-- 版  本:	1.0
-- 描  述:	定时器
-- 应  用:  基类  该版本的定时器会快一帧的误差，上一个版本的时间比较准 但是每次都要获取基准时间的开销 
---------------------------------------------------------------------------------------
--限制次数的定时器
local Class_LimitCountTimer = class("Class_LimitCountTimer")
Class_LimitCountTimer.__index = Class_LimitCountTimer

local nTimerID = 0
--fInterval每次时间， nCount总共循环多少次
function Class_LimitCountTimer:create(nCount, fInterval, func)
	self.fInterval = fInterval
	self.func = func
	self.nCount = nCount
	self.nCurInterval  = 0
	nTimerID = nTimerID + 1
	self.nTimerID = nTimerID
end

--true 则删除该定时器
function Class_LimitCountTimer:Process(fDeltaTime)
	self.nCurInterval =self.nCurInterval + fDeltaTime
	if(self.fInterval <= self.nCurInterval)then
		self.nCount  = self.nCount  - 1
		self.nCurInterval  = 0
		if(self.nCount <= 0 )then
			self.func(fDeltaTime, true)
			return true
		else
			return self.func(fDeltaTime)
		end
	end
	
	return false
end

--限制时间的定时器
local Class_LimitTimeTimer = class("Class_LimitTimeTimer")
Class_LimitTimeTimer.__index = Class_LimitTimeTimer
--fInterval每次时间， nCount总共循环多少次
function Class_LimitTimeTimer:create(nTime, fInterval, func)
	self.fInterval = fInterval
	self.func = func
	self.nTime = nTime
	self.nCurInterval  = 0
	nTimerID = nTimerID + 1
	self.nTimerID = nTimerID
	--self.nCurTime = API_GetCurrentTime()
end

--true 则删除该定时器
function Class_LimitTimeTimer:Process(fDeltaTime)
	self.nCurInterval =self.nCurInterval + fDeltaTime
	self.nTime = self.nTime - fDeltaTime
	if(self.nTime <= 0)then
		self.func(fDeltaTime, true) --true表示时间到 最后一轮调用
		return true
	end
	
	if(self.fInterval <= self.nCurInterval)then
		self.nCurInterval  = 0
		return self.func(fDeltaTime)
	end
	
	return false
end

--无限循环定时器
local Class_LoopTimer = class("Class_LoopTimer")
Class_LoopTimer.__index = Class_LoopTimer
--fInterval每次时间
function Class_LoopTimer:create(fInterval, func)
	self.fInterval = fInterval
	self.func = func
	self.nCurInterval  = 0
	nTimerID = nTimerID + 1
	self.nTimerID = nTimerID
end

--true 则删除该定时器
function Class_LoopTimer:Process(fDeltaTime)
	self.nCurInterval =self.nCurInterval + fDeltaTime
	if(self.fInterval <= self.nCurInterval)then
		self.nCurInterval  = 0
		return self.func(fDeltaTime)
	end
	
	return false
end

--创建CTimer类
local Class_Timer = class("Class_Timer")
Class_Timer.__index = Class_Timer

function Class_Timer:create(funcMsgProcess)
	local function processTimerCallBack(fDeltaTime)
		funcMsgProcess()
		
		--因为LUA ERROR: invalid key to 'next'
		-- if #self.tabDel ~= 0 then
			-- for k,v in ipairs(self.tabDel)do
				-- self.tbTimer[v] = nil
			-- end
		-- end
		-- self.tabDel = {}
		
        for key, classTimers in pairs(self.tbTimer) do
            if classTimers:Process(fDeltaTime) then
                self.tbTimer[key] = nil
				--table.insert(self.tabDel, key)
            end
        end

        -- if #self.tabDel ~= 0 then
			-- for k,v in ipairs(self.tabDel)do
				-- self.tbTimer[v] = nil
			-- end
		-- end
		-- self.tabDel = {}
		
	end
	self.tabDel = {}
    self.tbTimer = {}
	self.nTimerID =  CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(processTimerCallBack, 0,  false)
	g_Timer:clearAllTimer()
end

function Class_Timer:destroy()
	CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.nTimerID)
	self.nTimerID = nil
end

--定时器
function Class_Timer:pushTimer(fInterval, func)
	return self:pushLimtCountTimer(1, fInterval, func)
end

--nTime总共执行多久，fInterval每次间隔的时间 默认是每帧都调用
function Class_Timer:pushLimtTimeTimer(nTime, func, fInterval)
	fInterval = fInterval or 0
	local classTimer = Class_LimitTimeTimer.new()
	classTimer:create(nTime, fInterval, func)
	self.tbTimer[classTimer.nTimerID] = classTimer

	return classTimer.nTimerID 
end

--nCount总共执行多少次 fInterval多长时间执行一次
function Class_Timer:pushLimtCountTimer(nCount, fInterval, func)
	local classTimer = Class_LimitCountTimer.new()
	classTimer:create(nCount, fInterval, func)
	self.tbTimer[classTimer.nTimerID] = classTimer

	return classTimer.nTimerID 
end

--循环定时器，fInterval每次回调的频率
function Class_Timer:pushLoopTimer(fInterval, func)
	local classTimer = Class_LoopTimer.new()
	classTimer:create(fInterval, func)
	self.tbTimer[classTimer.nTimerID] = classTimer

	return classTimer.nTimerID 
end

--清除所有的定时器
function Class_Timer:clearAllTimer()
	self.tbTimer  = {}
	
	local function dumpMem()
		local mem = collectgarbage("count")/1024
		cclog("Lua Mem is: "..mem.." mb")
		API_DumpProcessMem()
        -- if not mainWnd then
        CCTextureCache:sharedTextureCache():removeAllTextures()
		CCTextureCache:sharedTextureCache():dumpCachedTextureInfo()
        -- end
	end
	--g_Timer:pushLoopTimer(2, dumpMem)

	--这个真的没地方加了
	g_FormMsgSystem:RegistTimeCall()
	CreateClientPing()
end

--清除所有的定时器
function Class_Timer:destroyTimerByID(nTimerID)
    if not nTimerID or nTimerID < 0 then return end

	--因为LUA ERROR: invalid key to 'next'
	if self.tbTimer[nTimerID] then self.tbTimer[nTimerID] = nil end
	-- table.insert(self.tabDel, nTimerID)
	-- for k , v in pairs(self.tbTimer) do
		-- if k == nTimerID then
			-- table.insert(self.tabDel, k)
			-- break
		-- end
	-- end
end

--返回定时器
function Class_Timer:getTimerByID(nTimerID)
    if not nTimerID or nTimerID < 0 then return end

	return self.tbTimer[nTimerID]
end

g_Timer = Class_Timer.new()
g_Timer.tbTimer  = {}

-----------------------------------用cocos action 替代g_Timer----------------------
--[[
@fInterval 间隔时间 0 就是每帧执行
@callback  被执行回调函数
@runWgt 绑定到当前业务类的窗口 生成周期是跟当前窗口类一致
]]
function g_PushLoopTimer(fInterval, callback, runWgt)
	if not callback or not runWgt then return end

	local arrAct = CCArray:create()

	local DelayTime = CCDelayTime:create(fInterval)

	local funcCall = CCCallFuncN:create(callback)

	arrAct:addObject(funcCall)
	arrAct:addObject(DelayTime)

	local actionquence = CCSequence:create(arrAct)

	local Forever = CCRepeatForever:create(actionquence)

	runWgt:runAction(Forever)
end


--[[
@times 		执行次数
@fInterval 间隔时间 0 就是每帧执行
@callback  被执行回调函数
@runWgt 绑定到当前业务类的窗口 生成周期是跟当前窗口类一致
]]
function g_pushLimtCountTimer(fInterval, times, callback, runWgt)
	if not callback or not runWgt or not times or times < 1 then return end

	local arrAct = CCArray:create()

	local DelayTime = CCDelayTime:create(fInterval)

	local funcCall = CCCallFuncN:create(callback)

	for i=1, times do
		arrAct:addObject(DelayTime)
		arrAct:addObject(funcCall)
	end

	local actionquence = CCSequence:create(arrAct)
	runWgt:runAction(actionquence)
end


--[[
@nTime 总共执行多久，
@fInterval 每次间隔的时间 默认是每帧都调用
@callback  被执行回调函数
@runWgt 绑定到当前业务类的窗口 生成周期是跟当前窗口类一致
]]

function g_pushLimtTimeTimer(nTime, fInterval, callback, runWgt)
	local nCount = math.max(tonumber(nTime/fInterval) , 1)
	local lasttime = nTime - (nCount*fInterval)

	local arrAct = CCArray:create()

	local DelayTime = CCDelayTime:create(fInterval)
	local funcCall = CCCallFuncN:create(callback)

	for i=1, nCount do
		arrAct:addObject(DelayTime)
		arrAct:addObject(funcCall)
	end

	if lasttime > 0 then
		local lastDelayTime = CCDelayTime:create(lasttime)
		arrAct:addObject(lastDelayTime)
		arrAct:addObject(funcCall)
	end
	

	local actionquence = CCSequence:create(arrAct)
	runWgt:runAction(actionquence)
end










