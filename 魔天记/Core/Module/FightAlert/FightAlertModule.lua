require "Core.Module.Pattern.BaseModule"
require "Core.Module.FightAlert.FightAlertMediator"
require "Core.Module.FightAlert.FightAlertProxy"
FightAlertModule = BaseModule:New();
FightAlertModule:SetModuleName("FightAlertModule");
function FightAlertModule:_Start()
	self:_RegisterMediator(FightAlertMediator);
	self:_RegisterProxy(FightAlertProxy);
end

function FightAlertModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

