require "Core.Role.Action.MoveRoleToDistanceAction";

RepelAction = class("RepelAction", MoveRoleToDistanceAction)

function RepelAction:New(toPoint, distance)
    self = { };
    setmetatable(self, { __index = RepelAction });
    self:Init();
    self.actionType = ActionType.COOPERATION;
    self._toPoint = toPoint;
    self._distance = distance;
    return self;
end

function RepelAction:_InitData()
    local controller = self._controller;
    if (controller) then
        self._r = math.atan2(self._toPoint.x - controller.transform.position.x, self._toPoint.z - controller.transform.position.z);
        self._totalTime = self._distance / controller:GetMoveSpeed();
    end
end