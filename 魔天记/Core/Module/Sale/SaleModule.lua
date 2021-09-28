require "Core.Module.Pattern.BaseModule"
require "Core.Module.Sale.SaleMediator"
require "Core.Module.Sale.SaleProxy"
SaleModule = BaseModule:New();
SaleModule:SetModuleName("SaleModule");
function SaleModule:_Start()
	self:_RegisterMediator(SaleMediator);
	self:_RegisterProxy(SaleProxy);
end

function SaleModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

