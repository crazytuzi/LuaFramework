require "Core.Module.Pattern.Mediator";
require "Core.Module.Common.ResID";
require "Core.Module.Friend.FriendNotes";
require "Core.Module.Friend.View.FriendPanel"
require "Core.Module.Friend.View.YaoQingZuDingListPanel"
require "Core.Module.Friend.View.YaoQingPiPeiPanel"
require "Core.Module.Mail.MailNotes";
require "Core.Module.Common.ChatFacePanel"

local WaitForAddFriendPanel = require "Core.Module.Friend.View.WaitForAddFriendPanel";

FriendMediator = Mediator:New();
function FriendMediator:OnRegister()

end

function FriendMediator:_ListNotificationInterests()
    return {
        [1] = FriendNotes.OPEN_FRIENDPANEL,
        [2] = FriendNotes.CLOSE_FRIENDPANEL,

        [3] = FriendNotes.FRIEND_OPEN_CHAT_FACE_PANEL,
        [4] = ChatFacePanel.CLOSE_CHAT_FACE_PANEL2,
        [5] = ChatFacePanel.FACE_SELECTED,

        [6] = FriendNotes.OPEN_YAOQINGZUDINGLISTPANEL,
        [7] = FriendNotes.CLOSE_YAOQINGZUDINGLISTPANEL,

        [8] = FriendNotes.OPEN_YAOQINGPIPEIPANEL,
        [9] = FriendNotes.CLOSE_YAOQINGPIPEIPANEL,
        [10] = FriendNotes.OPEN_TEAMPANEL,

        [11] = FriendNotes.OPEN_WAITFORADDFRIENDPANEL,
        [12] = FriendNotes.CLOSE_WAITFORADDFRIENDPANEL,

    };
end

function FriendMediator:_HandleNotification(notification)
    local nType = notification:GetName()
    if nType == FriendNotes.OPEN_FRIENDPANEL then
        if (self._panel == nil) then
            self._panel = PanelManager.BuildPanel(ResID.UI_FRIENDPANEL, FriendPanel,true);
        end
        local param = notification:GetBody();
        if (param == nil) then param = FriendNotes.PANEL_FRIEND end
        self._panel:SetOpenParam(param);
    elseif nType == FriendNotes.CLOSE_FRIENDPANEL then
        if (self._panel ~= nil) then
            PanelManager.RecyclePanel(self._panel,ResID.UI_FRIENDPANEL)
            self._panel = nil;
        end

    elseif nType == FriendNotes.FRIEND_OPEN_CHAT_FACE_PANEL then
        if (self._chatFacePanel2 == nil) then self._chatFacePanel2 = PanelManager.BuildPanel(ResID.UI_CHAT_FACE_PANEL2, ChatFacePanel)end
        self._chatFacePanel2:Show(2) 
    elseif nType == ChatFacePanel.CLOSE_CHAT_FACE_PANEL2 then
        if (self._chatFacePanel2 ~= nil) then
            --self._chatFacePanel2:Hide()
            PanelManager.RecyclePanel(self._chatFacePanel2, ResID.UI_CHAT_FACE_PANEL2)
            self._chatFacePanel2 = nil
        end
    elseif nType == ChatFacePanel.FACE_SELECTED then
        local p = self._panel and self._panel:GetPanel(FriendNotes.PANEL_FRIEND) or nil
        if p and p.friendRightPanelControll and
            p.friendRightPanelControll.bottomBarCtr then
            p.friendRightPanelControll.bottomBarCtr:AddFace(notification:GetBody())
        end

-----------------------------------------------------------------------------------------
   elseif nType == FriendNotes.OPEN_YAOQINGZUDINGLISTPANEL then
        if (self._yaoQingZuDingListPanel == nil) then
            self._yaoQingZuDingListPanel = PanelManager.BuildPanel(ResID.UI_YAOQINGZUDINGLISTPANEL, YaoQingZuDingListPanel);
        end
        local param = notification:GetBody();
       
       self._yaoQingZuDingListPanel:SetData(param)

    elseif nType == FriendNotes.CLOSE_YAOQINGZUDINGLISTPANEL then
        if (self._yaoQingZuDingListPanel ~= nil) then
            PanelManager.RecyclePanel(self._yaoQingZuDingListPanel,ResID.UI_YAOQINGZUDINGLISTPANEL)
            self._yaoQingZuDingListPanel = nil;
        end

 ------------------------------------------------------------------------------
  elseif nType == FriendNotes.OPEN_YAOQINGPIPEIPANEL then
        if (self._yaoQingPiPeiPanel == nil) then
            self._yaoQingPiPeiPanel = PanelManager.BuildPanel(ResID.UI_YAOQINGPIPEIPANEL, YaoQingPiPeiPanel);
        end
      local param = notification:GetBody();
      self._yaoQingPiPeiPanel:SetDafultData(param);

    elseif nType == FriendNotes.CLOSE_YAOQINGPIPEIPANEL then
        if (self._yaoQingPiPeiPanel ~= nil) then
            PanelManager.RecyclePanel(self._yaoQingPiPeiPanel,ResID.UI_YAOQINGPIPEIPANEL)
            self._yaoQingPiPeiPanel = nil;
        end

------------------------------------------------------------------------------
    elseif nType == FriendNotes.OPEN_TEAMPANEL then
        if (self._panel == nil) then
            self._panel = PanelManager.BuildPanel(ResID.UI_FRIENDPANEL, FriendPanel,true);
        end
        local param = notification:GetBody();
        self._panel:SetOpenParam(FriendNotes.PANEL_PARTY);
        self._panel:SetInstanceId(param)        

-------------------------------------------------------------------------------------
 elseif nType == FriendNotes.OPEN_WAITFORADDFRIENDPANEL then
        if (self._waitForAddFriendPanel == nil) then
            self._waitForAddFriendPanel = PanelManager.BuildPanel(ResID.UI_WAITFORADDFRIENDPANEL, WaitForAddFriendPanel);
        end
        local param = notification:GetBody();
        self._waitForAddFriendPanel:SetOpenParam(param);

    elseif nType == FriendNotes.CLOSE_WAITFORADDFRIENDPANEL then
        if (self._waitForAddFriendPanel ~= nil) then
            PanelManager.RecyclePanel(self._waitForAddFriendPanel,ResID.UI_WAITFORADDFRIENDPANEL)
            self._waitForAddFriendPanel = nil;
        end



    end
end

function FriendMediator:OnRemove()
    
end

