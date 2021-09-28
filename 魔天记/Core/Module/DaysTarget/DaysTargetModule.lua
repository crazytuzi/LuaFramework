require "Core.Module.Pattern.BaseModule"
require "Core.Module.DaysTarget.DaysTargetMediator"
require "Core.Module.DaysTarget.DaysTargetProxy"
--require "Core.Module.DaysTarget.DaysTargetManager"

DaysTargetModule = BaseModule:New();
DaysTargetModule:SetModuleName("DaysTargetModule");
function DaysTargetModule:_Start()
	self:_RegisterMediator(DaysTargetMediator);
	self:_RegisterProxy(DaysTargetProxy);
end

function DaysTargetModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

