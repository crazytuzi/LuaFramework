require "Core.Module.Common.Panel"

TestCodePanel = class("TestCodePanel", Panel);
function TestCodePanel:New()
    self = { };
    setmetatable(self, { __index = TestCodePanel });
    return self
end

function TestCodePanel:IsPopup()
    return false
end

function TestCodePanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function TestCodePanel:_InitReference()
    self._btn_ok = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_ok");
    self._txtTestCode = UIUtil.GetChildByName(self._trsContent, "UILabel", "inputTestCode/testCode")
end

function TestCodePanel:_InitListener()
    self._onClickBtn_ok = function(go) self:_OnClickBtn_ok(self) end
    UIUtil.GetComponent(self._btn_ok, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_ok);
end

function TestCodePanel:_OnClickBtn_ok()
    coroutine.start(LoginHttp.TryLogin, nil, nil, self._txtTestCode.text)
end

function TestCodePanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function TestCodePanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_ok, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_ok = nil;
end

function TestCodePanel:_DisposeReference()
    self._btn_ok = nil;
end
