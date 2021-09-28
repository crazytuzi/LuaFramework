require "Core.Role.AI.AbsAiController";
require "Core.Role.Action.SendCmd.SendFollowTargetAction"

HireAIController = class("HireAIController", AbsAiController)

HireAIController.Max_Master_Distance = 12;
HireAIController.Follow_Distance = 3;




function HireAIController:New(role)
    self = { };
    setmetatable(self, { __index = HireAIController });
    self:_Init(role);
    self._waitTime = 5;
    self._attackTime = 5;
    self._strollTime = 100;
    self._status = AI.Status.Stand;
    return self;
end

function HireAIController:_GetSkill()
    if (self._role and self._role.info) then
        local roleInfo = self._role.info;
        -- local skill = roleInfo:GetInnateSkill();
        -- if (skill  and(not skill:IsCooling()) and roleInfo.mp >= skill:GetSeriesSkill().mp_cost and skill.skill_type ~= 3) then
        --     return skill;
        -- else
            local index = 1;
            skill = roleInfo:GetSkillByIndex(index)
            while (skill ~= nil) do
                index = index + 1;
                if (not skill:IsCooling() and roleInfo.mp >= skill:GetSeriesSkill().mp_cost and skill.skill_type ~= 3 and skill.req_lv <= roleInfo.level) then
                --if (not skill:IsCooling() and roleInfo.mp >= skill:GetSeriesSkill().mp_cost and skill.skill_type ~= 3) then
                    return skill;
                else
                    skill = roleInfo:GetSkillByIndex(index);
                end
            end
            skill = roleInfo:GetBaseSkill();
            if (skill and(not skill:IsCooling()) and roleInfo.mp >= skill:GetSeriesSkill().mp_cost) then
                return skill;
            end
        -- end
    end
    return nil;
end

function HireAIController:_GetRandomPosition()
    self:_Randomseed();
    local master = self._role:GetMaster();
    local masterPt = master.transform.position;
    local d = HireAIController.Follow_Distance / 3 * 2;
    local distance = math.random() *(HireAIController.Follow_Distance / 3) + d;
    local angle = math.random(0, 360);
    local index = 0;
    while (index < 9) do
        for i = 1, 3, 2 do
            local r =(angle +(i - 2) * index * 20) * math.pi / 180;
            local pt = Vector3.New(masterPt.x, masterPt.y, masterPt.z);
            pt.x = pt.x + math.sin(r) * distance;
            pt.z = pt.z + math.cos(r) * distance;
            --if (GameSceneManager.mpaTerrain:IsWalkable(pt)) then
            if (GameSceneManager.mpaTerrain:IsWalkable(pt) and GameSceneManager.mpaTerrain:IsWalkPath(masterPt,pt)) then
                return MapTerrain.SampleTerrainPosition(pt);
            end
        end
        index = index + 1
    end
    return nil;
end

function HireAIController:_OnStopHandler()
    local role = self._role;
    if (role and not role:IsDie() and self._status ~= AI.Status.CastSkill) then
        role:StopAction(3)
        role:DoAction(SendStandAction:New());
        self._status = AI.Status.Stand
    end
end

function HireAIController:_OnTimerHandler()
    local role = self._role;
    if (role and not role:IsDie()) then
        local master = role:GetMaster();
        if (master) then
            self:_CheckFlash(master)
        end
    end
end

function HireAIController:_CheckFlash(master)
    local role = self._role;
    if (role and not role:IsDie() and master) then
        local distance = Vector3.Distance2(role.transform.position, master.transform.position);
        if (distance > HireAIController.Max_Master_Distance) then
            local action = role:GetAction();
            if (action == nil or(action and action.actionType ~= ActionType.BLOCK)) then
                local transform = role.transform;
                local toPt = self:_GetRandomPosition();
                if (toPt) then
                    local angle = math.atan2(toPt.x - transform.position.x, toPt.z - transform.position.z) / math.pi * 180;
                    role:SetTarget(nil);
                    role:StopAction(3);
                    role:DoAction(SendStandAction:New(toPt, angle));
                    self:_CheckStand(master);
                    --self._strollTime = 0;
                end
            end
        else
            self:_CheckSearch(master)
        end
    else
        if (self._status ~= AI.Status.Stand) then
            self._waitTime = 5
            self._strollTime = 10;
            self._status = AI.Status.Stand
        end
    end
end

function HireAIController:_CheckSearch(master)
    local role = self._role;
    if (role and not role:IsDie() and master) then
        if (master.state ~= RoleState.SKILL) then
            self._attackTime = self._attackTime - self._timer.duration;
        else
            self._attackTime = 10;
            if (master.target ~= master) then
                if (role.target ~= master.target) then
                    --self._strollTime = 0
                end
                if (self._status ~= AI.Status.CastSkill) then
                    role:SetTarget(master.target);
                end
            end
        end
        if (self._attackTime <= 0) then
            role:SetTarget(nil);
        end
        if (role.target ~= nil and(not role.target:IsDie())) then
            self:_CheckFight(master);
        else
            --self._strollTime = 0;
            self:_CheckFollow(master);
        end
    end
end

