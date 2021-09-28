local ScenePropNearAction = require "Core.Role.Action.SceneProp.ScenePropNearAction"
local ScenePropBaoXianAction = class("ScenePropBaoXianAction", ScenePropNearAction)

function ScenePropBaoXianAction:New()
    self = { };
    setmetatable(self, { __index = ScenePropBaoXianAction });
    return self
end

function ScenePropBaoXianAction:OnNear()
    local info = self._controller.info
    --PrintTable(info,"___",Warning)
    ModuleManager.SendNotification(SceneEntityNotes.SCENE_ENTITY_NEAR, info )
end
function ScenePropNearAction:OnAway()
    --Warning("OnAway__" .. self.__cname)
    ModuleManager.SendNotification(SceneEntityNotes.SCENE_ENTITY_AWAY)
end

function ScenePropNearAction:_Dispose()
    self:Stop()
end

return ScenePropBaoXianAction