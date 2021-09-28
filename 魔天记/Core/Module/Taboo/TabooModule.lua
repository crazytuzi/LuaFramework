require "Core.Module.Pattern.BaseModule"
require "Core.Module.Taboo.TabooProxy"
local TabooMediator = require "Core.Module.Taboo.TabooMediator"
local TabooModule = BaseModule:New();
TabooModule:SetModuleName("TabooModule");
function TabooModule:_Start()
	self:_RegisterMediator(TabooMediator);
	self:_RegisterProxy(TabooProxy);
end

function TabooModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

return TabooModule