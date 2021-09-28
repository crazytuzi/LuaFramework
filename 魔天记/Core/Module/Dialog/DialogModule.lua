require "Core.Module.Pattern.BaseModule"
require "Core.Module.Dialog.DialogMediator"

DialogModule = BaseModule:New();
DialogModule:SetModuleName("DialogModule");
function DialogModule:_Start()
	self:_RegisterMediator(DialogMediator);
end

function DialogModule:_Dispose()
	self:_RemoveMediator();
end

