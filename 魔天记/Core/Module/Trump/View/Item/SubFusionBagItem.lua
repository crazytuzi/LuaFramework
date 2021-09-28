require "Core.Module.Common.UIItem"
SubFusionBagItem = class("SubFusionBagItem", UIItem);

function SubFusionBagItem:New()
    self = { };
    setmetatable(self, { __index = SubFusionBagItem });
    return self
end


function SubFusionBagItem:_Init()
    self:_InitReference();
    self:UpdateItem(self.data)
end

function SubFusionBagItem:_InitReference()
    self._imgIcon = UIUtil.GetChildByName(self.transform, "UISprite", "icon")
    self._imgQuaility = UIUtil.GetChildByName(self.transform, "UISprite", "quality")
    self._collider = UIUtil.GetComponent(self.transform, "Collider")
    self._onClickItem = function(go) self:_OnClickItem(self) end
    self._toggle = UIUtil.GetComponent(self.transform, "UIToggle")
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickItem);
end 
 
function SubFusionBagItem:UpdateItem(data)
    if (data == nil or data.info == nil) then
        self._imgIcon.spriteName = ""
        self._collider.enabled = false
        self._imgQuaility.spriteName = ""
        return
    end
    self.data = data
    self._collider.enabled = true
    self._imgQuaility.color = ColorDataManager.GetColorByQuality(self.data.info.configData.quality)
    ProductManager.SetIconSprite(self._imgIcon, self.data.info.configData.icon_id)
end

function SubFusionBagItem:_Dispose()
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickItem = nil;
end

function SubFusionBagItem:_OnClickItem()
    if (self.data) then
        if (self._toggle.value) then
            TrumpProxy.AddTrumpMaterial(self.data)
        else
            TrumpProxy.RemoveTrumpMaterial(self.data)
        end
    end
end


function SubFusionBagItem:SetToggleValue(enable)
    self._toggle.value = enable
end