require "Core.Role.Action.MoveToAngleAction";

SkillMoveAction = class("SkillMoveAction", MoveToAngleAction)

function SkillMoveAction:New(angle)
    self = { };
    setmetatable(self, { __index = SkillMoveAction });
    self:Init();
    self.actionType = ActionType.COOPERATION;
    self:_SetAngle(angle);
    return self;
end

function SkillMoveAction:_OnStartHandler()
    local controller = self._controller;
    if (controller) then
        controller.state = RoleState.MOVE;
        --controller.transform.rotation = Quaternion.Euler(0,(self._r * 180.0 / math.pi), 0);
        Util.SetRotation(controller.transform, 0, (self._r * 180.0 / math.pi), 0)
        self:_InitTimer(0, -1);
        self:_OnStartCompleteHandler();
    end
end

function SkillMoveAction:_OnTimerHandler()
    local controller = self._controller;
    local act = controller:GetAction();
    if (act == nil) then
        self:Stop();
        controller:DoAction(MoveToAngleAction:New(self._angle));
    else
        self:_OnMoveToAngleHandler();
    end
end
