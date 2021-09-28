require "Core.Module.Common.UIItem"
SubFusionEquipItem = class("SubFusionEquipItem", UIItem);

function SubFusionEquipItem:New()
    self = { };
    setmetatable(self, { __index = SubFusionEquipItem });
    return self
end


function SubFusionEquipItem:_Init()
    self:_InitReference();
    self:UpdateItem(self.data)
end

function SubFusionEquipItem:_InitReference()
    self._imgIcon = UIUtil.GetChildByName(self.transform, "UISprite", "icon")
    self._imgQuaility = UIUtil.GetChildByName(self.transform, "UISprite", "quality")
    self._collider = UIUtil.GetComponent(self.transform, "Collider")
    self._toggle = UIUtil.GetComponent(self.transform, "UIToggle")
    self._txtLevel = UIUtil.GetChildByName(self.transform, "UILabel", "level")
    self._onClickItem = function(go) self:_OnClickItem(self) end
    self._goDress = UIUtil.GetChildByName(self.transform, "dress").gameObject
    self._trsLvBg = UIUtil.GetChildByName(self.transform, "trsLvBg").gameObject
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickItem);
end 

function SubFusionEquipItem:_OnClickItem()
    if (self.data and self.data.info) then
        TrumpProxy.SetSelectTrumpData(self.data)
    end
end
 
function SubFusionEquipItem:UpdateItem(data)
    if (data == nil or data.info == nil) then
        self._imgIcon.spriteName = ""
        self._collider.enabled = false
        self._goDress:SetActive(false)
        self._txtLevel.text = ""
        self._trsLvBg:SetActive(false)
        self._imgQuaility.color = ColorDataManager.GetColorByQuality(0)
        return
    end
    self.data = data
    if (self.data.info.id == TrumpManager.GetMainTrumpId()) then
        self._goDress:SetActive(true)
    else
        self._goDress:SetActive(false)
    end
    self._trsLvBg:SetActive(true)
    self._collider.enabled = true
    self._imgQuaility.color = ColorDataManager.GetColorByQuality(self.data.info.configData.quality)
    self._txtLevel.text = tostring(self.data.info.lev)
    ProductManager.SetIconSprite(self._imgIcon, self.data.info.configData.icon_id)
    self:_UpdateOther(data)
    --    self._imgIcon.spriteName = tostring(self.data.info.configData.icon_id)
end

function SubFusionEquipItem:_UpdateOther()

end

function SubFusionEquipItem:_Dispose()
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickItem = nil;
end

function SubFusionEquipItem:SetToggleValue(v)
    self._toggle.value = v
end