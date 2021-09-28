require "Core.Module.Pattern.BaseModule"
require "Core.Module.Compose.ComposeMediator"
require "Core.Module.Compose.ComposeProxy"
require "Core.Manager.Item.ComposeManager"

ComposeModule = BaseModule:New();
ComposeModule:SetModuleName("ComposeModule");
function ComposeModule:_Start()
	self:_RegisterMediator(ComposeMediator);
	self:_RegisterProxy(ComposeProxy);
end

function ComposeModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

