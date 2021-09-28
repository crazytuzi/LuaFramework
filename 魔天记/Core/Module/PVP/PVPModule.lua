require "Core.Module.Pattern.BaseModule"
require "Core.Module.PVP.PVPMediator"
require "Core.Module.PVP.PVPProxy"
PVPModule = BaseModule:New();
PVPModule:SetModuleName("PVPModule");
function PVPModule:_Start()
	self:_RegisterMediator(PVPMediator);
	self:_RegisterProxy(PVPProxy);
end

function PVPModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

