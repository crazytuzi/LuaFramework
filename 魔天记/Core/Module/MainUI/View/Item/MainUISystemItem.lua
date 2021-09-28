require "Core.Module.Common.UIItem"

MainUISystemItem = UIItem:New();

function MainUISystemItem:_Init()
    self._icon = UIUtil.GetChildByName(self.transform, "UISprite", "icon");
    self._hasMsg = UIUtil.GetChildByName(self.transform, "UISprite", "hasMsg");
    self._onClick = function(go) self:_OnClick() end
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClick);
    self:SetHasMsgFlg(false)
    self:UpdateItem(self.data);
end

function MainUISystemItem:SetHasMsgFlg(val)
    --Warning("id="..self.id .. ",icon=" ..self.data.icon ..",val="..tostring(val))
    self._hasMsg.enabled = val
end

function MainUISystemItem:GetId()
    return self.id
end

function MainUISystemItem:_Dispose()
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClick = nil;
    if self._effect then
        Resourcer.Recycle(self._effect, false)
        self._effect = nil;
    end
end

function MainUISystemItem:_OnClick()
    if self.data then
        MessageManager.Dispatch(MainUINotes, MainUINotes.EVENT_SYSITEM_CLICK, self.data);
    end
end

function MainUISystemItem:UpdateItem(data)
    self.data = data    
    if self.data == nil then
        self._icon.spriteName = "";
    else
        self.gameObject.name = data.id; 
        self._icon.spriteName = data.icon;
        self.id = data.id

        if self._effect then
            if self:NeedShowEffect() == false then
                Resourcer.Recycle(self._effect, false)
                self._effect = nil;
            end
        elseif self:NeedShowEffect() then
            self._effect = UIUtil.GetUIEffect("ui_rot", self._icon.transform, nil);
            --[[
            if self._effect then
                UIUtil.AddEffectAnchor(self._effect, self._icon, 1);
            end
            ]]
        end
    end
end

function MainUISystemItem:NeedShowEffect()
    if self.data.id == SystemConst.Id.FIRSTRECHARGEAWARD
        or self.data.id == SystemConst.Id.RechargeAward
        or self.data.id == SystemConst.Id.DaysTarget
        or self.data.id == SystemConst.Id.MidAutumn
        or self.data.id == SystemConst.Id.CloudPurchase
        or self.data.id == SystemConst.Id.CashGift
        then
        return true;
    elseif self.data.id == SystemConst.Id.Group_1 or self.data.id == SystemConst.Id.DAYSRANK then
        return DaysRankManager.displayInToday;
    end
    return false;
end
