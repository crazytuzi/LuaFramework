require "Core.Module.Pattern.BaseModule"
require "Core.Module.ProductTip.ProductTipMediator"
require "Core.Module.ProductTip.ProductTipProxy"
ProductTipModule = BaseModule:New();
ProductTipModule:SetModuleName("ProductTipModule");
function ProductTipModule:_Start()
	self:_RegisterMediator(ProductTipMediator);
	self:_RegisterProxy(ProductTipProxy);
end

function ProductTipModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

