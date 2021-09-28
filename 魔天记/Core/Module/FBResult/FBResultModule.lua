require "Core.Module.Pattern.BaseModule"
require "Core.Module.FBResult.FBResultMediator"
require "Core.Module.FBResult.FBResultProxy"
FBResultModule = BaseModule:New();
FBResultModule:SetModuleName("FBResultModule");
function FBResultModule:_Start()
	self:_RegisterMediator(FBResultMediator);
	self:_RegisterProxy(FBResultProxy);
end

function FBResultModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

