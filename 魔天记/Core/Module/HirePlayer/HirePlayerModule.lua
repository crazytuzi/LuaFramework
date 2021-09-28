require "Core.Module.Pattern.BaseModule"
require "Core.Module.HirePlayer.HirePlayerMediator"
require "Core.Module.HirePlayer.HirePlayerProxy"
HirePlayerModule = BaseModule:New();
HirePlayerModule:SetModuleName("HirePlayerModule");
function HirePlayerModule:_Start()
	self:_RegisterMediator(HirePlayerMediator);
	self:_RegisterProxy(HirePlayerProxy);
end

function HirePlayerModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

