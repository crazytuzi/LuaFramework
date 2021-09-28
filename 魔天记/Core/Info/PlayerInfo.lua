require "Core.Info.FightRoleInfo";

PlayerInfo = class("PlayerInfo", FightRoleInfo);
PlayerInfo.vip = 0;
PlayerInfo.career = "";
PlayerInfo.fighting = 0;
PlayerInfo.walk_sound = "";
PlayerInfo.hurt_sound = "";
PlayerInfo.die_sound = "";

function PlayerInfo:New(data)
    self = { };
    setmetatable(self, { __index = PlayerInfo });
    self:_InitDefAttribute();
    self.baseSkills = { };
    self.skills = { };
    self:_Init(data)
    return self;
end

function PlayerInfo:_Init(data)
    local careerCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_CAREER);
    local baseInfo = careerCfg[data.kind];

    if (baseInfo) then
        baseInfo = ConfigManager.TransformConfig(baseInfo)
        table.copyTo(baseInfo, self);

        if (data.title) then
            self:SetTitle(data.title)
        end

        self:_SetBaseAttribute(baseInfo, false);
        self.camp = data.camp;
        self.kind = data.kind;
        self.realm = data.realm;
        self:SetLevel(data.level);
        self.id = data.id;
        self.name = data.name;
        self.hp = data.hp;
        self.mp = data.mp;
        if (data.mhp) then
            self.hp_max = data.mhp;
        else
            if (self.hp > self.hp_max) then
                self.hp_max = self.hp
            end
        end
        self.tgn = data.tgn
        if (data.pk) then
            self.pkType = data.pk.m;
            self.pkState = data.pk.st;
        else
            self.pkType = 0;
            self.pkState = 0;
        end
        self.dress = data.dress

        self:_InitDefaultSkills();
        if (data.skills) then
            self:_InitSkills(data.skills)            
        end

        if (data.skill_set) then
            self:InitSkillSet(data.skill_set);
        end
    else
        log(data.kind .. "没有找到职业类型")
    end
end 

--            1     2     3     4     5       6      7      8     9    10    11      12      13
-- skillSet 激活id_技能1_技能2_技能3_技能4_天赋法门_神通id_技能5_技能6_技能7_技能8_天赋法门_神通id
-- 后端不管技能配置, 只给前端一个字符串去保存2套技能设置. 只能以逗号分割来保存 当前激活的设置id+2套技能配置数据 
function PlayerInfo:InitSkillSet(skillSet)
    self.skillSet1 = { };
    self.skillSet2 = { };

    if skillSet == "" then
        self.skillSetId = 1;
        self.skillSet_T1 = 1;
        self.skillSet_T2 = 1;
        self.skillSet_S1 = 1;
        self.skillSet_S2 = 1;
    else
        local tmp = string.split(skillSet, "_");
        self.skillSetId = tonumber(tmp[1]);
        if self.skillSetId > 10 then
            self.skillSetId = 1;
        end
        self.skillSet_T1 = tonumber(tmp[6]) or 1;
        self.skillSet_T2 = tonumber(tmp[12]) or 1;
        self.skillSet_S1 = tonumber(tmp[7]) or 1;
        self.skillSet_S2 = tonumber(tmp[13]) or 1;
        for i = 1, 4 do
            local skillId1 = tmp[i + 1] and tonumber(tmp[i + 1]) or 0;
            self.skillSet1[i] = self:GetSkill(skillId1);

            local skillId2 = tmp[i + 7] and tonumber(tmp[i + 7]) or 0;
            self.skillSet2[i] = self:GetSkill(skillId2);
        end
    end

    -- 如果技能为空则替换成默认技能.(防止读取已设置的技能id不存在).
    -- local careerCfg = ConfigManager.GetCareerByKind(self.kind);
    local defSkill = self.default_skill;
    local defSkillReqLv = self.skillslot_open;
    local skillStr1 = "";
    local skillStr2 = "";
    for i = 1, 4 do
        local skillId = defSkill[i] and tonumber(defSkill[i]) or 0;
        if self.level >= defSkillReqLv[i] then
            if self.skillSet1[i] == nil then
                self.skillSet1[i] = self:GetSkill(skillId);
            end
            if self.skillSet2[i] == nil then
                self.skillSet2[i] = self:GetSkill(skillId);
            end
        else
            self.skillSet1[i] = nil;
            self.skillSet2[i] = nil;
        end

        skillStr1 = skillStr1 .. "_" ..(self.skillSet1[i] and self.skillSet1[i].id or "0");
        skillStr2 = skillStr2 .. "_" ..(self.skillSet2[i] and self.skillSet2[i].id or "0");
    end
    -- self.skillSet = string.format("%s%s_%s_%s%s_%s_%s", self.skillSetId, skillStr1, self.skillSet_T1, self.skillSet_S1, skillStr2, self.skillSet_T2, self.skillSet_S2);
    self.skillSet = self.skillSetId .. skillStr1 .. "_" .. self.skillSet_T1 .. "_" .. self.skillSet_S1 .. skillStr2 .. "_" .. self.skillSet_T2 .. "_" .. self.skillSet_S2;
end

function PlayerInfo:GetSkillSet()
    return self.skillSet;
end

function PlayerInfo:GetCurrSkillSet()
    return self["skillSet" .. self.skillSetId]
end

function PlayerInfo:SetCurrSkillSet(val)
    self["skillSet" .. self.skillSetId] = val;
end

function PlayerInfo:GetSkillSetInfo()
    return { id = self.skillSetId, t1 = self.skillSet_T1, t2 = self.skillSet_T2, s1 = self.skillSet_S1, s2 = self.skillSet_S2 };
end

function PlayerInfo:GetSkillByIndex(index, sId)
    if (self.skillSet) then
        sId = sId or self.skillSetId;
        local set = self["skillSet" .. sId] or self.skillSet1;
        return set[index];
    elseif self.skills then
        return self.skills[index];
    end
    return nil;
end

function PlayerInfo:GetDefSkillByIndex(index)
    local sk = self.skills;
    if (sk) then
        return sk[index];
    end
    return nil;
end
local insert = table.insert
function PlayerInfo:GetSkillList()
    local tmp = { };
    for i = 0, table.getn(self.skills) do
        if (i == 0) then
            insert(tmp, self:GetBaseSkill());
        else
            insert(tmp, self:GetDefSkillByIndex(i));
        end
    end
    return tmp;
end


function PlayerInfo:SetLevel(level)
    local AttributeCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_CAREER_ATTR);
    local att = AttributeCfg[self.kind .. "_" .. level];
    att = ConfigManager.TransformConfig(att)
    if (att) then
        self:_SetBaseAttribute(att);
        self.level = level;
    end
end

function PlayerInfo:GetSex()
    return self.sex;
end

function PlayerInfo:GetVip()
    return self.vip;
end

function PlayerInfo:GetCareer()
    local careerCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_CAREER);
    local baseInfo = careerCfg[self.kind];
    return baseInfo.id;
end

function PlayerInfo:SetTitle(id)
    if (id ~= nil) then
        self.titleData = TitleManager.GetTitleConfigById(id)
    end
end