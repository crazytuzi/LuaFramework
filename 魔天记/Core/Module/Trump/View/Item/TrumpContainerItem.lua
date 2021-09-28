require "Core.Module.Common.UIItem"
TrumpContainerItem = class("TrumpContainerItem", UIItem);

function TrumpContainerItem:New()
    self = { };
    setmetatable(self, { __index = TrumpContainerItem });
    return self
end


function TrumpContainerItem:_Init()
    self:_InitReference();
    self:_InitListener();
    self:UpdateItem(self.data)
end

function TrumpContainerItem:_InitReference()
    self._imgIcon = UIUtil.GetChildByName(self.transform, "UISprite", "icon")
    self._imgQuaility = UIUtil.GetChildByName(self.transform, "UISprite", "quality")
    self._txtLevel = UIUtil.GetChildByName(self.transform, "UILabel", "level")
end

function TrumpContainerItem:_InitListener()
    self._onBtnItemClick = function(go) self:_OnBtnItemClick(self) end
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onBtnItemClick);
end

function TrumpContainerItem:_OnBtnItemClick()
    if (self.data and self.data.info) then
        ModuleManager.SendNotification(TrumpNotes.OPEN_TRUMPINFOPANEL, self.data.info)
    end
end

function TrumpContainerItem:UpdateItem(data)
    self.data = data
    if (data == nil or data.info == nil) then
        self._imgQuaility.spriteName = ""
        self._imgIcon.spriteName = ""
        self._txtLevel.text = ""
        return
    end
 
    self._txtLevel.text = GetLvDes(self.data.info.lev)
    ProductManager.SetIconSprite(self._imgIcon,self.data.info.configData.icon_id)
    self._imgQuaility.color = ColorDataManager.GetColorByQuality(self.data.info.configData.quality)
end

function TrumpContainerItem:_Dispose()
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onBtnItemClick = nil;
end
 
