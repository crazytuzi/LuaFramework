require "Core.Module.Pattern.BaseModule"
require "Core.Module.RechargeAward.RechargeAwardProxy"
local RechargeAwardMediator = require "Core.Module.RechargeAward.RechargeAwardMediator"
local RechargeAwardModule = BaseModule:New();
RechargeAwardModule:SetModuleName("RechargeAwardModule");
function RechargeAwardModule:_Start()
	self:_RegisterMediator(RechargeAwardMediator);
	self:_RegisterProxy(RechargeAwardProxy);
end

function RechargeAwardModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

return RechargeAwardModule