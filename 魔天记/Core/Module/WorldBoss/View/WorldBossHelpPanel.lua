require "Core.Module.Common.Panel"

WorldBossHelpPanel = class("WorldBossHelpPanel", Panel);
function WorldBossHelpPanel:New()
	self = { };
	setmetatable(self, { __index = WorldBossHelpPanel });
	return self
end 

function WorldBossHelpPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function WorldBossHelpPanel:_InitReference()
	self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");

	local txtTitle = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtTitle");
	txtTitle.text = LanguageMgr.Get("WorldBoss/help/title")

	local txtText = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtText");
	txtText.text = LanguageMgr.Get("WorldBoss/help/desc")
end

function WorldBossHelpPanel:_InitListener()
	self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
end

function WorldBossHelpPanel:_OnClickBtn_close()
	ModuleManager.SendNotification(WorldBossNotes.CLOSE_WORLDBOSSHELPPANEL)
end

function WorldBossHelpPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function WorldBossHelpPanel:_DisposeListener()
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtn_close = nil;
end

function WorldBossHelpPanel:_DisposeReference()
	self._btn_close = nil;
end