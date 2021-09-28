require "Core.Module.Common.Panel"

require "Core.Module.XLTInstance.controlls.XLTLeftPanelControll"
require "Core.Module.XLTInstance.controlls.XLTRightPanelControll"

XLTInstancePanel = class("XLTInstancePanel", Panel);
function XLTInstancePanel:New()
    self = { };
    setmetatable(self, { __index = XLTInstancePanel });
    return self
end


function XLTInstancePanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function XLTInstancePanel:_InitReference()
    local txts = UIUtil.GetComponentsInChildren(self._trsContent, "UILabel");
    self._txtPower = UIUtil.GetChildInComponents(txts, "txtPower");
    self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");
    self._btn_uknow = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_uknow");

    self.mainView = UIUtil.GetChildByName(self._trsContent, "Transform", "mainView");

    self.leftPanel = UIUtil.GetChildByName(self.mainView, "Transform", "leftPanel");
    self.rightPanel = UIUtil.GetChildByName(self.mainView, "Transform", "rightPanel");

    self.leftPanelCtr = XLTLeftPanelControll:New();
    self.leftPanelCtr:Init(self.leftPanel);

    self.rightPanelCtr = XLTRightPanelControll:New();
    self.rightPanelCtr:Init(self.rightPanel,self);

    self._trsContent.gameObject:SetActive(false);

    XLTInstanceProxy.TryGetXLTSaoDangInfo()

    MessageManager.AddListener(XLTInstanceProxy, XLTInstanceProxy.MESSAGE_NEED_UP_INSTREDS, XLTInstancePanel.NeedUpInstreds, self);

end

function XLTInstancePanel:_Opened()
    self.leftPanelCtr:_Opened();

    InstanceDataManager.UpData(XLTInstancePanel.GetFbLog, self);

    self._trsContent.gameObject:SetActive(true);

end

function XLTInstancePanel:NeedUpInstreds()
    InstanceDataManager.UpData(XLTInstancePanel.GetFbByRight, self);
end

function XLTInstancePanel:GetFbByRight()
    self.rightPanelCtr:Show();
end


function XLTInstancePanel:GetFbLog()
    self.leftPanelCtr:Show();
    self.rightPanelCtr:Show();

   XLTInstanceProxy.GetChuangGuanAwardLog()

end

function XLTInstancePanel:_InitListener()
    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
    self._onClickBtn_uknow = function(go) self:_OnClickBtn_uknow(self) end
    UIUtil.GetComponent(self._btn_uknow, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_uknow);
end

function XLTInstancePanel:_OnClickBtn_close()
    ModuleManager.SendNotification(XLTInstanceNotes.CLOSE_XLTINSTANCE_PANEL);
end

function XLTInstancePanel:_OnClickBtn_uknow()
    ModuleManager.SendNotification(XLTInstanceNotes.OPEN_XLTINSTANCEDECPANEL);
end

function XLTInstancePanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function XLTInstancePanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;
    UIUtil.GetComponent(self._btn_uknow, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_uknow = nil;
end

function XLTInstancePanel:_DisposeReference()
    self._btn_close = nil;
    self._btn_uknow = nil;
    self._txtPower = nil;

    self.leftPanelCtr:Dispose();
    self.rightPanelCtr:Dispose();

    MessageManager.RemoveListener(XLTInstanceProxy, XLTInstanceProxy.MESSAGE_NEED_UP_INSTREDS, XLTInstancePanel.NeedUpInstreds);



    self.mainView = nil;

    self.leftPanel = nil;
    self.rightPanel = nil;

    self.leftPanelCtr = nil;

    self.rightPanelCtr = nil;


end
