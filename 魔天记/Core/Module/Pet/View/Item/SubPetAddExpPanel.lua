require "Core.Module.Common.UIComponent"
require "Core.Module.Pet.View.Item.PetAddExpItem"

SubPetAddExpPanel = class("SubPetAddExpPanel", UIComponent);
function SubPetAddExpPanel:New(transform)
    self = { };
    setmetatable(self, { __index = SubPetAddExpPanel });
    if (transform) then
        self:Init(transform)
    end
    return self
end

function SubPetAddExpPanel:_Init()
    self._imgMask = UIUtil.GetChildByName(self._transform, "mask")
    self._phalanxInfo = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "itemPhalanx")
    self._phalanx = Phalanx:New()
    self._phalanx:Init(self._phalanxInfo, PetAddExpItem)


    self._onClickMask = function(go) self:_OnClickMask(self) end
    UIUtil.GetComponent(self._imgMask, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickMask);
    self:UpdatePanel()
end 

function SubPetAddExpPanel:_OnClickMask()
    self:SetActive(false)
    SequenceManager.TriggerEvent(SequenceEventType.Guide.PET_LVUP_PANEL_HIDE);
end

function SubPetAddExpPanel:_Dispose()
    self._phalanx:Dispose()
    UIUtil.GetComponent(self._imgMask, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickMask = nil;
end

function SubPetAddExpPanel:UpdatePanel()
    self._phalanx:Build(3, 1, PetManager.PetAddExpItemId)
end
