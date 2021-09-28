require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.Map.MapNotes"
require "Core.Module.Map.View.MapPanel"
require "Core.Module.Map.View.MapWorldPanel"
require "Core.Module.Map.View.ArathiMapPanel"
require "Core.Module.Map.View.GuildWarMapPanel"
local FieldMapPanel = require "Core.Module.Map.View.FieldMapPanel"
local BossMapPanel = require "Core.Module.Map.View.BossMapPanel"

MapMediator = Mediator:New();
function MapMediator:OnRegister()

end

function MapMediator:_ListNotificationInterests()
    return
    {
        MapNotes.OPEN_MAPPANEL,
        MapNotes.CLOSE_MAPPANEL,
        MapNotes.UPDATE_MAPPANEL,

        MapNotes.OPEN_MAPWORLDPANEL,
        MapNotes.CLOSE_MAPWORLDPANEL,

        MapNotes.OPEN_ARATHIMAPPANEL,
        MapNotes.CLOSE_ARATHIMAPPANEL,

        MapNotes.OPEN_GUILDWARMAPPANEL,
        MapNotes.CLOSE_GUILDWARMAPPANEL,

        MapNotes.OPEN_FIELD_MAP_PANEL,
        MapNotes.CLOSE_FIELD_MAP_PANEL,

        MapNotes.OPEN_BOSS_MAP_PANEL,
        MapNotes.CLOSE_BOSS_MAP_PANEL,
    }
end

function MapMediator:_HandleNotification(notification)
    local t = notification:GetName()
    if t == MapNotes.OPEN_MAPPANEL then
        if (self._arathiMapPanel ~= nil) then
            PanelManager.RecyclePanel(self._arathiMapPanel, ResID.UI_ARATHIMAPPANEL)
            self._arathiMapPanel = nil
        end
        if self._mapPanel == nil then
            if (self._mapPanel == nil) then
                self._mapPanel = PanelManager.BuildPanel(ResID.UI_MAPPANEL, MapPanel);
            end
        end
    elseif t == MapNotes.CLOSE_MAPPANEL then
        if (self._mapPanel ~= nil) then
            PanelManager.RecyclePanel(self._mapPanel, ResID.UI_MAPPANEL)
            self._mapPanel = nil
        end
    elseif t == MapNotes.OPEN_MAPWORLDPANEL then
        if self._worldMapPanel == nil then
            self._worldMapPanel = PanelManager.BuildPanel(ResID.UI_MAPWORLDPANEL, MapWorldPanel);
        end
    elseif t == MapNotes.CLOSE_MAPWORLDPANEL then
        if (self._worldMapPanel ~= nil) then
            PanelManager.RecyclePanel(self._worldMapPanel, ResID.UI_MAPWORLDPANEL)
            self._worldMapPanel = nil
        end
    elseif t == MapNotes.OPEN_ARATHIMAPPANEL then
        if (self._mapPanel ~= nil) then
            PanelManager.RecyclePanel(self._mapPanel, ResID.UI_MAPPANEL)
            self._mapPanel = nil
        end
        if self._arathiMapPanel == nil then
            self._arathiMapPanel = PanelManager.BuildPanel(ResID.UI_ARATHIMAPPANEL, ArathiMapPanel);
        end
    elseif t == MapNotes.CLOSE_ARATHIMAPPANEL then
        if (self._arathiMapPanel ~= nil) then
            PanelManager.RecyclePanel(self._arathiMapPanel, ResID.UI_ARATHIMAPPANEL)
            self._arathiMapPanel = nil
        end
    elseif t == MapNotes.OPEN_GUILDWARMAPPANEL then
        if (self._mapPanel ~= nil) then
            PanelManager.RecyclePanel(self._mapPanel, ResID.UI_MAPPANEL)
            self._mapPanel = nil
        end
        if self._guildWarMapPanel == nil then
            self._guildWarMapPanel = PanelManager.BuildPanel(ResID.UI_GUILDWARMAPPANEL, GuildWarMapPanel);
        end
    elseif t == MapNotes.CLOSE_GUILDWARMAPPANEL then
        if (self._guildWarMapPanel ~= nil) then
            PanelManager.RecyclePanel(self._guildWarMapPanel, ResID.UI_GUILDWARMAPPANEL)
            self._guildWarMapPanel = nil
        end
    elseif t == MapNotes.OPEN_FIELD_MAP_PANEL then
        if self._fieldMapPanel == nil then
            self._fieldMapPanel = PanelManager.BuildPanel(ResID.UI_FIELD_MAP_PANEL, FieldMapPanel);
        end
        self._fieldMapPanel:SetData(notification:GetBody())
    elseif t == MapNotes.CLOSE_FIELD_MAP_PANEL then
        if (self._fieldMapPanel ~= nil) then
            PanelManager.RecyclePanel(self._fieldMapPanel, ResID.UI_FIELD_MAP_PANEL)
            self._fieldMapPanel = nil
        end
    elseif t == MapNotes.OPEN_BOSS_MAP_PANEL then
        if self._bossMapPanel == nil then
            self._bossMapPanel = PanelManager.BuildPanel(ResID.UI_FIELD_MAP_PANEL, BossMapPanel);
        end
        self._bossMapPanel:SetData(notification:GetBody())
    elseif t == MapNotes.CLOSE_BOSS_MAP_PANEL then
        if (self._bossMapPanel ~= nil) then
            PanelManager.RecyclePanel(self._bossMapPanel, ResID.UI_FIELD_MAP_PANEL)
            self._bossMapPanel = nil
        end
    end
end

function MapMediator:OnRemove()
    if (self._mapPanel ~= nil) then
        PanelManager.RecyclePanel(self._mapPanel, ResID.UI_MAPPANEL)
        self._mapPanel = nil
    end

    if (self._worldMapPanel ~= nil) then
        PanelManager.RecyclePanel(self._worldMapPanel, ResID.UI_MAPWORLDPANEL)
        self._worldMapPanel = nil
    end

    if (self._guildWarMapPanel ~= nil) then
        PanelManager.RecyclePanel(self._guildWarMapPanel, ResID.UI_GUILDWARMAPPANEL)
        self._guildWarMapPanel = nil
    end
end

