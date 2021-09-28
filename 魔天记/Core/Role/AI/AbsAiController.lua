AbsAiController = class("AbsAiController")

AI = {}
AI.Status = {
    Normal = 0;
    Stand = 1;
    Patrol = 2;
    Follow = 3;
    Fight = 4;
    ToTarget = 5;
    CastSkill = 6;
}

AbsAiController.ID = 1

function AbsAiController:New(role)
    self = { };
    setmetatable(self, { __index = AbsAiController });
    self:_Init(role);
    return self;
end

function AbsAiController:_Init(role)
    AbsAiController.ID = AbsAiController.ID + 1
    self._role = role;
    self._osTime = os.clock();
    self._delayTime = 0 
    self.isPause = false;
    self.id = AbsAiController.ID
end

function AbsAiController:_Randomseed()
    if (self._role and self._role.transform) then
        local position = self._role.transform.position;
        -- math.randomseed(position.x * position.y * position.z * 100 + self.id);
    else
        -- math.randomseed(Time.time)
    end
end

-- 开始
function AbsAiController:Start()
    if (self._timer == nil) then
        self._timer = Timer.New( function(val) self:_OnTickHandler(val) end, 0.1, -1, false);
        self._timer:Start();
    end    
end

-- 停止
function AbsAiController:Stop()    
    if (self._timer) then
        self._timer:Stop();
        self._timer = nil;
    end
    self:_OnStopHandler()
end

function AbsAiController:_OnStopHandler()
    if (self._timer) then
        self._timer:Stop();
        self._timer = nil;
    end
end

function AbsAiController:IsTimeRuning()
    if self._timer ~= nil then
     return true;
    end
     return false;
end

-- 暂停
function AbsAiController:IsPause()
    return self.isPause;
end

-- 暂停
function AbsAiController:Pause()
    self.isPause = true;
end

-- 继续
function AbsAiController:Resume()
    self.isPause = false;
end

function AbsAiController:_OnTickHandler()
    if (GameSceneManager.map == nil) then return end
    if (not self.isPause) then
        local currTime = os.clock();
        self._delayTime = currTime - self._osTime
        self._osTime = currTime;
        self:_OnTimerHandler();
    end
end

-- 心跳调用函数，子类重写
function AbsAiController:_OnTimerHandler()

end

function AbsAiController:_DisposeHandler()

end

function AbsAiController:Dispose()
    self:_DisposeHandler()
    self:Stop();
    self._role = nil;
end