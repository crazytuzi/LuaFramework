require "Core.Module.Common.UIItem"
TrumpObtainItem = class("TrumpObtainItem", UIItem);

function TrumpObtainItem:New()
    self = { };
    setmetatable(self, { __index = TrumpObtainItem });
    return self
end


function TrumpObtainItem:_Init()
    self:_InitReference();
    self:UpdateItem(self.data)
end

function TrumpObtainItem:_InitReference()
    self._imgIcon = UIUtil.GetChildByName(self.transform, "UISprite", "icon")
    self._imgQuality = UIUtil.GetChildByName(self.transform, "UISprite", "quality")
end 
 
function TrumpObtainItem:UpdateItem(data)
    self.data = data

    if (data == nil) then
        self._imgIcon.spriteName = ""
        self._imgQuality.spriteName = "frame5"
        return
    end
    ProductManager.SetIconSprite(self._imgIcon, data.configData.icon_id)
    self._imgQuality.spriteName = ProductManager.GetQulitySpriteName(self.data.configData.quality)
end

