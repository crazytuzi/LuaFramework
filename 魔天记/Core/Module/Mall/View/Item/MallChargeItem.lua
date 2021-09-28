require "Core.Module.Common.UIComponent"

MallChargeItem = class("MallChargeItem", UIComponent);
function MallChargeItem:New(trs)
    self = { };
    setmetatable(self, { __index = MallChargeItem });
    if (trs) then self:Init(trs) end
    return self
end


function MallChargeItem:_Init()
    self:_InitReference();
    self:_InitListener();
end

function MallChargeItem:_InitReference()
    self._txtTop = UIUtil.GetChildByName(self._gameObject, "UILabel", "txtTop");
    self._txtMiddle = UIUtil.GetChildByName(self._gameObject, "UILabel", "txtMiddle");
    self._txtBottom = UIUtil.GetChildByName(self._gameObject, "UILabel", "txtBottom");
    self._imgIcon = UIUtil.GetChildByName(self._gameObject, "UISprite", "imgIcon");
    self._trsFlg = UIUtil.GetChildByName(self._gameObject, "Transform", "trsFlg");
    self._trsFlg.gameObject:SetActive(false)
end

function MallChargeItem:InitData(config, first, recommend)
    self.config = config
    self._txtMiddle.text = LanguageMgr.Get("Mall/Charge/price") .. config.rmb .. LanguageMgr.Get("Mall/Charge/yuang")
    self._txtBottom.text = config.gold_des
    self._imgIcon.spriteName = config.icon
    self._imgIcon:MakePixelPerfect()
    self:UpdateData(config, first, recommend)
end

function MallChargeItem:UpdateData(config, first, recommend)
    self._txtTop.text = first and config.first_des or config.bind_des
    self._trsFlg.gameObject:SetActive(recommend)
end

function MallChargeItem:_InitListener()
    self._onClickItem = function(go) self:_OnClickItem(self) end
    UIUtil.GetComponent(self._gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickItem);
end

function MallChargeItem:_OnClickItem()
    --    if (GameConfig.instance.useSdk) then
    --        MallProxy.SendCharge(self.config.id)
    --    else
    -- VIPManager.SendCharge(self.config.id, MallChargeItem.BuySuccess)
    --    end
    local t = self.config.type
    if t == ChargeType.normal or t == ChargeType.month then
        VIPManager.SendCharge(self.config.id, MallChargeItem.BuySuccess)
    elseif t == ChargeType.gack then
        local fun = function(d)
            VIPManager.SendCharge(self.config.id, MallChargeItem.BuySuccess)
        end
        local ads = ProductInfo.GetProductInfos(self.config.reward)
        ModuleManager.SendNotification(MallNotes.SHOW_PRODUCT_PACK_PANEL,
            { fun = fun, ads = ads, des = LanguageMgr.Get("ProductPackPanel/des")})
    end
end

function MallChargeItem:Select(f)
    --Warning(self.config.id .. '----' .. tostring(f))
    if not self._effectGo then
        self._effectGo = UIUtil.GetChildByName(self._gameObject, "Transform", "select").gameObject
    end
    self._effectGo:SetActive(f)
end

function MallChargeItem.BuySuccess(id)
    MessageManager.Dispatch(VIPManager, VIPManager.BuySuccess, id)
    --    ModuleManager.SendNotification(MallNotes.UPDATE_MALLPANEL)
end

function MallChargeItem:_Dispose()
    self:_DisposeReference();
end

function MallChargeItem:_DisposeReference()
    self._txtTop = nil;
    self._txtMiddle = nil;
    self._txtBottom = nil;
    self._imgIcon = nil;
    self._trsFlg = nil;
end
