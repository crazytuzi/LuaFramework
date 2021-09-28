require "Core.Role.Action.SendCmd.SendSkillAction"
require "Core.Role.Action.SendCmd.SendMoveToSkillAction"
require "Core.Role.Action.SendCmd.SendAttackAction"
require "Core.Role.Action.SendCmd.SendMoveToAttackAction"

MountAttackController = class("MountAttackController");
MountAttackController._timer = nil;
MountAttackController._role = nil;
function MountAttackController:New(role)
    self = { };
    setmetatable(self, { __index = MountAttackController });
    self:_Init(role);
    return self;
end

function MountAttackController:_Init(role)
    self._role = role;
    self._timer = Timer.New( function(val) self:_OnTimerHandler(val) end, 0.1, -1, false);
end

function MountAttackController:_OnTimerHandler()
    local role = self._role;
    if (role and role.state ~= RoleState.die) then
        local skill = role.info:GetBaseSkill();
        local action = role:GetAction();
        if (action == nil or(action and action.actionType ~= ActionType.Block)) then
            local target = role.target;
            if (target == nil or(target and(target.state == RoleState.DIE or target.state == RoleState.RETREAT or Vector3.Distance2(role.transform.position, target.transform.position) > skill.max_distance / 100))) then
                target = GameSceneManager.map:GetRoleByDistance(role.transform.position, skill.max_distance / 100, ControllerType.MONSTER)
                role.target = target;
            end
            if (target and target.transform) then
                if (Vector3.Distance2(role.transform.position, target.transform.position) < skill.distance / 100) then
                    role:DoAction(SendAttackAction:New());
                else
                    if (action) then
                        if (action.__cname == "SendMoveToAttackAction") then
                            if (action:GetTarget() ~= target) then
                                action:SetTarget(target);
                            end
                        else
                            role:DoAction(SendMoveToAttackAction:New(target));
                        end
                    else
                        role:DoAction(SendMoveToAttackAction:New(target));
                    end
                end
            else
                if (skill.is_tar_need == 0) then
                    role:DoAction(SendAttackAction:New());
                else

                    MsgUtils.ShowTips(nil, nil, nil, "找不到目标，无法释放技能");
                end
            end
        end
    end
end

function MountAttackController:StartAttack()
    local role = self._role;
    if (role) then
        self._timer.running = true;
        self._timer:Start();
        self:_OnTimerHandler();
    end
end

function MountAttackController:StopAttack()
    self._timer.running = false;
end

function MountAttackController:CastSkill(skill)
    local role = self._role;
    if (role and role.state ~= RoleState.die and skill) then
        local action = role:GetAction();
        if (action == nil or(action and action.actionType ~= ActionType.Block)) then
            local target = role.target;
            if (target == nil or(target and(target.state == RoleState.DIE or target.state == RoleState.RETREAT or Vector3.Distance2(role.transform.position, target.transform.position) > skill.max_distance / 100))) then
                target = GameSceneManager.map:GetRoleByDistance(role.transform.position, skill.max_distance / 100, ControllerType.MONSTER)
                --role.target = target;
                role:SetTarget(target);
            end
            if (target and target.transform) then

                if (Vector3.Distance2(role.transform.position, target.transform.position) < skill.distance / 100) then
                    role:DoAction(SendSkillAction:New(skill));
                else
                    role:DoAction(SendMoveToSkillAction:New(target, skill));
                end
            else
                if (skill.is_tar_need == 0) then
                    role:DoAction(SendSkillAction:New(skill));
                else

                    MsgUtils.ShowTips(nil, nil, nil, "找不到目标，无法释放技能");
                end
            end
        end
    end
end

function MountAttackController:Dispose()
    self:StopAttack();
    self._dispose = true
    self.visible = false
end