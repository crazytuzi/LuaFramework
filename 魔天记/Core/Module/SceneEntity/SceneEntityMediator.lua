require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.SceneEntity.SceneEntityNotes"

local SceneEntityMediator = Mediator:New();
local notes = {
    SceneEntityNotes.SCENE_ENTITY_NEAR
    ,SceneEntityNotes.SCENE_ENTITY_AWAY
}
function SceneEntityMediator:OnRegister()

end

function SceneEntityMediator:_ListNotificationInterests()
	return notes
end

function SceneEntityMediator:_HandleNotification(notification)
	local t = notification:GetName()
    if t == SceneEntityNotes.SCENE_ENTITY_NEAR then
        if (self._panel == nil) then
            local SceneCollectPanel = require "Core.Module.Common.SceneCollectPanel"
            self._panel = PanelManager.BuildPanel(ResID.UI_SCENE_PROP_COLLECT_PANEL, SceneCollectPanel)
            self._panel:SetData(notification:GetBody())
        end
    elseif t == SceneEntityNotes.SCENE_ENTITY_AWAY then
        if (self._panel ~= nil) then
            PanelManager.RecyclePanel(self._panel, ResID.UI_SCENE_PROP_COLLECT_PANEL)
            self._panel = nil
        end
    end
end

function SceneEntityMediator:OnRemove()

end

return SceneEntityMediator