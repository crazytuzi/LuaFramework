require "Core.Module.Common.Panel";

ArathiWarTipPanel = Panel:New();

function ArathiWarTipPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function ArathiWarTipPanel:_InitReference()
    local txtTitle1 = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtTitle1");
    local txtText1 = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtText1");
    local txtTitle2 = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtTitle2");
    local txtText2 = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtText2");
    txtTitle1.text = LanguageMgr.Get("Arathi/war/Tip/title1");
    txtText1.text = LanguageMgr.Get("Arathi/war/Tip/label1");
    txtTitle2.text = LanguageMgr.Get("Arathi/war/Tip/title2");
    txtText2.text = LanguageMgr.Get("Arathi/war/Tip/label2");
    self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnClose");
end

function ArathiWarTipPanel:_InitListener()
    self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);
end

function ArathiWarTipPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function ArathiWarTipPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnClose = nil;
end

function ArathiWarTipPanel:_DisposeReference()
    self._btnClose = nil;
end

function ArathiWarTipPanel:_OnClickBtnClose()
    ModuleManager.SendNotification(ArathiNotes.CLOSE_ARATHIWARTIPSPANEL)
end