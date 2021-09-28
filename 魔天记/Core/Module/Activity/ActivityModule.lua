require "Core.Module.Pattern.BaseModule"
require "Core.Module.Activity.ActivityMediator"
require "Core.Module.Activity.ActivityProxy"

ActivityModule = BaseModule:New();
ActivityModule:SetModuleName("ActivityModule");
function ActivityModule:_Start()
	self:_RegisterMediator(ActivityMediator);
	self:_RegisterProxy(ActivityProxy);

   
end

function ActivityModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

