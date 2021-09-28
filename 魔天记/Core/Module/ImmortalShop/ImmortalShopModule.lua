require "Core.Module.Pattern.BaseModule"
require "Core.Module.ImmortalShop.ImmortalShopProxy"
local ImmortalShopMediator = require "Core.Module.ImmortalShop.ImmortalShopMediator"
local ImmortalShopModule = BaseModule:New();
ImmortalShopModule:SetModuleName("ImmortalShopModule");
function ImmortalShopModule:_Start()
	self:_RegisterMediator(ImmortalShopMediator);
	self:_RegisterProxy(ImmortalShopProxy);
end

function ImmortalShopModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

return ImmortalShopModule