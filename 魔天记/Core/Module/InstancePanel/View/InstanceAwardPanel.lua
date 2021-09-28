require "Core.Module.Common.Panel"

InstanceAwardPanel = class("InstanceAwardPanel", Panel);

InstanceAwardPanel.doType_1 = 1;
InstanceAwardPanel.doType_2 = 2;
InstanceAwardPanel.doType_3 = 3;

function InstanceAwardPanel:New()
    self = { };
    setmetatable(self, { __index = InstanceAwardPanel });
    return self
end


function InstanceAwardPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function InstanceAwardPanel:_InitReference()
    self._txt_title = UIUtil.GetChildByName(self._trsContent, "UILabel", "txt_title");
    self._txt_tip = UIUtil.GetChildByName(self._trsContent, "UILabel", "txt_tip");
    self._txt_label = UIUtil.GetChildByName(self._trsContent, "UILabel", "txt_label");
    self._btn_ok = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_ok");
    self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");
    self.tipTxt = UIUtil.GetChildByName(self._trsContent, "UILabel", "tipTxt");

    for i = 1, 10 do
        self["product" .. i] = UIUtil.GetChildByName(self._trsContent, "Transform", "product" .. i);
        self["productCtr" .. i] = ProductCtrl:New();
        self["productCtr" .. i]:Init(self["product" .. i], { hasLocke = true, use_sprite = true, iconType = ProductCtrl.IconType_rectangle });
        self["productCtr" .. i]:SetOnClickBtnHandler(ProductCtrl.TYPE_FROM_OTHER);
    end


end

function InstanceAwardPanel:_InitListener()
    self._onClickBtn_ok = function(go) self:_OnClickBtn_ok(self) end
    UIUtil.GetComponent(self._btn_ok, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_ok);
    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);

    MessageManager.AddListener(InstancePanelProxy, InstancePanelProxy.MESSAGE_BOX_PRODUCTS_CHANGE, InstanceAwardPanel.BoxProductChange, self);
    MessageManager.AddListener(InstancePanelProxy, InstancePanelProxy.MESSAGE_GET_BOX_PROS_SUCCESS, InstanceAwardPanel.GetBoxProductSuccess, self);
end



function InstanceAwardPanel:_OnClickBtn_ok()

    --   local getobj = {index=self.index,t=self.fb_type,k=self.fb_kind};
    local obj = self.data.getobj;
    InstancePanelProxy.TryGetGBoxProducts(obj.t, obj.k, obj.index);

end

function InstanceAwardPanel:GetBoxProductSuccess()
    self._btn_ok.gameObject:SetActive(false);
    self.tipTxt.gameObject:SetActive(true);
    self.tipTxt.text = LanguageMgr.Get("InstancePanel/InstanceAwardPanel/label1");
end

function InstanceAwardPanel:_OnClickBtn_close()
    ModuleManager.SendNotification(InstancePanelNotes.CLOSE_INSTANCEAWARDPANEL);
end


-- {id=self.box_id,star=self.star_num,doType=self.doType,getobj=getobj}
function InstanceAwardPanel:SetData(data)

    self.data = data;
    local doType = data.doType;

    self._txt_tip.text = LanguageMgr.Get("InstancePanel/InstanceAwardPanel/label2", { n = data.star });

    InstancePanelProxy.TryGetBoxProducts(self.data.id);

    if doType == InstanceAwardPanel.doType_1 then


        self._btn_ok.gameObject:SetActive(true);
        self.tipTxt.gameObject:SetActive(false);
    elseif doType == InstanceAwardPanel.doType_2 then

        self._btn_ok.gameObject:SetActive(false);
        self.tipTxt.gameObject:SetActive(true);
        self.tipTxt.text = LanguageMgr.Get("InstancePanel/InstanceAwardPanel/label3", { n = self.data.star });
    elseif doType == InstanceAwardPanel.doType_3 then

        self._btn_ok.gameObject:SetActive(false);
        self.tipTxt.gameObject:SetActive(true);
        self.tipTxt.text = LanguageMgr.Get("InstancePanel/InstanceAwardPanel/label1");
    end

end

--  S <-- 11:49:29.832, 0x0417, 14, {"items":[{"am":1,"spId":1001}]}
function InstanceAwardPanel:BoxProductChange(data)

    local arr = data.items;

    for i = 1, 10 do

        local obj = arr[i];

        if obj ~= nil then
            local am = obj.am;
            local spid = obj.spId;

            local info = ProductInfo:New();
            info:Init( { spId = spid, am = am });

            self["productCtr" .. i]:SetData(info);
        else
            self["productCtr" .. i]:SetData(nil);
        end


    end

end

function InstanceAwardPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function InstanceAwardPanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_ok, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_ok = nil;
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;

    MessageManager.RemoveListener(InstancePanelProxy, InstancePanelProxy.MESSAGE_BOX_PRODUCTS_CHANGE, InstanceAwardPanel.BoxProductChange);
    MessageManager.RemoveListener(InstancePanelProxy, InstancePanelProxy.MESSAGE_GET_BOX_PROS_SUCCESS, InstanceAwardPanel.GetBoxProductSuccess);
end

function InstanceAwardPanel:_DisposeReference()
    self._btn_ok = nil;
    self._btn_close = nil;

    for i = 1, 10 do
        self["productCtr" .. i]:Dispose();
        self["productCtr" .. i] = nil;
        self["product" .. i] = nil;
    end


    self._txt_title = nil;
    self._txt_tip = nil;
    self._txt_label = nil;
    self._btn_ok = nil;
    self._btn_close = nil;
    self.tipTxt = nil;



end
