local EquipQualityEffect = require "Core.Module.Common.EquipQualityEffect"

PropsItem = class("PropsItem");

function PropsItem:Init(gameObject, data)
    self.gameObject = gameObject;
    self.transform = gameObject.transform;
    self.data = data;
    self:_Init();
end

function PropsItem:_Init()


    self._lockedBg = UIUtil.GetChildByName(self.gameObject, "lockedBg");
    self:SetLock(false);

    self._icon = UIUtil.GetChildByName(self.gameObject, "UISprite", "icon");
    self._icon_quality = UIUtil.GetChildByName(self.gameObject, "UISprite", "icon_quality");
    self._numLabel = UIUtil.GetChildByName(self.gameObject, "UILabel", "numLabel");

    self.icoLocal = UIUtil.GetChildByName(self.gameObject, "UISprite", "icoLocal");
    if self.icoLocal then
        self.icoLocal.alpha = 0;
    end

    self._icon_select = UIUtil.GetChildByName(self.gameObject, "UISprite", "icon_select");
    self:Selected(false);

     self._uiEffect = UIUtil.GetChildByName(self.gameObject, "UISprite", "uiEffect");
    if self._uiEffect ~= nil then
        self._uiEffect.gameObject:SetActive(false);
    end

    self._eqQualityspecEffect = EquipQualityEffect:New();

    self._onClick = function(go) self:_OnClick(self) end
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClick);

    self:_InitReference();
    self:UpdateItem(self.data);
end

function PropsItem:AddBoxCollider()
    local bc = UIUtil.GetComponent(self.gameObject, "BoxCollider");
    if (bc) then
        bc.center = Vector3.zero;
        bc.size = Vector3.New(90, 90, 0);
    end
end

function PropsItem:_InitReference()

end

function PropsItem:SetVisible(val)
    if self.gameObject then self.gameObject:SetActive(val) end
end

function PropsItem:GetData()
    return self.data;
end

function PropsItem:Selected(v)
    if self._icon_select then
        self._icon_select.gameObject:SetActive(v);
    end
end

function PropsItem:SetLock(v)
    if self._lockedBg ~= nil then
        self.lock = v;
        self._lockedBg.gameObject:SetActive(v);
    end
end

function PropsItem:UpdateItem(data)
    self.data = data;
    self:UpdateDisplay();
    self:TryCheckEqQualityspecEffect(data)
end

function PropsItem:SetClassType(type)
  self.ctype = type;

end 

function PropsItem:TryCheckEqQualityspecEffect(info)
   
   if self._eqQualityspecEffect == nil then
     return ;
   end 

    self._eqQualityspecEffect:StopEffect();
    if info ~= nil then
        local quality = info:GetQuality();
        local type = info:GetType();
      

        if self._uiEffect == nil then
            self._eqQualityspecEffect:TryCheckEquipQualityEffect(self.transform, self._icon_quality, type, quality);
        else
            self._eqQualityspecEffect:TryCheckEquipQualityEffectForUISprite(self._uiEffect, type, quality);
        end

    end

end


function PropsItem:Dispose()
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClick = nil;

    if (self._eqQualityspecEffect) then
        self._eqQualityspecEffect:Dispose()
        self._eqQualityspecEffect = nil
    end

    self:_Dispose();
end

function PropsItem:_Dispose()

end

function PropsItem:_OnClick()
    if self.data ~= nil then
       
        if self.ctype == 4 then
          self.data.suitAttInvented = {show=true};
        else
         self.data.suitAttInvented = nil;
        end 

        ModuleManager.SendNotification(ProductTipNotes.SHOW_BY_PRODUCT, { info = self.data, type = ProductCtrl.TYPE_FROM_OTHER });
        SequenceManager.TriggerEvent(SequenceEventType.Guide.PROPS_SHOW_TIPS, self.data);
    end
end

function PropsItem:UpdateDisplay()
    if self.data ~= nil then
        self._icon.gameObject:SetActive(true);
        self._icon_quality.gameObject:SetActive(true);
        local quality = self.data:GetQuality();
        ProductManager.SetIconSprite(self._icon, self.data:GetIcon_id());
        self._icon_quality.color = ColorDataManager.GetColorByQuality(quality);
        -- self._icon_quality.spriteName = ProductManager.GetQulitySpriteName(quality);

        if self.icoLocal then
            self.icoLocal.alpha = self.data:IsBind() and 1 or 0;
        end

        if self._numLabel then
            local am = self.data:GetAm();
            if am > 1 then
                if am > 99999999 then
                    am = LanguageMgr.Get("common/am/yi", { num = math.floor(am / 10000000) / 10 });
                elseif am > 9999 then
                    am = LanguageMgr.Get("common/am/wan", { num = math.floor(am / 10000) });
                end
                self._numLabel.text = am;
            else
                self._numLabel.text = "";
            end
        end
    else
        self._icon.gameObject:SetActive(false);
        self._icon_quality.gameObject:SetActive(false);
        if self._numLabel then
            self._numLabel.text = "";
        end
        if self.icoLocal then
            self.icoLocal.alpha = 0;
        end
    end


end