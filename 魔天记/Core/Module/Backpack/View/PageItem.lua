require "Core.Module.Common.UIItem"
require "Core.Module.Backpack.View.ProductItem"


PageItem = class("PageItem", UIItem);

function PageItem:New()
    self = { };
    setmetatable(self, { __index = PageItem });
    return self
end

 
function PageItem:UpdateItem(data)
    self.data = data
end

function PageItem:Init(gameObject, data)
    self.gameObject = gameObject
    self.data = data
    self:UpdateItem(self.data);
    self._product_phalanx = UIUtil.GetChildByName(self.gameObject.transform, "LuaAsynPhalanx", "product_phalanx");

    local product_data = {
    }

    local index = 1;
    for i = 1, 5 do
        for j = 1, 5 do
            product_data[index] = { name = "name" .. index, id = index };
            index = index + 1;
        end
    end

    self.product_phalanx = Phalanx:New();
    self.product_phalanx:Init(self._product_phalanx, ProductItem);
    self.product_phalanx:Build(5, 5, product_data);


end

function PageItem:SetActive(v)
    self.gameObject.gameObject:SetActive(v);
end

function PageItem:_Dispose()

    self.gameObject = nil;

    self.data = nil;

    self.product_phalanx:Dispose();
    self.product_phalanx = nil;


    self._product_phalanx = nil;
end