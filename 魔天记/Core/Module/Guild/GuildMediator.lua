require "Core.Module.Pattern.Mediator";
require "Core.Module.Common.ResID";
require "Core.Module.Guild.GuildNotes";
require "Core.Module.Guild.View.GuildPanel";
require "Core.Module.Guild.View.GuildListPanel";
require "Core.Module.Guild.View.GuildReqListPanel";
require "Core.Module.Guild.View.GuildVertifyPanel";
require "Core.Module.Guild.View.GuildLogPanel";
require "Core.Module.Guild.View.GuildEnemyPanel";
require "Core.Module.Guild.View.GuildDetailPanel";
require "Core.Module.Guild.View.GuildMemberPanel";
require "Core.Module.Guild.View.GuildTaskPanel";
require "Core.Module.Guild.View.GuildHelpListPanel";
require "Core.Module.Guild.View.GuildMoBaiPanel";
require "Core.Module.Guild.View.GuildSkillPanel";
require "Core.Module.Guild.View.GuildSalaryDescPanel";
require "Core.Module.Guild.View.GuildHongBaoPanel";
require "Core.Module.Guild.View.GuildHongBaoInfoPanel";
require "Core.Module.Guild.View.GuildSendHongBaoPanel";
require "Core.Module.Guild.View.GuildHongBaoNotifyPanel";

GuildMediator = Mediator:New();
function GuildMediator:OnRegister()

end

function GuildMediator:_ListNotificationInterests()
    return {
        [1] = GuildNotes.CLOSE_ALL_GUILDPANEL,
        [2] = GuildNotes.OPEN_GUILDPANEL,
        [3] = GuildNotes.CLOSE_GUILDPANEL,
        [4] = GuildNotes.OPEN_GUILDLISTPANEL,
        [5] = GuildNotes.CLOSE_GUILDLISTPANEL,
        [6] = GuildNotes.OPEN_GUILDVERIFYPANEL,
        [7] = GuildNotes.CLOSE_GUILDVERIFYPANEL,
        [8] = GuildNotes.OPEN_GUILDENEMYPANEL,
        [9] = GuildNotes.CLOSE_GUILDENEMYPANEL,
        [10] = GuildNotes.OPEN_GUILD_DETAIL_PANEL,
        [11] = GuildNotes.CLOSE_GUILD_DETAIL_PANEL,
        [12] = GuildNotes.OPEN_GUILD_MEMBER_PANEL,
        [13] = GuildNotes.CLOSE_GUILD_MEMBER_PANEL,
        [14] = GuildNotes.OPEN_GUILD_REQLIST_PANEL,
        [15] = GuildNotes.CLOSE_GUILD_REQLIST_PANEL,
        [16] = GuildNotes.OPEN_GUILD_LOG_PANEL,
        [17] = GuildNotes.CLOSE_GUILD_LOG_PANEL,
        [18] = GuildNotes.OPEN_GUILD_OTHER_PANEL,
        [19] = GuildNotes.CLOSE_GUILD_OTHER_PANEL,
        [20] = GuildNotes.OPEN_GUILDHONGBAOPANEL,
        [21] = GuildNotes.CLOSE_GUILDHONGBAOPANEL,
        [22] = GuildNotes.OPEN_GUILDHONGBAOINFOPANEL,
        [23] = GuildNotes.CLOSE_GUILDHONGBAOINFOPANEL,
        [24] = GuildNotes.OPEN_GUILDSENDHONGBAOPANEL,
        [25] = GuildNotes.CLOSE_GUILDSENDHONGBAOPANEL,
        [26] = GuildNotes.OPEN_GUILDHONGBAONOTIFYPANEL,
        [27] = GuildNotes.CLOSE_GUILDHONGBAONOTIFYPANEL
    };
end

