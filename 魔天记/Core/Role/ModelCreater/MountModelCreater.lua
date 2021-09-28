require "Core.Role.ModelCreater.BaseModelCreater"
MountModelCreater = class("MountModelCreater", BaseModelCreater); 

function MountModelCreater:New(data, parent, asyncLoad, onLoadedSource)
    self = { };
    setmetatable(self, { __index = MountModelCreater });
    self.asyncLoadSource = false
    self.onLoadedSource = onLoadedSource
    self:Init(data, parent);
    return self;
end

--
function MountModelCreater:_Init(data)
    self.onEnableOpen = true
    self.model_id = data.model_id;
end
 
function MountModelCreater:_GetModern()
    return "Roles", self.model_id;
end

-- 设置为空
function MountModelCreater:GetRideInfo()
    return nil;
end

function MountModelCreater:_GetSourceDir()
    return "Monsters"
end


function MountModelCreater:GetDefaultAction()
    return "stand"
end

function MountModelCreater:_GetModelDefualt()
    return "ride_03";
end


