require "Core.Module.Pattern.BaseModule"
require "Core.Module.WiseEquip.WiseEquipPanelProxy"
local WiseEquipPanelMediator = require "Core.Module.WiseEquip.WiseEquipPanelMediator"
local WiseEquipPanelModule = BaseModule:New();
WiseEquipPanelModule:SetModuleName("WiseEquipPanelModule");
function WiseEquipPanelModule:_Start()
	self:_RegisterMediator(WiseEquipPanelMediator);
	self:_RegisterProxy(WiseEquipPanelProxy);
end

function WiseEquipPanelModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

return WiseEquipPanelModule