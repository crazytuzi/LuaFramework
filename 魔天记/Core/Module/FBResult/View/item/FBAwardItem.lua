require "Core.Module.Common.UIItem"


FBAwardItem = class("FBAwardItem", UIItem);

function FBAwardItem:New()
    self = { };
    setmetatable(self, { __index = FBAwardItem });
    return self
end
 

function FBAwardItem:UpdateItem(data)
    self.data = data
end

function FBAwardItem:Init(gameObject, data)

    self.gameObject = gameObject;
    self.product = UIUtil.GetChildByName(self.gameObject, "Transform", "product");


    self._productCtrls = ProductCtrl:New();
    self._productCtrls:Init(self.product, { hasLocke = true, use_sprite = true, iconType = ProductCtrl.IconType_rectangle });
  --  self._productCtrls:SetOnClickBtnHandler(ProductCtrl.TYPE_FROM_OTHER);

    self:SetData(data)
end



function FBAwardItem:SetActive(v)
    self.gameObject.gameObject:SetActive(v);
end



function FBAwardItem:SetData(data)

    self._productCtrls:SetData(data);
end



function FBAwardItem:_Dispose()

    if self._productCtrls ~= nil then
        self._productCtrls:Dispose()
        self._productCtrls = nil;
    end

    self.gameObject = nil;
    self.product = nil;
end