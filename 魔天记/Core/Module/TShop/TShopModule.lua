require "Core.Module.Pattern.BaseModule"
require "Core.Module.TShop.TShopMediator"
require "Core.Module.TShop.TShopProxy"
TShopModule = BaseModule:New();
TShopModule:SetModuleName("TShopModule");
function TShopModule:_Start()
	self:_RegisterMediator(TShopMediator);
	self:_RegisterProxy(TShopProxy);
end

function TShopModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

