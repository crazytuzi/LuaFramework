local ArmyScene = class("ArmyScene", BaseScene);

function ArmyScene:ctor(data)
	self.super.ctor(self,data);
	local logic = require("lua.logic.army.ArmyLayer"):new();
    self:addLayer(logic);
end

return ArmyScene;