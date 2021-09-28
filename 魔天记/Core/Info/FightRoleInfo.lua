require "Core.Info.RoleInfo";
require "Core.Info.SkillInfo";

FightRoleInfo = class("FightRoleInfo", RoleInfo);
local insert = table.insert
function FightRoleInfo:New()
    self = { };
    setmetatable(self, { __index = FightRoleInfo });
    return self;
end

function FightRoleInfo:_InitDefAttribute()
    RoleInfo._InitDefAttribute(self);
    self.baseAttribute.phy_att = 0;
    -- self.baseAttribute.mag_att = 0;
    self.baseAttribute.phy_def = 0;
    -- self.baseAttribute.mag_def = 0;
    self.baseAttribute.hit = 0;
    self.baseAttribute.eva = 0;
    self.baseAttribute.crit = 0;
    self.baseAttribute.tough = 0;
    self.baseAttribute.fatal = 0;
    self.baseAttribute.block = 0;
    self.baseAttribute.phy_bns_rate = 0;
    self.baseAttribute.phy_bns_per = 0;
    -- self.baseAttribute.mag_bns_rate = 0;
    -- self.baseAttribute.mag_bns_per = 0;
    self.baseAttribute.direct_dmg = 0;
    self.baseAttribute.cd_rdc = 0;
    self.baseAttribute.phy_pen = 0;
    -- self.baseAttribute.mag_pen = 0;
    self.baseAttribute.phy_bld = 0;
    -- self.baseAttribute.mag_bld = 0;
    self.baseAttribute.stun_resist = 0;
    self.baseAttribute.silent_resist = 0;
    self.baseAttribute.still_resist = 0;
    self.baseAttribute.taunt_resist = 0;
    self.baseAttribute.att_dmg_rate = 0;
    self.baseAttribute.dmg_rate = 0;
    self.baseAttribute.fatal_bonus = 0;
    self.baseAttribute.crit_bonus = 0;
    self.baseAttribute.heal_correct_per = 0;
    self.baseAttribute.hit_rate_add = 0;
    self.baseAttribute.crit_rate_add = 0;
    self.baseAttribute.fatal_rate_add = 0;
    self.baseAttribute.def_rdc_a = 0;
    self.baseAttribute.def_rdc_b = 0;
    self.baseAttribute.def_rdc_c = 0;
    self.baseAttribute.exp_per = 0;
    
    self.per.phy_att_per = 1;
    -- self.per.mag_att_per = 1;
    self.per.phy_def_per = 1;
    -- self.per.mag_def_per = 1;
    self.per.hit_per = 1;
    self.per.eva_per = 1;
    self.per.crit_per = 1;
    self.per.tough_per = 1;
    self.per.fatal_per = 1;
    self.per.block_per = 1;
    self.per.direct_dmg_per = 1;
    self.per.phy_pen_per = 1;
    -- self.per.mag_pen_per = 1;
    self.per.phy_bld_per = 1;
    -- self.per.mag_bld_per = 1;
    self.per.stun_resist_per = 1;
    self.per.silent_resist_per = 1;
    self.per.still_resist_per = 1;
    self.per.taunt_resist_per = 1;
    

    self.extr.phy_att_extr = 0;
    -- self.extr.mag_att_extr = 0;
    self.extr.phy_def_extr = 0;
    -- self.extr.mag_def_extr = 0;
    self.extr.hit_extr = 0;
    self.extr.eva_extr = 0;
    self.extr.crit_extr = 0;
    self.extr.tough_extr = 0;
    self.extr.fatal_extr = 0;
    self.extr.block_extr = 0;
    self.extr.direct_dmg_extr = 0;
    self.extr.phy_pen_extr = 0;
    -- self.extr.mag_pen_extr = 0;
    self.extr.phy_bld_extr = 0;
    -- self.extr.mag_bld_extr = 0;
    self.extr.stun_resist_extr = 0;
    self.extr.silent_resist_extr = 0;
    self.extr.still_resist_extr = 0;
    self.extr.taunt_resist_extr = 0;

    self._baseSkills1 = { };
    self._baseSkills2 = { };
    self.currBaseSkills = self._baseSkills1;
    self.skills = { };
    self._otherSkills = { };
end

function FightRoleInfo:_SetBaseAttribute(obj, blRefresh)
    if (obj) then
        local refreshNow = blRefresh or true;
        for i, v in pairs(obj) do
            if (self.baseAttribute[i] ~= nil) then
                self.baseAttribute[i] = v;
            end
        end
        if (refreshNow == true) then
            self:RefreshAttribute();
        end
    end
end

