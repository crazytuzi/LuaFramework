require "Core.Module.Common.Panel";

ArathiEnterTipsPanel = Panel:New();

function ArathiEnterTipsPanel:_Init()
    self._totalTime = 60;
    self._startTime = os.time();
    self._currTime = self._totalTime;
    self:_InitReference();
    self:_InitListener();    
    self._timer = Timer.New( function(val) self:_OnTickHandler(val) end, 0.2, -1, false);
    self._timer:Start();
end

function ArathiEnterTipsPanel:IsFixDepth()
    return true;
end

function ArathiEnterTipsPanel:IsPopup()
    return false;
end

function ArathiEnterTipsPanel:_InitReference()
    self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnClose");
    self._txtLabel = UIUtil.GetChildByName(self._trsContent, "UILabel", "tips/Label");
    self._btnGO = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnGO");
    self._txtBtnLabel = UIUtil.GetChildByName(self._trsContent, "UILabel", "btnGO/txtLabel");
    self._txtBtnLabel.text = LanguageMgr.Get("Arathi/EnterTips/btn");
    self._txtLabel.text = LanguageMgr.Get("Arathi/EnterTips/label", { n = self._currTime });
end

function ArathiEnterTipsPanel:_InitListener()
    self._onClickBtnGO = function(go) self:_OnClickBtnGO(self) end
    UIUtil.GetComponent(self._btnGO, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnGO);

    self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);
end

function ArathiEnterTipsPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function ArathiEnterTipsPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnGO, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnGO = nil;

    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnClose = nil;
end

function ArathiEnterTipsPanel:_DisposeReference()
    if (self._timer) then
        self._timer:Stop();
        self._timer = nil;
    end
    self._btnClose = nil;
    self._btnGO = nil;
    self._txtBtnLabel = nil;
end

function ArathiEnterTipsPanel:_OnClickBtnGO()
    ModuleManager.SendNotification(ArathiNotes.CLOSE_ARATHIENTERTIPSPANEL)
end

function ArathiEnterTipsPanel:_OnClickBtnClose()
    ModuleManager.SendNotification(ArathiNotes.CLOSE_ARATHIENTERTIPSPANEL)
end

function ArathiEnterTipsPanel:_OnTickHandler()
    local cTime = os.time() - self._startTime;
    if (self._currTime ~= cTime) then
        self._currTime = cTime
        self._txtLabel.text = LanguageMgr.Get("Arathi/EnterTips/label", { n = self._totalTime - cTime});
    end
    if (cTime >= self._totalTime) then
        ModuleManager.SendNotification(ArathiNotes.CLOSE_ARATHIENTERTIPSPANEL)
    end
end