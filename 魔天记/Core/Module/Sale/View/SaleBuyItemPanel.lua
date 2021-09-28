require "Core.Module.Common.Panel"

SaleBuyItemPanel = class("SaleBuyItemPanel", Panel);
function SaleBuyItemPanel:New()
    self = { };
    setmetatable(self, { __index = SaleBuyItemPanel });
    return self
end


function SaleBuyItemPanel:_Init()
    self:_InitReference();
    self:_InitListener();
    self._buyCount = 1
end

function SaleBuyItemPanel:_InitReference()
    self._txtUseLevel = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtUseLevel");
    self._txtTitle = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtTitle");
    self._txtCount = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtCount");
    self._txtPrice = UIUtil.GetChildByName(self._trsContent, "UILabel", "price");
    self._txtNum = UIUtil.GetChildByName(self._trsContent, "UILabel", "Product/numLabel")
    self._txtTotalPrice = UIUtil.GetChildByName(self._trsContent, "UILabel", "totalPrice");
    self._goInput = UIUtil.GetChildByName(self._trsContent, "inputBg").gameObject
    self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");
    self._btnReduce = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnReduce");
    self._btnAdd = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnAdd");
    self._btnBuy = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnBuy");
    self._btnCancle = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnCancle");
    self._imgIcon = UIUtil.GetChildByName(self._trsContent, "UISprite", "Product/icon");
    self._imgQuality = UIUtil.GetChildByName(self._trsContent, "UISprite", "Product/icon_quality");

end

function SaleBuyItemPanel:_InitListener()
    self._onClickBtnReduce = function(go) self:_OnClickBtnReduce(self) end
    UIUtil.GetComponent(self._btnReduce, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnReduce);
    self._onClickBtnAdd = function(go) self:_OnClickBtnAdd(self) end
    UIUtil.GetComponent(self._btnAdd, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnAdd);
    self._onClickBtnBuy = function(go) self:_OnClickBtnBuy(self) end
    UIUtil.GetComponent(self._btnBuy, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnBuy);
    self._onClickBtnCancle = function(go) self:_OnClickBtnCancle(self) end
    UIUtil.GetComponent(self._btnCancle, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnCancle);

    self._onClickInput = function(go) self:_OnClickInput(self) end
    UIUtil.GetComponent(self._goInput, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickInput);
end
 

function SaleBuyItemPanel:_OnClickBtnReduce()
    self._buyCount = self._buyCount - 1
    self:_CheckBuyCount()
    self:_SetBuyCount()
end

function SaleBuyItemPanel:_OnClickBtnAdd()
    self._buyCount = self._buyCount + 1
    self:_CheckBuyCount()
    self:_SetBuyCount()
end

function SaleBuyItemPanel:_OnClickBtnBuy()
    SaleProxy.SendBuySaleItem(self.data.spId, self._buyCount, self.data.price)
end

function SaleBuyItemPanel:_OnClickBtnCancle()
    ModuleManager.SendNotification(SaleNotes.CLOSE_SALEBUYITEMPANEL)
end

function SaleBuyItemPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function SaleBuyItemPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnReduce, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnReduce = nil;
    UIUtil.GetComponent(self._btnReduce, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnReduce = nil;
    UIUtil.GetComponent(self._btnAdd, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnAdd = nil;
    UIUtil.GetComponent(self._btnBuy, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnBuy = nil;
    UIUtil.GetComponent(self._btnCancle, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnCancle = nil;
    UIUtil.GetComponent(self._goInput, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickInput = nil;
end

function SaleBuyItemPanel:_DisposeReference()
    self._btnReduce = nil;
    self._btnAdd = nil;
    self._btnBuy = nil;
    self._btnCancle = nil;
    self._txtUseLevel = nil;
    self._txtTitle = nil;
    self._txtCount = nil;
    self._txtPrice = nil
    self._txtTotalPrice = nil
    self._goInput = nil
    self._imgIcon = nil
    self._imgQuality = nil
end

function SaleBuyItemPanel:UpdatePanel(data)
    self.data = data
    if (self.data) then
        self._txtUseLevel.text = tostring(self.data.configData.lev)
        self._txtPrice.text = tostring(self.data.price)
        self._txtTotalPrice.text = tostring(self.data.price * self._buyCount)
        self._txtTitle.text = self.data.configData.name
        self._txtNum.text = tostring(self.data.num)
        ProductManager.SetIconSprite(self._imgIcon, self.data.configData.icon_id)
        self._imgQuality.color = ColorDataManager.GetColorByQuality(self.data.configData.quality)
        self:_SetBuyCount()
    end
end

function SaleBuyItemPanel:_CheckBuyCount()
    if (self._buyCount > self.data.num) then
        self._buyCount = self.data.num
    end

    if (self._buyCount < 1) then
        self._buyCount = 1
    end
end

function SaleBuyItemPanel:_SetBuyCount()
    self._txtCount.text = tostring(self._buyCount)
    self._txtTotalPrice.text = tostring(self._buyCount * self.data.price)
end

function SaleBuyItemPanel:_OnClickInput()
    local res = { };
    res.hd = SaleBuyItemPanel._NumberKeyHandler;
    res.confirmHandler = SaleBuyItemPanel._ConfirmHandler;
    res.hd_target = self;
    res.x = 0;
    res.y = 130;
    res.label = self._txtCount

    ModuleManager.SendNotification(NumInputNotes.OPEN_NUMINPUT, res);
end

function SaleBuyItemPanel:_NumberKeyHandler(v)
    self._buyCount = tonumber(v)
    self:_SetBuyCount()
end

function SaleBuyItemPanel:_ConfirmHandler(v)
    self._buyCount = tonumber(v)
    self:_CheckBuyCount()
    self:_SetBuyCount()
end