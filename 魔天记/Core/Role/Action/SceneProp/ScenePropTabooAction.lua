local ScenePropNearAction = require "Core.Role.Action.SceneProp.ScenePropNearAction"
local ScenePropTabooAction = class("ScenePropTabooAction", ScenePropNearAction)

function ScenePropTabooAction:New()
    self = { };
    setmetatable(self, { __index = ScenePropTabooAction });
    return self
end

function ScenePropTabooAction:OnNear()
    local info = self._controller.info
    --PrintTable(info,"___",Warning)
    MessageManager.Dispatch(TabooNotes, TabooNotes.TABOO_HOLD_MINE_NEAR, info )
end
function ScenePropNearAction:OnAway()
    --Warning("OnAway__" .. self.__cname)
    MessageManager.Dispatch(TabooNotes, TabooNotes.TABOO_HOLD_MINE_AWAY)
end

function ScenePropNearAction:_Dispose()
    self:Stop()
end

return ScenePropTabooAction