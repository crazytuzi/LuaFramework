require "Core.Module.Pattern.BaseModule"
require "Core.Module.WildBoss.WildBossMediator"
require "Core.Module.WildBoss.WildBossProxy"
WildBossModule = BaseModule:New();
WildBossModule:SetModuleName("WildBossModule");
function WildBossModule:_Start()
	self:_RegisterMediator(WildBossMediator);
	self:_RegisterProxy(WildBossProxy);
end

function WildBossModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

