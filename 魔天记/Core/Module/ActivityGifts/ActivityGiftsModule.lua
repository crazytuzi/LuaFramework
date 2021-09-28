require "Core.Module.Pattern.BaseModule"
require "Core.Module.ActivityGifts.ActivityGiftsMediator"
require "Core.Module.ActivityGifts.ActivityGiftsProxy"
ActivityGiftsModule = BaseModule:New();
ActivityGiftsModule:SetModuleName("ActivityGiftsModule");
function ActivityGiftsModule:_Start()
	self:_RegisterMediator(ActivityGiftsMediator);
	self:_RegisterProxy(ActivityGiftsProxy);
end

function ActivityGiftsModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

