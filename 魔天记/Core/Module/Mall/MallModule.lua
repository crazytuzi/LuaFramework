require "Core.Module.Pattern.BaseModule"
require "Core.Module.Mall.MallMediator"
require "Core.Module.Mall.MallProxy"
MallModule = BaseModule:New();
MallModule:SetModuleName("MallModule");
function MallModule:_Start()
	self:_RegisterMediator(MallMediator);
	self:_RegisterProxy(MallProxy);
end

function MallModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

