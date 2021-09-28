require "Core.Module.Pattern.BaseModule"
require "Core.Module.XLTInstance.XLTInstanceMediator"
require "Core.Module.XLTInstance.XLTInstanceProxy"
XLTInstanceModule = BaseModule:New();
XLTInstanceModule:SetModuleName("XLTInstanceModule");
function XLTInstanceModule:_Start()
	self:_RegisterMediator(XLTInstanceMediator);
	self:_RegisterProxy(XLTInstanceProxy);
end

function XLTInstanceModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

