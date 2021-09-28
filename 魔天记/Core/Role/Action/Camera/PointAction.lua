require "Core.Role.Action.AbsAction";
PointAction = class("PointAction", AbsAction)

function PointAction:New(pos, rotation)
    self = { };
    setmetatable(self, { __index = PointAction });
    self:Init();
    self.actionType = ActionType.NORMAL;
    self.isPauseMainAction = true;
    self.pos = pos
    self.rotation = rotation
    return self;
end

function PointAction:_OnStartHandler()
    if (self._controller) then
        self._controller:SetPoint(self.pos, self.rotation)
    end
end

function PointAction:_OnTimerHandler()
    
end

function PointAction:_OnStopHandler()
    
end