function FightRoleInfo:_GetSkillPertainById(id)
    local si = 1
    if (type(self.base_skill) == "number") then
        if (id == self.base_skill) then
            return self._baseSkills1, si;
        end
    else
        local bsk = self.base_skill
        for i, v in pairs(bsk) do
            if (v == id) then
                return self._baseSkills1, si;
            end
            si = si + 1;
        end
    end
    si = 1
    if (self.base_skill2 ~= nil) then
        if (type(self.base_skill2) == "number") then
            if (id == self.base_skill2) then
                return self._baseSkills2, si;
            end
        else
            local bsk = self.base_skill2
            for i, v in pairs(bsk) do
                if (v == id) then
                    return self._baseSkills2, si;
                end
                si = si + 1;
            end
        end
    end
    si = 1
    if (self.skill) then
        if (type(self.skill) == "number") then
            if (self.skill == id) then
                return self.skills, si;
            end
        else
            local sk = self.skill
            for i, v in pairs(sk) do
                if (v == id) then
                    return self.skills, si;
                end
                si = si + 1;
            end
        end
        -- self.skill = nil;
    end
    -- return nil;
end

function FightRoleInfo:_InitDefaultSkills()
    if (self.base_skill) then
        if (type(self.base_skill) == "number") then
            self:AddSkill(self.base_skill);
        else
            local bsk = self.base_skill
            for i, v in pairs(bsk) do
                self:AddSkill(v);
            end
        end
        if (self.base_skill2 ~= nil) then
            if (type(self.base_skill2) == "number") then
                self:AddSkill(self.base_skill2);
            else
                local bsk = self.base_skill2
                for i, v in pairs(bsk) do
                    self:AddSkill(v);
                end
            end
        end
        -- self.base_skill = nil;
    end

    if (self.skill) then
        if (type(self.skill) == "number") then
            if (self.skill > 0) then
                self:AddSkill(self.skill);
            end
        else
            local sk = self.skill
            for ii, vv in pairs(sk) do
                self:AddSkill(vv);
            end
        end
        -- self.skill = nil;
    end
end

function FightRoleInfo:CoolSkill(skill,blDelayCool)
    if (skill) then
        local cd_rdc = self.cd_rdc or 0;
        local r = (100 - cd_rdc) / 100;
        if (blDelayCool) then
            skill:ResetDelayCooling(r)                  
        else
            skill:StartCool(r);             
        end
    end
end

function FightRoleInfo:StartSkillCool(cdID)
    if (cdID and cdID > 0) then        
        if (self._baseSkills1) then
            for i, v in pairs(self._baseSkills1) do
                if (v.com_cd == cdID) then
                    -- v:StopCool();
                    --v:StartCool()
                    self:CoolSkill(v)
                end
            end
        end
        if (self._baseSkills2) then
            for i, v in pairs(self._baseSkills2) do
                if (v.com_cd == cdID) then
                    -- v:StopCool();
                    --v:StartCool()
                    self:CoolSkill(v)
                end
            end
        end
        if (self._trumpSkills) then
            for i, v in pairs(self._trumpSkills) do
                if (v.com_cd == cdID) then
                    -- v:StopCool();
                    --v:StartCool()
                    self:CoolSkill(v)
                end
            end
        end
        if (self._trumpSkill and self._trumpSkill.com_cd == cdID) then
            self:CoolSkill(self._trumpSkill)            
        end
        if (self.skills) then
            for i, v in pairs(self.skills) do
                if (v.com_cd == cdID) then
                    -- v:StopCool();
                    --v:StartCool()
                    self:CoolSkill(v)
                end
            end
        end
    end
end

function FightRoleInfo:_InitSkills(skills)
    for i, v in pairs(skills) do
        self:AddSkill(v.skill_id, v.level);
    end
end

function FightRoleInfo:AddTrumpSkill(skill, level)
    if (skill) then
        if (self._trumpSkills == nil) then
            self._trumpSkills = { }
        end
        if (type(skill) == "number") then
            local sLevel = level or 1;
            local sk = SkillInfo:New(id, sLevel);
            if (sk ~= nil) then
                self._trumpSkills = sk
                insert(self._trumpSkills, sk)
            end
        elseif (type(skill) == "table" and skill.__cname and skill.__cname == "SkillInfo") then
            insert(self._trumpSkills, skill)
        end
    end
end

-- 设置法宝技能
function FightRoleInfo:SetTrumpSkill(skill, level)
    if (skill) then
        if (type(skill) == "number") then
            local sLevel = level or 1;
            local sk = SkillInfo:New(skill, sLevel);
            if (sk ~= nil) then
                self._trumpSkill = sk
            end
        elseif (type(skill) == "table" and skill.__cname and skill.__cname == "SkillInfo") then
            self._trumpSkill = skill;
        end
    else
        self._trumpSkill = nil
    end
end
-- 获取法宝技能

function FightRoleInfo:GetTrumpSkill()
    return self._trumpSkill;
end

-- 娣诲姞鎶鑳?
function FightRoleInfo:AddSkill(id, level)
    if (id > 0) then
        local sk = self:GetSkill(id);
        if (sk) then
            if (level) then
                sk:SetLevel(level)
            end
        else
            local ls, si = self:_GetSkillPertainById(id);
            local sLevel = level or 1;
            sk = SkillInfo:New(id, sLevel);
            if (ls ~= nil) then
                ls[si] = sk;
            else
                self._otherSkills[id] = sk;
            end
        end
        return sk;
    end
    return nil
