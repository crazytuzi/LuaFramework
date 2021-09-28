require "Core.Module.Common.Panel"

DemoPanel = Panel:New();

function DemoPanel:_InitReference()
	self._btnOK = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnOK");
	self._btnAlert = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnAlert");
	self._txtInput = UIUtil.GetChildByName(self._trsContent, "InputField", "txtInput");
end

function DemoPanel:_OnClickBtnOK(evt)
	PanelManager.RecyclePanel(self);
end

function DemoPanel:_OnClickBtnAlert(evt)
	local alert = PanelManager.BuildPanel(ResID.UI_ALERT_OK, Alert:New());
	alert:SetContent(self._txtInput.text);
	alert:SetAutoCloseFlag(true);
end

function DemoPanel:_InitListener()
	self._onClickBtnOK = function(evt) self:_OnClickBtnOK(evt) end
	UIUtil.GetComponent(self._btnOK, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnOK);
	self._onClickBtnAlert = function(evt) self:_OnClickBtnAlert(evt) end
	UIUtil.GetComponent(self._btnAlert, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnAlert);
end

function DemoPanel:_Init()
	print("_Opened")
	self:_InitReference();
	self:_InitListener();
end

function DemoPanel:_Opened()
	
end

function DemoPanel:_DisposeListener()
	UIUtil.GetComponent(self._btnOK, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnOK = nil;
	UIUtil.GetComponent(self._btnAlert, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnAlert = nil;
end

function DemoPanel:_DisposeReference()
	self._btnOK = nil;
	self._btnAlert = nil;
	self._txtInput = nil;
end

function DemoPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end