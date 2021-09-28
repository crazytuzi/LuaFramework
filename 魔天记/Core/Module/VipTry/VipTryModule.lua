require "Core.Module.Pattern.BaseModule"
require "Core.Module.VipTry.VipTryProxy"
local VipTryMediator = require "Core.Module.VipTry.VipTryMediator"
local VipTryModule = BaseModule:New();
VipTryModule:SetModuleName("VipTryModule");
function VipTryModule:_Start()
	self:_RegisterMediator(VipTryMediator);
	self:_RegisterProxy(VipTryProxy);
end

function VipTryModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

return VipTryModule