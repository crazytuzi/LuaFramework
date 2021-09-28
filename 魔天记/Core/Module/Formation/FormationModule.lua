require "Core.Module.Pattern.BaseModule"
require "Core.Module.Formation.FormationProxy"
local FormationMediator = require "Core.Module.Formation.FormationMediator"
local FormationModule = BaseModule:New();
FormationModule:SetModuleName("FormationModule");
function FormationModule:_Start()
	self:_RegisterMediator(FormationMediator);
	self:_RegisterProxy(FormationProxy);
end

function FormationModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

return FormationModule