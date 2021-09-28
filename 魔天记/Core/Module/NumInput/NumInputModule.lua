require "Core.Module.Pattern.BaseModule"
require "Core.Module.NumInput.NumInputMediator"
require "Core.Module.NumInput.NumInputProxy"
NumInputModule = BaseModule:New();
NumInputModule:SetModuleName("NumInputModule");
function NumInputModule:_Start()
	self:_RegisterMediator(NumInputMediator);
	self:_RegisterProxy(NumInputProxy);
end

function NumInputModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

