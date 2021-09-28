require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.Star.StarNotes"

local StarMediator = Mediator:New();
local notes = {
    StarNotes.OPEN_STAR_PANEL
    ,StarNotes.CLOSE_STAR_PANEL
    ,StarNotes.OPEN_STAR_SHOW_PANEL
    ,StarNotes.CLOSE_STAR_SHOW_PANEL
    ,StarNotes.OPEN_STAR_GET_PANEL
    ,StarNotes.CLOSE_STAR_GET_PANEL
    ,StarNotes.OPEN_STAR_BAG_PANEL
    ,StarNotes.CLOSE_STAR_BAG_PANEL
}
function StarMediator:OnRegister()

end

function StarMediator:_ListNotificationInterests()
	return notes
end

function StarMediator:_HandleNotification(notification)
	local n = notification:GetName()
    if n == StarNotes.OPEN_STAR_PANEL  then
        if (self._panel == nil) then
            local panel = require "Core.Module.Star.View.StarPanel"
            self._panel = PanelManager.BuildPanel(ResID.UI_STAR_PANEL, panel, true)
        end
        self._panel:SetOpenParam(notification:GetBody());
    elseif n == StarNotes.CLOSE_STAR_PANEL then
        if self._panel ~= nil then
            PanelManager.RecyclePanel(self._panel, ResID.UI_STAR_PANEL)
            self._panel = nil
        end
    elseif n == StarNotes.OPEN_STAR_SHOW_PANEL  then
        if (self._showPanel == nil) then
            local panel = require "Core.Module.Star.View.StarShowPanel"
            self._showPanel = PanelManager.BuildPanel(ResID.UI_STAR_SHOW_PANEL, panel, false)
        end
    elseif n == StarNotes.CLOSE_STAR_SHOW_PANEL then
        if self._showPanel ~= nil then
            PanelManager.RecyclePanel(self._showPanel, ResID.UI_STAR_SHOW_PANEL)
            self._showPanel = nil
        end
    elseif n == StarNotes.OPEN_STAR_GET_PANEL  then
        if (self._getPanel == nil) then
            local panel = require "Core.Module.Star.View.StarGetPanel"
            self._getPanel = PanelManager.BuildPanel(ResID.UI_STAR_GET_PANEL, panel, false)
        end
        local bd = notification:GetBody()
        self._getPanel:SetData(bd)
    elseif n == StarNotes.CLOSE_STAR_GET_PANEL then
        if self._getPanel ~= nil then
            PanelManager.RecyclePanel(self._getPanel, ResID.UI_STAR_GET_PANEL)
            self._getPanel = nil
        end
    elseif n == StarNotes.OPEN_STAR_BAG_PANEL  then
        if (self._getPanel == nil) then
            local panel = require "Core.Module.Star.View.StarBagPanel"
            self._getPanel = PanelManager.BuildPanel(ResID.UI_STAR_BAG_PANEL, panel, false)
        end
         --源位置物品id,目标位置的下标idx （装备的槽位，背包栏位）,命星类型kind
        local bd = notification:GetBody()
        self._getPanel:SetData(bd)
    elseif n == StarNotes.CLOSE_STAR_BAG_PANEL then
        if self._getPanel ~= nil then
            PanelManager.RecyclePanel(self._getPanel, ResID.UI_STAR_BAG_PANEL)
            self._getPanel = nil
        end
    end
end

function StarMediator:OnRemove()

end

return StarMediator