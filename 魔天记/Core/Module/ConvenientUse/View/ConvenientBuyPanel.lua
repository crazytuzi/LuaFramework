require "Core.Module.Common.Panel"

local ConvenientBuyPanel = class("ConvenientBuyPanel", Panel);
function ConvenientBuyPanel:New()
    self = { };
    setmetatable(self, { __index = ConvenientBuyPanel });
    return self
end


function ConvenientBuyPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function ConvenientBuyPanel:_InitReference()
    local txts = UIUtil.GetComponentsInChildren(self._trsContent, "UILabel");
    self._txtAction = UIUtil.GetChildInComponents(txts, "txtAction");
    self._txtName = UIUtil.GetChildInComponents(txts, "txtName");
    local btns = UIUtil.GetComponentsInChildren(self._trsContent, "UIButton");
    self._btnAction = UIUtil.GetChildInComponents(btns, "btnAction");
    self._trsTips = UIUtil.GetChildByName(self._trsContent, "Transform", "trsTips");


    local product = UIUtil.GetChildByName(self._trsContent.transform, "trsTips/Product").gameObject;
    self._productCtrl = ProductCtrl:New();
    self._productCtrl:Init(product, { hasLocke = false, use_sprite = true, iconType = ProductCtrl.IconType_rectangle });
    self._productCtrl:SetOnClickBtnHandler(ProductCtrl.TYPE_FROM_OTHER);

end

function ConvenientBuyPanel:_InitListener()
    self._onClickBtnAction = function(go) self:_OnClickBtnAction(self) end
    UIUtil.GetComponent(self._btnAction, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnAction);
end

function ConvenientBuyPanel:_OnClickBtnAction()
    
    if self.doFun ~= nil then
        self.doFun(self.spid,self.buy_num);
    end

     TShopProxy.TryExchange(self.shop_id, self.spid, self.buy_num);

    ModuleManager.SendNotification(ConvenientUseNotes.CLOSE_CONVENIENTBUYPANEL);
end

function ConvenientBuyPanel:SetData(data)
    self.spid = data.spid;
    self.buy_num = data.num;
    self.shop_id =  data.shop_id;
    self.doFun = data.doFun;
   
    self.info = ProductManager.GetProductInfoById(self.spid, 1)
    self._productCtrl:SetData(self.info);

    local quality = self.info:GetQuality();
    self._txtName.text = ColorDataManager.GetColorTextByQuality(quality, self.info:GetName() .. " * " .. self.buy_num);

    self:StopTime();

    self.elseTime = 10;
    self:UpTimeStr();

    self._sec_timer = Timer.New( function()

        self.elseTime = self.elseTime - 1;
        self:UpTimeStr();

        if self.elseTime < 0 then
            self:StopTime();
            self:_OnClickBtnAction();
        end

    end , 1, self.elseTime + 1, false);
    self._sec_timer:Start();


end

function ConvenientBuyPanel:UpTimeStr()

    self._txtAction.text = LanguageMgr.Get("ConvenientUsePanel/label4") .. "(" .. self.elseTime .. ")";

end

function ConvenientBuyPanel:StopTime()
    if self._sec_timer ~= nil then
        self._sec_timer:Stop();
        self._sec_timer = nil;
    end
end


function ConvenientBuyPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function ConvenientBuyPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnAction, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnAction = nil;
end

function ConvenientBuyPanel:_DisposeReference()

    self._productCtrl:Dispose();
    self:StopTime();
    self.doFun = nil;

    self._btnAction = nil;
    self._txtAction = nil;
    self._txtName = nil;
    self._trsTips = nil;
end
return ConvenientBuyPanel