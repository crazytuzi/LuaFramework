require "Core.Module.Pattern.BaseModule"
require "Core.Module.EndlessTry.EndlessTryProxy"
local EndlessTryMediator = require "Core.Module.EndlessTry.EndlessTryMediator"
local EndlessTryModule = BaseModule:New();
EndlessTryModule:SetModuleName("EndlessTryModule");
function EndlessTryModule:_Start()
	self:_RegisterMediator(EndlessTryMediator);
	self:_RegisterProxy(EndlessTryProxy);
end

function EndlessTryModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

return EndlessTryModule