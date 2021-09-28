require "Core.Module.Common.UIItem"

SubRefineMaterialItem = class("SubRefineMaterialItem", UIItem);

function SubRefineMaterialItem:New()
    self = { };
    setmetatable(self, { __index = SubRefineMaterialItem });
    return self
end
 
function SubRefineMaterialItem:_Init()
    self:_InitReference();
    self:UpdateItem(self.data)
end

function SubRefineMaterialItem:UpdateItem(data)
    self.data = data

    if (self.data) then

        self._productInfo = ProductInfo:New()
        self._productInfo:Init( { spId = data.id })
        local itemData = ProductManager.GetProductById(data.id)
        ProductManager.SetIconSprite(self._imgIcon, itemData.icon_id)
        self._imgQuality.color = ColorDataManager.GetColorByQuality(itemData.quality)
        self._txtCount.text = BackpackDataManager.GetProductTotalNumBySpid(data.id) .. "/" .. data.count
    else
        self._productInfo = nil
        self._imgIcon.spriteName = ""
        self._imgQuality.spriteName = ""
        self._txtCount.text = ""
    end
end

function SubRefineMaterialItem:_InitReference()
    self._imgIcon = UIUtil.GetChildByName(self.gameObject, "UISprite", "icon")
    self._imgQuality = UIUtil.GetChildByName(self.gameObject, "UISprite", "icon_quality")
    self._txtCount = UIUtil.GetChildByName(self.gameObject, "UILabel", "count")
    self._onClickItem = function(go) self:_OnClickItem(self) end
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickItem);
end

function SubRefineMaterialItem:_Dispose()
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickItem = nil;
end

function SubRefineMaterialItem:_OnClickItem()
    if (self._productInfo) then

        ModuleManager.SendNotification(ProductTipNotes.SHOW_BY_PRODUCT, { info = self._productInfo, type = ProductCtrl.TYPE_FROM_OTHER });
    end
end