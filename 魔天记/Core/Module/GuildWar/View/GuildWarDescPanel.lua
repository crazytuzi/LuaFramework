require "Core.Module.Common.Panel";

GuildWarDescPanel = Panel:New();

function GuildWarDescPanel:_Init()
	self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnClose");

	self._onClickClose = function() self:_OnClickClose() end
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickClose);
end

function GuildWarDescPanel:_Dispose()
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickClose = nil;
end

function GuildWarDescPanel:_OnClickClose()
	ModuleManager.SendNotification(GuildWarNotes.CLOSE_DESC_PANEL);
end
