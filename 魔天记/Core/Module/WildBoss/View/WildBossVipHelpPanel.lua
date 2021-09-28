require "Core.Module.Common.Panel"

WildBossVipHelpPanel = class("WildBossVipHelpPanel", Panel);
function WildBossVipHelpPanel:New()
	self = { };
	setmetatable(self, { __index = WildBossVipHelpPanel });
	return self
end 

function WildBossVipHelpPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function WildBossVipHelpPanel:_InitReference()
	self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");
end

function WildBossVipHelpPanel:_InitListener()
	self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
end

function WildBossVipHelpPanel:_OnClickBtn_close()
	ModuleManager.SendNotification(WildBossNotes.CLOSE_WILDBOSSVIPHELPPANEL)
end

function WildBossVipHelpPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function WildBossVipHelpPanel:_DisposeListener()
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtn_close = nil;
end

function WildBossVipHelpPanel:_DisposeReference()
	self._btn_close = nil;
end