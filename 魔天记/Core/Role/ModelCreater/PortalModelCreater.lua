require "Core.Role.ModelCreater.BaseModelCreater"
PortalModelCreater = class("PortalModelCreater", BaseModelCreater); 

function PortalModelCreater:New(data, parent)
    self = { };
    setmetatable(self, { __index = PortalModelCreater });
    self.asyncLoadSource = true
    self:Init(data, parent);
    return self;
end 
 
function PortalModelCreater:_GetModern()
    return "Effect/ScenceEffect", "chuanSongMen";
end

function PortalModelCreater:GetCheckAnimation()
    return false
end