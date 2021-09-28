require "Core.Module.Common.UIItem"
require "Core.Module.TShop.View.ProductInfoCtr"


ShopPageItem = class("ShopPageItem", UIItem);
ShopPageItem.currSelect = nil;

function ShopPageItem:New()
    self = { };
    setmetatable(self, { __index = ShopPageItem });
    return self
end


 
function ShopPageItem:UpdateItem(data)
    self.data = data

    if data~=nil and  data.isInit == nil then
     self.itemCtrs:SetData(data);

     else
      self.itemCtrs:SetData(nil);
    end

end

function ShopPageItem:Init(gameObject, data)
    self.gameObject = gameObject
    self.data = data
   
    self.itemCtrs = ProductInfoCtr:New();
     self.itemCtrs:Init(self.gameObject.transform, nil);
     self.itemCtrs:SetClickHandler(ShopPageItem.itemClickHandler, self)

     self:UpdateItem(data)
end

function ShopPageItem:SetSelect(v)
   
   if v then
     self:itemClickHandler(self.itemCtrs)
   end

end

function ShopPageItem:itemClickHandler(target)

     if ShopPageItem.currSelect ~= nil then
        ShopPageItem.currSelect.itemCtrs:SetSelect(false);
     end

     ShopPageItem.currSelect = self;

    ShopPageItem.currSelect.itemCtrs:SetSelect(true);
     MessageManager.Dispatch(ShopProItem, ShopProItem.MESSAGE_PRODUCT_SELECT,target.curr_info);


end



function ShopPageItem:_Dispose()
   

     self.gameObject = nil;
   

end

