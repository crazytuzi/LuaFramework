require "Core.Module.Common.Panel"

XMBossAwardPanel = class("XMBossAwardPanel", Panel);
function XMBossAwardPanel:New()
    self = { };
    setmetatable(self, { __index = XMBossAwardPanel });
    return self
end


function XMBossAwardPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function XMBossAwardPanel:_InitReference()
    self._txtTipTitle = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtTipTitle");
    self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");


    self.awardsPanel = UIUtil.GetChildByName(self._trsContent, "Transform", "awardsPanel");

    for i = 1, 10 do
        self["product" .. i] = UIUtil.GetChildByName(self.awardsPanel, "Transform", "product" .. i);
        self["productCtr" .. i] = ProductCtrl:New();
        self["productCtr" .. i]:Init(self["product" .. i], { hasLocke = true, use_sprite = true, iconType = ProductCtrl.IconType_rectangle }, true);
    end

end

function XMBossAwardPanel:_InitListener()
    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
end

function XMBossAwardPanel:SetData(box_id)


end

function XMBossAwardPanel:_OnClickBtn_close()
    ModuleManager.SendNotification(XMBossNotes.CLOSE_XMBOSSAWARDPANEL);
end

function XMBossAwardPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function XMBossAwardPanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;
end

function XMBossAwardPanel:_DisposeReference()

    for i = 1, 10 do
        self["productCtr" .. i]:Dispose();
        self["productCtr" .. i] = nil;
        self["product" .. i] = nil;
    end

    self._btn_close = nil;
    self._txtTipTitle = nil;

    self.awardsPanel = nil;


end
