FriendModule = FriendModule or BaseClass(BaseModel)

FriendType = {
    All = 1,
    Local = 2,
    Cross = 3,
    Black = 4,
}

function FriendModule:__init()
    self.friendWin = nil
    self.chatTarget = nil
    self.chatTargetInfo = {}
    self.friendselect = nil
    self.friendMgr = FriendManager.Instance
    self.isAutoSend = false
    self.lastopen = 0
    self.last_friendtype = FriendType.Local
    self.last_addBlackList = nil
end

function FriendModule:__delete()
    if self.friendWin then
        self.friendWin = nil
    end
end

function FriendModule:OpenWindow(args)
    MainUIManager.Instance.noticeView:set_mailnotice_num(0)
    MainUIManager.Instance.noticeView:set_chatnotice_num(0)
    MainUIManager.Instance.noticeView:set_friendnotice_num(0)
    local currtime = Time.time
    if currtime - self.lastopen > 1800 then
        self.lastopen = currtime
        self.friendMgr:Require11801()
    end
    if self.friendWin == nil then
        self.friendWin = FriendWindow.New(self)
       -- self.friendWin:Open(args)
    else
        self.friendWin.openArgs = args
        --self.friendWin:ChangeShow()
    end
        self.friendWin:Open(args)
end

function FriendModule:CloseMain()
    self.chatTarget = nil
    self.chatTargetInfo = {}
    if self.friendWin ~= nil then
        WindowManager.Instance:CloseWindow(self.friendWin)
    end
end

function FriendModule:UpdataFriendList()
    if self.friendWin ~= nil and self.friendWin.isOpen == true then
        self.friendWin:UpdateFriendList()
    end
end

function FriendModule:DeleteFriend(uid)
    if self.friendWin ~= nil and self.friendWin.isOpen == true then
        self.friendWin:DeltePlayeritem(uid)
    end
end

function FriendModule:CheckReq()
    if self.friendWin ~= nil and self.friendWin.isOpen == true then
        -- self.friendWin:CheckoutRequest()
        self.friendWin:UpdateFriendList()
    end
end

function FriendModule:CheckRedPoint()
    if self.friendWin ~= nil and self.friendWin.isOpen == true then
        self.friendWin:CheckoutRedPoint()
    end
end

function FriendModule:GetMailItemSucc(data)
    if self.friendWin ~= nil and self.friendWin.mailPanle ~= nil then
        self.friendWin.mailPanle:AlreadyGet(data)
    end
end

function FriendModule:UpdateMailList()
    if self.friendWin ~= nil and self.friendWin.mailPanle ~= nil then
        self.friendWin.mailPanle:UpdateMailList()
    end
end

function FriendModule:OpenPushWindow()
    if self.friendpushWin == nil then
        self.friendpushWin = FriendPushWindow.New(self)
    end
    self.friendpushWin:Open()
end

function FriendModule:ClosePushWindow()
    if self.friendpushWin ~= nil then
        WindowManager.Instance:CloseWindow(self.friendpushWin)
    end
end

function FriendModule:OpenFriendSelect(args)
    if self.friendselect == nil then
        self.friendselect = FriendSelectWindow.New(self)
    end
    self.friendselect:Show(args)
end

function FriendModule:CloseFriendSelect()
    if self.friendselect ~= nil then
        self.friendselect:DeleteMe()
        self.friendselect = nil
    end
end

function FriendModule:ShowPushPlayer()
    if self.friendpushWin ~= nil then
        self.friendpushWin:ShowPlayer()
    end
end

function FriendModule:UpdateChatMsg(isgroup)
    if self.friendWin ~= nil and self.friendWin.chatPanel ~= nil then
        if not isgroup then
            self.friendWin.chatPanel:MsgUpdate()
        else
            self.friendWin.groupchatPanel:MsgUpdate()
        end
    end
end


function FriendModule:ClickSend()
    if self.friendWin ~= nil then
        self.friendWin.chatPanel:SendMsg()
    end
end

function FriendModule:ClickGroupSend()
    if self.friendWin ~= nil then
        self.friendWin.groupchatPanel:SendMsg()
    end
end

function FriendModule:AppendInputElement(element)
    if self.friendWin ~= nil then
        self.friendWin.chatPanel:AppendInputElement(element)
    end
end

function FriendModule:GroupAppendInputElement(element)
    if self.friendWin ~= nil then
        self.friendWin.groupchatPanel:AppendInputElement(element)
    end
end

function FriendModule:SendQuest(quest, type)
    if type == MsgEumn.ExtPanelType.Friend then
        if self.friendWin ~= nil then
            self.friendWin.chatPanel:SendQuest(quest)
        end
    else
        if self.friendWin ~= nil then
            self.friendWin.groupchatPanel:SendQuest(quest)
        end
    end
end

function FriendModule:OpenAwardPanel(args)
    if self.awardPanel == nil then
        self.awardPanel = FriendAwardOfferMedalPanel.New(self)
    end
    self.awardPanel:Show(args)
end

function FriendModule:CloseAwardPanel()
    if self.awardPanel ~= nil then
        self.awardPanel:DeleteMe()
        self.awardPanel = nil
    end
end

function FriendModule:OpenAddBlackPanel(args)
    if self.addblackpanel == nil then
        self.addblackpanel = FriendGroupInvitePanel.New(self, 2)
    end
    self.addblackpanel:Show(args)
end

function FriendModule:CloseAddBlackPanel()
    if self.addblackpanel ~= nil then
        self.addblackpanel:DeleteMe()
        self.addblackpanel = nil
    end
end