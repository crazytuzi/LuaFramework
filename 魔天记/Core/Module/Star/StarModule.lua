require "Core.Module.Pattern.BaseModule"
require "Core.Module.Star.StarProxy"
local StarMediator = require "Core.Module.Star.StarMediator"
local StarModule = BaseModule:New();
StarModule:SetModuleName("StarModule");
function StarModule:_Start()
	self:_RegisterMediator(StarMediator);
	self:_RegisterProxy(StarProxy);
end

function StarModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

return StarModule