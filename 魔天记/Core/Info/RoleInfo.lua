RoleInfo = class("RoleInfo");

-- 地图显示的标识
MapItemType =
{
    Npc = 1;
    Monster = 2;
}

PlayerPKType = {
    Peace = 0;
    GoodEvil = 1;
    Guild = 2;
    Killing = 3;
    Taboo = 4; --禁忌之地
}

PlayerPKState = {
    White = 0;
    Yellow = 1;
    Red = 3;
}



function RoleInfo:New()
    self = { };
    setmetatable(self, { __index = RoleInfo });    

    return self;
end

-- 初始化默认属性值
function RoleInfo:_InitDefAttribute()
    self.baseAttribute = { };
    self.baseAttribute.move_spd = 0;
    self.baseAttribute.hp_max = 100;
    self.baseAttribute.mp_max = 100;

    self.per = { };
    self.per.move_spd_per = 1;
    self.per.hp_max_per = 1;
    self.per.mp_max_per = 1;

    self.extr = { };
    self.extr.move_spd_extr = 0;
    self.extr.hp_max_extr = 0;
    self.extr.mp_max_extr = 0;

    self.camp = 0;

    self.move_spd = self.baseAttribute.move_spd;
    self.hp_max = self.baseAttribute.hp_max;
    self.hp = self.baseAttribute.hp_max;
    self.mp_max = self.baseAttribute.mp_max;
    self.mp = self.baseAttribute.mp_max;

    self.model_rate = 1;
    self.gearmonster = false;
    self.fixed = false
    self.isPlayDie = true;
    self.is_back = false;
    self.die_fly = false;    
end

function RoleInfo:AddAttribute(data)
    if (data) then
        for i, v in pairs(data) do
            self:AddAttributeValue(i, v, false);
        end
    end
end

function RoleInfo:RemoveAttribute(data)
    if (data) then
        for i, v in pairs(data) do
            self:RemoveAttributeValue(i, v, false);
        end
    end
end

-- 添加属性值
-- name：属性名，属性表中的名字，如：move_spd、move_spd_pre、move_spd_extr
-- value：属性值
-- blRefresh：是否立刻更新角色属性，默认false
function RoleInfo:AddAttributeValue(name, value, blRefresh)
    local blChange = false;
    if (name and value) then
        local refreshNow = blRefresh or false;
        if (self.baseAttribute[name] ~= nil) then
            local extrName = name .. "_extr";
            if (self.extr[extrName] == nil) then
                self.extr[extrName] = value
            else
                self.extr[extrName] = self.extr[extrName] + value;
            end
            blChange = true
            if (refreshNow) then
                self:RefreshAttribute();
            end
        else
            if (self.extr[name] ~= nil) then
                self.extr[name] = self.extr[name] + value;
                blChange = true
            elseif (self.per[name] ~= nil) then
                self.per[name] = self.per[name] + value / 1000;
                blChange = true
            end
            if (refreshNow and blChange) then
                self:RefreshAttribute();
            end
        end
    end
    return blChange;
end

-- 减少属性值
-- name：属性名，属性表中的名字，如：move_spd、move_spd_pre、move_spd_extr
-- value：属性值
-- blRefresh：是否立刻更新角色属性，默认false
function RoleInfo:RemoveAttributeValue(name, value, blRefresh)
    local blChange = false;
    if (name and value) then
        local refreshNow = blRefresh or false;
        if (self.baseAttribute[name] ~= nil) then
            local extrName = name .. "_extr";
            if (self.extr[extrName] ~= nil) then
                self.extr[extrName] = self.extr[extrName] - value;
            end
            blChange = true
            if (refreshNow) then
                self:RefreshAttribute();
            end
        else
            if (self.extr[name] ~= nil) then
                self.extr[name] = self.extr[name] - value;
                blChange = true
            elseif (self.per[name] ~= nil) then
                self.per[name] = self.per[name] - value / 100;
                blChange = true
            end
            if (refreshNow and blChange) then
                self:RefreshAttribute();
            end
        end
    end
    return blChange
end

-- 刷新属性值
function RoleInfo:RefreshAttribute(blLimit)
    
    for i, v in pairs(self.baseAttribute) do
        local extr = self.extr[i .. "_extr"];
        local pre = self.per[i .. "_per"];
        if (extr ~= nil and pre ~= nil) then
            self[i] = math.floor(math.floor(v + extr) * pre);
        elseif (extr ~= nil) then
            self[i] = math.floor(v + extr);
        elseif (pre ~= nil) then
            self[i] = math.floor(v * pre);
        else
            self[i] = v;
        end
    end
    if (blLimit ~= false) then
        if (self.hp > self.hp_max) then
            self.hp = self.hp_max
        end

        if (self.mp > self.mp_max) then
            self.mp = self.mp_max
        end
    end

end

-- 重置属性值
function RoleInfo:ResetAttribute(blRefresh)
    local refreshNow = blRefresh or false;
    for i, v in pairs(self.extr) do
        self.extr[i] = 0;
    end
    for i, v in pairs(self.per) do
        self.per[i] = 1;
    end
    if (refreshNow) then
        self:RefreshAttribute();
    end
end

function RoleInfo:StartSkillCool(cdID)

end

function RoleInfo:Dispose()

end

function RoleInfo:GetId()
    return self.id;
end

function RoleInfo:GetKind()
    return self.kind;
end

function RoleInfo:GetName()
    return self.name;
end

function RoleInfo:GetIcon()
    return self.icon;
end

function RoleInfo:SetLevel(level)
    self.level = level
end

function RoleInfo:GetLevel()
    return self.level;
end

function RoleInfo:GetHp()
    return self.hp;
end

function RoleInfo:GetMaxHp()
    return self.hp_max;
end

function RoleInfo:GetMp()
    return self.mp;
end

function RoleInfo:GetMaxMp()
    return self.mp;
end
