require "Core.Module.Common.Panel";

ArathiTipsPanel = Panel:New();

function ArathiTipsPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function ArathiTipsPanel:_InitReference()
    local txtLabel1 = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtLabel1");
    local txtLabel2 = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtLabel2");
    txtLabel1.text = LanguageMgr.Get("Arathi/Tip/label1");
    txtLabel2.text = LanguageMgr.Get("Arathi/Tip/label2");
    self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnClose");    
end

function ArathiTipsPanel:_InitListener()
    self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);
end

function ArathiTipsPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function ArathiTipsPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnClose = nil;
end

function ArathiTipsPanel:_DisposeReference()
     self._btnClose = nil;
end

function ArathiTipsPanel:_OnClickBtnClose()
    ModuleManager.SendNotification(ArathiNotes.CLOSE_ARATHITIPSPANEL)
end