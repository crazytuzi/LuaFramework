require "Core.Module.Common.Panel"

GMPanel = class("GMPanel", Panel);
function GMPanel:New()
    self = { };
    setmetatable(self, { __index = GMPanel });
    return self
end


function GMPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function GMPanel:_InitReference()
    local txts = UIUtil.GetComponentsInChildren(self._trsContent, "UILabel");
    self._txtProtocolContent = UIUtil.GetChildInComponents(txts, "txtProtocolContent");
    self._txtProtocol = UIUtil.GetChildInComponents(txts, "txtProtocol");
    self._txtGmContent = UIUtil.GetChildInComponents(txts, "txtGmContent");
    self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");
    self._btnSend1 = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnSend1");
    self._btnSend2 = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnSend2");
end

function GMPanel:_InitListener()
    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
    self._onClickBtnSend1 = function(go) self:_OnClickBtnSend1(self) end
    UIUtil.GetComponent(self._btnSend1, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnSend1);
    self._onClickBtnSend2 = function(go) self:_OnClickBtnSend2(self) end
    UIUtil.GetComponent(self._btnSend2, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnSend2);
end

function GMPanel:_OnClickBtn_close()
    ModuleManager.SendNotification(GMNotes.CLOSE_GMPANEL)
end

function GMPanel:_OnClickBtnSend1()
    GMProxy.SendProtocol(self._txtProtocol.text, string.format("{%s}", self._txtProtocolContent.text))
end

function GMPanel:_OnClickBtnSend2()
    local cmd = string.sub(self._txtGmContent.text, 1, 1);
    if (cmd == "#") then
        local guide = string.sub(self._txtGmContent.text, 2, -1);
        GuideManager.Guide(guide);
        ModuleManager.SendNotification(GMNotes.CLOSE_GMPANEL)
    elseif (cmd == "@") then
        local ty = string.sub(self._txtGmContent.text, 2, -1);
        ActivityProxy.ActivityNotify(0, { t = tonumber(ty) })

    elseif (cmd == "&") then
        local fid = string.sub(self._txtGmContent.text, 2, -1);
        GameSceneManager.GoToFB(fid);
    else
        GMProxy.SendGmCmd(self._txtGmContent.text)
    end
end

function GMPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function GMPanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;
    UIUtil.GetComponent(self._btnSend1, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnSend1 = nil;
    UIUtil.GetComponent(self._btnSend2, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnSend2 = nil;
end

function GMPanel:_DisposeReference()
    self._btn_close = nil;
    self._btnSend1 = nil;
    self._btnSend2 = nil;
end
