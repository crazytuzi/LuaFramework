require "Core.Module.Pattern.BaseModule"
require "Core.Module.MainUI.MainUIMediator"
require "Core.Module.MainUI.MainUIProxy"

MainUIModule = BaseModule:New();
MainUIModule:SetModuleName("MainUIModule");
function MainUIModule:_Start()
	self:_RegisterMediator(MainUIMediator);
	self:_RegisterProxy(MainUIProxy);
end

function MainUIModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

