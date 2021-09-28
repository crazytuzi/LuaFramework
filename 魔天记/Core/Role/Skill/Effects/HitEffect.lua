require "Core.Role.Skill.Effects.AbsEffect";

HitEffect = class("HitEffect", AbsEffect)

function HitEffect:New(skill, stage, caster, target)
    self = { };
    setmetatable(self, { __index = HitEffect });
    if (self:_Init(skill, stage, caster, target)) then
        self:BindTarget(target);
        return self;
    end
    --Warning(">>> skill:" .. skill.id .. "(" .. skill.name .. ") stage:" .. stage .. "(" .. self.info.key .. ") hit_effect_id:" .. self.info.hit_effect_id .. "，在skill_effect.lua没找到对应的特效配置")
    return nil;
end

function HitEffect:_InitEffectInfo()
    local effectCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_SKILL_EFFECT);
    self.effectInfo = effectCfg[self.info.hit_effect_id];
    if (self.effectInfo) then
        self._sumTime = self.effectInfo.totalTime / 1000;
        self:_InitSkillEffect(self.target);
        return true
    end
    return false
end

function HitEffect:_OnLoadCompleteHandler(go, toRole)
    if (go) then
        local roleTransform = toRole.transform;
        local toTransform = toRole:GetCenter();
        local transform = go.transform;
        local offect = Vector3.New(self.effectInfo.x / 100, self.effectInfo.y / 100, self.effectInfo.z / 100);
        local scale = roleTransform.localScale

        transform.rotation = Quaternion.Euler(0, roleTransform.rotation.eulerAngles.y, 0);

        if (toTransform == nil) then
            Util.SetPos(transform, roleTransform:TransformPoint(offect))

            --            transform.position = roleTransform:TransformPoint(offect)
            if (self.effectInfo.bind == 1) then
                transform:SetParent(roleTransform);
                transform.localScale = Vector3.one;
            else
                UIUtil.ScaleParticleSystem(go, scale.x);
            end
        else
            transform:SetParent(toTransform);
            transform.localScale = Vector3.one;
            Util.SetLocalPos(transform, 0, 0, 0)
            --            transform.localPosition = Vector3.zero;
        end

        self.transform = transform;
        toTransform = nil
        go = nil
        self:_InitEffectComplete();
    end
end

--function HitEffect:_OnTimerHandler(delay)
--    if (self.effectInfo.bind == 1 and self.transform and self.transform.parent) then
--        if (self.transform.parent.gameObject.activeSelf == false) then
--            self:Dispose()
--            return
--        end
--    end
--end