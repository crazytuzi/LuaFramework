require "Core.Module.Common.UIComponent"
require "Core.Module.Common.StarItem"

RealmCompactProductItem = class("RealmCompactProductItem", UIComponent);

function RealmCompactProductItem:New(transform)
    self = { };
    setmetatable(self, { __index = RealmCompactProductItem });
    self._value = 0;
    self.total = 0;
    if (transform) then
        self:Init(transform);
    end
    return self
end

function RealmCompactProductItem:SetProductId(id, num)
    self.total = num or 0;
    self.id = id;
    self._info = ProductManager.GetProductInfoById(id, 1)
    self:_Refresh();
end

function RealmCompactProductItem:SetValue(val)
    self._value = val;
    self:_RefreshNum();
end

function RealmCompactProductItem:_Init()
    self:_InitReference();
    self:_InitListener();
end

function RealmCompactProductItem:AddClickListener(owner, handler)
    self._owner = owner;
    self._handler = handler;
end


function RealmCompactProductItem:_InitReference()
    self._imgQuality = UIUtil.GetComponent(self._transform, "UISprite")
    self._imgIcon = UIUtil.GetChildByName(self._transform, "UISprite", "imgIcon");
    self._txtNum = UIUtil.GetChildByName(self._transform, "UILabel", "txtNum");
    self:_Refresh();
end

function RealmCompactProductItem:_RefreshNum()
    if (self._txtNum) then

        if (self._value < self.total) then
            -- self._txtNum.text = ColorDataManager.GetColorTextByQuality(6, math.clamp(self._value, 0, self.total) .. "/" .. self.total);
            self._txtNum.text = ColorDataManager.GetColorTextByQuality(6, self._value .. "/" .. self.total);
        else
            -- self._txtNum.text = ColorDataManager.GetColorTextByQuality(1, math.clamp(self._value, 0, self.total) .. "/" .. self.total);
            self._txtNum.text = ColorDataManager.GetColorTextByQuality(1, self._value .. "/" .. self.total);
        end
    end
end

function RealmCompactProductItem:_Refresh()
    if (self._info) then
        self._imgQuality.color = ColorDataManager.GetColorByQuality(self._info.baseData.quality);
        ProductManager.SetIconSprite(self._imgIcon, self._info.baseData.icon_id)
        self:_RefreshNum();
        self._gameObject:SetActive(true)
    else
        self._gameObject:SetActive(false)
    end
end

function RealmCompactProductItem:_InitListener()
    self._onClickHandler = function(go) self:_OnClickHandler(self) end
    UIUtil.GetComponent(self._gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickHandler);
end

function RealmCompactProductItem:_OnClickHandler()
    if (self._info) then
        -- ModuleManager.SendNotification(ProductTipNotes.SHOW_BY_PRODUCT, { info = self._info, type = ProductCtrl.TYPE_FROM_OTHER });		
        ProductCtrl.ShowProductTip(self._info.spId, ProductCtrl.TYPE_FROM_OTHER, 1);
    end
end
  
function RealmCompactProductItem:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function RealmCompactProductItem:_DisposeListener()
    UIUtil.GetComponent(self._gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickHandler = nil
    self._owner = nil;
    self._handler = nil;
end

function RealmCompactProductItem:_DisposeReference()
    self._imgQuality = nil;
    self._imgIcon = nil;
    self._txtNum = nil;
end