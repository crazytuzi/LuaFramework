require "Core.Module.Pattern.BaseModule"
require "Core.Module.ConvenientUse.ConvenientUseMediator"
require "Core.Module.ConvenientUse.ConvenientUseProxy"
ConvenientUseModule = BaseModule:New();
ConvenientUseModule:SetModuleName("ConvenientUseModule");
function ConvenientUseModule:_Start()
	self:_RegisterMediator(ConvenientUseMediator);
	self:_RegisterProxy(ConvenientUseProxy);
end

function ConvenientUseModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

