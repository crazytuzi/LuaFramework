FriendGroupModule = FriendGroupModule or BaseClass(BaseModel)


function FriendGroupModule:__init()
    self.chatTarget = nil
    self.chatTargetInfo = {}
    self.friendselect = nil
    self.friendMgr = FriendManager.Instance
    self.groupMgr = FriendGroupManager.Instance
    self.foropeninfo = false
    self.lastInvited = {}
end

function FriendGroupModule:__delete()
end

function FriendGroupModule:OpenInfoPanel(args)
    if self.groupMgr:GetGroupData(args[1], args[2], args[3]) == nil then
        self.foropeninfo = true
        print("没数据")
        self.groupMgr:Require19000(args[1], args[2], args[3])
        return
    end
    self.foropeninfo = false
    if self.infopanel == nil then
        self.infopanel = FriendGroupInfoPanel.New(self)
    end
    self.infopanel:Show(args)
end

function FriendGroupModule:CloseInfoPanel()
    if self.infopanel ~= nil then
        self.infopanel:DeleteMe()
        self.infopanel = nil
    end
end


function FriendGroupModule:OpenInvitePanel(args)
    if self.invitepanel == nil then
        self.invitepanel = FriendGroupInvitePanel.New(self)
    end
    self.invitepanel:Show(args)
end

function FriendGroupModule:CloseInvitePanel()
    if self.invitepanel ~= nil then
        self.invitepanel:DeleteMe()
        self.invitepanel = nil
    end
end


function FriendGroupModule:OpenCreatePanel(args)
    if self.createpanel == nil then
        self.createpanel = FriendGroupCreatePanel.New(self)
    end
    self.createpanel:Show(args)
end

function FriendGroupModule:CloseCreatePanel()
    if self.createpanel ~= nil then
        self.createpanel:DeleteMe()
        self.createpanel = nil
    end
end
