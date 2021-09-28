require "Core.Module.Common.Panel"
local NewEquipStrongSuitItem = require "Core.Module.Equip.Item.NewEquipStrongSuitItem";

local EquipNewStrongSuitOnePanel = class("EquipNewStrongSuitOnePanel", Panel);
function EquipNewStrongSuitOnePanel:New()
	self = {};
	setmetatable(self, {__index = EquipNewStrongSuitOnePanel});
	return self
end


function EquipNewStrongSuitOnePanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function EquipNewStrongSuitOnePanel:_InitReference()
	self._txtDes = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtDes");
	self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");
	self._goItemParent1 = UIUtil.GetChildByName(self._trsContent, "item1").gameObject
	self._item1 = NewEquipStrongSuitItem:New()
	self._item1:Init(self._goItemParent1)	
end

function EquipNewStrongSuitOnePanel:_InitListener()
	self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
end

function EquipNewStrongSuitOnePanel:_OnClickBtn_close()
	ModuleManager.SendNotification(EquipNotes.CLOSE_EQUIPNEWSTRONGSUITONEPANEL)
end

function EquipNewStrongSuitOnePanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function EquipNewStrongSuitOnePanel:_DisposeListener()
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtn_close = nil;
end

function EquipNewStrongSuitOnePanel:_DisposeReference()
	self._btn_close = nil;
	self._txtDes = nil;
	self._goItemParent1 = nil
	self._item1:Dispose()
	self._item1 = nil
end

function EquipNewStrongSuitOnePanel:UpdatePanel(data)
	self._txtDes.text = data.open_desc
	self._item1:UpdateItem(data)
end

return EquipNewStrongSuitOnePanel 