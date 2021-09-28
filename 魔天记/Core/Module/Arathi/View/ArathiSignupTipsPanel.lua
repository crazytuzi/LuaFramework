require "Core.Module.Common.Panel";

ArathiSignupTipsPanel = Panel:New();

function ArathiSignupTipsPanel:GetUIOpenSoundName()
    return ""
end

function ArathiSignupTipsPanel:_Init()
    self._totalTime = 60;
    self._currTime = self._totalTime;
    self:_InitReference();
    self:_InitListener();    
    self._timer = Timer.New( function(val) self:_OnTickHandler(val) end, 0, -1, false);
    self._timer:Start();
end


function ArathiSignupTipsPanel:IsPopup()
    return false;
end

function ArathiSignupTipsPanel:IsFixDepth()
    return true
end

function ArathiSignupTipsPanel:_InitReference()
    self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnClose");
    self._txtLabel = UIUtil.GetChildByName(self._trsContent, "UILabel", "tips/Label");
    self._btnGO = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnGO");
    self._txtBtnLabel = UIUtil.GetChildByName(self._trsContent, "UILabel", "btnGO/txtLabel");

    self._txtLabel.text = LanguageMgr.Get("Arathi/SignupTip");
    self._txtBtnLabel.text = LanguageMgr.Get("Arathi/Signup", { n = self._currTime });    
end

function ArathiSignupTipsPanel:_InitListener()
    self._onClickBtnGO = function(go) self:_OnClickBtnGO(self) end
    UIUtil.GetComponent(self._btnGO, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnGO);

    self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);
end

function ArathiSignupTipsPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function ArathiSignupTipsPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnGO, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnGO = nil;

    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnClose = nil;
end

function ArathiSignupTipsPanel:_DisposeReference()
    if (self._timer) then
        self._timer:Stop();
        self._timer = nil;
    end
    self._btnGO = nil;
    self._txtLabel = nil;
    self._txtBtnLabel = nil;
end

function ArathiSignupTipsPanel:_OnClickBtnGO()
    ModuleManager.SendNotification(ArathiNotes.CLOSE_ARATHISIGNUPTIPSPANEL)
    --ModuleManager.SendNotification(ArathiNotes.OPEN_ARATHIPANEL)    
    ArathiProxy.EnterReadyScene();
end

function ArathiSignupTipsPanel:_OnClickBtnClose()
    ModuleManager.SendNotification(ArathiNotes.CLOSE_ARATHISIGNUPTIPSPANEL)
end

function ArathiSignupTipsPanel:_OnTickHandler()
    self._totalTime = self._totalTime - Timer.deltaTime;
    local cTime = math.ceil(self._totalTime);
    if (self._currTime ~= cTime) then
        self._currTime = cTime
        self._txtBtnLabel.text = LanguageMgr.Get("Arathi/Signup", { n = cTime });
    end
    if (cTime < 1) then
        ModuleManager.SendNotification(ArathiNotes.CLOSE_ARATHISIGNUPTIPSPANEL)
    end
end