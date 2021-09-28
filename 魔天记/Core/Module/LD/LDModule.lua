require "Core.Module.Pattern.BaseModule"
require "Core.Module.LD.LDProxy"
require "Core.Module.LD.LDMediator"
LDModule = BaseModule:New();
LDModule:SetModuleName("LDModule");
function LDModule:_Start()
	self:_RegisterMediator(LDMediator);
	self:_RegisterProxy(LDProxy);
end

function LDModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end