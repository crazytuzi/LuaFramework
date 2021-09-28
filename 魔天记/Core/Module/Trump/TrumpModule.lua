require "Core.Module.Pattern.BaseModule"
require "Core.Module.Trump.TrumpMediator"
require "Core.Module.Trump.TrumpProxy"
TrumpModule = BaseModule:New();
TrumpModule:SetModuleName("TrumpModule");
function TrumpModule:_Start()
	self:_RegisterMediator(TrumpMediator);
	self:_RegisterProxy(TrumpProxy);
end

function TrumpModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

