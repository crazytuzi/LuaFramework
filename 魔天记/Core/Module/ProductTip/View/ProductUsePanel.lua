require "Core.Module.Common.Panel"

ProductUsePanel = Panel:New();

function ProductUsePanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function ProductUsePanel:_InitReference()
    local txts = UIUtil.GetComponentsInChildren(self._trsContent, "UILabel");
    self._txtName = UIUtil.GetChildInComponents(txts, "txtName");
    self._txtnum = UIUtil.GetChildInComponents(txts, "txtnum");
    self._txtTitle = UIUtil.GetChildInComponents(txts, "txtTitle");
    self._txtUsenum = UIUtil.GetChildInComponents(txts, "txtUsenum");
    self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");
    self._btn_use = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_use");
    self._btn_add = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_add");
    self._btn_sub = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_sub");

    self.btn_min = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_min");
    self.btn_max = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_max");

     self._product = UIUtil.GetChildByName(self._trsContent, "Transform", "Product");

    self._product_icon = UIUtil.GetChildByName(self._product, "UISprite", "icon");
    self._product_icon_quality = UIUtil.GetChildByName(self._product, "UISprite", "icon_quality");
    self._product_numLabel = UIUtil.GetChildByName(self._product, "UILabel", "numLabel");

end

function ProductUsePanel:_InitListener()
    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
    self._onClickBtn_use = function(go) self:_OnClickBtn_use(self) end
    UIUtil.GetComponent(self._btn_use, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_use);
    self._onClickBtn_add = function(go) self:_OnClickBtn_add(self) end
    UIUtil.GetComponent(self._btn_add, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_add);
    self._onClickBtn_sub = function(go) self:_OnClickBtn_sub(self) end
    UIUtil.GetComponent(self._btn_sub, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_sub);

    self._onBtn_min = function(go) self:_OnBtn_min(self) end
    UIUtil.GetComponent(self.btn_min, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onBtn_min);

    self._onBtn_max = function(go) self:_OnBtn_max(self) end
    UIUtil.GetComponent(self.btn_max, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onBtn_max);
end

function ProductUsePanel:_OnClickBtn_close()
    ModuleManager.SendNotification(ProductTipNotes.CLOSE_PRODUCTUSEPANELL);
end

function ProductUsePanel:_OnClickBtn_use()
   self.currUseNum = self._txtUsenum.text + 0;
    ProductTipProxy.TryUseProduct(self.productInfo, self.currUseNum)
end

function ProductUsePanel:_OnBtn_min()
    self.currUseNum = 1;
    self._txtUsenum.text = "" .. self.currUseNum;
end

function ProductUsePanel:_OnBtn_max()
    local max_num = self.productInfo:GetAm();
    self.currUseNum = max_num;
    self._txtUsenum.text = "" .. self.currUseNum;
end

function ProductUsePanel:_OnClickBtn_add()
    --    self.currUseNum = self._txtUsenum.text + 0;
    self.currUseNum = self.currUseNum + 1;
    local max_num = self.productInfo:GetAm();
    if self.currUseNum > max_num then
        self.currUseNum = max_num;
    end
    self._txtUsenum.text = "" .. self.currUseNum;
end

function ProductUsePanel:_OnClickBtn_sub()
    --    self.currUseNum = self._txtUsenum.text + 0;
    self.currUseNum = self.currUseNum - 1;
    if self.currUseNum < 1 then
        self.currUseNum = 1;
    end
    self._txtUsenum.text = "" .. self.currUseNum;
end

function ProductUsePanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function ProductUsePanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;
    UIUtil.GetComponent(self._btn_use, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_use = nil;
    UIUtil.GetComponent(self._btn_add, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_add = nil;
    UIUtil.GetComponent(self._btn_sub, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_sub = nil;


    UIUtil.GetComponent(self.btn_min, "LuaUIEventListener"):RemoveDelegate("OnClick");
    UIUtil.GetComponent(self.btn_max, "LuaUIEventListener"):RemoveDelegate("OnClick");

    self._onBtn_min = nil;
    self._onBtn_max = nil;

end

function ProductUsePanel:_DisposeReference()
    self._btn_close = nil;
    self._btn_use = nil;
    self._btn_add = nil;
    self._btn_sub = nil;


      self._txtName = nil;
    self._txtnum = nil;
    self._txtTitle = nil;
    self._txtUsenum = nil;
    self._btn_close = nil;
    self._btn_use = nil;
    self._btn_add = nil;
    self._btn_sub = nil;

    self.btn_min = nil;
    self.btn_max = nil;

     self._product =nil;

    self._product_icon = nil;
    self._product_icon_quality = nil;
    self._product_numLabel = nil;






end

function ProductUsePanel:SetData(productInfo)

    self.productInfo = productInfo;
    --    self._txtTitle.text = "出售";
    self._txtName.text = productInfo:GetName();
    self._txtnum.text = productInfo:GetAm();
    self.currUseNum = 1;

    self._txtUsenum.text = self.currUseNum .. "";

     local quality = productInfo:GetQuality();
    local am = productInfo:GetAm();

   -- self._product_icon_quality.spriteName = ProductManager.GetQulitySpriteName(quality);
   self._product_icon_quality.color = ColorDataManager.GetColorByQuality(quality);

    ProductManager.SetIconSprite(self._product_icon, productInfo:GetIcon_id());

    if am and(am > 1) then
        self._product_numLabel.text = am .. "";
    else
        self._product_numLabel.text = "";
    end


end

