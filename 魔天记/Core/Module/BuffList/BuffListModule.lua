require "Core.Module.Pattern.BaseModule"
require "Core.Module.BuffList.BuffListProxy"
require "Core.Module.BuffList.BuffListMediator"
BuffListModule = BaseModule:New();
BuffListModule:SetModuleName("BuffListModule");
function BuffListModule:_Start()
	self:_RegisterMediator(BuffListMediator);
	self:_RegisterProxy(BuffListProxy);
end

function BuffListModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end