function HireAIController:_CheckFight(master)
    local role = self._role;
    if (role and not role:IsDie() and master) then
        if (self._skill == nil or self._skill == role.info:GetBaseSkill() or self._skill:IsCooling() or self._skill.mp_cost > role.info.mp) then
            self._skill = self:_GetSkill();
        end
        -- self._status = AI.Status.Fight
        if (self._skill) then
            if (self._status ~= AI.Status.ToTarget) then
                local target = role.target;
                if (self._skill.target_type == 3) then
                    if (target and(target.info.camp == role.info.camp or target:IsDie())) then
                        if (master.target and master.target.info.camp ~= role.info.camp and not master.target:IsDie()) then
                            target = master.target;
                        else
                            target = nil;
                        end
                    end
                    if (target) then
                        local d =(self._skill.distance + target.info.radius) / 100 * 0.95;
                        role:SetTarget(target);
                        if (self._strollTime <= 0 or Vector3.Distance2(role.transform.position, target.transform.position) >= d) then
                            if (self._status ~= AI.Status.ToTarget and self._status ~= AI.Status.CastSkill) then
                                self:_Randomseed();
                                local act = nil;
                                if (target.info.kind == 120157) then                                
                                    local act = role:DoAction(SendFollowTargetAction:New(target, d * 0.9))
                                else
                                    act = role:DoAction(SendFollowTargetAction:New(target, d * 0.9, math.random(0, 360)))
                                end
                                if (act) then
                                    act:AddEventListener(self, HireAIController._CheckMoveToFinishHandler, HireAIController._CheckMoveToFinishHandler);
                                    self._status = AI.Status.ToTarget;
                                end
                            end
                        else
                            self:_CheckCastSkill(master);
                        end
                    else
                        role:SetTarget(nil);
                        self:_CheckFollow(master)
                    end
                else
                    role:SetTarget(role);
                    self:_CheckCastSkill(master);
                end
            else
                if(role.state == RoleState.STAND) then
                    self._status = AI.Status.Stand;
                end
            end
        else
            role:SetTarget(nil);
            self:_CheckFollow(master)
        end
    end
end

function HireAIController:_CheckCastSkill(master)
    local role = self._role;
    if (role and not role:IsDie() and master and self._skill and role.target and role.target.isAppear~=true) then
        if (self._status ~= AI.Status.CastSkill) then
            local act = role:DoAction(SendSkillAction:New(self._skill));
            if (act) then
                act:AddEventListener(self, HireAIController._CheckSkillFinishHandler, HireAIController._CheckSkillFinishHandler);
                self._status = AI.Status.CastSkill;
            end
        else
            if(role.state == RoleState.STAND) then
                self._status = AI.Status.Stand;
            end
            --self._strollTime = self._strollTime - self._timer.duration;
        end
    end
end

function HireAIController:_CheckFollow(master)
    local role = self._role;
    if (role and not role:IsDie() and master) then
        local distance = Vector3.Distance2(role.transform.position, master.transform.position);
        if (distance > HireAIController.Follow_Distance * 1.1) then
            if (self._status ~= AI.Status.Follow) then
                self:_Randomseed();
                local act = role:DoAction(SendFollowTargetAction:New(master, HireAIController.Follow_Distance, math.random(0, 360)))
                --self._strollTime = 0;
                if (act) then
                    act:AddEventListener(self, HireAIController._CheckFollowFinishHandler, HireAIController._CheckFollowFinishHandler);
                    self._status = AI.Status.Follow;
                end
            else
                if(role.state == RoleState.STAND) then
                    self._status = AI.Status.Stand;
                end
            end
        else
            if (self._status == AI.Status.Stand) then
                self:_CheckStand(master);
            elseif (self._status == AI.Status.Patrol) then
                self:_CheckPatrol(master);
            end
        end
    end
end

function HireAIController:_CheckStand(master)
    local role = self._role;
    if (role and not role:IsDie() and master) then
        if (self._status ~= AI.Status.Stand) then
            self._waitTime = 5
            role:DoAction(SendStandAction:New());
            self._status = AI.Status.Stand
        else
            self._waitTime = self._waitTime - self._timer.duration;

            if (self._waitTime <= 0) then
                self:_CheckPatrol(master)
            end
        end
    end
end

function HireAIController:_CheckPatrol(master)
    local role = self._role;
    if (role and not role:IsDie() and master) then
        if (self._status ~= AI.Status.Patrol) then
            local pt = self:_GetRandomPosition();
            if (pt) then
                local act = role:DoAction(SendMoveToAction:New(pt))
                if (act) then
                    act:AddEventListener(self, HireAIController._CheckPatrolFinishHandler, HireAIController._CheckPatrolFinishHandler);
                    self._status = AI.Status.Patrol;
                end
            end
        end
    end
end

function HireAIController:_CheckPatrolFinishHandler()
    self._status = AI.Status.Stand;
    self._waitTime = 5
end

function HireAIController:_CheckFollowFinishHandler()
    self._status = AI.Status.Stand;
    self._waitTime = 5
end

function HireAIController:_CheckMoveToFinishHandler()
    local role = self._role;
    if (role and not role:IsDie()) then
        if (self._status == AI.Status.ToTarget) then
            self._status = AI.Status.Fight;
            self._waitTime = 5
            self._strollTime = 10;
        end
    else
        self._status = AI.Status.Stand;
    end
end

function HireAIController:_CheckSkillFinishHandler()
    local role = self._role;
    if (role and not role:IsDie()) then
        if (self._status == AI.Status.CastSkill) then
            self._status = AI.Status.Fight;
            self._waitTime = 5
        end
    else
        self._status = AI.Status.Stand;
    end
end