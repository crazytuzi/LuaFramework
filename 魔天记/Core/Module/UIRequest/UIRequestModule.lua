require "Core.Module.Pattern.BaseModule"
require "Core.Module.UIRequest.UIRequestMediator"
require "Core.Module.UIRequest.UIRequestProxy"
UIRequestModule = BaseModule:New();
UIRequestModule:SetModuleName("UIRequestModule");
function UIRequestModule:_Start()
	self:_RegisterMediator(UIRequestMediator);
	self:_RegisterProxy(UIRequestProxy);
end

function UIRequestModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

