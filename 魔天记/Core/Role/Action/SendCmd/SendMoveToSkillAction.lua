require "Core.Role.Action.SendCmd.SendMoveToTargetAction";

SendMoveToSkillAction = class("SendMoveToSkillAction", SendMoveToTargetAction)

function SendMoveToSkillAction:New(target, skill, replaceDistance)
    self = { };
    setmetatable(self, { __index = SendMoveToSkillAction });
    self:Init();
    self.actionType = ActionType.NORMAL;
    self._skill = skill;
    if (target) then
        self._stopDistance =(skill.distance + target.info.radius) / 100 * 0.8;
    else
        self._stopDistance = skill.distance / 100 * 0.8;
    end
    self._toMap = GameSceneManager.map.info.id;
    self.isAcrossMap = false;
    self._disRoleEvent = false;
    self:SetTarget(target);
    return self;
end

function SendMoveToSkillAction:_OnCompleteHandler()
    local controller = self._controller;
    local target = self._target;
    if (target and target.transform) then
        if (Vector3.Distance2(target.transform.position, controller.transform.position) > self._stopDistance * 1.1) then
            self._toPosition = target.transform.position;
            if (controller) then
                self:_SearchPath();
                if (self._path) then
                    self:_NextPosition();
                else
                    controller:SetTarget(nil);
                    self:Finish();
                end
            end
        else
            self:Pause();
            -- self._delayTimer =  Timer.New( function(val) self:_OnDelayTimerCompleteHandler(val) end, 0.05, 1, false);
            -- self._delayTimer:Start();
            self:_StartSkill();
        end
    else
        self:Finish();
    end
end



function SendMoveToSkillAction:_StartSkill()
    if (self._skill and self._target and(not self._target:IsDie())) then
        self._controller:DoAction(SendSkillAction:New(self._skill));
    else
        self:Finish();
    end
end