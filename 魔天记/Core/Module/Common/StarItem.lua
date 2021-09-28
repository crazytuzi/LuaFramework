require "Core.Module.Common.UIItem"
 
StarItem = class("StarItem", UIItem);
 
function StarItem:New()
    self = { };
    setmetatable(self, { __index = StarItem });
    return self
end


function StarItem:_Init()
    self.icon = UIUtil.GetChildByName(self.transform, "UISprite", "star")
    self:UpdateItem(self.data)
end 

function StarItem:UpdateItem(data)
    self.data = data
    self.icon.spriteName = data and "star1" or "star2"
end

 