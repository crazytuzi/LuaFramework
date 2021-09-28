require "Core.Module.Pattern.BaseModule"
require "Core.Module.ChoosePKType.ChoosePKTypeMediator"
require "Core.Module.ChoosePKType.ChoosePKTypeProxy"
ChoosePKTypeModule = BaseModule:New();
ChoosePKTypeModule:SetModuleName("ChoosePKTypeModule");
function ChoosePKTypeModule:_Start()
	self:_RegisterMediator(ChoosePKTypeMediator);
	self:_RegisterProxy(ChoosePKTypeProxy);
end

function ChoosePKTypeModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

