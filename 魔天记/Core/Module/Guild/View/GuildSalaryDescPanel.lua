require "Core.Module.Common.Panel";

GuildSalaryDescPanel = Panel:New();

function GuildSalaryDescPanel:_Init()
	self:_InitReference();
	self:_InitListener();
    
end

function GuildSalaryDescPanel:_InitReference()
    self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnClose");

    

end

function GuildSalaryDescPanel:_InitListener()
    self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);

	
end

function GuildSalaryDescPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();

end

function GuildSalaryDescPanel:_DisposeReference()

end

function GuildSalaryDescPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnClose = nil;

end

function GuildSalaryDescPanel:_Opened()
    self:UpdateDisplay();
end

function GuildSalaryDescPanel:_OnClickBtnClose()
    ModuleManager.SendNotification(GuildNotes.CLOSE_GUILD_OTHER_PANEL, GuildNotes.OTHER.SALARYDESC);
end

function GuildSalaryDescPanel:UpdateDisplay()
    
end

