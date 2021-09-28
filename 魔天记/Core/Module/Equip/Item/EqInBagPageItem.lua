require "Core.Module.Common.UIItem"
require "Core.Module.Equip.Item.EqInBagProductItem"

EqInBagPageItem = UIItem:New();
 
function EqInBagPageItem:UpdateItem(data)
    self.data = data
end

function EqInBagPageItem:Init(gameObject, data)
    self.gameObject = gameObject
    self.data = data
    self:UpdateItem(self.data);
    self._product_phalanx = UIUtil.GetChildByName(self.gameObject.transform, "LuaAsynPhalanx", "product_phalanx");

    local product_data = {
    }

    local w_num = 5;
    local index = 1;
    for i = 1, 2 do
        for j = 1, w_num do
            product_data[index] = { name = "name" .. index, id = index };
            index = index + 1;
        end
    end

    self.product_phalanx = Phalanx:New();
    self.product_phalanx:Init(self._product_phalanx, EqInBagProductItem);
    self.product_phalanx:Build(2, w_num, product_data);
end


function EqInBagPageItem:SetActive(v)

    self.gameObject.gameObject:SetActive(v);

end

function EqInBagPageItem:_Dispose()
    self.gameObject = nil;

    self.data = nil;

    self.product_phalanx:Dispose();
    self.product_phalanx = nil;
    self._product_phalanx = nil;
end