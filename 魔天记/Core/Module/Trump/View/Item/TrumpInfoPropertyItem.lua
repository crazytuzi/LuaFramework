require "Core.Module.Common.UIItem"

TrumpInfoPropertyItem = class("TrumpInfoPropertyItem", UIItem);
TrumpInfoPropertyItem.unActiveDes = LanguageMgr.Get("trump/trumpPanel/unActiveRefineDes")
function TrumpInfoPropertyItem:New()
    self = { };
    setmetatable(self, { __index = TrumpInfoPropertyItem });
    return self
end
 
function TrumpInfoPropertyItem:_Init()
    self:_InitReference();
    self:UpdateItem(self.data)
end

function TrumpInfoPropertyItem:UpdateItem(data)
    self.data = data

    if (self.data) then
        self._txtContent.text = data.des .. "+" .. data.property .. data.sign ..
        (self.data.isActive and "" or TrumpInfoPropertyItem.unActiveDes)
    end
end

function TrumpInfoPropertyItem:_InitReference()
    self._txtContent = UIUtil.GetChildByName(self.transform, "UILabel", "content")
end

function TrumpInfoPropertyItem:_Dispose()

end

 