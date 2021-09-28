require "Core.Module.Pattern.BaseModule"
require "Core.Module.AutoFight.AutoFightMediator"
require "Core.Module.AutoFight.AutoFightProxy"
AutoFightModule = BaseModule:New();
AutoFightModule:SetModuleName("AutoFightModule");
function AutoFightModule:_Start()
	self:_RegisterMediator(AutoFightMediator);
	self:_RegisterProxy(AutoFightProxy);
end

function AutoFightModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

