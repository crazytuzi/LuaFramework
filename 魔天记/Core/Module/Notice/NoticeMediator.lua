require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.Notice.NoticeNotes"
require "Core.Module.Notice.View.NoticePanel"
require "Core.Module.Notice.View.NoticePanel2"

NoticeMediator = Mediator:New();
function NoticeMediator:OnRegister()
    --    self._panel = PanelManager.BuildPanel(ResID.UI_NOTICE_PANEL, NoticePanel, false)
end

function NoticeMediator:_ListNotificationInterests()
    return
    {
        NoticeNotes.OPEN_NOTICE_PANEL,
        NoticeNotes.CLOSE_NOTICE_PANEL,
        NoticeNotes.OPEN_NOTICE_PANEL2,
        NoticeNotes.CLOSE_NOTICE_PANEL2,
    }
end

function NoticeMediator:_HandleNotification(notification)
    local name = notification:GetName()
    if (name == NoticeNotes.OPEN_NOTICE_PANEL) then
        if (self._panel == nil) then
            self._panel = PanelManager.BuildPanel(ResID.UI_NOTICE_PANEL, NoticePanel, false, nil, false)
        end
    elseif (name == NoticeNotes.CLOSE_NOTICE_PANEL) then
        if (self._panel ~= nil) then
            PanelManager.RecyclePanel(self._panel, ResID.UI_NOTICE_PANEL)
            self._panel = nil
        end
    elseif (name == NoticeNotes.OPEN_NOTICE_PANEL2) then
        if (self._panel2 == nil) then
            self._panel2 = PanelManager.BuildPanel(ResID.UI_NOTICE_PANEL2, NoticePanel2, false, nil, false)
            self._panel2:UpdatePanel(notification:GetBody())
        end
    elseif (name == NoticeNotes.CLOSE_NOTICE_PANEL2) then
        if (self._panel2 ~= nil) then
            PanelManager.RecyclePanel(self._panel2, ResID.UI_NOTICE_PANEL2)
            self._panel2 = nil
        end
    end


end

function NoticeMediator:OnRemove()

end

