Trigger = class("Trigger");

function Trigger:ctor(id, data)
    self:Init(id, data);
end

function Trigger:Init(id, data)
    self.id = id;
    self._needUpdate = false;       --默认不需要update
    self._active = true;            --默认激活
    self:_Init(id, data);
    self:_SetParam(data);
end

function Trigger:_Init(id, data)
    
end

function Trigger:IsActive()
    return self._active;
end

--设置触发器参数
function Trigger:_SetParam(data)
    
end

function Trigger:OnEvent(sequenceEventType, param)
    
end

function Trigger:NeedUpdate()
    return self._needUpdate;
end

--触发器检查
function Trigger:Update()
    
end

--检查的结果
function Trigger:Result(bool)
    
end

--销毁
function Trigger:Dispose()
    
end