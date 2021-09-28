require "Core.Module.Pattern.BaseModule"
require "Core.Module.Countdown.CountdownMediator"
require "Core.Module.Countdown.CountdownProxy"
CountdownModule = BaseModule:New();
CountdownModule:SetModuleName("CountdownModule");
function CountdownModule:_Start()
	self:_RegisterMediator(CountdownMediator);
	self:_RegisterProxy(CountdownProxy);
end

function CountdownModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

