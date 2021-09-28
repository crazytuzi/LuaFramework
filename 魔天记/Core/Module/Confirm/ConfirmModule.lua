require "Core.Module.Pattern.BaseModule"
require "Core.Module.Confirm.ConfirmMediator"
require "Core.Module.Confirm.ConfirmProxy"
ConfirmModule = BaseModule:New();
ConfirmModule:SetModuleName("ConfirmModule");
function ConfirmModule:_Start()
	self:_RegisterMediator(ConfirmMediator);
	self:_RegisterProxy(ConfirmProxy);
end

function ConfirmModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

