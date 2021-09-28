require "Core.Module.Common.Panel"
local NewEquipStrongSuitItem = require "Core.Module.Equip.Item.NewEquipStrongSuitItem";

local EquipNewStrongSuitPanel = class("EquipNewStrongSuitPanel", Panel);
function EquipNewStrongSuitPanel:New()
	self = {};
	setmetatable(self, {__index = EquipNewStrongSuitPanel});
	return self
end

function EquipNewStrongSuitPanel:_Init()
	self:_InitReference();
	self:_InitListener();
	
end

function EquipNewStrongSuitPanel:_InitReference()
	self._txtDes = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtDes");
	self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");
	self._goItemParent1 = UIUtil.GetChildByName(self._trsContent, "item1").gameObject
	self._goItemParent2 = UIUtil.GetChildByName(self._trsContent, "item2").gameObject
	self._item1 = NewEquipStrongSuitItem:New()
	self._item1:Init(self._goItemParent1)	
	self._item2 = NewEquipStrongSuitItem:New()
	self._item2:Init(self._goItemParent2)	
	
end

function EquipNewStrongSuitPanel:_InitListener()
	self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
end

function EquipNewStrongSuitPanel:_OnClickBtn_close()
	ModuleManager.SendNotification(EquipNotes.CLOSE_EQUIPNEWSTRONGSUITPANEL)	
end

function EquipNewStrongSuitPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
	self._item1:Dispose()
	self._item1 = nil
	self._item2:Dispose()
	self._item2 = nil
end

function EquipNewStrongSuitPanel:_DisposeListener()
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtn_close = nil;
end

function EquipNewStrongSuitPanel:_DisposeReference()
	self._btn_close = nil;
	self._txtDes = nil;
	self._goItemParent1 = nil
	self._goItemParent2 = nil
end


function EquipNewStrongSuitPanel:UpdatePanel(data)
	self._txtDes.text = data[1].open_desc
	self._item1:UpdateItem(data[1])
	self._item2:UpdateItem(data[2])
end
return EquipNewStrongSuitPanel 