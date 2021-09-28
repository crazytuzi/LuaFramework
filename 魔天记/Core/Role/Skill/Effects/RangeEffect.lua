RangeEffect = class("RangeEffect")

RangeEffect.ALPHA = 0.5;
RangeEffect.OFFSETY = 0.1;

RangeEffect._role = nil;
RangeEffect._skill = nil;
RangeEffect._effect = nil;

function RangeEffect:New(skill, role)
    self = { };
    setmetatable(self, { __index = RangeEffect });
    self:_Init(skill, role);
    return self;
end

function RangeEffect:AddListener(func)
    self._callback = func;
end

function RangeEffect:_Init(skill, role)
    self._skill = skill;
    self._role = role;
    if (skill and role) then
        local effect = Resourcer.Get("Effect/RoleEffect", "RoleSkillRange");
        if (effect) then
            self._effect = effect
            self.transform = effect.transform;
            effect.transform:SetParent(nil);
            Util.SetPos(effect, 0, 0, 0)
            -- 		effect.transform.position = Vector3.zero;
            if (skill.range_type == 3) then
                effect.transform:SetParent(role.transform);
                self:_RangeRectangle();
            elseif (skill.range_type == 4) then
                effect.transform:SetParent(role.transform);
                self:_RangeFan();
            elseif (skill.range_type == 5) then
                effect.transform:SetParent(role.transform);
                self:_RangeCircle(skill.range[1] / 100);
            elseif (skill.range_type == 6) then
                if (role.target) then
                    Util.SetPos(effect, role.target.transform.position)
                    -- 				effect.transform.position = role.target.transform.position;
                    self:_RangeCircle(skill.range[1] / 100);
                end
                --            else
                --                self:_RangeCircle(skill.distance / 100);
            end
            self:_RefreshColor(effect.renderer.material);
            effect.transform.localRotation = Quaternion.Euler(90, -90, 0);
        end
    end
end

function RangeEffect:_RefreshColor(material)
    if (material) then
        local roleType = self._role.roleType;
        local alpha = RangeEffect.ALPHA
        if (roleType == ControllerType.Hero) then
            material:SetColor("_TintColor", Color.New(0, 1.0, 0, alpha));
        elseif (roleType == ControllerType.Player) then
            material:SetColor("_TintColor", Color.New(1, 0.38, 0, alpha));
        else
            material:SetColor("_TintColor", Color.New(1, 0, 0, alpha));
        end
    end
end

function RangeEffect:_RangeRectangle()
    local skill = self._skill;
    local effect = self._effect;
    local img = Resourcer.GetTexture("Texture/SkillRange", "skill_range_rectangle");
    self._imgPath = "Texture/SkillRange/skill_range_rectangle"
    local wide = skill.range[1] / 100.0;
    local length = skill.range[2] / 100.0;
    effect.renderer.material.mainTexture = img;
    if (effect.transform.parent == self._role.transform) then
        Util.SetLocalPos(effect.transform, 0, RangeEffect.OFFSETY, length / 2)
        --        effect.transform.localPosition = Vector3.New(0, RangeEffect.OFFSETY, length / 2);
    else
        Util.SetPos(effect.transform, effect.transform.position + Vector3.New(0, RangeEffect.OFFSETY, length / 2))
        --        effect.transform.position = effect.transform.position + Vector3.New(0, RangeEffect.OFFSETY, length / 2);
    end
    effect.transform.localScale = Vector3.New(length, wide, 1);
end

function RangeEffect:_RangeCircle(radius)
    local effect = self._effect;
    local img = Resourcer.GetTexture("Texture/SkillRange", "skill_range_circle");
    self._imgPath = "Texture/SkillRange/skill_range_circle"
    local diameter = radius * 2;
    effect.renderer.material.mainTexture = img;
    if (effect.transform.parent == self._role.transform) then
        Util.SetLocalPos(effect.transform, 0, RangeEffect.OFFSETY, 0)
        --        effect.transform.localPosition = Vector3.New(0, RangeEffect.OFFSETY, 0);
    else
        Util.SetPos(effect.transform, effect.transform.position + Vector3.New(0, RangeEffect.OFFSETY, 0))
        --        effect.transform.position = effect.transform.position + Vector3.New(0, RangeEffect.OFFSETY, 0);
    end
    effect.transform.localScale = Vector3.New(diameter, diameter, 1);
end

function RangeEffect:_RangeFan()
    local skill = self._skill;
    local effect = self._effect;
    local angle = skill.range[1];
    local radius = skill.range[2] / 100.0;
    local wide = math.sin((angle / 2.0) / 180.0 * math.pi) * 2 * radius;
    local angles = self:_GetFan(angle)
    local img = Resourcer.GetTexture("Texture/SkillRange", angles);
    self._imgPath = "Texture/SkillRange/" .. angles
    effect.renderer.material.mainTexture = img;
    if (effect.transform.parent == self._role.transform) then
        Util.SetLocalPos(effect, 0, RangeEffect.OFFSETY, radius / 2)
        --effect.transform.localPosition = Vector3.New(0, RangeEffect.OFFSETY, radius / 2);
    else
        Util.SetPos(effect.transform, effect.transform.position + Vector3.New(0, RangeEffect.OFFSETY, radius / 2))
        --effect.transform.position = effect.transform.position + Vector3.New(0, RangeEffect.OFFSETY, radius / 2);
    end
    effect.transform.localScale = Vector3.New(radius, wide, 1);
end

function RangeEffect:_GetFan(angle)
    if (angle < 45) then
        return "skill_range_fan30";
    elseif (angle < 75) then
        return "skill_range_fan60";
    elseif (angle < 105) then
        return "skill_range_fan90";
    elseif (angle < 135) then
        return "skill_range_fan120";
    elseif (angle < 165) then
        return "skill_range_fan150";
    end
    return "skill_range_fan180";
end

function RangeEffect:Dispose()
    if (self._effect) then
        Resourcer.Recycle(self._imgPath);
        Resourcer.Recycle(self._effect);
        if (self._callback) then
            self._callback(self);
            self._callback = nil;
        end;
        self._effect = nil
        self._skill = nil;
        self._role = nil;
    end
end