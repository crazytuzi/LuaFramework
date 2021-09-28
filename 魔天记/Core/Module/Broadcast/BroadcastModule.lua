require "Core.Module.Pattern.BaseModule"
require "Core.Module.Broadcast.BroadcastMediator"
require "Core.Module.Broadcast.BroadcastProxy"
BroadcastModule = BaseModule:New();
BroadcastModule:SetModuleName("BroadcastModule");
function BroadcastModule:_Start()
	self:_RegisterMediator(BroadcastMediator);
	self:_RegisterProxy(BroadcastProxy);
end

function BroadcastModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

