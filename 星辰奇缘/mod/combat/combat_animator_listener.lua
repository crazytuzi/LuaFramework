-- 动画事件监听
AnimatorListener = AnimatorListener or BaseClass()

function AnimatorListener:__init(controller)
    self.controller = controller
    -- eventDict = {eventType = {motionIndex = {action, action, ...}}}
    self.eventDict = {}
end

function AnimatorListener:AddListener(eventType, motionIndex, func, owner)
    local funcInfo = {func = func, param= owner}
    if self.eventDict[eventType] == nil then
        self.eventDict[eventType] = {}
        self.eventDict[eventType][motionIndex] = {funcInfo}
    else
        if self.eventDict[eventType][motionIndex] == nil then
            self.eventDict[eventType][motionIndex] = {funcInfo}
        else
            local list = self.eventDict[eventType][motionIndex]
            table.insert(list, funcInfo)
        end
    end
end

function AnimatorListener:OnStart()
    self:Fire(CombatEventType.Start)
end

function AnimatorListener:OnEnd()
    self:Fire(CombatEventType.End)
end

function AnimatorListener:OnHit()
    self:Fire(CombatEventType.Hit)
end

function AnimatorListener:OnMultiHit()
    self:Fire(CombatEventType.MultiHit)
end

function AnimatorListener:OnMoveEnd()
    self:Fire(CombatEventType.MoveEnd)
end

function AnimatorListener:Fire(eventType)
    local status, err = xpcall(function() self:DoFire(eventType) end, function(errinfo) print("InvokeDelay出错了:" .. tostring(errinfo)); print(debug.traceback()) end)
    if not status then
        CombatManager.Instance.isBrocasting = false
        error("DoFire出错了" .. tostring(err))
    end
end

function AnimatorListener:DoFire(eventType)
    local motionIndex = nil
    if eventType == CombatEventType.MoveEnd then
        motionIndex = self.controller:GetMoveIndex()
    else
        motionIndex = self.controller:GetMotionIndex()
    end
    if self.eventDict[eventType] ~= nil and self.eventDict[eventType][motionIndex] ~= nil then
        local list = self.eventDict[eventType][motionIndex]
        self.eventDict[eventType][motionIndex] = nil
        for i, v in ipairs(list) do
            v.func(v.param)
        end
    end
    if eventType == CombatEventType.End then
        for k, v in pairs(self.eventDict) do
            if self.eventDict[k][motionIndex] ~= nil then
                self.eventDict[k][motionIndex] = nil
                Log.Error("战斗事件出问题了,可能是事件设置时间不对，EventType:" .. k .. " Type:" .. eventType.." 单位："..self.controller.fighterData.name)
            end
        end
    end
end

