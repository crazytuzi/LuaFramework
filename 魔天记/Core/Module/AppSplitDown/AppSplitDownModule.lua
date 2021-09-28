require "Core.Module.Pattern.BaseModule"
require "Core.Module.AppSplitDown.AppSplitDownMediator"
require "Core.Module.AppSplitDown.AppSplitDownProxy"
AppSplitDownModule = BaseModule:New();
AppSplitDownModule:SetModuleName("AppSplitDownModule");
function AppSplitDownModule:_Start()
	self:_RegisterMediator(AppSplitDownMediator);
	self:_RegisterProxy(AppSplitDownProxy);
end

function AppSplitDownModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

