---
--- Created by  Administrator
--- DateTime: 2019/7/11 14:36
---
WeddingInvitationPanel = WeddingInvitationPanel or class("WeddingInvitationPanel", BasePanel)
local this = WeddingInvitationPanel

function WeddingInvitationPanel:ctor(parent_node, parent_panel)
    self.abName = "marry"
    self.assetName = "WeddingInvitationPanel"
    self.layer = LayerManager.LayerNameList.UI
    self.use_background = true
    self.change_scene_close = true
    self.events = {}
    self.leftItems = {}
    self.rightItems = {}
    self.model = MarryModel:GetInstance()
    self.role = RoleInfoModel.GetInstance():GetMainRoleData()
end

function WeddingInvitationPanel:dctor()
    self.model:RemoveTabListener(self.events)

    for i, v in pairs(self.leftItems) do
        v:destroy()
    end
    self.leftItems = {}

    for i, v in pairs(self.rightItems) do
        v:destroy()
    end
    self.rightItems = {}
end

function WeddingInvitationPanel:LoadCallBack()
    self.nodes = {
        "closeBtn","times","addBtn","rightObj/rightScrollView/Viewport/rightContent",
        "leftObj/leftScrollView/Viewport/leftContent",
        "leftObj/guildBtn","WeddingInvitationItem","leftObj/friendBtn",
        "title/des","leftObj/friendBtn/friendSelect","leftObj/guildBtn/guildSelect",
    }
    self:GetChildren(self.nodes)
    self.times = GetText(self.times)
   -- self:InitUI()
    self:AddEvent()

    MarryController:GetInstance():RequsetGuestList()
end

function WeddingInvitationPanel:InitUI()
   -- if self.role.guild == "0" or self.role.guild == 0  then
       -- self:ClickFriend()
   -- else
        self:ClickGuild()
   -- end

end

function WeddingInvitationPanel:AddEvent()
    
    local function call_back() --工会

        self:ClickGuild()
    end
    AddClickEvent(self.guildBtn.gameObject,call_back)
    
    local function call_back() -- 好友
        self:ClickFriend()
    end
    AddClickEvent(self.friendBtn.gameObject,call_back)
    
    
    local function call_back()
        self:Close()
    end
    AddClickEvent(self.closeBtn.gameObject,call_back)


    local function call_back()  --添加次数
        local cfg = Config.db_marriage["invite_add"]
        if not cfg then
            return
        end
        local tab = String2Table(cfg.val)
        local id = tab[1][1][1]
        local pri = tab[1][1][2]
        print2(id,pri)
        local str = string.format("Use %s bound diamond/diamond to invite 1 more guest\n (Diamonds will be consumed first)",pri)
        local function call_back()
            MarryController:GetInstance():RequsetInvitationAdd()
        end
        Dialog.ShowTwo("Tip", str, "Confirm", call_back, nil, "Cancel", nil, nil
        ,"Don't notice me again today",true,false, self.__cname)
    end
    AddButtonEvent(self.addBtn.gameObject,call_back)
    self.events[#self.events + 1] = self.model:AddListener(MarryEvent.GuestInvite,handler(self,self.GuestInvite))
    self.events[#self.events + 1] = self.model:AddListener(MarryEvent.GuestList,handler(self,self.GuestList))
    self.events[#self.events + 1] = self.model:AddListener(MarryEvent.InvitationAdd,handler(self,self.InvitationAdd))

end

function WeddingInvitationPanel:ClickGuild()
    if self.role.guild == "0" or self.role.guild == 0  then
        Notify.ShowText("Please join a guild first")
       -- return
    end
    SetVisible(self.guildSelect,true)
    SetVisible(self.friendSelect,false)
    local guildMembers = FactionModel:GetInstance():GetMember()
    self:UpdateLeftItems(guildMembers)
    --dump(guildMembers)
end

function WeddingInvitationPanel:ClickFriend()
    local friendMembers = FriendModel:GetInstance():GetFriendList()
    if table.nums(friendMembers) == 0 or not friendMembers then
        Notify.ShowText("No friend is available for the invitation")
        return
    end
    SetVisible(self.guildSelect,false)
    SetVisible(self.friendSelect,true)
    self:UpdateLeftItems(friendMembers)
end


function WeddingInvitationPanel:UpdateLeftItems(items)
    self.leftItems = self.leftItems or {}
    local index = 0
    for i, v in pairs(items) do
        local id = 0
        if v.base then
            id = v.base.id
        else
            id = v.id
        end
        if id ~= self.role.id and self.model:GetGuestState(id) == 0 and id ~= self.model.withMarry.id then
            index = index + 1
            local item =  self.leftItems[index]
            if  not item then
                item = WeddingInvitationItem(self.WeddingInvitationItem.gameObject,self.leftContent,"UI")

                self.leftItems[index] = item
            else
                item:SetVisible(true)
            end
            item:SetData(v,1)
        end
    end

    for i = index + 1,#self.leftItems do
        local buyItem = self.leftItems[i]
        if buyItem then
            buyItem:SetVisible(false)
        end

    end

    --if #self.leftItems == 0 then
    --    Notify.ShowText("没有可邀请的宾客")
    --end
end


function WeddingInvitationPanel:UpdateRightItems()

end

function WeddingInvitationPanel:GuestList(data)
    self:InitUI()
    self.maxTimes = data.max_invite
    local items = data.guests
    self.curTimes = table.nums(items)
    self.times.text = string.format("Invite: %s/%s",self.curTimes ,self.maxTimes)

    self.rightItems = self.rightItems or {}
    for i = 1, #items do
        if items[i].id ~= self.role.id and self.model:GetGuestState() == 0 then
            local item =  self.rightItems[i]
            if  not item then
                item = WeddingInvitationItem(self.WeddingInvitationItem.gameObject,self.rightContent,"UI")

                self.rightItems[i] = item
            else
                item:SetVisible(true)
            end
            item:SetData(items[i],2)
        end
    end

    for i = #items + 1,#self.rightItems do
        local buyItem = self.rightItems[i]
        buyItem:SetVisible(false)
    end


end

function WeddingInvitationPanel:GuestInvite(data)
    self.curTimes = self.curTimes + 1
    self.times.text = string.format("You can still invite: %s/%s",self.curTimes ,self.maxTimes)
    local role = data.guest
    local item = WeddingInvitationItem(self.WeddingInvitationItem.gameObject,self.rightContent,"UI")
    item:SetData(role,2)
  --  print2(role.id)
    dump(self.leftItems)
    for i, v in pairs(self.leftItems) do
        local id = 0
        if v.data.base then
            id = v.data.base.id
        else
            id = v.data.id
        end
        if id== role.id then
            v:SetVisible(false)
        end
    end
    --for i = 1, #self.leftItems do
    --    local id = 0
    --    if self.leftItems[i].data.base then
    --        id = self.leftItems[i].data.base.id
    --    else
    --        id = self.leftItems[i].data.id
    --    end
    --    if id== role.id then
    --        self.leftItems[i]:SetVisible(false)
    --    end
    --end
end

function WeddingInvitationPanel:InvitationAdd(data)
    self.maxTimes = data.max_invite
    self.times.text = string.format("You can still invite: %s/%s",self.curTimes ,self.maxTimes)
end