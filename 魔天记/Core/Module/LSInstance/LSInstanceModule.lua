require "Core.Module.Pattern.BaseModule"
require "Core.Module.LSInstance.LSInstanceMediator"
require "Core.Module.LSInstance.LSInstanceProxy"
LSInstanceModule = BaseModule:New();
LSInstanceModule:SetModuleName("LSInstanceModule");
function LSInstanceModule:_Start()
	self:_RegisterMediator(LSInstanceMediator);
	self:_RegisterProxy(LSInstanceProxy);
end

function LSInstanceModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

