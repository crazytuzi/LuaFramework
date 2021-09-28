require "Core.Manager.Item.EquipDataManager"
local EquipQualityEffect = require "Core.Module.Common.EquipQualityEffect"

ProductCostPanelCtrl = { };

-- 装备格子容器管理器

function ProductCostPanelCtrl:New()
    local o = { };
    setmetatable(o, { __index = self });
    return o;
end

function ProductCostPanelCtrl:Init(gameObject, index)

    self.gameObject = gameObject
    self._lockedBg = UIUtil.GetChildByName(self.gameObject, "lockedBg").gameObject;
    self._icon = UIUtil.GetChildByName(self.gameObject, "UISprite", "icon");
    self._icon_quality = UIUtil.GetChildByName(self.gameObject, "UISprite", "icon_quality");
    self._numLabel = UIUtil.GetChildByName(self.gameObject, "UILabel", "numLabel");
    self._icon_select = UIUtil.GetChildByName(self.gameObject, "UISprite", "icon_select");

     self._uiEffect = UIUtil.GetChildByName(self.gameObject, "UISprite", "uiEffect");
    if self._uiEffect ~= nil then
        self._uiEffect.gameObject:SetActive(false);
    end

    self.kind = index;
    self._eqQualityspecEffect = EquipQualityEffect:New();

    self:SetLock(false);
    self:Selected(false);

end

function ProductCostPanelCtrl:SetOnClickBtnHandler(handler)

    self._selectHandler = handler;
    self._onClickBtn = function(go) self:_OnClickBtn(self) end
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn);
end

function ProductCostPanelCtrl:Selected(v)
    self._icon_select.gameObject:SetActive(v);
end

function ProductCostPanelCtrl:SetLock(v)
    self.lock = v;
    self._lockedBg:SetActive(v);
end

function ProductCostPanelCtrl:SetData(equip_lv_data)
    self.equip_lv_data = equip_lv_data;

    --  需要获取装备栏里的 对应装备
    local productInfo = EquipDataManager.GetProductByIdx(self.equip_lv_data.idx - 1);

    self:SetProduct(productInfo);






end

function ProductCostPanelCtrl:TryCheckEqQualityspecEffect(info)

    self._eqQualityspecEffect:StopEffect();

    if info ~= nil then
        local quality = info:GetQuality();
        local type = info:GetType();

          if self._uiEffect == nil then
            self._eqQualityspecEffect:TryCheckEquipQualityEffect(self.gameObject.transform, self._icon, type, quality);
        else
            self._eqQualityspecEffect:TryCheckEquipQualityEffectForUISprite(self._uiEffect, type, quality);
        end

    end

end

function ProductCostPanelCtrl:SetProduct(productInfo)

    self._productInfo = productInfo;

    self:TryCheckEqQualityspecEffect(productInfo);

    if self._productInfo ~= nil then


        ProductManager.SetIconSprite(self._icon, self._productInfo:GetIcon_id());

        self._icon.gameObject:SetActive(true);

        local quality = self._productInfo:GetQuality();
        -- self._icon_quality.spriteName =ProductManager.GetQulitySpriteName(quality);
        self._icon_quality.color = ColorDataManager.GetColorByQuality(quality);
        self._icon_quality.gameObject:SetActive(true);

        local am = self._productInfo:GetAm();

        if am > 1 then
            self._numLabel.text = "" .. am;
        else
            self._numLabel.text = "";
        end


        self:SetLock(false);

    else
        self._icon.gameObject:SetActive(false);
        self._numLabel.text = "";
        self._icon_quality.gameObject:SetActive(false);

        self:SetLock(true);

    end

end

function ProductCostPanelCtrl:_OnClickBtn()

    if self._selectHandler ~= nil then
        self._selectHandler(self);
    end

end

function ProductCostPanelCtrl:Dispose()

    if self._onClickBtn ~= nil then
        UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
        self._onClickBtn = nil;
    end

    if (self._eqQualityspecEffect) then
        self._eqQualityspecEffect:Dispose()
        self._eqQualityspecEffect = nil
    end

    self.gameObject = nil;
    self._lockedBg = nil;
    self._icon = nil;
    self._icon_quality = nil;
    self._numLabel = nil;
    self._icon_select = nil;

    self._selectHandler = nil;
end

