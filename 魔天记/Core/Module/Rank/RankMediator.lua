require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.Rank.RankNotes"
require "Core.Module.Rank.View.RankPanel"


RankMediator = Mediator:New();
function RankMediator:OnRegister()

end

function RankMediator:_ListNotificationInterests()
    return {
        [1] = RankNotes.OPEN_RANKPANEL,
        [2] = RankNotes.CLOSE_RANKPANEL,
    };
end

function RankMediator:_HandleNotification(notification)
    if notification:GetName() == RankNotes.OPEN_RANKPANEL then
        if (self._panel == nil) then
            self._panel = PanelManager.BuildPanel(ResID.UI_RANKPANEL, RankPanel);     
        end
        self._panel:UpdateType(notification:GetBody());
    elseif notification:GetName() == RankNotes.CLOSE_RANKPANEL then
        self:ClosePanel();
    end
end

function RankMediator:OnRemove()
    self:ClosePanel();
end

function RankMediator:ClosePanel()
    if (self._panel ~= nil) then
        PanelManager.RecyclePanel(self._panel);
        self._panel = nil;
    end
end