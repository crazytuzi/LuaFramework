--
-- Author: MiYu
-- Date: 2014-02-12 11:25:08
--

local TFEventManager 		= require('TFFramework.client.manager.TFEventManager')
local TFEnterFrameManager 	= require('TFFramework.client.manager.TFEnterFrameManager')
local TFTimerManager 		= require('TFFramework.client.manager.TFTimerManager')

function TFDirector:description(...)
	--
	TFDirector:addEnterFrameEvent(enterFrameFunc, ...)
	TFDirector:removeEnterFrameEvent(enterFrameFunc)
	TFDirector:removeAllEnterFrameEvents()
	TFDirector:addMEListener(objTarget, szEventType, func, bIsOnce)
	TFDirector:addMEGlobalListener(szEventType, func, bIsOnce)
	TFDirector:addMEListenerOnce(objTarget, szEventType, func)
	TFDirector:addMEGlobalListenerOnce(szEventType, func)
	TFDirector:removeMEListener(objTarget, szEventType, func)
	TFDirector:removeMEGlobalListener(szEventType, func)
	TFDirector:dispatchEventWith(objTarget, szEventType, ...)
	TFDirector:dispatchGlobalEventWith(szEventType, ...)
	TFDirector:addTimer(nDelay, nRepeatCount, timerCompleteCallBackFunc, timerCallBackFunc, ...)
	TFDirector:removeTimer(nTimerId)
	TFDirector:startTimer(nTimerId)
	TFDirector:stopTimer(nTimerId)
	TFDirector:resetTimer(nTimerId)
	TFDirector:getTimerCurrCount(nTimerId)
	TFDirector:registerBeforTimerCallbackFunc(btFunc)
	TFDirector:unRegisterBeforTimerCallbackFunc()

end

--[[--
	添加帧频事件
	@param enterFrameFunc: 注册的事件句柄
	@param ...: 事件回调时附加的参数
]]
function TFDirector:addEnterFrameEvent(enterFrameFunc, ...)
	TFEnterFrameManager:addEnterFrameEvent(enterFrameFunc, ...)
end

--[[--
	移除指定帧频事件
	@param enterFrameFunc: 需要移除的事件句柄
]]
function TFDirector:removeEnterFrameEvent(enterFrameFunc)
	TFEnterFrameManager:removeEnterFrameEvent(enterFrameFunc)
end

--[[--
	移除所有帧频事件
]]
function TFDirector:removeAllEnterFrameEvents()
	TFEnterFrameManager:removeAllEnterFrameEvents()
end

--[[--
	添加指定对象的指定事件类型的指定事件
	@param objTarget:事件对象
	@param szEventType:事件类型
	@param func:事件回调
	@param bIsOnce:事件回调的执行次数,true表示只执行一次,false表示无限制,默认为false
]]
function TFDirector:addMEListener(objTarget, szEventType, func, bIsOnce)
	TFEventManager:addMEListener(objTarget, szEventType, func, bIsOnce)
end

--[[--
	添加全局指定事件类型的指定事件
	@param szEventType:事件类型
	@param func:事件回调
	@param bIsOnce:事件回调的执行次数,true表示只执行一次,false表示无限制,默认为false
]]
function TFDirector:addMEGlobalListener(szEventType, func, bIsOnce)
	TFEventManager:addMEGlobalListener(szEventType, func, bIsOnce)
end

--[[--
	添加指定对象的指定事件类型的指定事件, 事件回调只会执行一次
	@param objTarget:事件对象
	@param szEventType:事件类型
	@param func:事件回调
]]
function TFDirector:addMEListenerOnce(objTarget, szEventType, func)
	TFEventManager:addMEListenerOnce(objTarget, szEventType, func)
end

--[[--
	添加全局的指定事件类型的指定事件, 事件回调只会执行一次
	@param szEventType:事件类型
	@param func:事件回调
]]
function TFDirector:addMEGlobalListenerOnce(szEventType, func)
	TFEventManager:addMEGlobalListenerOnce(szEventType, func)
end

--[[--
	移除指定对象的指定事件类型的指定事件
	@param objTarget:事件对象
	@param szEventType:事件类型
	@param func:事件回调, 如果为空,表示移除当前事件的所有回调
]]
function TFDirector:removeMEListener(objTarget, szEventType, func)
	TFEventManager:removeMEListener(objTarget, szEventType, func)
end

--[[--
	移除全局对象的指定事件类型的指定事件
	@param szEventType:事件类型
	@param func:事件回调, 如果为空,表示移除当前事件的所有回调
]]
function TFDirector:removeMEGlobalListener(szEventType, func)
	TFEventManager:removeMEGlobalListener(szEventType, func)
end

--[[--
	给指定对象的指定事件类型派发事件
	@param objTarget:事件对象
	@param szEventType:事件类型
	@param ...:事件数据
]]
function TFDirector:dispatchEventWith(objTarget, szEventType, ...)
	TFEventManager:dispatchEventWith(objTarget, szEventType, ...)
end

--[[--
	给全局对象的指定事件类型派发事件
	@param szEventType:事件类型
	@param ...:事件数据
]]
function TFDirector:dispatchGlobalEventWith(szEventType, ...)
	TFEventManager:dispatchGlobalEventWith(szEventType, ...)
end

--[[--
	添加定时器
	@param nDelay:定的时间间隔
	@param nRepeatCount:执行的次数, -1表示无限制
	@param timerCompleteCallBackFunc:定时器完成执行的回调函数
	@param timerCallBackFunc:定时器每执行一次所执行的回调函数
	@return 定时器的id
]]
function TFDirector:addTimer(nDelay, nRepeatCount, timerCompleteCallBackFunc, timerCallBackFunc, ...)
	return TFTimerManager:addTimer(nDelay, nRepeatCount, timerCompleteCallBackFunc, timerCallBackFunc, ...)
end

--[[--
	移除指定定时器ID所代表定时器
	@param nTimerId: 定时器ID
]]
function TFDirector:removeTimer(nTimerId)
	TFTimerManager:removeTimer(nTimerId)
end

--[[--
	开始指定定时器ID所代表定时器
	@param nTimerId: 定时器ID
]]
function TFDirector:startTimer(nTimerId)
	TFTimerManager:startTimer(nTimerId)
end

--[[--
	停止指定定时器ID所代表定时器
	@param nTimerId: 定时器ID
]]
function TFDirector:stopTimer(nTimerId)
	TFTimerManager:stopTimer(nTimerId)
end

--[[--
	重置指定定时器ID所代表定时器
	@param nTimerId: 定时器ID
]]
function TFDirector:resetTimer(nTimerId)
	TFTimerManager:resetTimer(nTimerId)
end

--[[--
	获取指定定时器ID所代表定时器的当前执行次数
	@param nTimerId: 定时器ID	
	@return: 定时器执行次数
]]
function TFDirector:getTimerCurrCount(nTimerId)
	return TFTimerManager:getTimerCurrCount(nTimerId)
end

--[[
	not used yet
]]
function TFDirector:registerBeforTimerCallbackFunc(btFunc)
	TFTimerManager:registerBeforTimerCallbackFunc(btFunc)
end

function TFDirector:unRegisterBeforTimerCallbackFunc()
	TFTimerManager:unRegisterBeforTimerCallbackFunc()
end