function GuildMediator:_HandleNotification(notification)
    if notification:GetName() == GuildNotes.CLOSE_ALL_GUILDPANEL then
        self:OnRemove();

    elseif notification:GetName() == GuildNotes.OPEN_GUILDPANEL then
        local inGuild = GuildDataManager.InGuild();
        if inGuild then
            local param = notification:GetBody();
            self:OpenPanel(param);
        else
            self:OpenReqListPanel();
        end
    elseif notification:GetName() == GuildNotes.CLOSE_GUILDPANEL then
        self:ClosePanel();
    elseif notification:GetName() == GuildNotes.OPEN_GUILDLISTPANEL then
        if (self._listPanel == nil) then
            self._listPanel = PanelManager.BuildPanel(ResID.UI_GUILDLISTPANEL, GuildListPanel);
        end
    elseif notification:GetName() == GuildNotes.CLOSE_GUILDLISTPANEL then
        self:CloseListPanel();
    elseif notification:GetName() == GuildNotes.OPEN_GUILD_REQLIST_PANEL then
        self:OpenReqListPanel();
    elseif notification:GetName() == GuildNotes.CLOSE_GUILD_REQLIST_PANEL then
        self:CloseReqListPanel();

    elseif notification:GetName() == GuildNotes.OPEN_GUILD_LOG_PANEL then
        if (self._logPanel == nil) then
            self._logPanel = PanelManager.BuildPanel(ResID.UI_GUILDLOGPANEL, GuildLogPanel);
        end
    elseif notification:GetName() == GuildNotes.CLOSE_GUILD_LOG_PANEL then
        self:CloseLogPanel();

    elseif notification:GetName() == GuildNotes.OPEN_GUILDVERIFYPANEL then
        if (self._vertifyPanel == nil) then
            self._vertifyPanel = PanelManager.BuildPanel(ResID.UI_GUILDVERIFYPANEL, GuildVerifyPanel);
        end
    elseif notification:GetName() == GuildNotes.CLOSE_GUILDVERIFYPANEL then
        self:CloseVertifyPanel();
    elseif notification:GetName() == GuildNotes.OPEN_GUILDENEMYPANEL then
        if (self._enemyPanel == nil) then
            self._enemyPanel = PanelManager.BuildPanel(ResID.UI_GUILDENEMYPANEL, GuildEnemyPanel);
        end
    elseif notification:GetName() == GuildNotes.CLOSE_GUILDENEMYPANEL then
        self:CloseEnemyPanel();

    elseif notification:GetName() == GuildNotes.OPEN_GUILD_DETAIL_PANEL then
        if self._detailPanel == nil then
            self._detailPanel = PanelManager.BuildPanel(ResID.UI_GUILDDETAILPANEL, GuildDetailPanel);
        end
        local param = notification:GetBody();
        self._detailPanel:UpdateDisplay(param);
    elseif notification:GetName() == GuildNotes.CLOSE_GUILD_DETAIL_PANEL then
        self:CloseGuildDetailPanel();
    elseif notification:GetName() == GuildNotes.OPEN_GUILD_MEMBER_PANEL then
        if self._memberPanel == nil then
            self._memberPanel = PanelManager.BuildPanel(ResID.UI_GUILDMEMBERPANEL, GuildMemberPanel);
        end
        local param = notification:GetBody();
        self._memberPanel:UpdateDisplay(param);
    elseif notification:GetName() == GuildNotes.CLOSE_GUILD_MEMBER_PANEL then
        self:CloseMemberPanel();
    elseif notification:GetName() == GuildNotes.OPEN_GUILD_OTHER_PANEL then
        local id = notification:GetBody();
        if self._otherPanel == nil then
            self._otherPanel = { };
            self._otherRes = { };
        end

        if self._otherPanel[id] == nil then
            self:GetOtherPanel(id);
        end
    elseif notification:GetName() == GuildNotes.CLOSE_GUILD_OTHER_PANEL then
        local id = notification:GetBody();
        self:CloseOtherPanel(id);

    elseif notification:GetName() == GuildNotes.OPEN_GUILDHONGBAOPANEL then
        if self._hongbaoPanel == nil then
            self._hongbaoPanel = PanelManager.BuildPanel(ResID.UI_GUILDHONGBAOPANEL, GuildHongBaoPanel, false, GuildNotes.CLOSE_GUILDHONGBAOPANEL);
        end
    elseif notification:GetName() == GuildNotes.CLOSE_GUILDHONGBAOPANEL then
        self:CloseGuildHongBaoPanel();
    elseif notification:GetName() == GuildNotes.OPEN_GUILDHONGBAOINFOPANEL then
        local data = notification:GetBody()
        if (data) then
            if self._hongbaoInfoPanel == nil then
                self._hongbaoInfoPanel = PanelManager.BuildPanel(ResID.UI_GUILDHONGBAOINFOPANEL, GuildHongBaoInfoPanel, false, GuildNotes.CLOSE_GUILDHONGBAOINFOPANEL);
            end
            self._hongbaoInfoPanel:SetData(data)
        end
    elseif notification:GetName() == GuildNotes.CLOSE_GUILDHONGBAOINFOPANEL then
        self:CloseHongBaoInfoPanel();
    elseif notification:GetName() == GuildNotes.OPEN_GUILDSENDHONGBAOPANEL then
        local data = notification:GetBody()
        if (data) then
            if self._sendHongbaoPanel == nil then
                self._sendHongbaoPanel = PanelManager.BuildPanel(ResID.UI_GUILDSENDHONGBAOPANEL, GuildSendHongBaoPanel, false, GuildNotes.CLOSE_GUILDSENDHONGBAOPANEL);
            end
            self._sendHongbaoPanel:SetData(data)
        end
    elseif notification:GetName() == GuildNotes.CLOSE_GUILDSENDHONGBAOPANEL then
        self:CloseSendHongBaoPanel();
    elseif notification:GetName() == GuildNotes.OPEN_GUILDHONGBAONOTIFYPANEL then
        local data = notification:GetBody()
        if (data) then
            if self._hongBaoNotifyPanel == nil then
                self._hongBaoNotifyPanel = PanelManager.BuildPanel(ResID.UI_GUILDHONGBAONOTIFYPANEL, GuildHongBaoNotifyPanel, false, GuildNotes.CLOSE_GUILDHONGBAONOTIFYPANEL);
            end
            self._hongBaoNotifyPanel:SetData(data)
        end
    elseif notification:GetName() == GuildNotes.CLOSE_GUILDHONGBAONOTIFYPANEL then
        self:CloseHongBaoNotifyPanel();
    end
