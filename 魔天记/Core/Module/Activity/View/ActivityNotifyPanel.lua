require "Core.Module.Common.Panel";

ActivityNotifyPanel = Panel:New();

function ActivityNotifyPanel:_Init()
    self._totalTime = 60;
    self._startTime = os.time();
    self._currTime = self._totalTime;
    self:_InitReference();
    self:_InitListener();
    self._timer = Timer.New( function(val) self:_OnTickHandler(val) end, 0.2, -1, false);

end

function ActivityNotifyPanel:IsFixDepth()
    return true;
end

function ActivityNotifyPanel:IsPopup()
    return false;
end

function ActivityNotifyPanel:_InitReference()
    self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnClose");
    self._txtLabel = UIUtil.GetChildByName(self._trsContent, "UILabel", "tips/Label");
    self._btnGO = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnGO");
    self._txtBtnLabel = UIUtil.GetChildByName(self._trsContent, "UILabel", "btnGO/txtLabel");
    -- self._txtLabel.text = LanguageMgr.Get("Arathi/EnterTips/label", { n = self._currTime });
end

function ActivityNotifyPanel:_InitListener()
    self._onClickBtnGO = function(go) self:_OnClickBtnGO(self) end
    UIUtil.GetComponent(self._btnGO, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnGO);

    self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);
end

function ActivityNotifyPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function ActivityNotifyPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnGO, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnGO = nil;

    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnClose = nil;
end

function ActivityNotifyPanel:_DisposeReference()
    if (self._timer) then
        self._timer:Stop();
        self._timer = nil;
    end
    self._btnGO = nil;
    self._btnClose = nil;
    self._txtBtnLabel = nil;
end

function ActivityNotifyPanel:SetData(data)
    self._data = data;
    self._txtLabel.text = LanguageMgr.Get("ActivityNotifyPanel/tip" .. data.t);
    self._timer:Stop();
    self._timer:Start();
    self:_OnTickHandler();
end

function ActivityNotifyPanel:_OnClickBtnGO()
    if (self._data.t == 1) then
        GuildProxy.ReqEnterZone();
    elseif (self._data.t == 2) then
        ModuleManager.SendNotification(WildBossNotes.OPEN_WILDBOSSPANEL, {tab = 1, idx = WildBossManager.GetWildBossIndex(self._data.para)})
    elseif (self._data.t == 4) then
        ModuleManager.SendNotification(WildBossNotes.OPEN_WILDBOSSPANEL)
    elseif (self._data.t == 3) then
        ModuleManager.SendNotification(WorldBossNotes.OPEN_WORLDBOSSPANEL)
    elseif (self._data.t == 5) then
        GuildProxy.ReqEnterZone();
    elseif (self._data.t == 6) then
        ModuleManager.SendNotification(XMBossNotes.OPEN_XMBOSSPANEL);
    elseif (self._data.t == 7) then
        ModuleManager.SendNotification(XinJiRisksNotes.OPEN_XINJIRISKSPANEL)
    elseif (self._data.t == 8) then
        ModuleManager.SendNotification(YaoShouNotes.OPEN_YAOSHOUPANEL);
    elseif (self._data.t == 99) then
        ModuleManager.SendNotification(GuildWarNotes.OPEN_PANEL)
    end
    ModuleManager.SendNotification(ActivityNotes.CLOSE_ACTIVITYNOTIFY)
end


function ActivityNotifyPanel:_OnClickBtnClose()
    ModuleManager.SendNotification(ActivityNotes.CLOSE_ACTIVITYNOTIFY)
end

function ActivityNotifyPanel:_OnTickHandler()
    local cTime = os.time() - self._startTime;

    if (self._currTime ~= cTime) then
        self._currTime = cTime
        self._txtBtnLabel.text = LanguageMgr.Get("ActivityNotifyPanel/goto", { n = (self._totalTime - cTime) });
    end
    if (cTime >= self._totalTime) then
        ModuleManager.SendNotification(ActivityNotes.CLOSE_ACTIVITYNOTIFY)
    end
end 