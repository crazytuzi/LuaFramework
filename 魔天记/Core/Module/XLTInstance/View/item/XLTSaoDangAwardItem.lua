require "Core.Module.Common.UIItem"


XLTSaoDangAwardItem = class("XLTSaoDangAwardItem", UIItem);

function XLTSaoDangAwardItem:New()
    self = { };
    setmetatable(self, { __index = XLTSaoDangAwardItem });
    return self
end
 

function XLTSaoDangAwardItem:UpdateItem(data)
    self.data = data
end

function XLTSaoDangAwardItem:Init(gameObject, data)

    self.gameObject = gameObject;


    self.products = { };
    self.productCtrs = { };

    for i = 1, 5 do
        self.products[i] = UIUtil.GetChildByName(self.gameObject, "Transform", "product" .. i);
        self.productCtrs[i] = ProductCtrl:New();
        self.productCtrs[i]:Init(self.products[i], { hasLocke = true, use_sprite = true, iconType = ProductCtrl.IconType_rectangle }, true)
    end

    self:SetData(data);

end




function XLTSaoDangAwardItem:SetActive(v)
    self.gameObject.gameObject:SetActive(v);
end



function XLTSaoDangAwardItem:SetData(data)

    self.data = data;

    local len = table.getn(data);

    for i = 1, len do
        self.productCtrs[i]:SetData(data[i]);
    end

end


function XLTSaoDangAwardItem:_Dispose()
    self.gameObject = nil;


    for i = 1, 5 do
        self.products[i] = nil;
        self.productCtrs[i]:Dispose();
        self.productCtrs[i] = nil;
    end

end