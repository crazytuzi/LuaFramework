require "Core.Module.Pattern.BaseModule"
require "Core.Module.Map.MapMediator"
require "Core.Module.Map.MapProxy"
MapModule = BaseModule:New();
MapModule:SetModuleName("MapModule");
function MapModule:_Start()
	self:_RegisterMediator(MapMediator);
	self:_RegisterProxy(MapProxy);
end

function MapModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

