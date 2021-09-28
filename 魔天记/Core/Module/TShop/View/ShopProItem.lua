require "Core.Module.Common.UIItem"

require "Core.Module.TShop.View.items.ShopPageItem"

ShopProItem = class("ShopProItem", UIItem);

function ShopProItem:New()
    self = { };
    setmetatable(self, { __index = ShopProItem });
    return self
end

ShopProItem.MESSAGE_PRODUCT_SELECT = "MESSAGE_PRODUCT_SELECT";
 
function ShopProItem:UpdateItem(data)
    self.data = data
    
    self:SetProductData(data);
end

function ShopProItem:Init(gameObject, data)
    self.gameObject = gameObject
    self.data = data
   

     self.items_phala = UIUtil.GetChildByName(self.gameObject.transform, "LuaAsynPhalanx", "items_phalanx");
     self.pag_phalanx = Phalanx:New();
    self.pag_phalanx:Init(self.items_phala, ShopPageItem)

    local arr = { {isInit=true}, {isInit=true}, {isInit=true}, {isInit=true}, {isInit=true}, {isInit=true}, {isInit=true}, {isInit=true}, {isInit=true}, {isInit=true} };

     self.pag_phalanx:Build(5, 2, arr);

    

     self:UpdateItem(self.data);
end


function ShopProItem:SetDefSelect()

 local target = self.pag_phalanx._items[1].itemLogic;
  target:SetSelect(true);
-- MessageManager.Dispatch(ShopProItem, ShopProItem.MESSAGE_PRODUCT_SELECT,target.curr_info);
end

function ShopProItem:SetSelectById(id)
    local items = self.pag_phalanx._items;
    for i,v in pairs(items) do
        local logic = v.itemLogic;
        if (logic.data and logic.data.product_id == id) then
            logic:SetSelect(true);
            return true
        end
    end
    return false;
end

function ShopProItem:SetProductData(infos)


    if infos == nil then
        self.gameObject.gameObject:SetActive(false);
    else
       

       local items = self.pag_phalanx._items;
       
        for i = 1, 10 do
           items[i].itemLogic:UpdateItem(infos[i]);
        end

        self.gameObject.gameObject:SetActive(true);
    end


end

function ShopProItem:_Dispose()
   
    self.pag_phalanx:Dispose();
    self.pag_phalanx = nil;
     self.gameObject = nil;
    self.data = nil;
   

 
    ShopPageItem.currSelect = nil;

end

