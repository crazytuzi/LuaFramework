require "Core.Module.Pattern.BaseModule"
require "Core.Module.Promote.PromoteMediator"
require "Core.Module.Promote.PromoteProxy"
PromoteModule = BaseModule:New();
PromoteModule:SetModuleName("PromoteModule");
function PromoteModule:_Start()
	self:_RegisterMediator(PromoteMediator);
	self:_RegisterProxy(PromoteProxy);
end

function PromoteModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

