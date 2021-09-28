require "Core.Info.BaseAttrInfo";
require "Core.Info.SkillInfo";
require "Core.Info.BaseAdvanceAttrInfo";

TrumpInfo = class("TrumpInfo");

function TrumpInfo:New(data)
    self = { };
    setmetatable(self, { __index = TrumpInfo });
    self:_Init(data);
    return self;
end

function TrumpInfo:Init(data)
    self:_Init(data)
end 

function TrumpInfo:_Init(data)
    self.baseData = data;
    self.st = data.st;
    self.pt = data.pt;
    self.id = data.id;
    self.idx = data.idx;
    self.spId = data.spId;
    --    self.lev = data.level or 1;
    self.exp = data.exp or 0
    self.configData = ProductManager.GetProductById(self.spId);
    self:SetRefineLevel(self.spId, data.refine_lev)
    self:SetLevel(self.spId, data.level)
end
local insert = table.insert
function TrumpInfo:SetRefineLevel(spid, level)
    self.refineLev = level or 0
    self.refineConfig = TrumpManager.GetTrumpRefineConfig(spid, self.refineLev)
    self.nextRefineConfig = TrumpManager.GetTrumpRefineConfig(spid, self.refineLev + 1)
    self._refineNeed = { }
    self._refineProperty = BaseAdvanceAttrInfo:New()
    self._refineProperty:Init(self.refineConfig)
    if (self.nextRefineConfig) then
        self._nextRefineProperty = BaseAdvanceAttrInfo:New()
        self._nextRefineProperty:Init(self.nextRefineConfig)
    end

    local need = ""
    for k, v in ipairs(self.refineConfig.refine_material) do
        local item = string.split(v, "_")
        local temp = { }
        temp.id = tonumber(item[1])
        temp.count = tonumber(item[2])
       insert(self._refineNeed, temp)
    end
end

function TrumpInfo:SetLevel(id, level)
    self.lev = level or 1
    self.attr = BaseAttrInfo:New()
    self.attrConfig = ProductManager.GetProductAttrByIdAndLevel(id, level)
    if (self.attrConfig) then
        self.attr:Init(self.attrConfig)
    end

    local trumpSkillInfo = ConfigManager.GetTrumpSkillByIdAndLevel(self.spId, self.lev)
    if (trumpSkillInfo) then
        self._trumpSkillInfo = SkillInfo:New(trumpSkillInfo.trump_skill, trumpSkillInfo.skill_lev)
    end

    local maxExp = TrumpManager.GetTrumpExpConfigByQcAndLv(self.configData.quality, self.lev)
    self.maxExp = maxExp.up_exp
    --    self._trumpSkillInfo = SkillInfo:New()

end 

function TrumpInfo:GetTrumpPropertyDes()
    local des = self.attr:GetPropertyAndDes()
    local result = ""
    local count = table.getCount(des)
    for i = 1, count do
        result = result .. des[i].des .. "+" .. des[i].property
        if (i ~= count) then
            result = result .. "\n"
        end
    end
    return result
end

function TrumpInfo:GetTrumpSkillInfo()
    return self._trumpSkillInfo
end

function TrumpInfo:GetRefineNeed()
    return self._refineNeed
end

function TrumpInfo:GetRefineProperty()

    local p = nil
    -- 先取下一级的属性，因为0级是没有加成属性的
    if (self._nextRefineProperty) then
        p = self._nextRefineProperty:GetPropertyAndDes()
    end
    if (p) then
        for k, v in ipairs(p) do
            if (self._refineProperty) then
                v.nextProperty = self._refineProperty[v.key]
                v.nextProperty, v.property = v.property, v.nextProperty
                v.isActive =(self.refineLev > 0)
            end
        end
    else
        p = self._refineProperty:GetPropertyAndDes()
        for k, v in ipairs(p) do
            v.isActive =(self.refineLev > 0)
        end
    end


    --    local temp = { }
    --    temp.des = LanguageMgr.Get("trump/trumpPanel/upLevelLimit")
    --    temp.property = self.refineConfig.up_limit
    --    if (self.nextRefineConfig) then
    --        temp.nextProperty = self.nextRefineConfig.up_limit
    --    end
    --    table.insert(p, temp)
    return p
end

function TrumpInfo:GetAllProperty()
    local p = BaseAdvanceAttrInfo:New()
    p:Init(self.attr)
    if (self.refineLev ~= 0) then
        for k, v in pairs(self._refineProperty) do
            if (p[k]) then
                p[k] = p[k] + v
            end
        end
    end
    return p
end

function TrumpInfo:GetRefinePropertyWithLimit()
    local p = self:GetRefineProperty()
    local temp = { }
    temp.des = LanguageMgr.Get("trump/trumpPanel/upLevelLimit")
    temp.property = self.refineConfig.up_limit
    if (self.nextRefineConfig) then
        temp.nextProperty = self.nextRefineConfig.up_limit
    end
    insert(p, temp)
    return p
end



 
