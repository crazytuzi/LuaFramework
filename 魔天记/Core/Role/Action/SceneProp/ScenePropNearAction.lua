local ScenePropAction = require "Core.Role.Action.SceneProp.ScenePropAction"
local ScenePropNearAction = class("ScenePropNearAction", ScenePropAction)

function ScenePropNearAction:New()
    self = { };
    setmetatable(self, { __index = ScenePropNearAction });
    return self
end

function ScenePropNearAction:_OnStartHandler()
    if (self._controller) then
        self._target = HeroController.GetInstance();
        self:_InitTimer(0.3, -1);
        self.pos = self._controller:GetPos()
        self.range = self._controller.info.range
        self:_Near(self._target, self._controller)
    end
end
function ScenePropNearAction:_OnTimerHandler()
    self:_CheckNear()
end

function ScenePropNearAction:_CheckNear()
    local controller = self._controller;
    if (controller) then
        local target = self._target;
--        if (target) then
--            local act = target:GetAction();
--            if (act ~= nil and (act.__cname == "SendMoveToAngleAction" or act.__cname == "SendMoveToAction" or act.__cname == "SendMoveToNpcAction"
--                --or act.__cname == "SendMoveToPathAction" or act.__cname == "SendMoveToTargetAction"
--                )) then
                self:_Near(target, controller)
--            end
--        end
    end
end
function ScenePropNearAction:_Near(target, controller)
    local dis = Vector3.Distance2(self.pos, target:GetPos())
    if (dis < self.range) then
        if (not self._isInPortal) then
            self._isInPortal = true
            self:OnNear()
        end
    else
        if (self._isInPortal) then
            self._isInPortal = false;
            self:OnAway()
        end
    end
    if dis < 25 then controller:CheckLoadModel() end
end
function ScenePropNearAction:OnNear()
    
end
function ScenePropNearAction:OnAway()
    
end




return ScenePropNearAction