end


function GuildMediator:OpenPanel(idx)
    if (self._panel == nil) then
        self._panel = PanelManager.BuildPanel(ResID.UI_GUILDPANEL, GuildPanel, true);
    end
    idx = idx or 1;
    self._panel:OpenSubPanel(idx);
end

function GuildMediator:ClosePanel()
    if (self._panel ~= nil) then
        PanelManager.RecyclePanel(self._panel, ResID.UI_GUILDPANEL)
        self._panel = nil;
    end
end

function GuildMediator:CloseListPanel()
    if (self._listPanel ~= nil) then
        PanelManager.RecyclePanel(self._listPanel, ResID.UI_GUILDLISTPANEL);
        self._listPanel = nil;
    end
end

function GuildMediator:OpenReqListPanel()
    if (self._reqListPanel == nil) then
        self._reqListPanel = PanelManager.BuildPanel(ResID.UI_GUILDREQLISTPANEL, GuildReqListPanel);
    end
end

function GuildMediator:CloseReqListPanel()
    if (self._reqListPanel ~= nil) then
        PanelManager.RecyclePanel(self._reqListPanel, ResID.UI_GUILDREQLISTPANEL);
        self._reqListPanel = nil;
    end
end

function GuildMediator:CloseVertifyPanel()
    if (self._vertifyPanel ~= nil) then
        PanelManager.RecyclePanel(self._vertifyPanel, ResID.UI_GUILDVERIFYPANEL);
        self._vertifyPanel = nil;
    end
end

function GuildMediator:CloseLogPanel()
    if (self._logPanel ~= nil) then
        PanelManager.RecyclePanel(self._logPanel, ResID.UI_GUILDLOGPANEL);
        self._logPanel = nil;
    end
end

