require "Core.Module.Pattern.BaseModule"
require "Core.Module.NewTrump.NewTrumpMediator"
require "Core.Module.NewTrump.NewTrumpProxy"
NewTrumpModule = BaseModule:New();
NewTrumpModule:SetModuleName("NewTrumpModule");
function NewTrumpModule:_Start()
	self:_RegisterMediator(NewTrumpMediator);
	self:_RegisterProxy(NewTrumpProxy);
end

function NewTrumpModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

