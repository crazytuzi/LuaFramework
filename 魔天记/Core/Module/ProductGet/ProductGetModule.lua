require "Core.Module.Pattern.BaseModule"
require "Core.Module.ProductGet.ProductGetProxy"
local ProductGetMediator = require "Core.Module.ProductGet.ProductGetMediator"
ProductGetModule = BaseModule:New();
ProductGetModule:SetModuleName("ProductGetModule");
function ProductGetModule:_Start()
	self:_RegisterMediator(ProductGetMediator);
	self:_RegisterProxy(ProductGetProxy);
end

function ProductGetModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

return ProductGetModule