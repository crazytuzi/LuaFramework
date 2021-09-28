require "Core.Module.Pattern.BaseModule"
require "Core.Module.BusyLoading.BusyLoadingMediator"
require "Core.Module.BusyLoading.BusyLoadingProxy"
BusyLoadingModule = BaseModule:New();
BusyLoadingModule:SetModuleName("BusyLoadingModule");
function BusyLoadingModule:_Start()
	self:_RegisterMediator(BusyLoadingMediator);
	self:_RegisterProxy(BusyLoadingProxy);
end

function BusyLoadingModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

