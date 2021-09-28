require "Core.Module.Common.UIItem"
ActivityGiftsLimitBuyItem = class("ActivityGiftsLimitBuyItem", UIItem);

function ActivityGiftsLimitBuyItem:ctor(go, data)
    self:Init(go, data)
end

function ActivityGiftsLimitBuyItem:_Init()
    self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "name")
    self._txtNum = UIUtil.GetChildByName(self.transform, "UILabel", "num")
    self._txtDes = UIUtil.GetChildByName(self.transform, "UILabel", "des")
    self._imgQuality = UIUtil.GetChildByName(self.transform, "UISprite", "quality")
    self._imgIcon = UIUtil.GetChildByName(self.transform, "UISprite", "icon")
    self._btnCharge = UIUtil.GetChildByName(self.transform, "UIButton", "btncharge")
    self._hadChargeParent = UIUtil.GetChildByName(self.transform, "hadCharge")
    self._productInfo = ProductInfo:New()
    self._onClickIcon = function(go) self:_OnClickIcon(self) end
    UIUtil.GetComponent(self._imgIcon, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickIcon);
    self._onClickBtnCharge = function(go) self:_OnClickBtnCharge(self) end
    UIUtil.GetComponent(self._btnCharge, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnCharge);
end

function ActivityGiftsLimitBuyItem:_OnClickBtnCharge()
    if (VIPManager.GetSelfVIPLevel() >= self.data.vip_level) then   
        VIPManager.SendCharge(self.data.id, nil)
    else
        MsgUtils.ShowTips("ActivityGiftsLimitBuyItem/buyLimitVip", { lev = self.data.vip_level })
    end
end

function ActivityGiftsLimitBuyItem:_OnClickIcon()
    ModuleManager.SendNotification(ProductTipNotes.SHOW_BY_PRODUCT, { info = self._productInfo, type = ProductCtrl.TYPE_FROM_OTHER });
end

function ActivityGiftsLimitBuyItem:UpdateItem(data)
    self.data = data
    if (self.data) then
        if (self.data.num ~= nil) then
            self._btnCharge.gameObject:SetActive(self.data.num > 0)
            self._hadChargeParent.gameObject:SetActive(self.data.num <= 0)
            self._txtDes.text = self.data.gold_des
            self._txtName.text = self.data.product_name
            self._txtNum.text = self.data.rewardNum <= 1 and "" or tostring(self.data.rewardNum)
            self._productInfo:Init( { spId = self.data.rewardInfo.id })
            ProductManager.SetIconSprite(self._imgIcon, self.data.rewardInfo.icon_id)
            self._imgQuality.color = ColorDataManager.GetColorByQuality(self.data.rewardInfo.quality)

        else
            self._btnCharge.gameObject:SetActive(false)
            self._hadChargeParent.gameObject:SetActive(false)
        end
    end
end

function ActivityGiftsLimitBuyItem:_Dispose()
    UIUtil.GetComponent(self._btnCharge, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnCharge = nil;
    UIUtil.GetComponent(self._imgIcon, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickIcon = nil;
    self._txtName = nil
    self._txtNum = nil
    self._txtDes = nil
    self._imgQuality = nil
    self._imgIcon = nil
    self._btnCharge = nil
    self._hadChargeParent = nil
end