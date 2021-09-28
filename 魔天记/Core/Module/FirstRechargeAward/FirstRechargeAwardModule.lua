require "Core.Module.Pattern.BaseModule"
require "Core.Module.FirstRechargeAward.FirstRechargeAwardMediator"
require "Core.Module.FirstRechargeAward.FirstRechargeAwardProxy"
FirstRechargeAwardModule = BaseModule:New();
FirstRechargeAwardModule:SetModuleName("FirstRechargeAwardModule");
function FirstRechargeAwardModule:_Start()
	self:_RegisterMediator(FirstRechargeAwardMediator);
	self:_RegisterProxy(FirstRechargeAwardProxy);
end

function FirstRechargeAwardModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

