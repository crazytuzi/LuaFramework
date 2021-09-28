require "Core.Module.Pattern.BaseModule"
require "Core.Module.WorldBoss.WorldBossMediator"
require "Core.Module.WorldBoss.WorldBossProxy"
WorldBossModule = BaseModule:New();
WorldBossModule:SetModuleName("WorldBossModule");
function WorldBossModule:_Start()
	self:_RegisterMediator(WorldBossMediator);
	self:_RegisterProxy(WorldBossProxy);
end

function WorldBossModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

