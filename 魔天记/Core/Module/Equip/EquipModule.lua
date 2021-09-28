require "Core.Module.Pattern.BaseModule"
require "Core.Module.Equip.EquipMediator"
require "Core.Module.Equip.EquipProxy"
EquipModule = BaseModule:New();
EquipModule:SetModuleName("EquipModule");
function EquipModule:_Start()
	self:_RegisterMediator(EquipMediator);
	self:_RegisterProxy(EquipProxy);
end

function EquipModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

