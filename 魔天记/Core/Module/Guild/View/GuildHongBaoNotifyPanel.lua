require "Core.Module.Common.Panel";

GuildHongBaoNotifyPanel = Panel:New();

function GuildHongBaoNotifyPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function GuildHongBaoNotifyPanel:GetUIOpenSoundName( )
    return UISoundManager.ui_gold
end

function GuildHongBaoNotifyPanel:IsPopup()
    return false;
end

function GuildHongBaoNotifyPanel:IsFixDepth()
    return true
end

function GuildHongBaoNotifyPanel:SetData(data)
    self.data = data;
end

function GuildHongBaoNotifyPanel:_InitReference()
    self._btnGO = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnGO");
end

function GuildHongBaoNotifyPanel:_InitListener()
    self._onClickBtnGO = function(go) self:_OnClickBtnGO(self) end
    UIUtil.GetComponent(self._btnGO, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnGO);
end

function GuildHongBaoNotifyPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function GuildHongBaoNotifyPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnGO, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnGO = nil;
end

function GuildHongBaoNotifyPanel:_DisposeReference()
    self._btnGO = nil;
end

function GuildHongBaoNotifyPanel:_OnClickBtnGO()
    local data = self.data
    if (data) then
        GuildProxy.ReqShowHongBao(data.rpid)
    else
        ModuleManager.SendNotification(GuildNotes.CLOSE_GUILDHONGBAONOTIFYPANEL)
    end
end