end


function FightRoleInfo:_GetSkillDefaultIndex(list, id)
    local index = 1;
    if (type(list) == "table") then
        for i, v in pairs(list) do
            if (v == id) then
                return index;
            end
            index = index + 1;
        end
    end
    return index;
end

-- function FightRoleInfo:GetInnateSkill()
--     return nil;
-- end

function FightRoleInfo:GetBaseSkills()
    return self.currBaseSkills;
end

function FightRoleInfo:GetBaseSkillByIndex(index)
    local sk = self.currBaseSkills;
    if (sk) then
        return sk[index];
    end
    return nil;
end

function FightRoleInfo:GetBaseSkill()
    local sk = self.currBaseSkills;
    if (sk) then
        return sk[1];
    end
    return nil;
end

function FightRoleInfo:ReplaceBaseSkill()
    local len = table.getCount(self._baseSkills2);
    if (len > 0) then
        self.currBaseSkills = self._baseSkills2;
    end
end

function FightRoleInfo:ResumeBaseSkill()
    self.currBaseSkills = self._baseSkills1;
end

function FightRoleInfo:GetSkills()
    return self.skills;
end

function FightRoleInfo:SetSkills(sks)
    self.skills = sks;
end

function FightRoleInfo:GetSkillByIndex(index)
    local sk = self.skills;
    if (sk) then
        return sk[index];
    end
    return nil;
end

-- 鑾峰彇鎶鑳?
function FightRoleInfo:GetSkill(id, blAdd)
    local isAddSkill = false;
    local sk = self._baseSkills1;
    if (blAdd) then
        isAddSkill = blAdd;
    end
    if (sk) then
        for i, v in pairs(sk) do
            local rsk = v:GetSkill(id);
            if (rsk) then
                return rsk;
            end
        end
    end
    sk = self._baseSkills2;
    if (sk) then
        for i, v in pairs(sk) do
            local rsk = v:GetSkill(id);
            if (rsk) then
                return rsk;
            end
        end
    end
    sk = self.skills;
    if (sk) then
        for ii, vv in pairs(sk) do
            local rsk = vv:GetSkill(id);
            if (rsk) then
                return rsk;
            end
        end
    end
    sk = self._otherSkills;
    if (sk) then
        for i, v in pairs(sk) do
            local rsk = v:GetSkill(id);
            if (rsk) then
                return rsk;
            end
        end
    end
    sk = self._trumpSkills;
    if (sk) then
        for i, v in pairs(sk) do
            local rsk = v:GetSkill(id);
            if (rsk) then
                return rsk;
            end
        end
    end
    
    if self._trumpSkill then
        local rsk = self._trumpSkill:GetSkill(id);
        if (rsk) then
            return rsk;
        end
    end

    if (isAddSkill) then
        return self:AddSkill(id);
    end
    return nil;
end

-- 获取技能平均等级
function FightRoleInfo:GetSkillAverageLevel()
    local skillTotal = 0;
    local levelTotal = 0;
    local sk = self._baseSkills1;
    if (sk) then
        for i, v in pairs(sk) do
            skillTotal = skillTotal + 1;
            levelTotal = levelTotal + v.skill_lv;
        end
    end
    sk = self._baseSkills2;
    if (sk) then
        for i, v in pairs(sk) do
            skillTotal = skillTotal + 1;
            levelTotal = levelTotal + v.skill_lv;
        end
    end
    sk = self.skills;
    if (sk) then
        for ii, vv in pairs(sk) do
            skillTotal = skillTotal + 1;
            levelTotal = levelTotal + vv.skill_lv;
        end
    end
    return levelTotal / skillTotal;
end

-- 璁剧疆鎶鑳界瓑绾?
function FightRoleInfo:SetSkillLevel(id, level)
    local sLevel = level or 1;
    local skill = self:GetSkill(id);
    if (skill and skill.skill_lv ~= sLevel) then
        if (skill.skill_type == 1) then
            for i, v in pairs(self._baseSkills1) do
                v:SetLevel(sLevel);
            end
            for i, v in pairs(self._baseSkills2) do
                v:SetLevel(sLevel);
            end
        else
            skill:SetLevel(sLevel);
        end
    end
end

function RoleInfo:Dispose()
    local sk = self._baseSkills1;
    if (sk) then
        for i, v in pairs(sk) do
            v:Dispose();
        end
    end
    sk = self._baseSkills2;
    if (sk) then
        for i, v in pairs(sk) do
            v:Dispose();
        end
    end
    sk = self.skills;
    if (sk) then
        for ii, vv in pairs(sk) do
            vv:Dispose();
        end
    end
    self._trumpSkills = nil;        
end