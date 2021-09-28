require "Core.Role.ModelCreater.BaseModelCreater"
MonsterModelCreater = class("MonsterModelCreater", BaseModelCreater); 

function MonsterModelCreater:New(data, parent, asyncLoad, onLoadedSource)
    self = { };
    setmetatable(self, { __index = MonsterModelCreater });
    if (asyncLoad ~= nil) then
        self.asyncLoadSource = asyncLoad
    else
        self.asyncLoadSource = true
    end
    self.onLoadedSource = onLoadedSource
    self.hasCollider = true
    -- self.checkAnimation = true -- 要检查动画内容
    self.showShadow = true
    self:Init(data, parent);
    return self;
end

--
function MonsterModelCreater:_Init(data)
    local config = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_MONSTER)[data.kind]
    self.onEnableOpen = true
    self.model_id = config.model_id
end
 
function MonsterModelCreater:_GetModern()
    return "Roles", self.model_id;
end

function MonsterModelCreater:_GetSourceDir()
    return "Monsters"
end

function MonsterModelCreater:_GetModelDefualt()
    return "m_xsc003";
end

function MonsterModelCreater:_CanPoolMode()
    return true
end