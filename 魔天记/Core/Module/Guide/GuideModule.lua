require "Core.Module.Pattern.BaseModule"
require "Core.Module.Guide.GuideMediator"
require "Core.Module.Guide.GuideProxy"
require "Core.Module.Guide.GuideTools"
require "Core.Module.Guide.View.GuideDisplayCtrl"


GuideModule = BaseModule:New();
GuideModule:SetModuleName("GuideModule");
function GuideModule:_Start()
	self:_RegisterMediator(GuideMediator);
	self:_RegisterProxy(GuideProxy);
end

function GuideModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

