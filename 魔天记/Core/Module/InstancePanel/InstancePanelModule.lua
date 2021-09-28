require "Core.Module.Pattern.BaseModule"
require "Core.Module.InstancePanel.InstancePanelMediator"
require "Core.Module.InstancePanel.InstancePanelProxy"
InstancePanelModule = BaseModule:New();
InstancePanelModule:SetModuleName("InstancePanelModule");
function InstancePanelModule:_Start()
	self:_RegisterMediator(InstancePanelMediator);
	self:_RegisterProxy(InstancePanelProxy);
end

function InstancePanelModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