function GuildMediator:CloseEnemyPanel()
    if (self._enemyPanel ~= nil) then
        PanelManager.RecyclePanel(self._enemyPanel, ResID.UI_GUILDENEMYPANEL);
        self._enemyPanel = nil;
    end
end

function GuildMediator:CloseGuildDetailPanel()
    if (self._detailPanel ~= nil) then
        PanelManager.RecyclePanel(self._detailPanel, ResID.UI_GUILDDETAILPANEL);
        self._detailPanel = nil;
    end
end

function GuildMediator:CloseMemberPanel()
    if (self._memberPanel ~= nil) then
        PanelManager.RecyclePanel(self._memberPanel, ResID.UI_GUILDMEMBERPANEL);
        self._memberPanel = nil;
    end
end

function GuildMediator:GetOtherPanel(id)
    local res = nil;
    local panel = nil;
    if id == GuildNotes.OTHER.TASK then
        res = ResID.UI_GUILDTASKPANEL;
        panel = PanelManager.BuildPanel(res, GuildTaskPanel);

    elseif id == GuildNotes.OTHER.HELPLIST then
        res = ResID.UI_GUILDHELPLISTPANEL;
        panel = PanelManager.BuildPanel(res, GuildHelpListPanel);

    elseif id == GuildNotes.OTHER.MOBAI then
        res = ResID.UI_GUILDMOBAIPANEL;
        panel = PanelManager.BuildPanel(res, GuildMoBaiPanel);
    elseif id == GuildNotes.OTHER.SKILL then
        res = ResID.UI_GUILDSKILLPANEL;
        panel = PanelManager.BuildPanel(res, GuildSkillPanel);
    elseif id == GuildNotes.OTHER.SALARYDESC then
        res = ResID.UI_GUILDSALARYDESCPANEL;
        panel = PanelManager.BuildPanel(res, GuildSalaryDescPanel);
    end
    self._otherPanel[id] = panel;
    self._otherRes[id] = res;
end

function GuildMediator:CloseOtherPanel(id)
    if self._otherPanel and self._otherPanel[id] then
        PanelManager.RecyclePanel(self._otherPanel[id], self._otherRes[id]);
        self._otherPanel[id] = nil;
        self._otherRes[id] = nil;
    end
end

function GuildMediator:CloseGuildHongBaoPanel()
    if (self._hongbaoPanel) then
        PanelManager.RecyclePanel(self._hongbaoPanel, ResID.UI_GUILDHONGBAOPANEL);
        self._hongbaoPanel = nil;
    end
end

function GuildMediator:CloseHongBaoInfoPanel()
    if (self._hongbaoInfoPanel) then
        PanelManager.RecyclePanel(self._hongbaoInfoPanel, ResID.UI_GUILDHONGBAOINFOPANEL);
        self._hongbaoInfoPanel = nil;
    end
end

function GuildMediator:CloseSendHongBaoPanel()
    if (self._sendHongbaoPanel) then
        PanelManager.RecyclePanel(self._sendHongbaoPanel, ResID.UI_GUILDSENDHONGBAOPANEL);
        self._sendHongbaoPanel = nil;
    end
end

function GuildMediator:CloseHongBaoNotifyPanel()
    if (self._hongBaoNotifyPanel) then
        PanelManager.RecyclePanel(self._hongBaoNotifyPanel, ResID.UI_GUILDHONGBAONOTIFYPANEL);
        self._hongBaoNotifyPanel = nil;
    end
end



function GuildMediator:CloseAllOtherPanel()
    if self._otherPanel then
        for k, v in pairs(self._otherPanel) do
            self:CloseOtherPanel(k);
        end
    end
end

function GuildMediator:OnRemove()
    self:CloseGuildHongBaoPanel();
    self:CloseAllOtherPanel();
    self:CloseMemberPanel();
    self:CloseGuildDetailPanel();
    self:CloseReqListPanel();
    self:CloseVertifyPanel();
    self:CloseLogPanel();
    self:CloseEnemyPanel();
    self:CloseListPanel();
    self:ClosePanel();
end

