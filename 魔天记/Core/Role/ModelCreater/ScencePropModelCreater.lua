require "Core.Role.ModelCreater.BaseModelCreater"
ScencePropModelCreater = class("ScencePropModelCreater", BaseModelCreater)



function ScencePropModelCreater:New(data, parent, asyncLoad, onLoadedSource)
    self = { };
    setmetatable(self, { __index = ScencePropModelCreater });
    if (asyncLoad ~= nil) then
        self.asyncLoadSource = asyncLoad
    else
        self.asyncLoadSource = true
    end
    self.onLoadedSource = onLoadedSource
    self.hasCollider = true
    self.showShadow = false
    self:Init(data, parent);
    return self;
end

function ScencePropModelCreater:GetCheckAnimation()
    return false
end

--
function ScencePropModelCreater:_Init(data)
    -- local config = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_MONSTER)[data.kind]
    self.data = data;
    self.onEnableOpen = true
    self.model_id = data.model_id
end
 
function ScencePropModelCreater:_GetModern()
    return "Roles", self.model_id;
end

function ScencePropModelCreater:_GetSourceDir()
    return "SceneProp"
end

function ScencePropModelCreater:_GetSourceAnim()
    return self.model_id
end

function ScencePropModelCreater:GetDefaultAction()
    return self.data.born_act_name;--"stand"
end

function ScencePropModelCreater:_GetModelDefualt()
    return "sprop_001";
end
