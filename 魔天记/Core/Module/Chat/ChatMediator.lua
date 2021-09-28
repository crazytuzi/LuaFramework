require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.Chat.ChatNotes"
require "Core.Module.Common.ChatFacePanel"
require "Core.Module.Common.ChatItem"
require "Core.Module.Common.ChatSetPanel"
require "Core.Module.Common.ChatVoicePanel"
require "Core.Module.Chat.View.ChatPanel"

ChatMediator = Mediator:New();
function ChatMediator:OnRegister()

end

function ChatMediator:_ListNotificationInterests()
    return {
        [1] = ChatNotes.OPEN_CHAT_PANEL,
        [2] = ChatNotes.CLOSE_CHAT_PANEL,
        [3] = ChatNotes.OPEN_CHAT_SET_PANEL,
        [4] = ChatNotes.CLOSE_CHAT_SET_PANEL,
        [5] = ChatNotes.OPEN_CHAT_FACE_PANEL,
        [6] = ChatFacePanel.CLOSE_CHAT_FACE_PANEL,
        [7] = ChatNotes.OPEN_CHAT_VOICE_PANEL,
        [8] = ChatNotes.CLOSE_CHAT_VOICE_PANEL,

        [9] = ChatNotes.VOICE_CHANGE_VALUE,
        [10] = ChatNotes.VOICE_STATE_CHANGE,
        [11] = ChatFacePanel.FACE_SELECTED,
    };
end

function ChatMediator:_HandleNotification(notification)
    local nType = notification:GetName()
    if nType == ChatNotes.OPEN_CHAT_PANEL then
        if (self._chatMainPanel == nil) then self._chatMainPanel = PanelManager.BuildPanel(ResID.UI_CHAT_PANEL, ChatPanel) end
        self._chatMainPanel:Show(notification:GetBody());
    elseif nType == ChatNotes.CLOSE_CHAT_PANEL then
        if (self._chatMainPanel ~= nil) then
            PanelManager.RecyclePanel(self._chatMainPanel,ResID.UI_CHAT_PANEL)
            self._chatMainPanel = nil
            --self._chatMainPanel:Hide()
        end
    elseif nType == ChatFacePanel.FACE_SELECTED then
        if (self._chatMainPanel ~= nil and self._chatMainPanel.visible) then self._chatMainPanel:AddFace(notification:GetBody()) end

    elseif nType == ChatNotes.OPEN_CHAT_SET_PANEL then
        if (self._chatSetPanel == nil) then self._chatSetPanel = PanelManager.BuildPanel(ResID.UI_CHAT_SET_PANEL, ChatSetPanel) end
    elseif nType == ChatNotes.CLOSE_CHAT_SET_PANEL then
        if (self._chatSetPanel ~= nil) then
            PanelManager.RecyclePanel(self._chatSetPanel,ResID.UI_CHAT_SET_PANEL)
            self._chatSetPanel = nil
        end

    elseif nType == ChatNotes.OPEN_CHAT_FACE_PANEL then
        if (self._chatFacePanel == nil) then self._chatFacePanel = PanelManager.BuildPanel(ResID.UI_CHAT_FACE_PANEL, ChatFacePanel)end
        self._chatFacePanel:Show(1)
        if (self._chatMainPanel ~= nil) then self._chatMainPanel:ShowUpDow(true) end
    elseif nType == ChatFacePanel.CLOSE_CHAT_FACE_PANEL then
        if (self._chatFacePanel ~= nil) then
            PanelManager.RecyclePanel(self._chatFacePanel,ResID.UI_CHAT_FACE_PANEL)
            self._chatFacePanel = nil
            --self._chatFacePanel:Hide()
        if (self._chatMainPanel ~= nil) then self._chatMainPanel:ShowUpDow(false) end
        end

    elseif nType == ChatNotes.OPEN_CHAT_VOICE_PANEL then
        if (self._chatVoicePanel == nil) then
            self._chatVoicePanel = PanelManager.BuildPanel(ResID.UI_CHAT_VOICE_PANEL, ChatVoicePanel);
        end
        self._chatVoicePanel:ChangeValue(ChatVoiceState.voice)
    elseif nType == ChatNotes.CLOSE_CHAT_VOICE_PANEL then
        if (self._chatVoicePanel ~= nil) then
            PanelManager.RecyclePanel(self._chatVoicePanel,ResID.UI_CHAT_VOICE_PANEL)
            self._chatVoicePanel = nil
        end
    elseif nType == ChatNotes.VOICE_CHANGE_VALUE then       
        if (self._chatVoicePanel ~= nil) then self._chatVoicePanel:ChangeValue(notification:GetBody()) end
    elseif nType == ChatNotes.VOICE_STATE_CHANGE then       
        if (self._chatVoicePanel ~= nil) then self._chatVoicePanel:ChangeState(notification:GetBody()) end
    end
end

function ChatMediator:OnRemove()

end

