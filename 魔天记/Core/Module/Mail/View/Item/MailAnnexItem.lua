require "Core.Module.Common.UIItem"
require "Core.Module.Common.ProductCtrl"

MailAnnexItem = UIItem:New();

function MailAnnexItem:_Init()
    self._productCtrl = ProductCtrl:New();
    self._productCtrl:Init(self.gameObject);
    self:UpdateItem(self.data);

    self._productCtrl:SetOnClickBtnHandler(ProductCtrl.TYPE_FROM_OTHER);
end

function MailAnnexItem:UpdateItem(data)
    self.data = data
    self:SetData(data);
end

function MailAnnexItem:SetData(productInfo)
    self._productCtrl:SetData(productInfo);
end

