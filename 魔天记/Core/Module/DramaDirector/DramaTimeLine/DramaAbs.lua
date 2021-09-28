--剧情基类
DramaAbs = class("DramaAbs");
DramaAbs.EvenType = "eventType"
DramaAbs.EvenParam1 = "evenParam1"
DramaAbs.EvenParam2 = "evenParam2"
DramaAbs.EvenParam3 = "evenParam3"
DramaAbs.EvenParam4 = "evenParam4"
-- 剧情初始化
function DramaAbs:Init(config, hero, camera)
    self.config = config
    self._hero = hero
    self._camera = camera
    self:_Init()
end
function DramaAbs:_Init()
    
end
--准备剧情
function DramaAbs:Ready(skipTime)
    self._startTimer = DramaDirector.GetTimer((self.config.eventStartTime - skipTime) / 1000, 1,function ()
        self._startTimer = nil
        self:Begin()
    end)
end
-- 开始剧情
function DramaAbs:Begin()
    self.running = true
    self:_Begin()
    self._execute = true
    self._endTime = DramaDirector.GetTimer(self.config.eventDurationTime / 1000, 1,function ()
        self._endTime = nil
        self:End()
    end)
end
function DramaAbs:_Begin(fixed)
    
end
--关键处理
function DramaAbs:FixedExecute()
    if self._execute then return end
    self:_Begin(true)
    self._execute = true
end
-- 结束剧情
function DramaAbs:End()
    if not self.running then return end
    self.running = false
    self:_End()
    DramaTimer.End(self)
    self:Dispose()
end
function DramaAbs:_End()
end
-- 清理
function DramaAbs:Dispose()
    self._hero = nil
    self._camera = nil
    if self._endTime then
        self._endTime:Stop()
        self._endTime = nil
    end
    if self._startTimer then
        self._startTimer:Stop()
        self._startTimer = nil
    end
    self:_Dispose()
end
function DramaAbs:_Dispose()
end

--加速事件开始
function DramaAbs:CutTime(time)
    if self._startTimer then
        self._startTimer:CutTime(time)
    end
end
--场景中查找物件
function DramaAbs:_GetSceneGo(name)
    return GameObject.Find(name)
end
--场景中查找物件
function DramaAbs:_IsDelayDetele()
    self._delayDetele = self.config[DramaAbs.EvenParam3]
    self._isDelayDetele = self._delayDetele > 0
    return self._isDelayDetele
end

-- 延迟删除对象
function DramaAbs:_DelayDetele(obj)
    if self._isDelayDetele then DramaDirector.DeleteDelay(self._delayDetele / 1000, obj) end
end

