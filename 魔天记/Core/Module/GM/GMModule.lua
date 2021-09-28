require "Core.Module.Pattern.BaseModule"
require "Core.Module.GM.GMMediator"
require "Core.Module.GM.GMProxy"
GMModule = BaseModule:New();
GMModule:SetModuleName("GMModule");
function GMModule:_Start()
	self:_RegisterMediator(GMMediator);
	self:_RegisterProxy(GMProxy);
end

function GMModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

