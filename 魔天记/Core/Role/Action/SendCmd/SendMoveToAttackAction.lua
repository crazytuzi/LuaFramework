require "Core.Role.Action.SendCmd.SendMoveToSkillAction";

SendMoveToAttackAction = class("SendMoveToAttackAction", SendMoveToSkillAction)

function SendMoveToAttackAction:New(target)
    self = { };
    setmetatable(self, { __index = SendMoveToAttackAction });
    self:Init();
    self.actionType = ActionType.NORMAL;
    self._stopDistance = 0;
    self._toMap = GameSceneManager.map.info.id;
    self.isAcrossMap = false;
    self:SetTarget(target);
    return self;
end

function SendMoveToAttackAction:_SetController(controller)
    self._controller = controller;
    if (self._controller) then
        local skill = self._controller.info:GetBaseSkill();
        if (skill) then
            self._stopDistance = skill.distance / 100 * 0.8;
        end
    end
end

function SendMoveToAttackAction:_StartSkill()
    if (self._target and(not self._target:IsDie())) then
        self._controller:DoAction(SendAttackAction:New());
    end
end