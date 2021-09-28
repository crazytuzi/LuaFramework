require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.DaysRank.DaysRankNotes"
require "Core.Module.DaysRank.View.DaysRankPanel"
require "Core.Module.DaysRank.View.DaysRankListPanel"



DaysRankMediator = Mediator:New();
function DaysRankMediator:OnRegister()

end

function DaysRankMediator:_ListNotificationInterests()
	return {
        [1] = DaysRankNotes.OPEN_DAYSRANK_PANEL,
        [2] = DaysRankNotes.CLOSE_DAYSRANK_PANEL,
        [3] = DaysRankNotes.OPEN_DAYSRANK_LIST_PANEL,
        [4] = DaysRankNotes.CLOSE_DAYSRANK_LIST_PANEL,
    }
end

function DaysRankMediator:_HandleNotification(notification)
	if notification:GetName() == DaysRankNotes.OPEN_DAYSRANK_PANEL then
        if (self._panel == nil) then
            self._panel = PanelManager.BuildPanel(ResID.UI_DaysRank, DaysRankPanel);
        end
        DaysRankManager.OpenPanel();
    elseif notification:GetName() == DaysRankNotes.CLOSE_DAYSRANK_PANEL then
        if (self._panel ~= nil) then
            PanelManager.RecyclePanel(self._panel, ResID.UI_DaysRank);
            self._panel = nil;
        end
    elseif notification:GetName() == DaysRankNotes.OPEN_DAYSRANK_LIST_PANEL then
        if (self._listPanel == nil) then
            self._listPanel = PanelManager.BuildPanel(ResID.UI_DaysRankList, DaysRankListPanel);
        end
        self._listPanel:UpdateType(notification:GetBody());
    elseif notification:GetName() == DaysRankNotes.CLOSE_DAYSRANK_LIST_PANEL then
        if (self._listPanel ~= nil) then
            PanelManager.RecyclePanel(self._listPanel, ResID.UI_DaysRankList);
            self._listPanel = nil;
        end
    end
end

function DaysRankMediator:OnRemove()
	if (self._panel ~= nil) then
        PanelManager.RecyclePanel(self._panel, ResID.UI_DaysRank);
        self._panel = nil;
    end

    if (self._listPanel ~= nil) then
        PanelManager.RecyclePanel(self._listPanel, ResID.UI_DaysRankList);
        self._listPanel = nil;
    end
end

