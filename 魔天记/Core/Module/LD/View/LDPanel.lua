require "Core.Module.Common.Panel"

LDPanel = class("LDPanel", Panel);
function LDPanel:New()
    self = { };
    setmetatable(self, { __index = LDPanel });
    return self
end


function LDPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function LDPanel:_InitReference()
    local txts = UIUtil.GetComponentsInChildren(self._trsContent, "UILabel");
    self._txtIP = UIUtil.GetChildInComponents(txts, "txtIP");
    self._btnOK = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_ok");
    self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");
end

function LDPanel:_InitListener()
    self._onClickOk = function(go) self:_OnClickOk(self) end
    UIUtil.GetComponent(self._btnOK, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickOk);

    self._onClickClose = function(go) self:_OnClickClose(self) end
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickClose);
end


function LDPanel:_OnClickOk()
    require("LuaDebug")(self._txtIP.text, 7003)
    ModuleManager.SendNotification(LDNotes.CLOSE_LDPANEL);
end

function LDPanel:_OnClickClose()
    ModuleManager.SendNotification(LDNotes.CLOSE_LDPANEL);
end

function LDPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function LDPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnOK, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickOk = nil;

    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickClose = nil;
end

function LDPanel:_DisposeReference()
    self._btnOK = nil;
end
