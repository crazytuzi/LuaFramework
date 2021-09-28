require "Core.Role.Action.AbsAction";

DieAction = class("DieAction", AbsAction)

function DieAction:New(isFly)
    self = { };
    setmetatable(self, { __index = DieAction });
    self:Init();
    self.actionType = ActionType.BLOCK;

    self._playing = false;
    self._isDelay = false;
    if (isFly) then
        self._isFly = isFly
    else
        self._isFly = false
    end
    self._timeDelay = 0;
    self._r = 0.7 * FPSScale;

    return self;
end

function DieAction:_OnStartHandler()
    local controller = self._controller
    -- if (controller and controller.info and controller:GetVisible()) then
    if (controller and controller.info) then
        controller:SetTarget(nil)
        if (controller.roleType ~= ControllerType.MONSTER or(controller.roleType == ControllerType.MONSTER and controller.info.isPlayDie)) then
            controller:Play(RoleActionName.die);
            controller.state = RoleState.DIE;            
            self._isFly =(self._isFly and controller.info.die_fly)
--            local aInfo = controller:GetAnimatorStateInfo();
--            if (aInfo and aInfo.length ~= nil and aInfo.length > 0) then
--                self._totalTime = aInfo.length + 1;
--            else
--                self._totalTime = 2;
--            end
            self._totalTime = 2;
            self:_InitTimer(0, -1);
        elseif (controller.roleType == ControllerType.MONSTER and(not controller.info.isPlayDie)) then
            local entity = controller:GetRoleCreater();
            if (entity) then
                local go = entity:GetRole();
                if (go) then
                    go:SetActive(false);
                end
            end
            if (controller.info.dieEffect ~= "") then
                self._effect = Resourcer.Get("Effect/SkillEffect", controller.info.dieEffect)
                if (self._effect) then
                    Util.SetPos(self._effect, controller.transform.position)
                    --self._effect.transform.position = controller.transform.position
                    local lt = UIUtil.GetParticleSystemLength(self._effect.transform)
                    if (lt < 0) then lt = 5 end
                    Resourcer.RecycleDelay(self._effect, lt);
                end
            end
            self:Finish();
        else
            self:Finish();
        end
    else
        self:Finish();
    end
end

function DieAction:_OnFinishHandler()
    local controller = self._controller
    self._effect = nil;
    if (controller) then
        -- 英雄及玩家的尸体由后端来移除
        if (GameSceneManager.map and(controller.roleType ~= ControllerType.PLAYER) and(controller.roleType ~= ControllerType.HERO) and(controller.roleType ~= ControllerType.HIRE)) then
            GameSceneManager.map:RemoveRole(controller);
        end
    end
end

function DieAction:_OnTimerHandler()
    local controller = self._controller
    -- if (controller and controller:GetVisible()) then
    if (controller) then
        --local info = controller:GetAnimatorStateInfo();
        --if (info) then
            --[[
            if (info:IsName(RoleActionName.die)) then
                self._playing = true;
                if (self._totalTime == nil) then
                    self._totalTime = info.length + 1;
                    -- Warning(">>>>>>>>>> "..self._totalTime)
                end
            else
                controller:Play(RoleActionName.die);
            end
            ]]
            --if (self._playing) then
                local dt = Time.fixedDeltaTime;
                self._totalTime = self._totalTime - dt;
                if (self._isFly) then
                    self:_Update();
                else
                    if (self._totalTime < 0) then
                        self:Finish();
                    end
                    --[[
					if (info.normalizedTime >= 1) then
						self._timeDelay = self._timeDelay + Time.fixedDeltaTime
						if (self._timeDelay > 1) then
							self:Finish();
						end
					end
                    ]]
                end
            --end
        --else
            --self:Finish();
        --end
    else
        self:Finish();
    end
end

function DieAction:_Update()
    local transform = self._controller.transform;
    --local speed = self._controller:GetMoveSpeed() / 100 * FPSScale;
    local r = self._r;
    transform:Translate(Vector3.back * r);
    r = r * 0.8;
    self._r = r;
    if (r < 0.01) then
        self._isFly = false;
    end
end

-- function DieAction:_TimerDelayOverHandler()
-- self:Finish();
-- end