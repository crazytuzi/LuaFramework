require "Core.Module.Pattern.BaseModule"
require "Core.Module.XMBoss.XMBossMediator"
require "Core.Module.XMBoss.XMBossProxy"
XMBossModule = BaseModule:New();
XMBossModule:SetModuleName("XMBossModule");
function XMBossModule:_Start()
	self:_RegisterMediator(XMBossMediator);
	self:_RegisterProxy(XMBossProxy);
end

function XMBossModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

