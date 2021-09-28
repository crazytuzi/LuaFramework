require "Core.Module.Pattern.Mediator";
require "Core.Module.GuildWar.View.GuildWarPanel";
require "Core.Module.GuildWar.View.GuildWarRankPanel";
require "Core.Module.GuildWar.View.GuildWarDetailPanel";
require "Core.Module.GuildWar.View.GuildWarResultPanel";
require "Core.Module.GuildWar.View.GuildWarInfoPanel";
require "Core.Module.GuildWar.View.GuildWarDescPanel";



GuildWarMediator = Mediator:New();
function GuildWarMediator:OnRegister()

end

function GuildWarMediator:_ListNotificationInterests()
    return {
        [1] = GuildWarNotes.CLOSE_ALL_PANEL,
        [2] = GuildWarNotes.OPEN_PANEL,
        [3] = GuildWarNotes.CLOSE_PANEL,
        [4] = GuildWarNotes.OPEN_RANK_PANEL,
        [5] = GuildWarNotes.CLOSE_RANK_PANEL,
        [6] = GuildWarNotes.OPEN_DETAIL_PANEL,
        [7] = GuildWarNotes.CLOSE_DETAIL_PANEL,
        [8] = GuildWarNotes.OPEN_RESULT_PANEL,
        [9] = GuildWarNotes.CLOSE_RESULT_PANEL,
        [10] = GuildWarNotes.OPEN_INFO_PANEL,
        [11] = GuildWarNotes.CLOSE_INFO_PANEL,
        [12] = GuildWarNotes.OPEN_DESC_PANEL,
        [13] = GuildWarNotes.CLOSE_DESC_PANEL
    };
end

function GuildWarMediator:_HandleNotification(notification)
    if notification:GetName() == GuildWarNotes.CLOSE_ALL_PANEL then
        self:OnRemove();
    elseif notification:GetName() == GuildWarNotes.OPEN_PANEL then
        self:OpenPanel();
    elseif notification:GetName() == GuildWarNotes.CLOSE_PANEL then
        self:ClosePanel();
    elseif notification:GetName() == GuildWarNotes.OPEN_RANK_PANEL then
        if (self._rankPanel == nil) then
            self._rankPanel = PanelManager.BuildPanel(ResID.UI_GUILDWARRANKPANEL, GuildWarRankPanel);
        end
    elseif notification:GetName() == GuildWarNotes.CLOSE_RANK_PANEL then
        self:CloseRankPanel();
    elseif notification:GetName() == GuildWarNotes.OPEN_DETAIL_PANEL then
        if (self._detailPanel == nil) then
            self._detailPanel = PanelManager.BuildPanel(ResID.UI_GUILDWARDETAILPANEL, GuildWarDetailPanel);
        end
    elseif notification:GetName() == GuildWarNotes.CLOSE_DETAIL_PANEL then
        self:CloseDetailPanel();
    elseif notification:GetName() == GuildWarNotes.OPEN_RESULT_PANEL then
        if (self._resultPanel == nil) then
            self._resultPanel = PanelManager.BuildPanel(ResID.UI_GUILDWARRESULTPANEL, GuildWarResultPanel);
        end
        self._resultPanel:Update(notification:GetBody())
    elseif notification:GetName() == GuildWarNotes.CLOSE_RESULT_PANEL then
        self:CloseResultPanel();
    elseif notification:GetName() == GuildWarNotes.OPEN_INFO_PANEL then
        if (self._infoPanel == nil) then
            self._infoPanel = PanelManager.BuildPanel(ResID.UI_GUILDWARINFOPANEL, GuildWarInfoPanel);
        end
    elseif notification:GetName() == GuildWarNotes.CLOSE_INFO_PANEL then
        self:CloseInfoPanel();
    elseif notification:GetName() == GuildWarNotes.OPEN_DESC_PANEL then
        if (self._descPanel == nil) then
            self._descPanel = PanelManager.BuildPanel(ResID.UI_GUILDWARDESCPANEL, GuildWarDescPanel);
        end
    elseif notification:GetName() == GuildWarNotes.CLOSE_DESC_PANEL then
        self:CloseDescPanel();
    end
end


function GuildWarMediator:OpenPanel()
    if (self._panel == nil) then
        self._panel = PanelManager.BuildPanel(ResID.UI_GUILDWARPANEL, GuildWarPanel);
    end
end

function GuildWarMediator:ClosePanel()
    if (self._panel ~= nil) then
        PanelManager.RecyclePanel(self._panel, ResID.UI_GUILDWARPANEL)
        self._panel = nil;
    end
end

function GuildWarMediator:CloseRankPanel()
    if (self._rankPanel ~= nil) then
        PanelManager.RecyclePanel(self._rankPanel, ResID.UI_GUILDWARRANKPANEL)
        self._rankPanel = nil;
    end
end

function GuildWarMediator:CloseDetailPanel()
    if (self._detailPanel ~= nil) then
        PanelManager.RecyclePanel(self._detailPanel, ResID.UI_GUILDWARDETAILPANEL)
        self._detailPanel = nil;
    end
end

function GuildWarMediator:CloseResultPanel()
    if (self._resultPanel ~= nil) then
        PanelManager.RecyclePanel(self._resultPanel, ResID.UI_GUILDWARRESULTPANEL)
        self._resultPanel = nil;
    end
end

function GuildWarMediator:CloseInfoPanel()
    if (self._infoPanel ~= nil) then
        PanelManager.RecyclePanel(self._infoPanel, ResID.UI_GUILDWARINFOPANEL)
        self._infoPanel = nil;
    end
end

function GuildWarMediator:CloseDescPanel()
    if (self._descPanel ~= nil) then
        PanelManager.RecyclePanel(self._descPanel, ResID.UI_GUILDWARDESCPANEL)
        self._descPanel = nil;
    end
end

function GuildWarMediator:OnRemove()
    self:ClosePanel();
    self:CloseRankPanel();
    self:CloseDetailPanel();
    self:CloseResultPanel();
    self:CloseInfoPanel();
    self:CloseDescPanel();
end