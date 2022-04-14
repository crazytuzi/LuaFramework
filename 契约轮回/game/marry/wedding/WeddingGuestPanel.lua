---
--- Created by  Administrator
--- DateTime: 2019/7/16 11:44
---
WeddingGuestPanel = WeddingGuestPanel or class("WeddingGuestPanel", BasePanel)
local this = WeddingGuestPanel

function WeddingGuestPanel:ctor(parent_node, parent_panel)
    self.abName = "marry"
    self.assetName = "WeddingGuestPanel"
    self.layer = LayerManager.LayerNameList.UI
    self.use_background = true
    self.change_scene_close = true
    self.events = {}
    self.items = {}
    self.model = MarryModel:GetInstance()
    self.role = RoleInfoModel.GetInstance():GetMainRoleData()
end

function WeddingGuestPanel:dctor()
    self.model:RemoveTabListener(self.events)
    for i, v in pairs(self.items) do
        v:destroy()
    end
    self.items = {}
end

function WeddingGuestPanel:LoadCallBack()
    self.nodes = {
        "closeBtn","WeddingGuestItem","ScrollView/Viewport/itemContent",
        "addBtn","one_btn","num",
    }
    self:GetChildren(self.nodes)
    self.num = GetText(self.num)
    self:InitUI()
    self:AddEvent()
    MarryController:GetInstance():RequsetInvitationRequestList()
end

function WeddingGuestPanel:InitUI()

end

function WeddingGuestPanel:AddEvent()

    local function call_back()
        self:Close()
    end
    AddButtonEvent(self.closeBtn.gameObject,call_back)

    local function call_back() --一键同意
        local ids  = {}
        for i, v in pairs(self.model.guestSouList) do
            table.insert(ids,v.id)
        end
        if table.nums(ids) == 0 or ids == {} then
            Notify.ShowText("No player is available for the invitation")
            return
        end
        MarryController:GetInstance():RequsetInvitationRequestAccept(ids)
        self:Close()
    end
    AddButtonEvent(self.one_btn.gameObject,call_back)

    local function call_back() --添加
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
        Dialog.ShowTwo("Tip", str, "Confirm", call_back, nil, "Cancel", nil, nil)
    end
    AddButtonEvent(self.addBtn.gameObject,call_back)
    self.events[#self.events + 1] = self.model:AddListener(MarryEvent.InvitationAdd,handler(self,self.InvitationAdd))
    self.events[#self.events + 1] = self.model:AddListener( MarryEvent.InvitationRequestList,handler(self,self.InvitationRequestList))
    self.events[#self.events + 1] = self.model:AddListener( MarryEvent.InvitationRequestRefuse,handler(self,self.InvitationRequestRefuse))
    self.events[#self.events + 1] = self.model:AddListener( MarryEvent.InvitationRequestAccept,handler(self,self.InvitationRequestAccept))
end

function WeddingGuestPanel:InvitationRequestList(data)
    local guests = self.model.guestSouList
    self.times = data.remain_invite
    self.num.text = "Invitations:"..self.times
    self:UpdateItems(guests)
end


function WeddingGuestPanel:UpdateItems(tab)
    self.items = self.items or {}
    local index = 0
    for i, v in pairs(tab) do
        index = index + 1
        local item = self.items[index]
        if not item then
            item = WeddingGuestItem(self.WeddingGuestItem.gameObject,self.itemContent,"UI")
            self.items[index] = item
        else
            item:SetVisible(true)
        end
        item:SetData(v)
    end
    --for i = 1, #tab do
    --    local buyItem =  self.items[i]
    --    if  not buyItem then
    --        buyItem = UpShelfLeftItem(self.WeddingGuestItem.gameObject,self.itemContent,"UI")
    --
    --        self.items[i] = buyItem
    --    else
    --        buyItem:SetVisible(true)
    --    end
    --    buyItem:SetData(tab[i])
    --end
    for i = table.nums(tab) + 1,#self.items do
        local buyItem = self.items[i]
        buyItem:SetVisible(false)
    end
end

function WeddingGuestPanel:InvitationRequestAccept()
   -- dump(self.model.guestSouList)
    self.times = self.times - 1
    self.num.text = "Invitations:"..self.times
    self:UpdateItems(self.model.guestSouList)
end

function WeddingGuestPanel:InvitationRequestRefuse()
   -- dump(self.model.guestSouList)
    self:UpdateItems(self.model.guestSouList)
end

function WeddingGuestPanel:InvitationAdd()
    self.times = self.times + 1
    self.num.text = "Invitations:"..self.times
end