require "Core.Module.Pattern.BaseModule"
require "Core.Module.CashGift.CashGiftProxy"
local CashGiftMediator = require "Core.Module.CashGift.CashGiftMediator"
local CashGiftModule = BaseModule:New();
CashGiftModule:SetModuleName("CashGiftModule");
function CashGiftModule:_Start()
	self:_RegisterMediator(CashGiftMediator);
	self:_RegisterProxy(CashGiftProxy);
end

function CashGiftModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

return CashGiftModule