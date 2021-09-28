require "Core.Info.PlayerInfo";

HeroInfo = class("HeroInfo", PlayerInfo);

HeroInfo.exp = 0;
HeroInfo.gold = 0;
HeroInfo.bindGold = 0;
HeroInfo.money = 0;

function HeroInfo:New(data)
    self = { };
    setmetatable(self, { __index = HeroInfo });
    self:_InitDefAttribute();
    self.baseSkills = { };
    self.skills = { };
    self:_InitHeroInfo(data);
    return self;
end

function HeroInfo:_InitHeroInfo(data)
    self:_Init(data);
    self.exp = data.exp;
    if (type(data.money) == "table") then
        self.gold = data.money.gold;
        self.bindGold = data.money.bgold;
        self.money = data.money.money;
    elseif type(data.money) == "number" then
        self.money = data.money;
    end
end

function HeroInfo:GetExp()
    return self.exp;
end

function HeroInfo:SetExp(value)
    self.exp = value
end
local tempAttr = BaseAttrInfo:New()
function HeroInfo:SetLevel(level)
    local AttributeCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_CAREER_ATTR);
    local att = AttributeCfg[self.kind .. "_" .. level];
    tempAttr:Init(self)
    if (att) then
        att = ConfigManager.TransformConfig(att)
        self:_SetBaseAttribute(att);
        self.level = level;
    end    
    MessageManager.Dispatch(PlayerManager, PlayerManager.SELFATTRIBUTEADD,tempAttr)
end

--  男 0  女 1
function HeroInfo:GetSex()
    return self.sex
    --   local k = self.kind;

    --   if 101000 == k then -- 太清门
    --     return 0;
    --   elseif 102000 == k then -- 天妖谷
    --     return 0;
    --   elseif 103000 == k then -- 魔玄宗
    --     return 1;
    --   elseif 104000 == k then -- 天工宗
    --     return 1;
    --   end
end