require "Core.Module.Pattern.BaseModule"
require "Core.Module.CloudPurchase.CloudPurchaseProxy"
local CloudPurchaseMediator = require "Core.Module.CloudPurchase.CloudPurchaseMediator"
local CloudPurchaseModule = BaseModule:New();
CloudPurchaseModule:SetModuleName("CloudPurchaseModule");
function CloudPurchaseModule:_Start()
	self:_RegisterMediator(CloudPurchaseMediator);
	self:_RegisterProxy(CloudPurchaseProxy);
end

function CloudPurchaseModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

return CloudPurchaseModule