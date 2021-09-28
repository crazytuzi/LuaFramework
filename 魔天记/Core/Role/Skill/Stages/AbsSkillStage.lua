require "Core.Role.Skill.SkillExecuteManage";

AbsSkillStage = class("AbsSkillStage")

function AbsSkillStage:New(role, target, skill, stage)
    self = {};
    setmetatable(self, {__index = AbsSkillStage});
    self:_Init(role, target, skill, stage);
    return self;
end

function AbsSkillStage:_Init(role, target, skill, stage)
    local info = skill.stages[stage];
    self.role = role;
    self.target = target;
    self.skill = skill;
    self.stage = stage;
    self.info = info;
    self._sumTime = self.info.stage_time / 1000;
    self._blFinish = false;
    self.transform = role.transform;
    -- straybullet 由脚本触发特效
    if (info.script ~= "straybullet") then
        self:InitEffect();
        if (self.effect and info.LoopTime > 0) then
            self.effect:SetSumTime(info.LoopTime / 1000);
        end
    end
    if (info.offset[1] > 0 and (role.target == nil or (role.target ~= nil and role.target.info.is_back == true))) then
        self.role:Dart(info.offset[1] / 100, info.offset[2] / 1000, info.offset[3] / 1000);
    end
    if (info.attack_time > 0) then
        self._attackTime = info.attack_time / 1000;
		if (role.roleType == ControllerType.MONSTER and role.info.type == MonsterInfoType.BOSS and info.show_range) then
		if (skill.target_type == 3 and (info.range_type == 3 or info.range_type == 4 or info.range_type == 5 or info.range_type == 6)) then
        	self._rangeEff = SkillExecuteManage.ExecuteRangeEffect(self.info, role)
		end
		end
    else
        self:_Attack();
    end


--self.script = SkillExecuteManage.ExecuteScript(self);
end

function AbsSkillStage:_DoShake()
    local info = self.info;
    local role = self.role;
    if (role == HeroController.GetInstance() and info.knock_back_ID ~= 0) then
        local knockInfo = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_KNOCKBACK)[info.knock_back_ID];
        if (knockInfo) then
            local skock = knockInfo.shock;
            if (skock > 0) then
                MainCameraController.GetInstance():Shake(skock);
            end
        end
    end
end


function AbsSkillStage:_Attack()
    -- self.script = SkillExecuteManage.ExecuteScript(self);
    if (self._rangeEff) then
        self._rangeEff:Dispose();
        self._rangeEff = nil;
    end
    self.script = SkillExecuteManage.ExecuteScript(self);
    self:_DoShake();
end

function AbsSkillStage:InitEffect()
    local info = self.info;
    -- firerain特殊脚本，由后台通知攻击特效坐标
    if (info and info.effect_id ~= "" and info.script ~= "firerain") then
        self.effect = SkillExecuteManage.ExecuteAttackEffect(self.skill, self.stage, self.role, self.target);
    end
    return self.effect;
end

function AbsSkillStage:_Finish()
    if (not self._blFinish) then
        self._blFinish = true;
        if (self._callHandler) then
            self._callHandler(self._callOwner, self);
            self._callHandler = nil;
            self._callOwner = nil;
        end
        self:Dispose();
    end
end

function AbsSkillStage:AddFinishListener(handler, owner)
    self._callOwner = owner;
    self._callHandler = handler;
end

function AbsSkillStage:Update(dt)
    if (self._sumTime) then
        if (self._sumTime > 0) then
            self._sumTime = self._sumTime - dt;
            if (self._attackTime) then
                self._attackTime = self._attackTime - dt;
                if (self._attackTime <= 0) then
                    self._attackTime = nil;
                    self:_Attack();
                end
            end
        else
            self._sumTime = nil;
            self:_Finish();
        end
    end
end

function AbsSkillStage:GetEffectTransform()
    if (self.effect) then
        return self.effect.transform
    end
    return self.role.transform;
end

function AbsSkillStage:Dispose()
    if (self.info) then
        -- 吟唱范围特效自动删除
        --		if (self.skill.id == 209078) then
        --			Warning(">>>>  Dispose stage:" .. self.info.key)
        --		end
        if (self._rangeEff) then
            self._rangeEff:Dispose();
            self._rangeEff = nil;
        end
        if (self.effect) then
            if (self.info.LoopTime > 0) then
                self.effect:Dispose();
            end
            self.effect = nil;
        end
        if (self.script) then
            if (not self._blFinish) then
                self.script:Dispose();
            end
            self.script = nil;
        end
        self.role = nil;
        self.info = nil;
    end
end
