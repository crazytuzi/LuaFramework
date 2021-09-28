require "Core.Module.Common.Panel"

DialogSubPanel = class("DialogSubPanel", Panel);
function DialogSubPanel:New()
    self = { };
    setmetatable(self, { __index = DialogSubPanel });
    return self
end

function DialogSubPanel:_GetDefaultDepth()
    return 1
end

function DialogSubPanel:GetUIOpenSoundName( )
    return ""
end 

function DialogSubPanel:IsPopup()
    return false;
end
function DialogSubPanel:_Init()
    self._luaBehaviour.canPool = true
    self:_InitReference();
    self:_InitListener();
end

function DialogSubPanel:SetData(content, canSkip)
    self._txtMsg.text = content
    self._btn_close:SetActive(canSkip)
end
function DialogSubPanel:GetContent()
    return self._txtMsg.text
end
function DialogSubPanel:ClearText()
    self._txtMsg.text = ""
end
function DialogSubPanel:_InitReference()
    self._txtMsg = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtMsg");
    -- Warning("DialogSubPanel:_InitReference___"  .. tostring(self._txtMsg))
    self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close").gameObject;
end

function DialogSubPanel:_InitListener()
    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
end

function DialogSubPanel:_OnClickBtn_close()
    DramaDirector.Skip(true)
end
function DialogSubPanel:ShowSkipBtn()
    self._btn_close:SetActive(true)
end

function DialogSubPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function DialogSubPanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;
end

function DialogSubPanel:_DisposeReference()
    self._btn_close = nil;
    self._txtMsg = nil;
end
