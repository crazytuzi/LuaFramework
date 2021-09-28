require "Core.Module.Pattern.BaseModule"
require "Core.Module.Ride.RideMediator"
require "Core.Module.Ride.RideProxy"
RideModule = BaseModule:New();
RideModule:SetModuleName("RideModule");
function RideModule:_Start()
	self:_RegisterMediator(RideMediator);
	self:_RegisterProxy(RideProxy);
end

function RideModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

