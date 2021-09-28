AbsState = class("AbsState")


-- 初始化状态
function AbsState:Init(controller)
	self._controller = controller
    return self
end
-- 开启关闭状态
function AbsState:SetEnable(val)
	self.enable = val
end
-- 状态是否启用
function AbsState:GetEnable()
	return self.enable
end

-- 初始化心跳
function AbsState:_StartTimer(duration, loop)
    local t = self._timer
	if not t then 
		t = Timer.New(function(val) self:_OnTimerHandler(val) end, duration, loop, false)
        if duration > 0 then t:AddCompleteListener(function(val) self:_OnStopHandler(val) end) end
        self._timer = t
    else t:ResetDuration(duration)
    end
    if not t.running then t:Start() end
    self:_OnStartHandler()
end
-- 结束动作
function AbsState:_StopTimer()
    if self._timer then self._timer:Stop() end
    self:_OnStopHandler()
end
-- 心跳，子类可重写
function AbsState:_OnTimerHandler()
	
end
-- 结束动作，子类可重写
function AbsState:_OnStopHandler()
	
end
-- 开始动作，子类可重写
function AbsState:_OnStartHandler()
	
end

-- 销毁状态
function AbsState:Dispose()
    self:_StopTimer()
	self.enable = false
end
