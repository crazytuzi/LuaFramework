require "Core.Module.Common.Panel"

local EquipSQSuitItem = require "Core.Module.Equip.Item.EquipSQSuitItem";

local EquipSQSuitOnePanel = class("EquipSQSuitOnePanel",Panel);
function EquipSQSuitOnePanel:New()
	self = { };
	setmetatable(self, { __index =EquipSQSuitOnePanel });
	return self
end


function EquipSQSuitOnePanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function EquipSQSuitOnePanel:_InitReference()
	self._txtDes = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtDes");
	self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");

    self._goItemParent1 = UIUtil.GetChildByName(self._trsContent, "item1").gameObject
	self._item1 = EquipSQSuitItem:New()
	self._item1:Init(self._goItemParent1)	

end

function EquipSQSuitOnePanel:_InitListener()
	self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
end

function EquipSQSuitOnePanel:_OnClickBtn_close()
	 ModuleManager.SendNotification(EquipNotes.CLOSE_EQUIPSQSUITPANEL);
end


function EquipSQSuitOnePanel:UpdatePanel(suitCf,has_get)
	self._item1:UpdateItem(suitCf,has_get)
end


function EquipSQSuitOnePanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function EquipSQSuitOnePanel:_DisposeListener()
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtn_close = nil;
end

function EquipSQSuitOnePanel:_DisposeReference()
	self._btn_close = nil;
	self._txtDes = nil;
	self._goItemParent1 = nil
	self._item1:Dispose()
	self._item1 = nil
end
return EquipSQSuitOnePanel