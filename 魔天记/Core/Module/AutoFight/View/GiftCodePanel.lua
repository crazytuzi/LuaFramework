require "Core.Module.Common.UIComponent"

GiftCodePanel = class("GiftCodePanel", UIComponent);
function GiftCodePanel:New()
    self = { };
    setmetatable(self, { __index = GiftCodePanel });
    return self
end 
function GiftCodePanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function GiftCodePanel:_InitReference()
    self._codePanel = UIUtil.GetChildByName(self._gameObject, "Transform", "codePanel");

    self._input = UIUtil.GetChildByName(self._codePanel , "UIInput", "inputName");
    self._btnReqGift = UIUtil.GetChildByName(self._codePanel, "UIButton", "btnReqGift");

end

function GiftCodePanel:_InitListener()
    self._onClickBtnReqGift = function(go) self:_OnClickBtnReqGift(self) end
    UIUtil.GetComponent(self._btnReqGift, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnReqGift);

    MessageManager.AddListener(AutoFightNotes, AutoFightNotes.ENV_GIFTCODE_SUC, GiftCodePanel.OnResult, self);
end

function GiftCodePanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function GiftCodePanel:_DisposeListener()

    MessageManager.RemoveListener(AutoFightNotes, AutoFightNotes.ENV_GIFTCODE_SUC, GiftCodePanel.OnResult);

    UIUtil.GetComponent(self._btnReqGift, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnReqGift = nil;
    
end

function GiftCodePanel:_DisposeReference()

end

function GiftCodePanel:_OnClickBtnReqGift()
    local code = self._input.value;
    AutoFightProxy.ReqSendGiftCode(code);
end

function GiftCodePanel:UpdatePanel()
    
end

function GiftCodePanel:OnResult()
    self._input.value = "";
end