require "Core.Module.Common.Panel"

local EquipSQSuitItem = require "Core.Module.Equip.Item.EquipSQSuitItem";


local EquipSQSuitPanel = class("EquipSQSuitPanel", Panel);
function EquipSQSuitPanel:New()
    self = { };
    setmetatable(self, { __index = EquipSQSuitPanel });
    return self
end


function EquipSQSuitPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function EquipSQSuitPanel:_InitReference()
    self._txtDes = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtDes");
    self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");

    self._goItemParent1 = UIUtil.GetChildByName(self._trsContent, "item1").gameObject
    self._goItemParent2 = UIUtil.GetChildByName(self._trsContent, "item2").gameObject
    self._item1 = EquipSQSuitItem:New()
    self._item1:Init(self._goItemParent1)
    self._item2 = EquipSQSuitItem:New()
    self._item2:Init(self._goItemParent2)

end

function EquipSQSuitPanel:_InitListener()
    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
end

function EquipSQSuitPanel:_OnClickBtn_close()
    ModuleManager.SendNotification(EquipNotes.CLOSE_EQUIPSQSUITPANEL);
end

function EquipSQSuitPanel:UpdatePanel(suitCf1, suitCf2)

    self._item1:UpdateItem(suitCf1, true)
    self._item2:UpdateItem(suitCf2, false)

end

function EquipSQSuitPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function EquipSQSuitPanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;
end

function EquipSQSuitPanel:_DisposeReference()
    self._btn_close = nil;
    self._txtDes = nil;

    self._item1:Dispose()
    self._item1 = nil
    self._item2:Dispose()
    self._item2 = nil

    self._goItemParent1 = nil
    self._goItemParent2 = nil

end
return EquipSQSuitPanel