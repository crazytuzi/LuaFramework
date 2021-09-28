require "Core.Module.Pattern.BaseModule";
require "Core.Module.Demo.DemoMediator";
require "Core.Module.Demo.DemoProxy";

DemoModule = BaseModule:New();
DemoModule:SetModuleName("DemoModule");
function DemoModule:_Start()
	self:_RegisterMediator(DemoMediator);	
	self:_RegisterProxy(DemoProxy);
end

function DemoModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end