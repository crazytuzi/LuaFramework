require "Core.Module.Common.Panel"

ChatVoicePanel = class("ChatVoicePanel", Panel);
ChatVoiceState = {
    voice = 1,
    cancel = 2,
}
function ChatVoicePanel:New()
    self = { };
    setmetatable(self, { __index = ChatVoicePanel });
    return self
end

function ChatVoicePanel:IsPopup()
    return false;
end

function ChatVoicePanel:GetUIOpenSoundName( )
    return ""
end

function ChatVoicePanel:ChangeValue(val)
    self._trsValue1.gameObject:SetActive(val > 0)
    self._trsValue2.gameObject:SetActive(val > 1)
    self._trsValue3.gameObject:SetActive(val > 2)
    self._trsValue4.gameObject:SetActive(val > 3)
end

function ChatVoicePanel:ChangeState(val)
    self._trsvoice.gameObject:SetActive(val == ChatVoiceState.voice)
    self._trscancel.gameObject:SetActive(val == ChatVoiceState.cancel)
end

function ChatVoicePanel:_Init()
    self._luaBehaviour.canPool = true;
    self:_InitReference();
    self:_InitListener();
end

function DialogPanel:_GetDefaultDepth()
    return 1
end


function ChatVoicePanel:_InitReference()
    local trss = UIUtil.GetComponentsInChildren(self._trsContent, "Transform");
    self._trsvoice = UIUtil.GetChildInComponents(trss, "trsvoice");
    self._trsValue1 = UIUtil.GetChildInComponents(trss, "trsValue1");
    self._trsValue2 = UIUtil.GetChildInComponents(trss, "trsValue2");
    self._trsValue3 = UIUtil.GetChildInComponents(trss, "trsValue3");
    self._trsValue4 = UIUtil.GetChildInComponents(trss, "trsValue4");
    self._trscancel = UIUtil.GetChildInComponents(trss, "trscancel");
end

function ChatVoicePanel:_InitListener()
end

function ChatVoicePanel:_Dispose()
    self:_DisposeReference();
end

function ChatVoicePanel:_DisposeReference()
    self._trsvoice = nil;
    self._trsValue1 = nil;
    self._trsValue2 = nil;
    self._trsValue3 = nil;
    self._trsValue4 = nil;
    self._trscancel = nil;
end
