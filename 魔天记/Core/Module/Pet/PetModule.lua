require "Core.Module.Pattern.BaseModule"
require "Core.Module.Pet.PetMediator"
require "Core.Module.Pet.PetProxy"
PetModule = BaseModule:New();
PetModule:SetModuleName("PetModule");
function PetModule:_Start()
	self:_RegisterMediator(PetMediator);
	self:_RegisterProxy(PetProxy);
end

function PetModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

