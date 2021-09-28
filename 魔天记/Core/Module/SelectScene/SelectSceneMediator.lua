require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.SelectScene.SelectSceneNotes"
require "Core.Module.SelectScene.View.SelectScenePanel"

SelectSceneMediator = Mediator:New();
function SelectSceneMediator:OnRegister()

end

function SelectSceneMediator:_ListNotificationInterests()
    return {
        [1] = SelectSceneNotes.OPEN_SELECTSCENE_PANEL,
        [2] = SelectSceneNotes.CLOSE_SELECTSCENE_PANEL,
        }
end

function SelectSceneMediator:_HandleNotification(notification)
    local ntype = notification:GetName()
    if ntype == SelectSceneNotes.OPEN_SELECTSCENE_PANEL then
        if (self._panel == nil) then
            self._panel = PanelManager.BuildPanel(ResID.UI_SCENE_LINE_PANEL, SelectScenePanel, false);
        end
    elseif ntype == SelectSceneNotes.CLOSE_SELECTSCENE_PANEL then
        if self._panel ~= nil then
            PanelManager.RecyclePanel(self._panel,ResID.UI_SCENE_LINE_PANEL)
            self._panel = nil
        end
    end
end

function SelectSceneMediator:OnRemove()
    if self._panel then self._panel:Dispose() end
end

