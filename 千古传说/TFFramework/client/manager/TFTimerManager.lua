--[[--
	定时器管理器:

	--By: yun.bo
	--2013/7/8
]]
local TFFunction 			= TFFunction

local TFBaseManager 		= require('TFFramework.client.manager.TFBaseManager')
local TFTimer 				= require('TFFramework.client.timer.TFTimer')
local TFTimerQueue 			= require('TFFramework.client.timer.TFTimerQueue')

local TFTimerManager 		= class('TFTimerManager', TFBaseManager)
local TFTimerManagerModel 	= {}
TFTimerManager.model = TFTimerManagerModel


function TFTimerManagerModel:reset()
	TFTimerManagerModel.nTimerCount 	= 0
	TFTimerManagerModel.tTimers 		= {}
	TFTimerManagerModel.tTimerQueue 	= {} -- TFTimerQueue:new()
	TFTimerManagerModel.tTimerQueueBuf 	= {} -- TFTimerQueue:new()

	TFTimerManagerModel.beforTimerCallBackFunc = nil
end

function TFTimerManager:ctor()
	self.model:reset()
end

function TFTimerManager:registerBeforTimerCallbackFunc(btFunc)
	TFTimerManagerModel.beforTimerCallBackFunc = btFunc
end

function TFTimerManager:unRegisterBeforTimerCallbackFunc()
	TFTimerManagerModel.beforTimerCallBackFunc = nil
end
		
function TFTimerManager:update(nElapse)
    for id, tTimer in pairs(TFTimerManagerModel.tTimers) do 
        if tTimer then
			if not tTimer.bIsStop then
				tTimer.nExecuteTime = tTimer.nExecuteTime + nElapse * 1000
				if tTimer.nExecuteTime >= tTimer.nDelay then
					--TFFunction.call(TFTimerManagerModel.beforTimerCallBackFunc)
					tTimer:execute()
				end
			end
		end
    end

--[[
	local tTimerQueue 		= TFTimerManagerModel.tTimerQueue
	local tTimerQueueBuf 	= TFTimerManagerModel.tTimerQueueBuf

	local tTimer = tTimerQueue:popFront()
	local bIsUpdate = false
	while tTimer do
		if tTimer then
			if not tTimer.bIsStop and TFTimerManagerModel.tTimers[tTimer.nTimerId] then
				tTimer.nExecuteTime = tTimer.nExecuteTime + nElapse * 1000
				if tTimer.nExecuteTime >= tTimer.nDelay then
					--TFFunction.call(TFTimerManagerModel.beforTimerCallBackFunc)
					tTimer:execute()
				end
			end
			if TFTimerManagerModel.tTimers[tTimer.nTimerId] then
				tTimerQueueBuf:push(tTimer)
				bIsUpdate = true
			end
		end
		tTimer = tTimerQueue:popFront()
	end
	if bIsUpdate then
		TFTimerManagerModel.tTimerQueue = tTimerQueueBuf
		TFTimerManagerModel.tTimerQueueBuf = tTimerQueue
    	tTimerQueue:clear()
	end
    ]]
end

function TFTimerManager:insertQueue(tTimer)
	--[[local tTimerQueue = TFTimerManagerModel.tTimerQueue
	local nLen = tTimerQueue:length()
	if nLen == 0 then tTimerQueue:push(tTimer) return end
	for i = 1, nLen do
		if tTimerQueue:getTimerAt(i).nExecuteTime >= tTimer.nExecuteTime then
			tTimerQueue:insertAt(i, tTimer)
			return
		end
	end]]
end

--[[--
	添加定时器
	@param nDelay:定的时间间隔( 毫秒)
	@param nRepeatCount:执行的次数, -1表示无限制
	@param timerCompleteFunc:定时器完成执行的回调函数
	@param timerFunc:定时器每执行一次所执行的回调函数
	@return 定时器的id
]]	
function TFTimerManager:addTimer(nDelay, nRepeatCount, timerCompleteFunc, timerFunc, ...)
	nDelay = nDelay or 0
	nRepeatCount = nRepeatCount or -1
	TFTimerManagerModel.nTimerCount = TFTimerManagerModel.nTimerCount + 1
	local properties = {
		nDelay 					= nDelay,
		nRepeatCount 			= nRepeatCount,
		nTimerId 				= TFTimerManagerModel.nTimerCount,          	 	
		timerCompleteFunc 		= timerCompleteFunc,
		timerFunc     			= timerFunc
	}
	local tTimer = TFTimer:new(properties)
	tTimer.tParam = {...}
	tTimer.tParam[#tTimer.tParam + 1] = 0
	--self:insertQueue(tTimer)
	--TFTimerManagerModel.tTimerQueue:push(tTimer)
	TFTimerManagerModel.tTimers[tTimer.nTimerId] = tTimer
	return tTimer.nTimerId
end

--[[--
	移除指定定时器
	@param nTimerId:定时器id
	@return nil
]]	
function TFTimerManager:removeTimer(nTimerId)
	if not nTimerId then return end
	local nIndex
	local tTimerQueue
	local tTimer = TFTimerManagerModel.tTimers[nTimerId]
	if not tTimer then return end
	--local tTimerQueue = TFTimerManagerModel.tTimerQueue
	--tTimerQueue:removeObject(tTimer)
	TFTimerManagerModel.tTimers[tTimer.nTimerId] = nil
end

--[[--
	开始指定定时器
	@param nTimerId:定时器id
	@return nil
]]	
function TFTimerManager:startTimer(nTimerId)
	local tTimer = TFTimerManagerModel.tTimers[nTimerId]
	if not tTimer then return end
	tTimer:start()
end

--[[--
	停止指定定时器
	@param nTimerId:定时器id
	@return nil
]]	
function TFTimerManager:stopTimer(nTimerId)
	local tTimer = TFTimerManagerModel.tTimers[nTimerId]
	if not tTimer then return end
	tTimer:stop()
end

--[[--
	重置指定定时器
	@param nTimerId:定时器id
	@return nil
]]	
function TFTimerManager:resetTimer(nTimerId)
	local tTimer = TFTimerManagerModel.tTimers[nTimerId]
	if not tTimer then return end
	tTimer:reset()
end

--[[--
	获取指定定时器当前执行的次数
	@param nTimerId:定时器id
	@return 定时器当前执行的次数
]]	
function TFTimerManager:getTimerCurrCount(nTimerId)
	local tTimer = TFTimerManagerModel.tTimers[nTimerId]
	if tTimer then
		return tTimer.nCurrentCount
	end
	return -1
end

return TFTimerManager:new()