 SequenceInstance = class("SequenceInstance");

function SequenceInstance:ctor(seqName, param)
    self:_Init(seqName, param);
end

function SequenceInstance:_Init(seqName, param)
    self.name = seqName;
    self.content = SequencePool.Create(self.name);
    self.param = param;
    self._updateInterval = 0;
    self._lastUpdateTime = -1;
    self._isStart = false;
    self._leftTime = -1;
    self._ignoreTimeScale = false;
    self.currentTrigger = nil;
    self.lastSequenceEventType = SequenceEventType.NONE;
end

function SequenceInstance:UpdateParam(param)
    self.param = param;
end

function SequenceInstance:Start()
    self._isFinish = false;
    self.currentStep = 1;
    self._updateInterval = self.content:GetFrameRate() > 0 and ( 1 / self.content:GetFrameRate() ) or 0;
    self._lastUpdateTime = -1;
    self.currentTrigger = nil;
    self:Process(SequenceEventType.START);
end

--[[
function SequenceInstance:Test(param)
    --返回内容的对比结果.
    return self.content:Test(self.param, param);
end
]]

function SequenceInstance:TriggerEvent(eType, args)
    local sequenceEvent = self:CheckTrigger(eType, args);
    if (sequenceEvent ~= nil) then
        self:OnTriggerEvent(sequenceEvent, args);
    end
end

function SequenceInstance:CheckTrigger(sequenceEventType, args)
    if (self._isFinish ~= true and self.currentTrigger ~= nil and self.currentTrigger.events ~= nil) then
        for i, sequenceEvent in ipairs(self.currentTrigger.events) do
            if(sequenceEvent.eventType == sequenceEventType) then 
                if (sequenceEvent.eventFilter == nil) then
                    return sequenceEvent;
                else 
                    if (sequenceEvent.eventFilter(args)) then
                        return sequenceEvent;
                    end
                end
            end
        end
    end
    return nil;
end

function SequenceInstance:OnTriggerEvent(sequenceEvent, args)
    if (sequenceEvent.triggerCallBack ~= nil) then
        sequenceEvent.triggerCallBack(sequenceEvent.eventType, args);
    end
    self:Process(sequenceEvent.eventType);
end

function SequenceInstance:UpdateSequence()
    
    if(self._updateInterval > 0) then
        if (Time.unscaledTime - self._lastUpdateTime < self._updateInterval) then 
            return;
        end
        self._lastUpdateTime = Time.unscaledTime;
    end
    
    if (self.currentTrigger== nil or self.currentTrigger.events == nil) then
        
        self:Process(SequenceEventType.UPDATE);

    else
        for i, sequenceEvent in ipairs(self.currentTrigger.events) do
            
            if (sequenceEvent.eventType == SequenceEventType.NONE) then
                
                self:Process(SequenceEventType.UPDATE);
            
            elseif(sequenceEvent.eventType == SequenceEventType.DELAY)then
                
                if self._ignoreTimeScale then
                    self._leftTime = self._leftTime - Time.unscaledDeltaTime;
                else 
                    self._leftTime = self._leftTime - Time.deltaTime;
                end

                if (self._leftTime <= 0) then
                    if (sequenceEvent.triggerCallBack ~= nil) then
                        sequenceEvent.triggerCallBack(SequenceEventType.DELAY, nil);
                    end
                    self:Process(SequenceEventType.UPDATE);
                end

            elseif(sequenceEvent.eventType == SequenceEventType.DELAY_FRAME)then
                
                if(self.lastSequenceEventType == SequenceEventType.UPDATE) then
                    if (sequenceEvent.triggerCallBack ~= nil) then
                        sequenceEvent.triggerCallBack(SequenceEventType.DELAY_FRAME, nil);
                    end
                    self:Process(SequenceEventType.UPDATE);
                else 
                    self.lastSequenceEventType = SequenceEventType.UPDATE;
                end

            end
            
        end
    end
end

local function __OnSequenceError__(errmsg)
    local track_text = debug.traceback(tostring(errmsg), 6);
    --Warning("---------------------------------------- OnSequenceError ----------------------------------------");
    --Warning(track_text, "LUA ERROR");
    --Warning("---------------------------------------- OnSequenceError ----------------------------------------");
    Error(track_text);
    return false;
end

function SequenceInstance:Process(sequenceEventType)

    if (sequenceEventType == SequenceEventType.START) then
        self._isStart = true;
    end

    if (self._isStart ~= true) then
        return;
    end

    self.lastSequenceEventType = sequenceEventType;
    while (self._isFinish ~= true and self.content ~= nil and table.getn(self.content.GetSteps()) >= self.currentStep) do
        
        --self.currentTrigger = self:GetCurrentStep()(self);

        local fun = self:GetCurrentStep();
        xpcall(function() self.currentTrigger = fun(self); end, function(err) __OnSequenceError__(err); self:SetError(); end);

        if SequenceManager.DEBUG then
            if self.stepGo then
                self.stepGo.name = "Step_" .. self.currentStep;
            end
        end
        self:NextStep();
        
        if (self.currentTrigger ~= nil) then
            for i, sequenceEvent in ipairs(self.currentTrigger.events) do
                if (sequenceEvent.eventType == SequenceEventType.NONE) then
                
                    self.currentTrigger = nil;
            
                elseif (sequenceEvent.eventType == SequenceEventType.DELAY) then
                    
                    self._leftTime = sequenceEvent.eventArgs[1];
                    self._ignoreTimeScale = sequenceEvent.eventArgs[2];

                end
            end

        end
       
        if (self.currentTrigger ~= nil) then
            return;
        end

    end
    self:Finish();
end

function SequenceInstance:GetCurrentStep()
    return self.content.GetSteps()[self.currentStep];
end

function SequenceInstance:NextStep()
    self.currentStep = self.currentStep + 1;
end

function SequenceInstance:Finish()
    if (self._isFinish == true) then
        return;
    end

    self._isFinish = true;
    self._isStart = false;
    self.currentTrigger = nil;

    SequenceManager.Stop(self.name);
end

function SequenceInstance:Dispose()
    self.content = nil;
end

--如果是在Trigger的Callback里执行 则是跳转到某个执行步骤.
--如果是在步骤里执行.则是跳转到sequenceStep的后一个步骤.
function SequenceInstance:SkipAfterStep(sequenceStep, offset)
    offset = offset or 0;
    local newStep = 1;
    local steps = self.content.GetSteps();
    while (newStep <= #steps) do
        if (steps[newStep] == sequenceStep) then
            break;
        end
        newStep = newStep + 1;
    end
    self.currentStep = offset + newStep;
end

