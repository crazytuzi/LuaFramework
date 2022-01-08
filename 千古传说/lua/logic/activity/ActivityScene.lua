local ActivityScene = class("ActivityScene", BaseScene);

function ActivityScene:ctor(data)
	self.super.ctor(self,data);
	local layer  = require("lua.logic.activity.ActivityLayer"):new();
    self:addLayer(layer);
end

function ActivityScene:loadResource()
	print("loadResource");
end

return ActivityScene;